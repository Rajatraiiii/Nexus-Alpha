// ============================================================
//  DATA SUBMISSION SERVICE  ←  OPEN SOCKET #2
//  The UI calls `DataSubmissionService.onDataCaptured(payload)`.
//  Your sync engine overrides the handler by calling:
//    DataSubmissionService.registerHandler(yourSyncFunction)
//
//  The UI NEVER makes a direct API call.
//  It only builds the payload and calls onDataCaptured().
// ============================================================

import type { IDataSubmissionService, MeterReadingPayload } from '../types';

type SubmissionHandler = (payload: MeterReadingPayload) => void | Promise<void>;

/**
 * Default no-op handler used when no sync engine is registered yet.
 * Logs a warning and stores the payload in a pending queue so nothing
 * is silently dropped before the plugin layer connects.
 */
const pendingQueue: MeterReadingPayload[] = [];

const defaultHandler: SubmissionHandler = (payload) => {
  console.warn(
    '[DataSubmissionService] No sync handler registered. ' +
    'Payload queued locally until a handler is plugged in.',
    payload
  );
  pendingQueue.push(payload);
};

class DataSubmissionServiceImpl implements IDataSubmissionService {
  private _handler: SubmissionHandler = defaultHandler;

  /**
   * ════════════════════════════════════════════════════
   *  PLUGIN POINT — Your sync engine calls this ONCE on startup.
   *  After registration, all future submissions and all queued
   *  payloads are flushed to your handler.
   * ════════════════════════════════════════════════════
   *
   *  Example (in your sync engine bootstrap):
   *    DataSubmissionService.registerHandler(async (payload) => {
   *      await localDb.insert('meter_readings', payload);
   *      syncQueue.enqueue(payload.id);
   *    });
   */
  registerHandler(handler: SubmissionHandler): void {
    this._handler = handler;

    // Flush any payloads captured before the handler was ready
    if (pendingQueue.length > 0) {
      console.info(
        `[DataSubmissionService] Flushing ${pendingQueue.length} queued payload(s) to registered handler.`
      );
      pendingQueue.splice(0).forEach((p) => this._handler(p));
    }
  }

  /**
   * ════════════════════════════════════════════════════
   *  UI CONTRACT — The Submit button calls this.
   *  Never call an API directly from the UI.
   * ════════════════════════════════════════════════════
   */
  async onDataCaptured(payload: MeterReadingPayload): Promise<void> {
    // Guard: synced must always be 0 when leaving the UI
    if ((payload.synced as unknown) !== 0) {
      throw new Error('[DataSubmissionService] Payload integrity violation: synced must be 0');
    }
    await this._handler(payload);
  }

  /** Inspect pending queue (for diagnostics only) */
  getPendingCount(): number {
    return pendingQueue.length;
  }
}

export const DataSubmissionService = new DataSubmissionServiceImpl();
