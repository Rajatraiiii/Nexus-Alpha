// ============================================================
//  ImageUpload — Image Upload UI Component
//  Provides file selection, preview, and upload functionality
// ============================================================

import React, { useRef } from 'react';
import { useImageUpload } from '../../hooks/useImageUpload';
import './ImageUpload.css';

interface ImageUploadProps {
  onImageSelected: (imagePath: string) => void;
  meterId: string;
  disabled?: boolean;
}

export function ImageUpload({ onImageSelected, meterId, disabled = false }: ImageUploadProps) {
  const { isUploading, error, selectedImage, previewUrl, selectImage, uploadImage, clearImage } =
    useImageUpload();
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [uploadSuccess, setUploadSuccess] = React.useState<string | null>(null);

  const handleFileInput = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      selectImage(file);
    }
    // Reset input so same file can be selected again
    e.target.value = '';
  };

  const handleUpload = async () => {
    if (!meterId) {
      alert('Please enter meter ID first');
      return;
    }

    const result = await uploadImage(meterId);
    if (result) {
      setUploadSuccess(`✓ Image uploaded: ${result.imagePath}`);
      onImageSelected(result.imagePath);
      setTimeout(() => {
        clearImage();
        setUploadSuccess(null);
      }, 3000);
    }
  };

  const handleCapture = async () => {
    // Try to open camera for capture
    if (fileInputRef.current) {
      fileInputRef.current.accept = 'image/*';
      fileInputRef.current.capture = true as any;
      fileInputRef.current.click();
    }
  };

  const handleSelectFromGallery = () => {
    if (fileInputRef.current) {
      fileInputRef.current.accept = 'image/jpeg,image/jpg,image/png';
      fileInputRef.current.capture = false as any;
      fileInputRef.current.click();
    }
  };

  return (
    <div className="image-upload">
      <div className="upload-section">
        <h3>📸 Meter Image</h3>

        {!previewUrl ? (
          <div className="upload-actions">
            <button
              type="button"
              className="btn-capture"
              onClick={handleCapture}
              disabled={disabled}
            >
              📷 Capture Image
            </button>
            <button
              type="button"
              className="btn-gallery"
              onClick={handleSelectFromGallery}
              disabled={disabled}
            >
              🖼️ Select from Gallery
            </button>
          </div>
        ) : (
          <div className="preview-container">
            <img src={previewUrl} alt="Meter" className="image-preview" />
            <div className="preview-info">
              <p>File: {selectedImage?.name}</p>
              <p>Size: {((selectedImage?.size || 0) / 1024).toFixed(2)} KB</p>
            </div>
          </div>
        )}

        {previewUrl && (
          <div className="upload-buttons">
            <button
              type="button"
              className="btn-upload"
              onClick={handleUpload}
              disabled={isUploading}
            >
              {isUploading ? '⏳ Uploading...' : '☁️ Upload Image'}
            </button>
            <button
              type="button"
              className="btn-clear"
              onClick={clearImage}
              disabled={isUploading}
            >
              ✕ Clear
            </button>
          </div>
        )}

        {uploadSuccess && (
          <div className="upload-success">
            <p>{uploadSuccess}</p>
          </div>
        )}

        {error && (
          <div className="upload-error">
            <p>❌ {error}</p>
          </div>
        )}

        <input
          ref={fileInputRef}
          type="file"
          accept="image/jpeg,image/jpg,image/png"
          onChange={handleFileInput}
          style={{ display: 'none' }}
        />
      </div>
    </div>
  );
}
