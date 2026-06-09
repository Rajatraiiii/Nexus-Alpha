# Technical Documentation - Industrial Meter Reading System

## 📋 Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Frontend Components](#frontend-components)
3. [React Hooks](#react-hooks)
4. [Backend API](#backend-api)
5. [Type Definitions](#type-definitions)
6. [Data Flow](#data-flow)
7. [Error Handling](#error-handling)

---

## Architecture Overview

### System Architecture

```
┌─────────────────────────────────────────────────┐
│         React Frontend (Vite + TypeScript)      │
├─────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │   QR     │  │   GPS    │  │  Image   │      │
│  │ Scanner  │  │ Location │  │  Upload  │      │
│  └──────────┘  └──────────┘  └──────────┘      │
├─────────────────────────────────────────────────┤
│        MeterDataForm Component                  │
│        DataSubmissionService                    │
├─────────────────────────────────────────────────┤
│  Axios / Fetch to FastAPI Backend               │
└─────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────┐
│      FastAPI Backend (Python 3.8+)              │
├─────────────────────────────────────────────────┤
│  POST /upload-image                             │
│  POST /save-reading                             │
│  GET /                                          │
└─────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────┐
│      SQLite Database & File Storage             │
├─────────────────────────────────────────────────┤
│  database/meters.db                             │
│  uploads/METER-*.jpg                            │
└─────────────────────────────────────────────────┘
```

### Data Flow Layers

```
User Input Layer
    ↓
UI Component Layer (React)
    ↓
Hook Layer (Custom Logic)
    ↓
Service Layer (API Communication)
    ↓
Backend Layer (FastAPI)
    ↓
Data Layer (SQLite + File System)
```

---

## Frontend Components

### 1. QRCodeScanner Component

**Path**: `src/components/qrcode/QRCodeScanner.tsx`

**Props**:
```typescript
interface QRCodeScannerProps {
  onScanSuccess: (result: QRScanResult) => void;
  onCancel: () => void;
}
```

**Returns**:
```typescript
interface QRScanResult {
  meterId: string;
  latitude: number;
  longitude: number;
}
```

**Features**:
- Real-time camera feed
- Scanning overlay with animated border
- Success/error messages
- Camera permission handling

**Usage**:
```jsx
<QRCodeScanner
  onScanSuccess={(result) => {
    setMeter(result.meterId);
    setLat(result.latitude);
    setLon(result.longitude);
  }}
  onCancel={() => setShowScanner(false)}
/>
```

---

### 2. LocationPicker Component

**Path**: `src/components/location/LocationPicker.tsx`

**Props**:
```typescript
interface LocationPickerProps {
  onLocationFetched: (latitude: string, longitude: string) => void;
  disabled?: boolean;
}
```

**Features**:
- Single-click GPS fetching
- Loading indicator
- Permission handling
- Accuracy display
- Error messages

**Usage**:
```jsx
<LocationPicker
  onLocationFetched={(lat, lon) => {
    setLatitude(lat);
    setLongitude(lon);
  }}
  disabled={!isMeterSet}
/>
```

---

### 3. ImageUpload Component

**Path**: `src/components/image/ImageUpload.tsx`

**Props**:
```typescript
interface ImageUploadProps {
  onImageSelected: (imagePath: string) => void;
  meterId: string;
  disabled?: boolean;
}
```

**Features**:
- Capture from camera or gallery
- Image preview
- File validation (JPG/PNG, <10MB)
- Upload progress
- Error handling

**Usage**:
```jsx
<ImageUpload
  onImageSelected={(path) => {
    console.log('Uploaded to:', path);
  }}
  meterId="METER-101"
  disabled={!meterSerial}
/>
```

---

### 4. MeterDataForm Component

**Path**: `src/components/form/MeterDataForm.tsx`

**Props**:
```typescript
interface MeterDataFormProps {
  form: MeterFormState;
  errors: FormErrors;
  onField: <K extends keyof MeterFormState>(
    field: K,
    value: MeterFormState[K]
  ) => void;
}
```

**Integration Points**:
- Includes QRCodeScanner (modal)
- Includes LocationPicker (inline)
- Includes ImageUpload (section)
- Existing meter reading form fields

**Handlers**:
```typescript
const handleQRScanSuccess = (result) => {
  onField('meterSerial', result.meterId);
  onField('gpsLatitude', result.latitude.toFixed(6));
  onField('gpsLongitude', result.longitude.toFixed(6));
};

const handleLocationFetched = (lat, lon) => {
  onField('gpsLatitude', lat);
  onField('gpsLongitude', lon);
};

const handleImageSelected = (imagePath) => {
  onField('capturedImagePaths', [
    ...form.capturedImagePaths,
    imagePath
  ]);
};
```

---

## React Hooks

### 1. useQRScanner Hook

**Path**: `src/hooks/useQRScanner.ts`

**Returns**:
```typescript
interface UseQRScannerReturn {
  isScanning: boolean;
  error: string | null;
  videoRef: React.RefObject<HTMLVideoElement>;
  canvasRef: React.RefObject<HTMLCanvasElement>;
  startScanning: () => Promise<void>;
  stopScanning: () => void;
  scanFrame: (callback: (result: QRScanResult) => void) => Promise<void>;
}
```

**Usage**:
```typescript
const { isScanning, error, videoRef, canvasRef, startScanning, stopScanning, scanFrame } = 
  useQRScanner();

// Start camera
await startScanning();

// Scan frames in interval
const interval = setInterval(() => {
  scanFrame((result) => {
    console.log('QR Result:', result);
  });
}, 300);

// Stop scanning
stopScanning();
```

**QR Data Format**:
```
Raw QR Code Data: METER-101,24.1912,82.5511
Parsed Result: {
  meterId: "METER-101",
  latitude: 24.1912,
  longitude: 82.5511
}
```

---

### 2. useGeoLocation Hook

**Path**: `src/hooks/useGeoLocation.ts`

**Returns**:
```typescript
interface UseGeoLocationReturn {
  isLoading: boolean;
  error: string | null;
  getLocation: () => Promise<GeoLocationResult | null>;
}

interface GeoLocationResult {
  latitude: number;
  longitude: number;
  accuracy: number | null;
  timestamp: string;
}
```

**Usage**:
```typescript
const { isLoading, error, getLocation } = useGeoLocation();

const handleClick = async () => {
  const result = await getLocation();
  if (result) {
    console.log('Lat:', result.latitude);
    console.log('Lon:', result.longitude);
    console.log('Accuracy:', result.accuracy, 'meters');
  }
};
```

**Geolocation Options**:
```javascript
{
  enableHighAccuracy: true,    // Best accuracy
  timeout: 10000,              // 10 second timeout
  maximumAge: 0                // Fresh data only
}
```

---

### 3. useImageUpload Hook

**Path**: `src/hooks/useImageUpload.ts`

**Returns**:
```typescript
interface UseImageUploadReturn {
  isUploading: boolean;
  error: string | null;
  selectedImage: File | null;
  previewUrl: string | null;
  selectImage: (file: File) => void;
  uploadImage: (meterId: string) => Promise<ImageUploadResult | null>;
  clearImage: () => void;
}

interface ImageUploadResult {
  imagePath: string;
  fileName: string;
  fileSize: number;
}
```

**Usage**:
```typescript
const { 
  isUploading, 
  error, 
  previewUrl, 
  selectImage, 
  uploadImage, 
  clearImage 
} = useImageUpload();

// Select image
const handleFileSelect = (file: File) => {
  selectImage(file);
};

// Upload image
const handleUpload = async () => {
  const result = await uploadImage("METER-101");
  if (result) {
    console.log('Saved to:', result.imagePath);
  }
};

// Clear selection
handleClearClick = () => {
  clearImage();
};
```

**File Validation**:
```
Allowed Types: image/jpeg, image/jpg, image/png
Max Size: 10 MB
```

---

## Backend API

### Endpoint 1: Home

**URL**: `GET /`

**Response**:
```json
{
  "message": "Backend Running Successfully"
}
```

**Status**: 200 OK

---

### Endpoint 2: Upload Image (NEW)

**URL**: `POST /upload-image`

**Content-Type**: `multipart/form-data`

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| file | File | Yes | Image file (JPG/PNG) |
| meter_id | String | Yes | Meter identifier |

**Request Example**:
```bash
curl -X POST "http://localhost:8000/upload-image" \
  -F "file=@meter.jpg" \
  -F "meter_id=METER-101"
```

**Response (Success - 200)**:
```json
{
  "image_path": "uploads/METER-101.jpg",
  "file_name": "METER-101.jpg",
  "file_size": 245623
}
```

**Response (Error - 400)**:
```json
{
  "detail": "Only JPG and PNG images are allowed"
}
```

**Response (Error - 500)**:
```json
{
  "detail": "File upload failed: [error message]"
}
```

**Implementation**:
```python
@app.post("/upload-image")
async def upload_image(
    file: UploadFile = File(...),
    meter_id: str = Form(...)
):
    # Validate extension
    # Save file
    # Return path
```

---

### Endpoint 3: Save Reading

**URL**: `POST /save-reading`

**Content-Type**: `application/json`

**Body**:
```json
{
  "meter_id": "METER-101",
  "latitude": 24.1912,
  "longitude": 82.5511,
  "image_path": "uploads/METER-101.jpg",
  "ocr_reading": "1234.56",
  "flag_reason": "NORMAL",
  "processing_status": "PENDING"
}
```

**Response (Success - 200)**:
```json
{
  "message": "Saved Successfully"
}
```

**Database Record**:
```sql
INSERT INTO meter_readings (
  meter_id, latitude, longitude, image_path,
  ocr_reading, flag_reason, processing_status
) VALUES (...)
```

---

## Type Definitions

### QRScanData

```typescript
interface QRScanData {
  meterId: string;        // e.g., "METER-101"
  latitude: number;       // e.g., 24.1912
  longitude: number;      // e.g., 82.5511
}
```

### GeoLocationData

```typescript
interface GeoLocationData {
  latitude: number;           // Decimal degrees
  longitude: number;          // Decimal degrees
  accuracy: number | null;    // Meters
  timestamp: string;          // ISO-8601
}
```

### ImageUploadData

```typescript
interface ImageUploadData {
  imagePath: string;      // e.g., "uploads/METER-101.jpg"
  fileName: string;       // e.g., "METER-101.jpg"
  fileSize: number;       // Bytes
}
```

### MeterFormState

```typescript
interface MeterFormState {
  stage: 'scanning' | 'reviewing' | 'verified';
  mlResult: MLInferenceResult | null;
  meterSerial: string;
  currentReading: string;
  readingType: ReadingType;
  flagStatus: FlagStatus;
  notes: string;
  gpsLatitude: string;
  gpsLongitude: string;
  capturedImagePath: string | null;
  capturedImagePaths: string[];      // NEW: Image paths
  processingMl: boolean;
  mlError: string | null;
}
```

---

## Data Flow

### Complete User Journey with New Features

```
1. USER SCANS QR CODE
   ├─ Click "📷 QR" button
   ├─ useQRScanner starts camera
   ├─ detectQRCode() parses data
   ├─ handleQRScanSuccess() fires
   └─ Form fields populate:
      ├─ meterSerial ← meterId
      ├─ gpsLatitude ← latitude
      └─ gpsLongitude ← longitude

2. USER GETS GPS LOCATION (Optional)
   ├─ Click "📍 Get Current Location"
   ├─ useGeoLocation calls navigator.geolocation
   ├─ Browser prompts for permission
   ├─ handleLocationFetched() fires
   └─ GPS fields update:
      ├─ gpsLatitude ← new GPS lat
      └─ gpsLongitude ← new GPS lon

3. USER UPLOADS IMAGE
   ├─ Enter meterSerial (enables upload)
   ├─ Click "📷 Capture" or "🖼️ Gallery"
   ├─ Select image file
   ├─ useImageUpload validates
   ├─ Show preview
   ├─ Click "☁️ Upload"
   ├─ POST /upload-image to backend
   ├─ Backend saves to uploads/METER-*.jpg
   ├─ Return imagePath
   ├─ handleImageSelected() fires
   └─ imagePath stored in form state

4. USER FILLS REMAINING FORM
   ├─ Enter reading value
   ├─ Select reading type
   ├─ Choose flag status
   └─ Add notes

5. USER SUBMITS FORM
   ├─ Form validation
   ├─ Build MeterReadingPayload:
   │  ├─ id (UUID)
   │  ├─ meterSerial
   │  ├─ currentReading
   │  ├─ gpsLatitude
   │  ├─ gpsLongitude
   │  └─ imagePaths (from uploads)
   ├─ DataSubmissionService.onDataCaptured()
   ├─ Send payload to backend
   └─ Backend INSERT to database

6. DATABASE STORAGE
   ├─ meter_readings table
   └─ image_path = "uploads/METER-101.jpg"
```

### API Call Sequence

```
Frontend                              Backend
    │                                    │
    ├──────── POST /upload-image ────────>
    │         (multipart/form-data)     │
    │                                    ├─ Save file
    │                                    ├─ Return path
    │<────── {image_path: "..."}─────────┤
    │                                    │
    │                                    │
    ├──────── POST /save-reading ────────>
    │         (JSON payload)             │
    │                                    ├─ Validate
    │                                    ├─ INSERT to DB
    │<───── {message: "Saved"}───────────┤
    │                                    │
```

---

## Error Handling

### Frontend Error Handling

**QR Scanner Errors**:
```typescript
// User denies camera permission
error: "Permission denied"

// Camera timeout
error: "Timeout getting device"

// Unsupported browser
error: "Your browser doesn't support media devices"
```

**Geolocation Errors**:
```typescript
// User denies location permission
error: "Location permission denied. Please enable in browser settings."

// GPS unavailable
error: "Location information is unavailable."

// Request timeout
error: "Location request timed out. Please try again."
```

**Image Upload Errors**:
```typescript
// Invalid file type
error: "Only JPG and PNG images are allowed"

// File too large
error: "File size must be less than 10MB"

// Upload network error
error: "Upload failed: [network error]"

// Server error
error: "Upload failed with status 500"
```

### Backend Error Handling

```python
try:
    # Validate file extension
    if file_ext not in {'.jpg', '.jpeg', '.png'}:
        return {"detail": "Only JPG and PNG images are allowed"}, 400
    
    # Validate file size
    # Save file
    # Return success
except Exception as e:
    return {
        "detail": f"File upload failed: {str(e)}"
    }, 500
```

---

## Performance Optimization

### Frontend Optimization

1. **Image Compression**:
   - Compress before upload
   - Reduce file size from MB to KB

2. **Lazy Loading**:
   - Load components on demand
   - Camera/GPS only when needed

3. **Caching**:
   - Cache geolocation permission
   - Reduce re-requests

### Backend Optimization

1. **File Storage**:
   - Use relative paths
   - CDN delivery for images

2. **Database Indexing**:
   ```sql
   CREATE INDEX idx_meter_id ON meter_readings(meter_id);
   CREATE INDEX idx_timestamp ON meter_readings(timestamp);
   ```

3. **Connection Pooling**:
   - SQLite connection reuse
   - Connection timeout management

---

## Security Considerations

### File Upload Security

1. **File Type Validation**:
   ```python
   ALLOWED_EXTENSIONS = {'.jpg', '.jpeg', '.png'}
   ```

2. **File Size Limit**:
   ```
   MAX_SIZE = 10 * 1024 * 1024  # 10 MB
   ```

3. **File Naming**:
   ```python
   filename = f"{meter_id}.jpg"  # Sanitized, no user input
   ```

4. **Directory Isolation**:
   ```
   uploads/  # Separate from code
   ```

### CORS Security

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Update for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

**Production Config**:
```python
allow_origins=["https://yourdomain.com"]
```

---

## Testing

### Unit Tests

```bash
# Frontend
npm test

# Backend
pytest tests/
```

### Integration Tests

```bash
# Test QR scanning
# Test GPS fetching
# Test image upload
# Test full flow
```

### Manual Testing Checklist

- [ ] QR scan successfully extracts data
- [ ] GPS location fetches with permission
- [ ] Image upload saves to correct location
- [ ] Database stores image path
- [ ] All error cases handled gracefully
- [ ] UI responsive on mobile

---

**Last Updated**: June 9, 2026
**Version**: 1.0
**Author**: Industrial Meter Reading Team
