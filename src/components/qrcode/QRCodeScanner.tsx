// ============================================================
//  QRCodeScanner — QR Code Scanning UI Component
//  Displays camera feed and scans for QR codes
//  Format: METER-101,24.1912,82.5511
// ============================================================

import React, { useEffect, useState } from 'react';
import { useQRScanner, type QRScanResult } from '../../hooks/useQRScanner';
import './QRCodeScanner.css';

interface QRCodeScannerProps {
  onScanSuccess: (result: QRScanResult) => void;
  onCancel: () => void;
}

export function QRCodeScanner({ onScanSuccess, onCancel }: QRCodeScannerProps) {
  const { isScanning, error, videoRef, canvasRef, startScanning, stopScanning, scanFrame } =
    useQRScanner();
  const [successMessage, setSuccessMessage] = useState<string | null>(null);
  const scanIntervalRef = React.useRef<number | null>(null);

  useEffect(() => {
    return () => {
      if (scanIntervalRef.current) {
        clearInterval(scanIntervalRef.current);
      }
      stopScanning();
    };
  }, [stopScanning]);

  const handleStartScan = async () => {
    await startScanning();
  };

  const handleScanSuccess = (result: QRScanResult) => {
    setSuccessMessage(
      `✓ Scanned: ${result.meterId}\nLat: ${result.latitude}, Lon: ${result.longitude}`
    );
    setTimeout(() => {
      onScanSuccess(result);
    }, 1500);
  };

  useEffect(() => {
    if (!isScanning) return;

    // Scan every 300ms while camera is active
    scanIntervalRef.current = window.setInterval(() => {
      scanFrame(handleScanSuccess);
    }, 300);

    return () => {
      if (scanIntervalRef.current) {
        clearInterval(scanIntervalRef.current);
      }
    };
  }, [isScanning, scanFrame]);

  return (
    <div className="qr-scanner-modal">
      <div className="qr-scanner-container">
        <h2>Scan Meter QR Code</h2>

        {!isScanning ? (
          <button className="btn-primary btn-start-scan" onClick={handleStartScan}>
            📷 Start Camera
          </button>
        ) : (
          <>
            <div className="camera-view">
              <video
                ref={videoRef}
                className="camera-feed"
                playsInline
                autoPlay
                muted
              />
              <div className="scan-overlay">
                <div className="scan-box" />
              </div>
            </div>
            <button className="btn-secondary btn-stop-scan" onClick={stopScanning}>
              ✕ Stop Scanning
            </button>
          </>
        )}

        {successMessage && (
          <div className="success-message">
            <p>{successMessage}</p>
          </div>
        )}

        {error && (
          <div className="error-message">
            <p>❌ {error}</p>
          </div>
        )}

        <button className="btn-tertiary btn-cancel" onClick={onCancel}>
          Cancel
        </button>

        <canvas ref={canvasRef} style={{ display: 'none' }} />
      </div>
    </div>
  );
}
