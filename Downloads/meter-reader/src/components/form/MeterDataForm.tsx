// ============================================================
//  MeterDataForm — UI COMPONENT
//  Pure controlled form component. All state lives in
//  useMeterForm() — this component only renders and dispatches.
// ============================================================

import React from 'react';
import type { MeterFormState, FlagStatus, ReadingType, FormErrors } from '../../types';

const FLAG_OPTIONS: { value: FlagStatus; label: string; color: string }[] = [
  { value: 'NORMAL',       label: 'Normal',       color: '#4ADE80' },
  { value: 'TAMPERED',     label: 'Tampered',     color: '#FF4D4D' },
  { value: 'LEAK',         label: 'Leak',         color: '#FB923C' },
  { value: 'BROKEN_SEAL',  label: 'Broken Seal',  color: '#FACC15' },
  { value: 'INACCESSIBLE', label: 'Inaccessible', color: '#94A3B8' },
  { value: 'DAMAGED',      label: 'Damaged',      color: '#F472B6' },
];

const READING_TYPES: { value: ReadingType; label: string }[] = [
  { value: 'MONTHLY',      label: 'Monthly' },
  { value: 'SPOT_CHECK',   label: 'Spot Check' },
  { value: 'RECONNECTION', label: 'Reconnection' },
  { value: 'FINAL',        label: 'Final' },
  { value: 'AUDIT',        label: 'Audit' },
];

interface MeterDataFormProps {
  form: MeterFormState;
  errors: FormErrors;
  onField: <K extends keyof MeterFormState>(field: K, value: MeterFormState[K]) => void;
}

export function MeterDataForm({ form, errors, onField }: MeterDataFormProps) {
  const selectedFlag = FLAG_OPTIONS.find((f) => f.value === form.flagStatus);

  return (
    <div className="meter-form">
      {/* ── Location ──────────────────────────────────────── */}
      <div className="form-section">
        <span className="section-label">LOCATION</span>
        <div className="form-row-2col">
          <div className="form-field">
            <label className="field-label" htmlFor="gps-lat">LAT</label>
            <input
              id="gps-lat"
              className={`field-input ${errors.gps ? 'field-input--error' : ''}`}
              type="number"
              step="0.000001"
              placeholder="00.000000"
              value={form.gpsLatitude}
              onChange={(e) => onField('gpsLatitude', e.target.value)}
            />
          </div>
          <div className="form-field">
            <label className="field-label" htmlFor="gps-lon">LON</label>
            <input
              id="gps-lon"
              className={`field-input ${errors.gps ? 'field-input--error' : ''}`}
              type="number"
              step="0.000001"
              placeholder="00.000000"
              value={form.gpsLongitude}
              onChange={(e) => onField('gpsLongitude', e.target.value)}
            />
          </div>
        </div>
        {errors.gps && <span className="field-error">{errors.gps}</span>}
      </div>

      {/* ── Meter Serial ──────────────────────────────────── */}
      <div className="form-section">
        <span className="section-label">METER SERIAL</span>
        <div className="form-field">
          <input
            id="meter-serial"
            className={`field-input field-input--mono ${errors.meterSerial ? 'field-input--error' : ''}`}
            type="text"
            placeholder="e.g. MTR-2024-00847"
            value={form.meterSerial}
            onChange={(e) => onField('meterSerial', e.target.value.toUpperCase())}
            autoCapitalize="characters"
            spellCheck={false}
          />
          {errors.meterSerial && <span className="field-error">{errors.meterSerial}</span>}
        </div>
      </div>

      {/* ── Reading ───────────────────────────────────────── */}
      <div className="form-section">
        <span className="section-label">READING</span>
        <div className="form-row-2col">
          <div className="form-field">
            <label className="field-label" htmlFor="current-reading">VALUE</label>
            <input
              id="current-reading"
              className={`field-input field-input--mono ${errors.currentReading ? 'field-input--error' : ''}`}
              type="number"
              step="0.01"
              placeholder="0000.00"
              value={form.currentReading}
              onChange={(e) => onField('currentReading', e.target.value)}
            />
            {errors.currentReading && <span className="field-error">{errors.currentReading}</span>}
          </div>
          <div className="form-field">
            <label className="field-label" htmlFor="reading-type">TYPE</label>
            <select
              id="reading-type"
              className="field-select"
              value={form.readingType}
              onChange={(e) => onField('readingType', e.target.value as ReadingType)}
            >
              {READING_TYPES.map((rt) => (
                <option key={rt.value} value={rt.value}>{rt.label}</option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* ── Flag Status ───────────────────────────────────── */}
      <div className="form-section">
        <span className="section-label">FLAG STATUS</span>
        <div className="flag-grid">
          {FLAG_OPTIONS.map((flag) => (
            <button
              key={flag.value}
              type="button"
              className={`flag-chip ${form.flagStatus === flag.value ? 'flag-chip--active' : ''}`}
              style={form.flagStatus === flag.value ? { borderColor: flag.color, color: flag.color } : {}}
              onClick={() => onField('flagStatus', flag.value)}
              aria-pressed={form.flagStatus === flag.value}
            >
              {flag.label}
            </button>
          ))}
        </div>
      </div>

      {/* ── Notes ─────────────────────────────────────────── */}
      <div className="form-section">
        <span className="section-label">NOTES</span>
        <textarea
          className="field-textarea"
          placeholder="Field observations, anomalies, access issues..."
          value={form.notes}
          onChange={(e) => onField('notes', e.target.value)}
          rows={3}
          maxLength={500}
        />
        <span className="char-count">{form.notes.length}/500</span>
      </div>
    </div>
  );
}
