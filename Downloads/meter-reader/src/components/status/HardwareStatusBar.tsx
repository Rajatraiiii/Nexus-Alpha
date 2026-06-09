// ============================================================
//  HardwareStatusBar — UI COMPONENT
//  Reads from useHardwareStatus() — purely reactive.
//  No props needed; hardware service pushes state in.
// ============================================================

import React from 'react';
import { useHardwareStatus } from '../../hooks/useHardwareStatus';
import type { NetworkType, UsbOtgStatus } from '../../types';

// ── Icon helpers (text-based, swap for your icon library) ─────────────────

const networkIcon: Record<NetworkType, string> = {
  WIFI: '▲▲▲',
  '4G': '4G',
  '3G': '3G',
  '2G': '2G',
  OFFLINE: '✕',
  UNKNOWN: '?',
};

const usbIcon: Record<UsbOtgStatus, string> = {
  CONNECTED: '⚡',
  DISCONNECTED: '○',
  UNSUPPORTED: '—',
};

// ── Battery sub-component ─────────────────────────────────────────────────

function BatteryIndicator() {
  const { percentage, isCharging, isLow } = useHardwareStatus().battery;

  const label =
    percentage === null
      ? '—'
      : isCharging
      ? `${percentage}% ⚡`
      : `${percentage}%`;

  const color =
    isLow ? '#FF4D4D' : percentage !== null && percentage > 60 ? '#4ADE80' : '#FACC15';

  return (
    <div className="hw-indicator" aria-label={`Battery: ${label}`}>
      <span className="hw-label">BAT</span>
      <span className="hw-value" style={{ color }}>
        {label}
      </span>
    </div>
  );
}

// ── Network sub-component ─────────────────────────────────────────────────

function NetworkIndicator() {
  const { type, isOnline } = useHardwareStatus().network;
  const icon = networkIcon[type];
  const color = isOnline ? '#4ADE80' : '#FF4D4D';

  return (
    <div className="hw-indicator" aria-label={`Network: ${type}`}>
      <span className="hw-label">NET</span>
      <span className="hw-value" style={{ color }}>
        {icon}
      </span>
    </div>
  );
}

// ── USB/OTG sub-component ─────────────────────────────────────────────────

function UsbIndicator() {
  const { status, deviceName } = useHardwareStatus().usb;
  const icon = usbIcon[status];
  const color = status === 'CONNECTED' ? '#4ADE80' : '#6B7280';

  return (
    <div className="hw-indicator" aria-label={`USB: ${status}${deviceName ? ` — ${deviceName}` : ''}`}>
      <span className="hw-label">USB</span>
      <span className="hw-value" style={{ color }}>
        {icon}
      </span>
    </div>
  );
}

// ── Combined status bar ───────────────────────────────────────────────────

export function HardwareStatusBar() {
  return (
    <div className="hardware-status-bar" role="status" aria-label="Hardware status">
      <NetworkIndicator />
      <div className="hw-divider" />
      <BatteryIndicator />
      <div className="hw-divider" />
      <UsbIndicator />
    </div>
  );
}
