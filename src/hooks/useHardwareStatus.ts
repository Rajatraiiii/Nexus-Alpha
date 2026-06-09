// ============================================================
//  useHardwareStatus — OPEN SOCKET HOOK
//  Reactive bridge between HardwareStatusService and React UI.
//  Components consume this hook; they never access the service
//  directly, keeping the service framework-agnostic.
//
//  Usage:
//    const { battery, network, usb } = useHardwareStatus();
// ============================================================

import { useEffect, useState, useCallback } from 'react';
import { HardwareStatusService } from '../services/hardwareStatusService';
import type { HardwareStatus } from '../types';

export function useHardwareStatus(): HardwareStatus {
  const [status, setStatus] = useState<HardwareStatus>(
    HardwareStatusService.getSnapshot()
  );

  useEffect(() => {
    // Subscribe returns an unsubscribe function — perfect for cleanup
    const unsubscribe = HardwareStatusService.subscribe(setStatus);
    return unsubscribe;
  }, []);

  return status;
}

// ── Granular hooks for components that only care about one subsystem ───────

export function useBatteryStatus() {
  return useHardwareStatus().battery;
}

export function useNetworkStatus() {
  return useHardwareStatus().network;
}

export function useUsbStatus() {
  return useHardwareStatus().usb;
}
