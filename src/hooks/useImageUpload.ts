// ============================================================
//  useImageUpload — Image Upload Hook
//  Handles image selection, validation, and upload to backend
// ============================================================

import { useState, useCallback } from 'react';

export interface ImageUploadResult {
  imagePath: string;
  fileName: string;
  fileSize: number;
}

interface UseImageUploadReturn {
  isUploading: boolean;
  error: string | null;
  selectedImage: File | null;
  previewUrl: string | null;
  selectImage: (file: File) => void;
  uploadImage: (meterId: string) => Promise<ImageUploadResult | null>;
  clearImage: () => void;
}

const ALLOWED_TYPES = ['image/jpeg', 'image/jpg', 'image/png'];
const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';

function validateImage(file: File): string | null {
  if (!ALLOWED_TYPES.includes(file.type)) {
    return 'Only JPG and PNG images are allowed';
  }

  if (file.size > MAX_FILE_SIZE) {
    return `File size must be less than ${MAX_FILE_SIZE / (1024 * 1024)}MB`;
  }

  return null;
}

export function useImageUpload(): UseImageUploadReturn {
  const [isUploading, setIsUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [selectedImage, setSelectedImage] = useState<File | null>(null);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);

  const selectImage = useCallback((file: File) => {
    setError(null);

    // Validate image
    const validationError = validateImage(file);
    if (validationError) {
      setError(validationError);
      return;
    }

    // Create preview URL
    const url = URL.createObjectURL(file);
    setSelectedImage(file);
    setPreviewUrl(url);
  }, []);

  const uploadImage = useCallback(
    async (meterId: string): Promise<ImageUploadResult | null> => {
      if (!selectedImage) {
        setError('No image selected');
        return null;
      }

      setIsUploading(true);
      setError(null);

      try {
        const formData = new FormData();
        formData.append('file', selectedImage);
        formData.append('meter_id', meterId);

        const response = await fetch(`${API_BASE_URL}/upload-image`, {
          method: 'POST',
          body: formData,
        });

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({}));
          throw new Error(
            errorData.detail || `Upload failed with status ${response.status}`
          );
        }

        const data = await response.json();

        const result: ImageUploadResult = {
          imagePath: data.image_path,
          fileName: selectedImage.name,
          fileSize: selectedImage.size,
        };

        setIsUploading(false);
        return result;
      } catch (err) {
        const message = err instanceof Error ? err.message : 'Upload failed';
        setError(message);
        setIsUploading(false);
        return null;
      }
    },
    [selectedImage]
  );

  const clearImage = useCallback(() => {
    if (previewUrl) {
      URL.revokeObjectURL(previewUrl);
    }
    setSelectedImage(null);
    setPreviewUrl(null);
    setError(null);
  }, [previewUrl]);

  return {
    isUploading,
    error,
    selectedImage,
    previewUrl,
    selectImage,
    uploadImage,
    clearImage,
  };
}
