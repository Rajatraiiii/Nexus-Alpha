// ============================================================
//  METER READER — TYPE CONTRACTS (ML-DRIVEN ARCHITECTURE)
//  All data shapes crossing the UI ↔ Plugin boundary live here.
//  The backend team imports from this file; never duplicate.
// ============================================================

/** Flag tags the field agent can assign to a reading */
export type FlagStatus =
  | 'NORMAL'
  | 'TAMPERED'
  | 'LEAK'
  | 'BROKEN_SEAL'
  | 'INACCESSIBLE'
  | 'DAMAGED';

/** Reading category */
export type ReadingType = 'MONTHLY' | 'SPOT_CHECK' | 'RECONNECTION' | 'FINAL' | 'AUDIT';

/** ════════════════════════════════════════════════════
 *  OPEN SOCKET #0: ML INFERENCE MODEL OUTPUT
 *  Your ML team returns this shape after processing a frame.
 *  ════════════════════════════════════════════════════ */
export interface MLInferenceResult {
  /** The predicted meter reading (e.g. "1234.56") */
  readingValue: string;
  /** Confidence score 0–1 (e.g. 0.987) */
  confidence: number;
  /** Raw frame/image that was processed */
  processedImagePath: string;
  /** Optional extracted meter serial from ML */
  meterSerialHint?: string;
  /** Timestamp when ML processed the frame */
  inferenceTimestamp: string;
}

/**
 * The canonical payload emitted by the UI on submission.
 * `synced: 0` is ALWAYS set by the UI layer.
 * The sync engine owns toggling this to 1.
 * 
 * ════════════════════════════════════════════════════
 *  OPEN SOCKET #2: DATA SUBMISSION
 *  When user confirms, this exact shape fires to your
 *  data submission service with synced: 0 literal.
 *  Your sync engine owns incrementing syncAttempts
 *  and writing to lastSyncError.
 * ════════════════════════════════════════════════════
 */
export interface MeterReadingPayload {
  // ── Identity ──────────────────────────────────────────────
  id: string;                  // UUID generated client-side
  capturedAt: string;          // ISO-8601 timestamp (device local)
  agentId: string | null;      // Populated by auth layer (pluggable)

  // ── Meter Data (populated by ML model, user may verify) ───
  meterSerial: string;         // Verified/corrected by user post-ML
  currentReading: number;      // ML-derived, user may override
  readingType: ReadingType;
  flagStatus: FlagStatus;
  notes: string;

  // ── ML Metadata (for audit trail) ─────────────────────────
  mlConfidence: number;        // 0–1, from ML model
  mlInferenceTimestamp: string | null;  // When ML processed
  mlImagePath: string | null;  // Reference to original ML input

  // ── Location ──────────────────────────────────────────────
  gps: {
    latitude: number | null;
    longitude: number | null;
    accuracy: number | null;    // metres
    capturedAt: string | null;  // ISO-8601
  };

  // ── Media ─────────────────────────────────────────────────
  imagePaths: string[];         // Legacy; mostly empty in ML flow

  // ── Sync Control (DO NOT MUTATE IN UI) ───────────────────
  synced: 0;                    // Literal 0 — UI always initialises this
  syncAttempts: 0;              // Literal 0 — sync engine increments
  lastSyncError: null;          // Literal null — sync engine writes errors
}

// ── Form State (UI-internal) ───────────────────────────────────────────────

/**
 * ════════════════════════════════════════════════════
 *  OPEN SOCKET #1: ML-DRIVEN FORM STATE
 *  Tracks the reading progression:
 *  scanning → reviewing (with ML result) → verified
 * ════════════════════════════════════════════════════
 */
export interface MeterFormState {
  // ── Workflow Stage ────────────────────────────────────────
  stage: 'scanning' | 'reviewing' | 'verified';  // UI shows different panel per stage

  // ── ML Inference Result (populated by ML socket) ─────────
  mlResult: MLInferenceResult | null;

  // ── User Fields (editable or verified) ────────────────────
  meterSerial: string;         // User can override ML hint
  currentReading: string;      // Derived from ML, user may edit
  readingType: ReadingType;
  flagStatus: FlagStatus;
  notes: string;

  // ── Location ──────────────────────────────────────────────
  gpsLatitude: string;
  gpsLongitude: string;

  // ── Camera State ──────────────────────────────────────────
  capturedImagePath: string | null;  // Latest frame sent to ML
  capturedImagePaths: string[];     // Multiple captured images for non-ML flow
  processingMl: boolean;        // True while ML is inferring
  mlError: string | null;       // Error message if ML fails
}

export interface FormErrors {
  meterSerial?: string;
  currentReading?: string;
  gps?: string;
}

// ── Hardware Status ────────────────────────────────────────────────────────

export type NetworkType = 'WIFI' | '4G' | '3G' | '2G' | 'OFFLINE' | 'UNKNOWN';
export type UsbOtgStatus = 'CONNECTED' | 'DISCONNECTED' | 'UNSUPPORTED';

/**
 * Hardware telemetry shape. All fields nullable so UI can render
 * gracefully before the hardware service connects.
 */
export interface HardwareStatus {
  battery: {
    percentage: number | null;   // 0–100
    isCharging: boolean | null;
    isLow: boolean | null;       // e.g. < 20%
  };
  network: {
    type: NetworkType;
    signalStrength: number | null; // 0–4 bars
    isOnline: boolean;
  };
  usb: {
    status: UsbOtgStatus;
    deviceName: string | null;
  };
}

// ── QR Code Scanner ───────────────────────────────────────────────────────

export interface QRScanData {
  meterId: string;
  latitude: number;
  longitude: number;
}

// ── Location/GPS ───────────────────────────────────────────────────────────

export interface GeoLocationData {
  latitude: number;
  longitude: number;
  accuracy: number | null;
  timestamp: string;
}

// ── Image Upload ───────────────────────────────────────────────────────────

export interface ImageUploadData {
  imagePath: string;
  fileName: string;
  fileSize: number;
}

// ── Plugin Interface Contracts ─────────────────────────────────────────────

/**
 * ════════════════════════════════════════════════════
 *  OPEN SOCKET #0: ML INFERENCE SERVICE
 *  Your ML team implements this. Returns prediction
 *  or throws error.
 * ════════════════════════════════════════════════════
 */
export interface IMLInferenceService {
  /**
   * Process a frame and return predicted reading + confidence.
   * @param imagePath Local path to frame captured from camera
   * @returns ML prediction result or throws MLInferenceError
   */
  predictReading(imagePath: string): Promise<MLInferenceResult>;
}

/**
 * The shape the UI calls into for data submission.
 * Backend team implements this interface in their sync service.
 */
export interface IDataSubmissionService {
  onDataCaptured(payload: MeterReadingPayload): void | Promise<void>;
}

/**
 * The shape the hardware monitoring service must conform to
 * in order to push telemetry updates into the UI.
 */
export interface IHardwareStatusProvider {
  /** Call this from your BroadcastReceiver / native module to push updates */
  pushUpdate(partial: Partial<HardwareStatus>): void;
  /** Subscribe to the current state stream */
  subscribe(listener: (status: HardwareStatus) => void): () => void;
}

