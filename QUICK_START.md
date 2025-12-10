# ExportSafe AI - Quick Start Guide

## 🚀 Get Started in 5 Minutes

---

## ✅ Prerequisites

- ✅ Python 3.8+ installed
- ✅ Chrome browser
- ✅ Git installed
- ✅ Flutter SDK (optional, for mobile)

---

## 🎯 Step 1: Start Backend Server

```powershell
cd "g:\Export Safe AI 2\exportsafe.ai-\backend"
python -m uvicorn main:app --reload --host 127.0.0.1 --port 8000
```

**Expected Output:**
```
Uvicorn running on http://127.0.0.1:8000
```

---

## 🎯 Step 2: Start Web Server

```powershell
cd "g:\Export Safe AI 2\exportsafe.ai-\backend"
python -m http.server 8080
```

**Expected Output:**
```
Serving HTTP on 0.0.0.0 port 8080
```

---

## 🎯 Step 3: Open Web Tester

```powershell
start chrome http://localhost:8080/web_tester.html
```

Or manually open Chrome and go to:
```
http://localhost:8080/web_tester.html
```

---

## 🎯 Step 4: Test the System

### Demo Audit
1. Click "Run Demo Audit" button
2. See results in real-time
3. Check statistics update

### Custom Audit
1. Click "Custom Audit" tab
2. Paste LC text in first field
3. Paste Invoice text in second field
4. Click "Run Custom Audit"
5. View results

### Health Check
1. Click "Health Check" button
2. Verify backend is running

---

## 📊 Expected Results

### Demo Audit Response
```json
{
  "status": "PASS",
  "risk_score": 0,
  "risk_level": "COMPLIANT",
  "recommendation": "APPROVE - No discrepancies found.",
  "discrepancies": [],
  "breakdown": {
    "math_risk": 0,
    "description_risk": 0,
    "date_risk": 0,
    "beneficiary_risk": 0,
    "total_discrepancies": 0,
    "critical": 0
  }
}
```

---

## 🔗 API Endpoints

### Health Check
```
GET http://localhost:8000/health
```

### Demo Audit
```
POST http://localhost:8000/audit/demo
```

### Custom Audit
```
POST http://localhost:8000/audit
Content-Type: multipart/form-data

Body:
- lc_file: <LC document>
- invoice_file: <Invoice document>
```

---

## 🎨 Web Tester Features

### Dashboard
- 📈 Total Audits counter
- ✅ Pass/Fail statistics
- ⏱️ Average processing time
- 🔄 Real-time updates

### Testing Modes
- 🧪 Demo Audit - Pre-configured data
- 🏥 Health Check - Server status
- 📝 Custom Audit - Your own data

### Response Viewer
- Pretty-printed JSON
- Color-coded results
- Scrollable output
- Copy-friendly format

---

## 🧪 Test Scenarios

### Test 1: Perfect Match
```
LC: USD 50,000 for 1000 KGS TEA
Invoice: USD 50,000 for 1000 KGS TEA
Result: PASS ✅
```

### Test 2: Amount Mismatch
```
LC: USD 50,000
Invoice: USD 60,000
Result: FAIL ❌
```

### Test 3: Description Mismatch
```
LC: "Tea Black CTC"
Invoice: "Black Tea CTC"
Result: FAIL ❌
```

---

## 🔧 Troubleshooting

### Backend Not Starting
```powershell
# Check if port 8000 is in use
netstat -ano | findstr ":8000"

# Kill process if needed
Stop-Process -Id <PID> -Force

# Try different port
python -m uvicorn main:app --port 8001
```

### Web Server Not Starting
```powershell
# Check if port 8080 is in use
netstat -ano | findstr ":8080"

# Try different port
python -m http.server 8081
```

### Chrome Won't Connect
```powershell
# Verify backend is running
curl http://localhost:8000/health

# Verify web server is running
curl http://localhost:8080/web_tester.html

# Clear browser cache (Ctrl+Shift+Delete)
```

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| FINAL_SUMMARY.md | Complete project overview |
| FLUTTER_UI_BUILD_GUIDE.md | Flutter implementation code |
| ALGORITHM_DOCUMENTATION.md | Algorithm reference |
| BACKEND_LIVE.md | Backend status |
| CHROME_SETUP.md | Web tester setup |

---

## 🚀 Next Steps

### Option 1: Test More
1. Modify LC/Invoice data
2. Create test scenarios
3. Observe risk scores
4. Test edge cases

### Option 2: Implement Flutter
1. Copy code from FLUTTER_UI_BUILD_GUIDE.md
2. Paste into Flutter project
3. Run: `flutter pub get`
4. Run: `flutter run`

### Option 3: Deploy
1. Deploy backend to cloud
2. Update API URLs
3. Build Flutter APK
4. Publish to Play Store

---

## 💡 Tips

### Performance
- Backend processes <150ms per audit
- Web tester shows real-time statistics
- No external API calls needed

### Testing
- Use demo audit for quick tests
- Use custom audit for detailed testing
- Check health before running audits

### Development
- All code is well-documented
- Clean architecture implemented
- Easy to extend and modify

---

## 🎉 Summary

**Everything is ready to use!**

1. ✅ Start backend server
2. ✅ Start web server
3. ✅ Open web tester
4. ✅ Run demo audit
5. ✅ See results instantly

**Time to first result: ~2 minutes** ⚡

---

## 📞 Need Help?

- Check FINAL_SUMMARY.md for complete overview
- Review ALGORITHM_DOCUMENTATION.md for algorithm details
- See FLUTTER_UI_BUILD_GUIDE.md for Flutter code
- Check browser console (F12) for errors

---

**ExportSafe AI - Ready to Use!** 🚀
