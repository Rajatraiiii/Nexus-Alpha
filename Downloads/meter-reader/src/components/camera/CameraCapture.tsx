// ============================================================
//  CameraCapture — UI COMPONENT
//  Renders camera UI and image preview strip.
//
//  OPEN SOCKET: `onImageCaptured(localPath: string)` is a prop.
//  Wire it to `useMeterForm().addImagePath`.
//  Your native camera module calls the same prop pattern.
// ============================================================

import React, { useRef, useState } from 'react';

interface CameraCaptureProps {
  /** ← OPEN SOCKET: called with the local file path after capture */
  onImageCaptured: (localPath: string) => void;
  onImageRemoved: (localPath: string) => void;
  capturedPaths: string[];
  maxImages?: number;
}

export function CameraCapture({
  onImageCaptured,
  onImageRemoved,
  capturedPaths,
  maxImages = 5,
}: CameraCaptureProps) {
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [previews, setPreviews] = useState<Record<string, string>>({});

  /**
   * In production (React Native / Capacitor), replace this handler
   * with your native camera module call. The contract is identical:
   * call onImageCaptured(localFilePath) when done.
   *
   * Example (Capacitor):
   *   const photo = await Camera.getPhoto({ resultType: CameraResultType.Uri });
   *   onImageCaptured(photo.path!);
   */
  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Create a local object URL as a stand-in for the native temp path
    const localPath = URL.createObjectURL(file);
    setPreviews((prev) => ({ ...prev, [localPath]: localPath }));
    onImageCaptured(localPath);
  };

  const handleRemove = (path: string) => {
    setPreviews((prev) => {
      const next = { ...prev };
      delete next[path];
      return next;
    });
    onImageRemoved(path);
  };

  const canCapture = capturedPaths.length < maxImages;

  return (
    <div className="camera-capture">
      <div className="camera-header">
        <span className="section-label">IMAGES</span>
        <span className="image-count">
          {capturedPaths.length}/{maxImages}
        </span>
      </div>

      <div className="image-strip">
        {/* Captured thumbnails */}
        {capturedPaths.map((path) => (
          <div key={path} className="thumbnail-wrapper">
            {previews[path] ? (
              <img src={previews[path]} alt="Captured meter" className="thumbnail" />
            ) : (
              <div className="thumbnail-placeholder">
                <span className="placeholder-icon">📷</span>
              </div>
            )}
            <button
              className="remove-image-btn"
              onClick={() => handleRemove(path)}
              aria-label="Remove image"
            >
              ✕
            </button>
          </div>
        ))}

        {/* Capture button */}
        {canCapture && (
          <button
            className="capture-btn"
            onClick={() => fileInputRef.current?.click()}
            aria-label="Capture meter image"
          >
            <span className="capture-icon">+</span>
            <span className="capture-label">CAPTURE</span>
          </button>
        )}
      </div>

      {/* Hidden native input — replaced by Camera.getPhoto in production */}
      <input
        ref={fileInputRef}
        type="file"
        accept="image/*"
        capture="environment"
        onChange={handleFileSelect}
        style={{ display: 'none' }}
        aria-hidden="true"
      />
    </div>
  );
}
