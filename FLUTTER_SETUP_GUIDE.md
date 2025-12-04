# ExportSafe AI - Complete Build Guide

## ✅ What's Been Built

### Flutter Frontend (exportsafe_ai/)
- ✅ **Clean Architecture** - Proper separation of concerns (Presentation, Domain, Data)
- ✅ **Theme System** - Navy Blue (#0A2342), Emerald Green (#2CA58D), Crimson Red (#D72638)
- ✅ **Navigation** - GoRouter with 4 routes (/login, /dashboard, /audit, /report)
- ✅ **Authentication** - Firebase Auth + Google Sign-In
- ✅ **Dashboard** - Stats cards, recent activity, start audit button
- ✅ **Upload Screen** - Dual file drop zones with file picker
- ✅ **Report Screen** - Risk gauge, discrepancy cards, action buttons
- ✅ **State Management** - Provider pattern with DashboardProvider & AuditProvider
- ✅ **API Integration** - Multipart file upload to Python backend

### Python Backend (ackend/)
- ✅ **FastAPI** - Production-grade REST API
- ✅ **/audit Endpoint** - Accepts 2 PDF files, returns JSON audit results
- ✅ **LlamaParse** - Extracts text from PDFs
- ✅ **Claude 3.5 Sonnet** - UCP 600 compliance auditing
- ✅ **CORS** - Configured for cross-origin requests
- ✅ **Docker** - Containerized for deployment
- ✅ **Error Handling** - Graceful fallbacks for missing API keys

---

## 🚀 Getting Started

### Prerequisites
1. **Flutter SDK** - Download from flutter.dev
2. **Python 3.9+** - Download from python.org
3. **Firebase Project** - Create at console.firebase.google.com
4. **API Keys**:
   - Anthropic: https://console.anthropic.com
   - LlamaParse: https://cloud.llamaindex.ai

---

## 📱 Running the Flutter App

### Step 1: Get Dependencies
\\\ash
cd exportsafe_ai
flutter pub get
\\\

### Step 2: Run on Emulator/Device
\\\ash
flutter run
\\\

**Expected Result:** Login screen with ExportSafe AI logo and Google Sign-In button

---

## 🐍 Running the Python Backend

### Step 1: Install Dependencies
\\\ash
cd backend
pip install -r requirements.txt
\\\

### Step 2: Set Up Environment Variables
Edit \.env\ file in the backend folder:
\\\
ANTHROPIC_API_KEY=your_key_here
LLAMA_PARSE_API_KEY=your_key_here
\\\

### Step 3: Run the Server
\\\ash
uvicorn main:app --reload
\\\

**Expected Result:** Server running on http://localhost:8000
- API Docs: http://localhost:8000/docs

---

## �� Testing the Flow

### 1. **Login**
- Tap "Sign in with Google"
- Authenticate with your Google account
- Should redirect to Dashboard

### 2. **Dashboard**
- See stats: Audits Done (12), Money Saved (₹50k), Credits Left (5)
- See recent activity list
- Tap "Start New Audit" button

### 3. **Upload**
- Tap first drop zone → Select a PDF (Letter of Credit)
- Tap second drop zone → Select a PDF (Commercial Invoice)
- "RUN ANALYSIS" button should turn Navy Blue
- Tap to start processing

### 4. **Processing**
- Loading dialog appears
- Backend receives files
- Claude processes documents
- Takes 30-60 seconds

### 5. **Report**
- Green banner if PASS, Red if FAIL
- Risk score gauge (0-100)
- Discrepancy cards showing mismatches
- Action buttons: Download PDF, Share WhatsApp, Start New Audit

---

## 📁 Project Structure

\\\
exportsafe_ai/
├── lib/
│   ├── core/
│   │   ├── theme/
│   │   │   └── app_theme.dart          # Material 3 design system
│   │   ├── router/
│   │   │   └── app_router.dart         # GoRouter configuration
│   │   ├── constants/
│   │   │   └── app_constants.dart      # App-wide constants
│   │   └── utils/                      # Helper functions
│   ├── data/
│   │   ├── datasources/
│   │   │   └── remote/
│   │   │       └── api_service.dart    # HTTP client
│   │   ├── models/
│   │   │   └── audit_report.dart       # Data models
│   │   ├── repositories/               # Repository pattern
│   │   └── services/
│   │       └── auth_service.dart       # Firebase Auth
│   ├── domain/
│   │   ├── entities/                   # Business objects
│   │   └── repositories/               # Abstract interfaces
│   ├── presentation/
│   │   ├── providers/
│   │   │   ├── dashboard_provider.dart
│   │   │   └── audit_provider.dart
│   │   ├── screens/
│   │   │   ├── auth/
│   │   │   │   └── login_screen.dart
│   │   │   ├── dashboard/
│   │   │   │   └── dashboard_screen.dart
│   │   │   └── audit/
│   │   │       ├── upload_screen.dart
│   │   │       └── report_screen.dart
│   │   └── widgets/                    # Reusable components
│   └── main.dart                       # App entry point

backend/
├── main.py                             # FastAPI app
├── requirements.txt                    # Python dependencies
├── .env                                # API keys (add yours)
└── Dockerfile                          # Container config
\\\

---

## 🔑 Key Features

### Frontend
- **Clean Architecture** - Easy to test and maintain
- **Material 3 Design** - Professional banking app look
- **State Management** - Provider pattern for reactive UI
- **File Upload** - Drag-and-drop style interface
- **Real-time Feedback** - Loading dialogs, error messages

### Backend
- **UCP 600 Compliance** - Strict validation rules
- **AI-Powered** - Claude 3.5 Sonnet for intelligent auditing
- **PDF Processing** - LlamaParse for text extraction
- **Production-Ready** - Error handling, CORS, Docker support

---

## ⚠️ Important Notes

1. **API Keys Required**
   - Get Anthropic key: https://console.anthropic.com
   - Get LlamaParse key: https://cloud.llamaindex.ai
   - Add to \.env\ file in backend folder

2. **Firebase Setup**
   - Create Firebase project
   - Add Android/iOS/Web apps
   - Download google-services.json (Android)
   - Download GoogleService-Info.plist (iOS)

3. **Android Emulator**
   - Use \http://10.0.2.2:8000\ to connect to localhost backend
   - Physical devices use actual IP address

4. **Testing Without API Keys**
   - Backend returns mock response if keys are missing
   - Useful for UI testing

---

## 🚀 Next Steps

1. **Add Firebase Config**
   - Download credentials from Firebase Console
   - Add to Flutter project

2. **Get API Keys**
   - Anthropic: https://console.anthropic.com
   - LlamaParse: https://cloud.llamaindex.ai

3. **Test End-to-End**
   - Run Flutter app
   - Run Python backend
   - Upload sample LC and Invoice PDFs

4. **Deploy**
   - Flutter: Google Play Store, Apple App Store, Firebase Hosting
   - Backend: Render.com, Railway.app, or Docker

---

## 📞 Troubleshooting

### Flutter Won't Run
\\\ash
flutter clean
flutter pub get
flutter run
\\\

### Backend Connection Error
- Check backend is running on port 8000
- Verify API URL in \pi_service.dart\
- For Android emulator, use \http://10.0.2.2:8000\

### API Keys Not Working
- Verify keys in \.env\ file
- Check API key format (no extra spaces)
- Ensure keys have sufficient credits

### File Upload Fails
- Check file size (should be < 10MB)
- Verify file format (PDF, JPG, PNG)
- Check backend logs for errors

---

## 📊 Architecture Overview

\\\
User (Flutter App)
    ↓
GoRouter (Navigation)
    ↓
Provider (State Management)
    ↓
API Service (HTTP Client)
    ↓
Python Backend (FastAPI)
    ↓
LlamaParse (PDF Extraction)
    ↓
Claude 3.5 Sonnet (AI Auditing)
    ↓
JSON Response (Audit Results)
    ↓
Report Screen (Display Results)
\\\

---

## ✅ Checklist

- [ ] Flutter dependencies installed (\lutter pub get\)
- [ ] Python dependencies installed (\pip install -r requirements.txt\)
- [ ] .env file created with API keys
- [ ] Firebase project created and configured
- [ ] Backend running on port 8000
- [ ] Flutter app running on emulator/device
- [ ] Can login with Google
- [ ] Can upload files
- [ ] Can see audit results

---

**You're all set! Start building! 🚀**
