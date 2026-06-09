// ============================================================
//  LocationPicker — GPS Location UI Component
//  Provides "Get Current Location" button with loading state
// ============================================================

import React, { useState } from 'react';
import { useGeoLocation } from '../../hooks/useGeoLocation';
import './LocationPicker.css';

interface LocationPickerProps {
  onLocationFetched: (latitude: string, longitude: string) => void;
  disabled?: boolean;
}

export function LocationPicker({ onLocationFetched, disabled = false }: LocationPickerProps) {
  const { isLoading, error, getLocation } = useGeoLocation();
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  const handleGetLocation = async () => {
    const result = await getLocation();
    if (result) {
      onLocationFetched(
        result.latitude.toFixed(6),
        result.longitude.toFixed(6)
      );
      setSuccessMessage(
        `✓ Location fetched (Accuracy: ${result.accuracy ? Math.round(result.accuracy) + 'm' : 'unknown'})`
      );
      setTimeout(() => setSuccessMessage(null), 3000);
    }
  };

  return (
    <div className="location-picker">
      <button
        type="button"
        className="btn-get-location"
        onClick={handleGetLocation}
        disabled={isLoading || disabled}
      >
        {isLoading ? '📍 Fetching location...' : '📍 Get Current Location'}
      </button>

      {successMessage && (
        <div className="location-success">
          <p>{successMessage}</p>
        </div>
      )}

      {error && (
        <div className="location-error">
          <p>❌ {error}</p>
        </div>
      )}
    </div>
  );
}
