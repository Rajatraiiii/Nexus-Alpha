// ============================================================
//  HARDWARE STATUS SERVICE  ←  OPEN SOCKET #1
//  This is a standalone observable store. The UI reads from it.
//  Your hardware monitoring native module WRITES to it by
//  calling HardwareStatusService.pushUpdate(partial).
//
//  Usage (your native bridge / background service):
//    import { HardwareStatusService } from './services/hardwareStatusService';
//    HardwareStatusService.pushUpdate({ battery: { percentage: 82, isCharging: false, isLow: false } });
// ============================================================

import type { HardwareStatus, IHardwareStatusProvider } from '../types';

const DEFAULT_STATE: HardwareStatus = {
  battery: {
    percentage: null,
    isCharging: null,
    isLow: null,
  },
  network: {
    type: 'UNKNOWN',
    signalStrength: null,
    isOnline: false,
  },
  usb: {
    status: 'DISCONNECTED',
    deviceName: null,
  },
};

/**
 * Singleton observable store.
 * The UI layer reads from this; native services write to it.
 * Zero direct UI coupling — no React imports here.
 */
class HardwareStatusServiceImpl implements IHardwareStatusProvider {
  private _state: HardwareStatus = { ...DEFAULT_STATE };
  private _listeners = new Set<(s: HardwareStatus) => void>();

  /**
   * ════════════════════════════════════════════════════
   *  OPEN SOCKET — Your hardware bridge calls this.
   *  Accepts a deep partial — only supply what changed.
   * ════════════════════════════════════════════════════
   */
  pushUpdate(partial: Partial<HardwareStatus>): void {
    this._state = deepMerge(
      this._state as unknown as Record<string, unknown>,
      partial as unknown as Record<string, unknown>
    ) as unknown as HardwareStatus;
    this._notify();
  }

  /**
   * Subscribe to hardware state changes.
   * Returns an unsubscribe function.
   */
  subscribe(listener: (status: HardwareStatus) => void): () => void {
    this._listeners.add(listener);
    // Immediately emit current state to new subscriber
    listener(this._state);
    return () => this._listeners.delete(listener);
  }

  /** Read current snapshot synchronously */
  getSnapshot(): HardwareStatus {
    return this._state;
  }

  private _notify(): void {
    this._listeners.forEach((fn) => fn(this._state));
  }
}

/** Deep merge utility (no lodash dependency) */
function deepMerge(target: Record<string, unknown>, source: Record<string, unknown>): Record<string, unknown> {
  const out = { ...target };
  for (const key of Object.keys(source)) {
    const sv = source[key];
    const tv = target[key];
    if (sv && typeof sv === 'object' && !Array.isArray(sv) && tv && typeof tv === 'object') {
      out[key] = deepMerge(tv as Record<string, unknown>, sv as Record<string, unknown>);
    } else {
      out[key] = sv;
    }
  }
  return out;
}

export const HardwareStatusService = new HardwareStatusServiceImpl();
