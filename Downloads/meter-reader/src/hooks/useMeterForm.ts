// ============================================================
//  useMeterForm — FORM STATE + PAYLOAD FACTORY
//  Owns all form field state, validation, and the final
//  payload construction. Nothing outside this hook mutates
//  form state — components only receive values and setters.
// ============================================================

import { useState, useCallback, useReducer } from 'react';
import type {
  MeterFormState,
  MeterReadingPayload,
  FlagStatus,
  ReadingType,
  FormErrors,
} from '../types';
import { DataSubmissionService } from '../services/dataSubmissionService';

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
    errors.currentReading = 'Enter a valid numeric reading';
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

export function useMeterForm(agentId: string | null = null) {
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

  const addImagePath = useCallback((path: string) => {
    setForm((prev) => ({
      ...prev,
      capturedImagePaths: [...prev.capturedImagePaths, path],
    }));
  }, []);

  const removeImagePath = useCallback((path: string) => {
    setForm((prev) => ({
      ...prev,
      capturedImagePaths: prev.capturedImagePaths.filter((p) => p !== path),
    }));
  }, []);

  // ── GPS convenience setter (called by your GPS plugin) ───────────────

  /**
   * ════════════════════════════════════════════════════
   *  OPEN SOCKET — Your GPS module calls this to inject coordinates.
   *  DataSubmissionService.registerHandler(...) → your sync service
   *  injects GPS by calling meterForm.injectGps(lat, lon, accuracy)
   * ════════════════════════════════════════════════════
   */
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

  // ── Payload factory ────────────────────────────────────────────────────

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

      mlConfidence: 0,
      mlInferenceTimestamp: null,
      mlImagePath: null,

      gps: {
        latitude: isNaN(lat) ? null : lat,
        longitude: isNaN(lon) ? null : lon,
        accuracy: null,
        capturedAt: isNaN(lat) ? null : new Date().toISOString(),
      },

      imagePaths: [...form.capturedImagePaths],

      // ── SYNC CONTROL — DO NOT CHANGE THESE DEFAULTS ──────────────
      synced: 0,
      syncAttempts: 0,
      lastSyncError: null,
    };
  }

  // ── Submit handler ─────────────────────────────────────────────────────

  const handleSubmit = useCallback(async () => {
    const validationErrors = validate(form);
    if (Object.keys(validationErrors).length > 0) {
      setErrors(validationErrors);
      return;
    }

    dispatchSubmit({ type: 'START' });

    try {
      const payload = buildPayload();

      /**
       * ════════════════════════════════════════════════════
       *  OPEN SOCKET — This is THE handoff point.
       *  The UI builds the payload and fires the event.
       *  The sync engine receives it. No API call here.
       * ════════════════════════════════════════════════════
       */
      await DataSubmissionService.onDataCaptured(payload);

      dispatchSubmit({ type: 'SUCCESS' });
      // Reset form after successful hand-off
      setForm(INITIAL_FORM);
      setErrors({});
    } catch (err) {
      dispatchSubmit({
        type: 'ERROR',
        message: err instanceof Error ? err.message : 'Submission failed',
      });
    }
  }, [form, agentId]);

  const resetSubmitState = useCallback(() => {
    dispatchSubmit({ type: 'RESET' });
  }, []);

  return {
    // Form values
    form,
    errors,
    // Setters
    setField,
    addImagePath,
    removeImagePath,
    injectGps,          // ← OPEN SOCKET: GPS plugin calls this
    // Submit
    handleSubmit,
    submitStatus: submitState.status,
    submitError: submitState.error,
    resetSubmitState,
    isSubmitting: submitState.status === 'submitting',
  };
}
