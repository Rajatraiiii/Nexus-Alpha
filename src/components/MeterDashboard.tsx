// ============================================================
//  MeterDashboard — MAIN SCREEN
//  Root composition layer. Wires hooks → components.
//  Passes agentId from your auth layer via prop.
//
//  OPEN SOCKET SUMMARY (all plugin points in one view):
//
//  1. HardwareStatusService.pushUpdate(partial)
//     → Updates Network / Battery / USB status bars reactively
//     → Wire from: BroadcastReceiver, native module, BLE service
//
//  2. DataSubmissionService.registerHandler(fn)
//     → Receives MeterReadingPayload on every "Push Data" tap
//     → Wire from: your Sync Engine bootstrap in App.tsx
//
//  3. meterForm.injectGps(lat, lon, accuracy)
//     → Pre-fills GPS fields from your GPS background service
//     → Wire from: your location module
//
//  4. CameraCapture.onImageCaptured(localPath)
//     → Receives local file path after native camera capture
//     → Wire from: Capacitor Camera / React Native ImagePicker
// ============================================================

import React from 'react';
import { HardwareStatusBar } from '../components/status/HardwareStatusBar';
import { CameraCapture } from '../components/camera/CameraCapture';
import { MeterDataForm } from '../components/form/MeterDataForm';
import { SubmitButton } from '../components/submission/SubmitButton';
import { useMeterForm } from '../hooks/useMeterForm';

interface MeterDashboardProps {
  /** Injected by your auth layer. Pass null until authenticated. */
  agentId: string | null;
}

export function MeterDashboard({ agentId }: MeterDashboardProps) {
  const {
    form,
    errors,
    setField,
    addImagePath,
    removeImagePath,
    handleSubmit,
    submitStatus,
    submitError,
    resetSubmitState,
  } = useMeterForm(agentId);

  return (
    <div className="dashboard-root">
      {/* ── Header ──────────────────────────────────────── */}
      <header className="dashboard-header">
        <div className="header-left">
          <span className="app-title">METER READER</span>
          <span className="app-subtitle">Field Capture Unit</span>
        </div>
        <HardwareStatusBar />
      </header>

      {/* ── Scrollable body ─────────────────────────────── */}
      <main className="dashboard-body">
        {/* Camera */}
        <section className="dashboard-card" aria-label="Image capture">
          <CameraCapture
            onImageCaptured={addImagePath}
            onImageRemoved={removeImagePath}
            capturedPaths={form.capturedImagePaths}
            maxImages={5}
          />
        </section>

        {/* Data form */}
        <section className="dashboard-card" aria-label="Meter data entry">
          <MeterDataForm
            form={form}
            errors={errors}
            onField={setField}
          />
        </section>
      </main>

      {/* ── Fixed submit footer ─────────────────────────── */}
      <footer className="dashboard-footer">
        <SubmitButton
          onSubmit={handleSubmit}
          status={submitStatus}
          error={submitError}
          onReset={resetSubmitState}
        />
      </footer>
    </div>
  );
}
