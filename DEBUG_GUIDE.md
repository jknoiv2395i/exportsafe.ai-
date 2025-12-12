# Debugging Guide - Complete Troubleshooting

## Step 1: Check Backend Server Status

### Is the backend running?
```
Open: http://localhost:8000/health
Expected: {"status": "ok"}
```

If you see an error, restart backend:
```
1. Kill any running Python processes
2. Run: python run_server.py
3. Wait 2 seconds
4. Check http://localhost:8000/health again
```

---

## Step 2: Check Web Tester

### Is web tester accessible?
```
Open: http://localhost:8080/web_tester.html
Expected: Page loads with statistics and sections
```

If you see an error:
```
1. Refresh: Ctrl+F5
2. Clear cache: Ctrl+Shift+Delete
3. Try again
```

---

## Step 3: Open Browser Console

### To see actual errors:
```
Press: F12 (Open Developer Tools)
Click: Console tab
Look for: Red error messages
```

### Common errors and solutions:

**Error: "Failed to fetch"**
- Backend is not running
- Solution: Start backend server

**Error: "CORS error"**
- Backend headers are wrong
- Solution: Restart backend

**Error: "undefined is not a function"**
- JavaScript error
- Solution: Refresh page (Ctrl+F5)

---

## Step 4: Test Advanced Audit Manually

### Using curl (Windows PowerShell):
```powershell
$body = @{
    lc_text = "LETTER OF CREDIT`nLC Number: LC-2025-001`nBeneficiary: Test`nAmount: USD 1000"
    invoice_text = "INVOICE`nInvoice Number: INV-001`nAmount: USD 1000"
} | ConvertTo-Json

Invoke-WebRequest -Uri 'http://localhost:8000/audit/advanced' `
  -Method POST `
  -Headers @{'Content-Type'='application/json'} `
  -Body $body
```

### Expected response:
```json
{
  "audit_summary": "...",
  "risk_score": 0,
  "logic_checks": {...},
  "discrepancies": [],
  "corrected_lc": "..."
}
```

---

## Step 5: Complete Restart Procedure

### If everything is broken:

**Step 1: Kill all Python processes**
```
Press: Ctrl+Shift+Esc (Task Manager)
Find: Python
Right-click: End Task
```

**Step 2: Clear browser cache**
```
Press: Ctrl+Shift+Delete
Select: All time
Click: Clear data
```

**Step 3: Restart backend**
```
Open: Command Prompt
Navigate: cd g:\Export Safe AI 2\exportsafe.ai-\backend
Run: python run_server.py
Wait: 2 seconds
```

**Step 4: Restart web tester**
```
Close: Browser
Open: New browser window
Go to: http://localhost:8080/web_tester.html
```

---

## Step 6: Verify Each Component

### Backend Server
```
URL: http://localhost:8000/health
Expected: {"status": "ok"}
Status: ✅ or ❌
```

### Web Tester
```
URL: http://localhost:8080/web_tester.html
Expected: Page loads
Status: ✅ or ❌
```

### Advanced Audit Endpoint
```
URL: http://localhost:8000/audit/advanced
Method: POST
Expected: JSON response
Status: ✅ or ❌
```

### Download Endpoint
```
URL: http://localhost:8000/download/corrected-lc
Method: POST
Expected: File download
Status: ✅ or ❌
```

---

## Step 7: Test with Sample Data

### Perfect LC (No Errors)
```
LETTER OF CREDIT
LC Number: LC-2025-001
Beneficiary: Assam Tea Exports Ltd
Applicant: Global Imports Inc
Amount: USD 50,000
Currency: USD
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Latest Shipment Date: 31-12-2025
Expiry Date: 31-01-2026
```

**Expected Result:**
- Risk Score: 0/100
- Discrepancies: 0
- No download button (no errors to fix)

### LC with Spelling Errors
```
LETTER OF CREDIT
LC Number: LC-2025-001
Benificiary: Assam Tea Exports Ltd  ← ERROR
Applicant: Global Imports Inc
Amout: USD 50,000  ← ERROR
Currency: USD
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Latest Shipment Date: 31-12-2025
Expiry Date: 31-01-2026
```

**Expected Result:**
- Risk Score: > 0/100
- Discrepancies: > 0
- Download button appears ✅

### LC with Date Error
```
LETTER OF CREDIT
LC Number: LC-2025-001
Beneficiary: Assam Tea Exports Ltd
Applicant: Global Imports Inc
Amount: USD 50,000
Currency: USD
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Latest Shipment Date: 31-12-2025
Expiry Date: 31-01-2026
```

**Invoice:**
```
COMMERCIAL INVOICE
Invoice Number: INV-2025-001
Invoice Date: 15-12-2025  ← AFTER shipment date
Issuer: Assam Tea Exports Ltd
Buyer: Global Imports Inc
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Quantity: 1000 KGS
Unit Price: USD 50
Total Amount: USD 50,000
Shipment Date: 10-12-2025  ← BEFORE invoice date
```

**Expected Result:**
- Risk Score: 45/100
- Discrepancies: 2
- Download button appears ✅

---

## Step 8: Check Logs

### Backend logs
```
Look at: Command prompt where backend is running
Check for: Error messages
Look for: "ERROR" or "Exception"
```

### Browser console logs
```
Press: F12
Click: Console tab
Look for: Red error messages
Right-click: Copy message
Paste: In a text file
```

---

## Step 9: Common Issues & Solutions

### Issue: "No summary" in results
**Cause:** Backend not returning audit_summary
**Solution:** 
1. Restart backend
2. Check if LC/Invoice text is empty
3. Check browser console for errors

### Issue: "Risk Score: N/A/100"
**Cause:** Backend not returning risk_score
**Solution:**
1. Restart backend
2. Check backend logs
3. Try with different LC/Invoice

### Issue: "Discrepancies: undefined total"
**Cause:** Backend not returning discrepancies array
**Solution:**
1. Restart backend
2. Refresh browser (Ctrl+F5)
3. Try again

### Issue: Download button not appearing
**Cause:** No corrected_lc in response
**Solution:**
1. Make sure LC has errors
2. Check if audit completed successfully
3. Check browser console for errors

### Issue: "Failed to fetch" error
**Cause:** Backend server not running
**Solution:**
1. Check if port 8000 is running
2. Restart backend server
3. Wait 2 seconds
4. Try again

---

## Step 10: Final Verification

### Checklist:
- [ ] Backend server running (port 8000)
- [ ] Web tester accessible (port 8080)
- [ ] Browser cache cleared
- [ ] F12 console shows no red errors
- [ ] Health check returns {"status": "ok"}
- [ ] Advanced audit endpoint responds
- [ ] Sample LC with errors shows discrepancies
- [ ] Download button appears for LC with errors
- [ ] Download file works

---

## Need Help?

### Check these files:
1. `backend/run_server.py` - Backend server
2. `backend/utils/advanced_lc_auditor.py` - Audit logic
3. `backend/web_tester.html` - Frontend
4. Browser console (F12)
5. Backend logs (command prompt)

### Restart everything:
```
1. Kill Python processes (Ctrl+Shift+Esc)
2. Clear browser cache (Ctrl+Shift+Delete)
3. Restart backend (python run_server.py)
4. Refresh browser (Ctrl+F5)
5. Try again
```

---

**Follow these steps to identify and fix the problem!**
