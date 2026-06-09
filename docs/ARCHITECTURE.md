# Meter Reader — Frontend Architecture

## Overview

This is the **UI layer only**. It has zero API calls, zero database logic, and zero hardware polling. It exposes four clearly-marked "open sockets" that your team wires up without touching any UI code.

---

## Directory Structure

```
src/
├── types/
│   └── index.ts              ← ALL shared contracts (payload shapes, hardware types)
├── services/
│   ├── hardwareStatusService.ts   ← OPEN SOCKET #1 (hardware telemetry in)
│   └── dataSubmissionService.ts   ← OPEN SOCKET #2 (data submission out)
├── hooks/
│   ├── useHardwareStatus.ts  ← React binding for hardware service
│   └── useMeterForm.ts       ← Form state + payload factory + GPS socket
├── components/
│   ├── status/
│   │   └── HardwareStatusBar.tsx  ← Battery, Network, USB display
│   ├── camera/
│   │   └── CameraCapture.tsx      ← OPEN SOCKET #3 (camera path)
│   ├── form/
│   │   └── MeterDataForm.tsx      ← All data entry fields
│   ├── submission/
│   │   └── SubmitButton.tsx       ← Triggers the submission socket
│   └── MeterDashboard.tsx         ← Root composition screen
└── App.tsx                        ← PLUGIN WIRING POINT (touch this to connect)
```

---

## Open Sockets Reference

### Socket 1 — Hardware Telemetry (push into UI)

**Service:** `HardwareStatusService`  
**Call:** `HardwareStatusService.pushUpdate(partial: Partial<HardwareStatus>)`

Your native BroadcastReceiver, NativeEventEmitter, or BLE service calls this with partial updates. The UI re-renders automatically.

```typescript
// Example: your Android battery receiver
HardwareStatusService.pushUpdate({
  battery: { percentage: 82, isCharging: true, isLow: false }
});

// Example: your network change listener
HardwareStatusService.pushUpdate({
  network: { type: '4G', isOnline: true, signalStrength: 3 }
});

// Example: USB OTG connection event
HardwareStatusService.pushUpdate({
  usb: { status: 'CONNECTED', deviceName: 'DataLoggerV2' }
});
```

---

### Socket 2 — Data Submission (receive from UI)

**Service:** `DataSubmissionService`  
**Register:** `DataSubmissionService.registerHandler(fn)` — call once at app startup

Your sync engine registers a handler. Every "Push Data to Cloud" tap delivers a `MeterReadingPayload` with `synced: 0` guaranteed.

```typescript
// In App.tsx, during bootstrap:
DataSubmissionService.registerHandler(async (payload) => {
  // payload.synced is ALWAYS 0 — UI guarantees this
  await LocalDB.insert('meter_readings', payload);
  await SyncQueue.enqueue({ type: 'METER_READING', id: payload.id });
});
```

**Payload guarantee:**
```typescript
{
  id: "uuid-v4",
  capturedAt: "2024-03-15T10:23:00.000Z",
  meterSerial: "MTR-2024-00847",
  currentReading: 1234.56,
  readingType: "MONTHLY",
  flagStatus: "NORMAL",
  gps: { latitude: 28.6139, longitude: 77.2090, accuracy: 5, capturedAt: "..." },
  imagePaths: ["/tmp/img_001.jpg", "/tmp/img_002.jpg"],
  synced: 0,          // ← Always 0 from UI
  syncAttempts: 0,    // ← Always 0 from UI
  lastSyncError: null // ← Always null from UI
}
```

---

### Socket 3 — Camera Integration

**Component:** `CameraCapture`  
**Prop:** `onImageCaptured(localPath: string)`

Replace the file `<input>` in `CameraCapture.tsx` with your native camera module. The contract is the same: call `onImageCaptured(path)` with a local file URI.

```typescript
// Capacitor example:
const photo = await Camera.getPhoto({
  resultType: CameraResultType.Uri,
  source: CameraSource.Camera,
  quality: 90,
});
onImageCaptured(photo.path!);

// React Native example:
const result = await ImagePicker.launchCameraAsync({ quality: 0.9 });
if (!result.cancelled) onImageCaptured(result.uri);
```

---

### Socket 4 — GPS Injection

**Hook:** `useMeterForm`  
**Method:** `meterForm.injectGps(latitude, longitude, accuracy?)`

Your GPS background service calls this to pre-fill the location fields.

```typescript
// In MeterDashboard or App.tsx:
const { injectGps } = useMeterForm(agentId);

// From your location service:
LocationService.onLocationUpdate(({ lat, lon, accuracy }) => {
  injectGps(lat, lon, accuracy);
});
```

---

## Data Flow Diagram

```
[Hardware Native Module]
        │  pushUpdate()
        ▼
HardwareStatusService ──subscribe()──▶ useHardwareStatus() ──▶ HardwareStatusBar [UI]

[Field Agent Taps Form]
        │
        ▼
useMeterForm()  ──────────────────────────────────────────────▶ MeterDataForm [UI]
        │  handleSubmit()
        ▼
buildPayload() → { ...formData, synced: 0 }
        │
        ▼
DataSubmissionService.onDataCaptured(payload)
        │  registered handler
        ▼
[Your Sync Engine] → LocalDB.insert() → SyncQueue.enqueue()
        │
        ▼
[Backend: FastAPI / Redis / Celery / MySQL]
```

---

## State Ownership Rules

| State | Owner | Never mutate from |
|-------|-------|-------------------|
| Form fields | `useMeterForm` | Components (read-only, use setters) |
| Image paths | `useMeterForm` | Sync engine |
| Hardware status | `HardwareStatusService` | UI components |
| `synced` flag | Sync engine | UI (always starts at 0) |
| `agentId` | Auth layer → `App.tsx` prop | UI components |

---

## Adding New Hardware Sensors

1. Add new fields to `HardwareStatus` in `src/types/index.ts`
2. Add a display sub-component in `src/components/status/`
3. Your native module calls `HardwareStatusService.pushUpdate({ yourNewSensor: ... })`

No other files need to change.
