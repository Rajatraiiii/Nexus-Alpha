// ============================================================
//  useMLMeterForm — ML-DRIVEN FORM STATE MANAGEMENT
//  
//  Manages the three-stage workflow:
//  1. SCANNING — Live camera viewfinder, waiting for frame capture
//  2. REVIEWING — ML result arrived, user verifies/corrects
//  3. VERIFIED — User confirmed the reading, ready to submit
//
//  ════════════════════════════════════════════════════
//  OPEN SOCKET #1: ML INFERENCE INTEGRATION
//  When camera captures a frame, this hook fires the ML model
//  and populates the form with predicted reading + confidence.
//  ════════════════════════════════════════════════════
// ============================================================

import { useState, useCallback, useReducer } from 'react';
import type {
  MeterFormState,
  MeterReadingPayload,
  FlagStatus,
  ReadingType,
  FormErrors,
  MLInferenceResult,
} from '../types';
import { DataSubmissionService } from '../services/dataSubmissionService';
import { MLInferenceService } from '../services/mlInferenceService';

// ── Initial state ──────────────────────────────────────────────────────────

const INITIAL_FORM: MeterFormState = {
  stage: 'scanning',
  mlResult: null,

  meterSerial: '',
  currentReading: '',
  readingType: 'MONTHLY',
  flagStatus: 'NORMAL',
  notes: '',
  gpsLatitude: '',
  gpsLongitude: '',

  capturedImagePath: null,
  capturedImagePaths: [],
  processingMl: false,
  mlError: null,
};

// ── Submission state machine ───────────────────────────────────────────────

type SubmitStatus = 'idle' | 'submitting' | 'success' | 'error';

interface SubmitState {
  status: SubmitStatus;
  error: string | null;
}

type SubmitAction =
  | { type: 'START' }
  | { type: 'SUCCESS' }
  | { type: 'ERROR'; message: string }
  | { type: 'RESET' };

function submitReducer(state: SubmitState, action: SubmitAction): SubmitState {
  switch (action.type) {
    case 'START':   return { status: 'submitting', error: null };
    case 'SUCCESS': return { status: 'success', error: null };
    case 'ERROR':   return { status: 'error', error: action.message };
    case 'RESET':   return { status: 'idle', error: null };
    default:        return state;
  }
}

// ── Validation ─────────────────────────────────────────────────────────────

function validate(form: MeterFormState): FormErrors {
  const errors: FormErrors = {};

  if (!form.meterSerial.trim()) {
    errors.meterSerial = 'Meter serial is required';
  }

  const reading = parseFloat(form.currentReading);
  if (!form.currentReading.trim() || isNaN(reading)) {
    errors.currentReading = 'Reading must be numeric';
  }

  const lat = parseFloat(form.gpsLatitude);
  const lon = parseFloat(form.gpsLongitude);
  if (
    form.gpsLatitude && form.gpsLongitude &&
    (isNaN(lat) || isNaN(lon) || lat < -90 || lat > 90 || lon < -180 || lon > 180)
  ) {
    errors.gps = 'Invalid GPS coordinates';
  }

  return errors;
}

// ── UUID utility (no library dep) ─────────────────────────────────────────

function uuid(): string {
  if (typeof crypto !== 'undefined' && crypto.randomUUID) {
    return crypto.randomUUID();
  }
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
    const r = (Math.random() * 16) | 0;
    return (c === 'x' ? r : (r & 0x3) | 0x8).toString(16);
  });
}

// ── Hook ───────────────────────────────────────────────────────────────────

