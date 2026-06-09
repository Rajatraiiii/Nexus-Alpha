// ============================================================
//  App.tsx — ENTRY POINT & PLUGIN WIRING
//  This is the ONLY file your team needs to touch to plug in
//  your sync engine, hardware monitor, and GPS service.
//  The UI components never need to change.
// ============================================================

import React, { useEffect } from 'react';
import { MeterDashboard } from './components/MeterDashboard';
import { DataSubmissionService } from './services/dataSubmissionService';
import { HardwareStatusService } from './services/hardwareStatusService';
import type { MeterReadingPayload } from './types';

// ── ① SYNC ENGINE PLUGIN ──────────────────────────────────────────────────
//
//  Replace this stub with your real sync service import.
//  Your service just needs to implement:
//    (payload: MeterReadingPayload) => void | Promise<void>
//
//  Example wiring to your local SQLite + Celery queue:
//
//    import { SyncEngine } from './services/syncEngine';
//    DataSubmissionService.registerHandler(SyncEngine.enqueue);
//
import { saveReadingToBackend } from './services/apiService';

async function syncEngineHandler(payload: MeterReadingPayload): Promise<void> {

  console.log("SYNC ENGINE RECEIVED:");
  console.log(payload);

  await saveReadingToBackend(payload);

  console.log("DATA SENT TO FASTAPI");
}

// ── ② HARDWARE MONITOR PLUGIN ─────────────────────────────────────────────
//
//  Your native module / BroadcastReceiver calls HardwareStatusService.pushUpdate()
//  on every telemetry event. Example (React Native):
//
//    import { NativeEventEmitter, NativeModules } from 'react-native';
//    const emitter = new NativeEventEmitter(NativeModules.HardwareMonitor);
//    emitter.addListener('batteryUpdate', ({ percentage, isCharging }) => {
//      HardwareStatusService.pushUpdate({ battery: { percentage, isCharging, isLow: percentage < 20 } });
//    });
//    emitter.addListener('networkUpdate', ({ type, isOnline }) => {
//      HardwareStatusService.pushUpdate({ network: { type, isOnline, signalStrength: null } });
//    });
//    emitter.addListener('usbUpdate', ({ status, deviceName }) => {
//      HardwareStatusService.pushUpdate({ usb: { status, deviceName } });
//    });
//
//  For now, we simulate with mock data after a short delay:
function attachHardwareMonitor(): () => void {
  const mockTimer = setTimeout(() => {
    HardwareStatusService.pushUpdate({
      battery:  { percentage: 78, isCharging: false, isLow: false },
      network:  { type: 'WIFI', signalStrength: 3, isOnline: true },
      usb:      { status: 'DISCONNECTED', deviceName: null },
    });
  }, 1500);

  return () => clearTimeout(mockTimer);
}

// ── ③ AUTH LAYER ──────────────────────────────────────────────────────────
//
//  Replace with your auth context / secure storage read.
const MOCK_AGENT_ID = 'AGENT-0042';

// ── Root App Component ────────────────────────────────────────────────────

export function App() {
  useEffect(() => {
    // Register sync engine handler — runs once on mount
    DataSubmissionService.registerHandler(syncEngineHandler);

    // Attach hardware monitor — returns cleanup
    const detachHardwareMonitor = attachHardwareMonitor();

    return () => {
      detachHardwareMonitor();
      // Note: DataSubmissionService handler persists intentionally
      // to avoid dropping payloads during React re-renders
    };
  }, []);

  return (
    <MeterDashboard agentId={MOCK_AGENT_ID} />
  );
}

export default App;
