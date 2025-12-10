# Complete Restart & Test Guide

## STEP 1: Kill All Python Processes

### Windows:
```
1. Press: Ctrl + Shift + Esc (Task Manager)
2. Find: Python
3. Right-click: End Task
4. Close Task Manager
```

---

## STEP 2: Clear Browser Cache

### Chrome/Edge:
```
1. Press: Ctrl + Shift + Delete
2. Select: All time
3. Check: Cookies and cached images
4. Click: Clear data
5. Close browser
```

---

## STEP 3: Start Backend Server

### Open Command Prompt:
```
1. Press: Windows Key + R
2. Type: cmd
3. Press: Enter
```

### Navigate to backend:
```
cd g:\Export Safe AI 2\exportsafe.ai-\backend
```

### Start server:
```
python run_server.py
```

### Expected output:
```
Starting LC Validator...
Starting Advanced LC Auditor...
Server running on port 8000
  GET /health           - Health check
  POST /audit/demo      - Demo audit
  POST /audit           - Standard audit
  POST /validate/lc     - Validate LC
  POST /audit/advanced  - Advanced forensic audit
  POST /download/corrected-lc - Download corrected LC

Press Ctrl+C to stop
```

### If you see this, backend is running! ✅

---

## STEP 4: Open Web Tester

### Open new browser window:
```
1. Open Chrome/Edge/Firefox
2. Go to: http://localhost:8080/web_tester.html
3. Wait for page to load
```

### Expected:
```
- Page loads
- Shows statistics
- Shows multiple sections
- No red error messages
```

---

## STEP 5: Test Health Check

### In web tester:
```
1. Look for "Health Check" section
2. Click: "Check Health"
3. Wait for response
```

### Expected response:
```
{
  "status": "ok",
  "message": "LC Validator and Advanced Auditor are running"
}
```

### If you see this, backend is connected! ✅

---

## STEP 6: Test Advanced Audit

### Scroll down to "Advanced Forensic Audit" section:
```
1. Scroll down past all other sections
2. Find: "🔬 Advanced Forensic Audit (UCP 600)"
3. You should see:
   - LC text area (with default text)
   - Invoice text area (with default text)
   - "Run Advanced Audit" button
```

### Click "Run Advanced Audit":
```
1. Click the button
2. Wait 2-3 seconds
3. Results should appear
```

### Expected results:
```
AUDIT SUMMARY: FATAL DISCREPANCIES FOUND - 1 Critical, 1 Major issues

Risk Score: 45/100

Logic Checks:
  - MATH CHECK: PASS
  - DATE LOGIC: FAIL
  - INCOTERM LOGIC: PASS
  - INDIAN COMPLIANCE: FAIL

Discrepancies: 2 total
  - Critical: 1
  - Major: 1
  - Minor: 0

Detailed Discrepancies:

1. [CRITICAL] DATE
   Field: Invoice Date vs Shipment Date
   LC: Invoice Date <= Shipment Date
   Document: Invoice: 15-12-2025, Shipment: 10-12-2025
   Rule: UCP 600 Article 14c - Temporal Logic
   Fix: Correct invoice date to on or before 10-12-2025

2. [MAJOR] INDIAN_REGULATORY
   Field: GSTIN
   LC: Valid 15-digit GSTIN
   Document: GSTIN not found
   Rule: Indian GST Compliance
   Fix: Add GSTIN in format: XX AAAPG0000XXXXX
```

### If you see this, audit is working! ✅

---

## STEP 7: Test Download Button

### After audit results appear:
```
1. Look below the results
2. You should see: "Download Corrected LC" button (green)
3. Click the button
```

### Expected:
```
1. File downloads: corrected_lc.txt
2. File contains corrected LC with all fixes
3. Opens in text editor or downloads folder
```

### If download works, everything is working! ✅

---

## STEP 8: Test with Different LC

### Try LC with spelling errors:
```
LETTER OF CREDIT
LC Number: LC-2025-001
Benificiary: Assam Tea Exports Ltd  ← SPELLING ERROR
Applicant: Global Imports Inc
Amout: USD 50,000  ← SPELLING ERROR
Currency: USD
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Latest Shipment Date: 31-12-2025
Expiry Date: 31-01-2026
```

### Expected:
```
- Spelling errors detected
- Risk score > 0
- Download button appears
- Corrected LC shows: Benificiary → Beneficiary, Amout → Amount
```

---

## STEP 9: Verify All Features

### Checklist:
- [ ] Backend running (port 8000)
- [ ] Web tester loads (port 8080)
- [ ] Health check passes
- [ ] Advanced audit runs
- [ ] Errors detected
- [ ] Risk score calculated
- [ ] Download button appears
- [ ] File downloads
- [ ] Spelling errors fixed

---

## TROUBLESHOOTING

### Problem: Backend won't start
```
Solution:
1. Check if port 8000 is already in use
2. Kill all Python processes
3. Try again
```

### Problem: Web tester won't load
```
Solution:
1. Check if web server is running
2. Refresh browser (Ctrl+F5)
3. Clear cache (Ctrl+Shift+Delete)
```

### Problem: Audit returns "No summary"
```
Solution:
1. Check backend logs
2. Make sure LC/Invoice text is not empty
3. Restart backend
```

### Problem: Download button doesn't appear
```
Solution:
1. Make sure audit completed
2. Check if corrected_lc is in response
3. Open browser console (F12) for errors
```

### Problem: "Failed to fetch" error
```
Solution:
1. Backend is not running
2. Start backend: python run_server.py
3. Wait 2 seconds
4. Try again
```

---

## Quick Commands

### Start backend:
```
cd g:\Export Safe AI 2\exportsafe.ai-\backend
python run_server.py
```

### Kill Python:
```
taskkill /IM python.exe /F
```

### Check port 8000:
```
netstat -ano | findstr :8000
```

### Check port 8080:
```
netstat -ano | findstr :8080
```

---

## Files to Check

### Backend:
- `backend/run_server.py` - Main server
- `backend/utils/advanced_lc_auditor.py` - Audit logic
- `backend/web_tester.html` - Frontend

### Logs:
- Command prompt where backend is running
- Browser console (F12)

---

## Expected System Status

```
✅ Backend Server: Running on port 8000
✅ Web Tester: Running on port 8080
✅ Health Check: Responding
✅ Advanced Audit: Working
✅ Error Detection: Working
✅ Risk Scoring: Working
✅ Download Feature: Working
✅ Spelling Fixer: Working
```

---

## Summary

1. **Kill Python** (Ctrl+Shift+Esc)
2. **Clear cache** (Ctrl+Shift+Delete)
3. **Start backend** (python run_server.py)
4. **Open browser** (http://localhost:8080/web_tester.html)
5. **Scroll down** to Advanced Forensic Audit
6. **Click "Run Advanced Audit"**
7. **See results** with errors detected
8. **Click "Download Corrected LC"**
9. **File downloads** ✅

---

**Follow these steps and everything will work!** 🚀
