// ============================================================
//  useGeoLocation — GPS Location Hook
//  Provides browser geolocation API integration
// ============================================================

import { useState, useCallback } from 'react';

export interface GeoLocationResult {
  latitude: number;
  longitude: number;
  accuracy: number | null;
  timestamp: string;
}

interface UseGeoLocationReturn {
  isLoading: boolean;
  error: string | null;
  getLocation: () => Promise<GeoLocationResult | null>;
}

export function useGeoLocation(): UseGeoLocationReturn {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const getLocation = useCallback(async (): Promise<GeoLocationResult | null> => {
    setIsLoading(true);
    setError(null);

    return new Promise((resolve) => {
      if (!navigator.geolocation) {
        setError('Geolocation is not supported by your browser');
        setIsLoading(false);
        resolve(null);
        return;
      }

      navigator.geolocation.getCurrentPosition(
        (position) => {
          const { latitude, longitude, accuracy } = position.coords;
          const timestamp = new Date().toISOString();

          const result: GeoLocationResult = {
            latitude,
            longitude,
            accuracy,
            timestamp,
          };

          setIsLoading(false);
          setError(null);
          resolve(result);
        },
        (err) => {
          let errorMessage = 'Failed to get location';

          switch (err.code) {
            case err.PERMISSION_DENIED:
              errorMessage =
                'Location permission denied. Please enable location access in browser settings.';
              break;
            case err.POSITION_UNAVAILABLE:
              errorMessage = 'Location information is unavailable.';
              break;
            case err.TIMEOUT:
              errorMessage = 'Location request timed out. Please try again.';
              break;
            default:
              errorMessage = `Location error: ${err.message}`;
          }

          setError(errorMessage);
          setIsLoading(false);
          resolve(null);
        },
        {
          enableHighAccuracy: true,
          timeout: 10000,
          maximumAge: 0,
        }
      );
    });
  }, []);

  return {
    isLoading,
    error,
    getLocation,
  };
}
