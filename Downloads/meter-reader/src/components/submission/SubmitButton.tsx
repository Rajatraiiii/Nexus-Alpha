// ============================================================
//  SubmitButton — UI COMPONENT
//  The single action trigger for the open socket handoff.
//  Shows state feedback for idle / submitting / success / error.
// ============================================================

import React, { useEffect } from 'react';

interface SubmitButtonProps {
  onSubmit: () => void;
  status: 'idle' | 'submitting' | 'success' | 'error';
  error: string | null;
  onReset: () => void;
}

export function SubmitButton({ onSubmit, status, error, onReset }: SubmitButtonProps) {
  // Auto-reset success state after 3 seconds
  useEffect(() => {
    if (status === 'success') {
      const t = setTimeout(onReset, 3000);
      return () => clearTimeout(t);
    }
  }, [status, onReset]);

  const buttonContent = {
    idle:       { label: 'PUSH DATA TO CLOUD', className: 'submit-btn submit-btn--idle' },
    submitting: { label: 'QUEUING…',            className: 'submit-btn submit-btn--loading' },
    success:    { label: '✓ QUEUED FOR SYNC',   className: 'submit-btn submit-btn--success' },
    error:      { label: 'RETRY',               className: 'submit-btn submit-btn--error' },
  }[status];

  return (
    <div className="submit-area">
      {error && status === 'error' && (
        <div className="submit-error" role="alert">
          {error}
        </div>
      )}
      <button
        className={buttonContent.className}
        onClick={status === 'submitting' ? undefined : onSubmit}
        disabled={status === 'submitting'}
        aria-busy={status === 'submitting'}
        aria-label="Push meter reading data to cloud sync queue"
      >
        {buttonContent.label}
      </button>
      <p className="submit-note">
        Data is queued locally. Sync engine uploads when online.
      </p>
    </div>
  );
}
