// ============================================================
//  useQRScanner — QR Code Scanning Hook
//  Provides QR code scanning and parsing functionality.
//  QR code format: METER-101,24.1912,82.5511
//  Returns: { meter_id, latitude, longitude }
// ============================================================

import { useState, useCallback, useRef } from 'react';

export interface QRScanResult {
  meterId: string;
  latitude: number;
  longitude: number;
}

interface UseQRScannerReturn {
  isScanning: boolean;
  error: string | null;
  videoRef: React.RefObject<HTMLVideoElement>;
  canvasRef: React.RefObject<HTMLCanvasElement>;
  startScanning: () => Promise<void>;
  stopScanning: () => void;
  scanFrame: (callback: (result: QRScanResult) => void) => Promise<void>;
}

/**
 * Parse QR code data in format: METER-101,24.1912,82.5511
 * Returns parsed object or null if invalid format
 */
function parseQRData(data: string): QRScanResult | null {
  try {
    const parts = data.trim().split(',');
    if (parts.length !== 3) return null;

    const meterId = parts[0].trim();
    const latitude = parseFloat(parts[1].trim());
    const longitude = parseFloat(parts[2].trim());

    if (!meterId || isNaN(latitude) || isNaN(longitude)) return null;
    if (latitude < -90 || latitude > 90) return null;
    if (longitude < -180 || longitude > 180) return null;

    return { meterId, latitude, longitude };
  } catch {
    return null;
  }
}

/**
 * Detect QR code in image data using simple pattern recognition
 * For production, integrate with jsQR library or server-side processing
 */
function detectQRCode(imageData: ImageData): string | null {
  // This is a placeholder implementation
  // For production, use jsQR library: https://github.com/cozmo/jsQR
  // npm install jsqr
  // import jsQR from 'jsqr';
  // return jsQR(imageData.data, imageData.width, imageData.height)?.data || null;
  
  return null;
}

export function useQRScanner(): UseQRScannerReturn {
  const [isScanning, setIsScanning] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const scanIntervalRef = useRef<number | null>(null);

  const startScanning = useCallback(async () => {
    try {
      setError(null);
      setIsScanning(true);

      const stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: 'environment' },
      });

      if (videoRef.current) {
        videoRef.current.srcObject = stream;
        videoRef.current.play();
      }
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Failed to access camera';
      setError(message);
      setIsScanning(false);
    }
  }, []);

  const stopScanning = useCallback(() => {
    if (scanIntervalRef.current !== null) {
      clearInterval(scanIntervalRef.current);
      scanIntervalRef.current = null;
    }

    if (videoRef.current?.srcObject) {
      const stream = videoRef.current.srcObject as MediaStream;
      stream.getTracks().forEach((track) => track.stop());
      videoRef.current.srcObject = null;
    }

    setIsScanning(false);
    setError(null);
  }, []);

  const scanFrame = useCallback(
    async (callback: (result: QRScanResult) => void): Promise<void> => {
      if (!isScanning || !videoRef.current || !canvasRef.current) {
        return;
      }

      const canvas = canvasRef.current;
      const ctx = canvas.getContext('2d');
      if (!ctx) return;

      const video = videoRef.current;
      canvas.width = video.videoWidth;
      canvas.height = video.videoHeight;

      ctx.drawImage(video, 0, 0);
      const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);

      // Try to detect QR code
      const qrData = detectQRCode(imageData);
      if (qrData) {
        const parsed = parseQRData(qrData);
        if (parsed) {
          stopScanning();
          callback(parsed);
        }
      }
    },
    [isScanning, stopScanning]
  );

  return {
    isScanning,
    error,
    videoRef,
    canvasRef,
    startScanning,
    stopScanning,
    scanFrame,
  };
}