export function useMLMeterForm(agentId: string | null = null) {
  const [form, setForm] = useState<MeterFormState>(INITIAL_FORM);
  const [errors, setErrors] = useState<FormErrors>({});
  const [submitState, dispatchSubmit] = useReducer(submitReducer, {
    status: 'idle',
    error: null,
  });

  // ── Field setters ──────────────────────────────────────────────────────

  const setField = useCallback(
    <K extends keyof MeterFormState>(field: K, value: MeterFormState[K]) => {
      setForm((prev) => ({ ...prev, [field]: value }));
      // Clear field error on change
      setErrors((prev) => ({ ...prev, [field]: undefined }));
    },
    []
  );

  // ── GPS convenience setter (called by your GPS plugin) ───────────────

  const injectGps = useCallback(
    (latitude: number, longitude: number, _accuracy?: number) => {
      setForm((prev) => ({
        ...prev,
        gpsLatitude: String(latitude),
        gpsLongitude: String(longitude),
      }));
    },
    []
  );

  // ── ════════════════════════════════════════════════════
  //  OPEN SOCKET #1: ML FRAME CAPTURE HANDLER
  //  Camera component calls this when user captures a frame.
  //  This triggers ML inference and transitions to 'reviewing'.
  // ════════════════════════════════════════════════════

  const handleFrameCaptured = useCallback(async (imagePath: string) => {
    // Store the frame path and start ML processing
    setForm((prev) => ({
      ...prev,
      capturedImagePath: imagePath,
      processingMl: true,
      mlError: null,
    }));

    try {
      // Call the ML inference service
      const mlResult = await MLInferenceService.predictReading(imagePath);

      // Populate form with ML result
      setForm((prev) => ({
        ...prev,
        stage: 'reviewing',        // Transition to review stage
        mlResult,
        currentReading: mlResult.readingValue,
        processingMl: false,
        // Optionally pre-fill serial if ML extracted one
        meterSerial: mlResult.meterSerialHint || prev.meterSerial,
      }));
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : 'ML inference failed';
      setForm((prev) => ({
        ...prev,
        processingMl: false,
        mlError: errorMsg,
      }));
      console.error('[useMLMeterForm] ML inference error:', errorMsg);
    }
  }, []);

  // ── Review & Verification Flow ─────────────────────────────────────

  /**
   * User reviewed the ML result and is satisfied.
   * Transition to 'verified' stage, ready for submission.
   */
  const handleReviewConfirmed = useCallback(() => {
    const validationErrors = validate(form);
    if (Object.keys(validationErrors).length > 0) {
      setErrors(validationErrors);
      return;
    }
    setForm((prev) => ({ ...prev, stage: 'verified' }));
  }, [form]);

  /**
   * User wants to re-scan (go back to camera).
   */
  const handleReScan = useCallback(() => {
    setForm((prev) => ({
      ...INITIAL_FORM,
      gpsLatitude: prev.gpsLatitude,  // Preserve GPS
      gpsLongitude: prev.gpsLongitude,
    }));
    setErrors({});
  }, []);

  // ── Payload factory ────────────────────────────────────────────────────

  /**
   * ════════════════════════════════════════════════════
   *  OPEN SOCKET #2: PAYLOAD FACTORY
   *  Constructs the exact shape expected by the sync engine.
   *  synced: 0 is ALWAYS set here (UI contract).
   * ════════════════════════════════════════════════════
   */
  function buildPayload(): MeterReadingPayload {
    const lat = parseFloat(form.gpsLatitude);
    const lon = parseFloat(form.gpsLongitude);

    return {
      id: uuid(),
      capturedAt: new Date().toISOString(),
      agentId,

      meterSerial: form.meterSerial.trim(),
      currentReading: parseFloat(form.currentReading),
      readingType: form.readingType,
      flagStatus: form.flagStatus,
      notes: form.notes.trim(),

      // ML metadata (for audit trail)
      mlConfidence: form.mlResult?.confidence ?? 0,
      mlInferenceTimestamp: form.mlResult?.inferenceTimestamp ?? null,
      mlImagePath: form.mlResult?.processedImagePath ?? null,

      gps: {
        latitude: isNaN(lat) ? null : lat,
        longitude: isNaN(lon) ? null : lon,
        accuracy: null,
        capturedAt: isNaN(lat) ? null : new Date().toISOString(),
      },

      imagePaths: form.capturedImagePath ? [form.capturedImagePath] : [],

      // ── SYNC CONTROL — DO NOT CHANGE THESE DEFAULTS ──────────────
      synced: 0,
      syncAttempts: 0,
      lastSyncError: null,
    };
  }

  // ── Submit handler ─────────────────────────────────────────────────────

  /**
   * ════════════════════════════════════════════════════
   *  OPEN SOCKET #2: DATA SUBMISSION
   *  User confirmed the reading. Fire the payload to
   *  the data submission service with synced: 0.
   * ════════════════════════════════════════════════════
   */
  const handleSubmit = useCallback(async () => {
    const validationErrors = validate(form);
    if (Object.keys(validationErrors).length > 0) {
      setErrors(validationErrors);
      return;
    }

    dispatchSubmit({ type: 'START' });

    try {
      const payload = buildPayload();
      await DataSubmissionService.onDataCaptured(payload);

      dispatchSubmit({ type: 'SUCCESS' });
      // Reset form after successful submission
      setForm(INITIAL_FORM);
      setErrors({});
    } catch (err) {
      dispatchSubmit({
        type: 'ERROR',
        message: err instanceof Error ? err.message : 'Submission failed',
      });
    }
  }, [form, agentId]);

  return {
    // Form state
    form,
    errors,

    // Field setters
    setField,
    injectGps,

    // ML workflow
    handleFrameCaptured,
    handleReviewConfirmed,
    handleReScan,

    // Submission
    handleSubmit,
    submitStatus: submitState.status,
    submitError: submitState.error,
    resetSubmitState: () => dispatchSubmit({ type: 'RESET' }),
  };
}
