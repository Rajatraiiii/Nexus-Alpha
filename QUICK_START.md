# Quick Start Guide - Industrial Meter Reader System

## ⚡ 5-Minute Setup

### 1️⃣ Install Dependencies

```bash
# Frontend
npm install

# Backend
cd backend
pip install python-multipart
cd ..

# Optional: Advanced QR Scanning
npm install jsqr
```

### 2️⃣ Create Uploads Folder

```bash
mkdir -p uploads
chmod 755 uploads
```

### 3️⃣ Setup Environment

```bash
cp .env.example .env
# Edit .env if needed (default works for local development)
```

### 4️⃣ Start Services

**Terminal 1 - Frontend:**
```bash
npm run dev
# Open http://localhost:5173
```

**Terminal 2 - Backend:**
```bash
cd backend
python main.py
# API available at http://localhost:8000
```

---

## 🎯 Feature Quick Start

### QR Scanner
1. Click "📷 QR" button next to Meter Serial
2. Allow camera permission
3. Point camera at QR code (format: METER-101,24.1912,82.5511)
4. Fields auto-populate ✅

### GPS Location
1. Click "📍 Get Current Location"
2. Allow location permission
3. Latitude & Longitude auto-fill ✅

### Image Upload
1. Enter Meter Serial
2. Click "📷 Capture Image" or "🖼️ Select from Gallery"
3. Click "☁️ Upload Image"
4. Image saved to `uploads/METER-XXX.jpg` ✅

---

## 📁 File Structure

```
📦 meter-reader/
 ├── src/
 │   ├── hooks/
 │   │   ├── useQRScanner.ts ✨ NEW
 │   │   ├── useGeoLocation.ts ✨ NEW
 │   │   └── useImageUpload.ts ✨ NEW
 │   ├── components/
 │   │   ├── qrcode/ ✨ NEW
 │   │   ├── location/ ✨ NEW
 │   │   ├── image/ ✨ NEW
 │   │   └── form/
 │   │       └── MeterDataForm.tsx 🔄 UPDATED
 │   ├── types/index.ts 🔄 UPDATED
 │   └── styles.css 🔄 UPDATED
 ├── backend/
 │   ├── main.py 🔄 UPDATED (Image endpoint)
 │   └── database.py
 ├── uploads/ ✨ NEW (Image storage)
 ├── package.json 🔄 UPDATED
 ├── .env.example ✨ NEW
 ├── INTEGRATION_GUIDE.md ✨ NEW
 └── QUICK_START.md ✨ NEW (This file)
```

---

## ✅ Verification Checklist

- [ ] All dependencies installed (`npm install`)
- [ ] Backend python-multipart installed
- [ ] `uploads/` folder created
- [ ] `.env` file exists
- [ ] Frontend running on port 5173
- [ ] Backend running on port 8000
- [ ] Can click "📷 QR" button
- [ ] Can click "📍 Get Current Location"
- [ ] Can select and upload image

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| "Camera not working" | Check browser permissions + use HTTPS/localhost |
| "Location permission denied" | Enable location in browser settings |
| "Image upload failed" | Ensure uploads/ folder exists with proper permissions |
| "API not responding" | Check backend is running on port 8000 |
| "QR code not detected" | Install jsQR: `npm install jsqr` |

---

## 📚 Full Documentation

For detailed information, see: [INTEGRATION_GUIDE.md](./INTEGRATION_GUIDE.md)

---

## 🚀 Next Steps

1. ✅ Run the application
2. ✅ Test all 3 new features
3. ✅ Scan QR code / Get GPS / Upload image
4. ✅ Submit meter reading
5. ✅ Check database for saved data

```bash
# View saved data:
cd backend
python view_data.py
```

---

**Estimated Setup Time**: 5 minutes  
**Estimated Testing Time**: 5 minutes  
**Total**: 10 minutes to fully operational ⚡
