# Where to Find the Download Button - Quick Guide

## 🔍 Location of Advanced Forensic Audit & Download Button

### Step 1: Open Web Tester
```
URL: http://localhost:8080/web_tester.html
```

### Step 2: SCROLL DOWN to Find Advanced Forensic Audit Section

The page has multiple sections:
1. **Statistics** (Top)
2. **LC Validation** (Left side)
3. **Demo Audit** (Right side)
4. **Health Check** (Left side)
5. **Custom Audit** (Full width)
6. **🔬 Advanced Forensic Audit** ← **YOU ARE HERE** (Scroll down to see this)

### Step 3: Look for This Section

```
┌─────────────────────────────────────────────────────┐
│  🔬 Advanced Forensic Audit (UCP 600)               │
│                                                     │
│  Forensic-level compliance checking with           │
│  automatic spelling fixes and corrected LC download │
│                                                     │
│  [Paste LC Text Here]                              │
│  [Paste Invoice Text Here]                         │
│                                                     │
│  [Run Advanced Audit Button]                       │
│                                                     │
│  [Results Box]                                     │
│  [Download Corrected LC Button] ← HERE!            │
└─────────────────────────────────────────────────────┘
```

---

## 📍 Exact Location

### In Your Browser:
1. Open: `http://localhost:8080/web_tester.html`
2. **Scroll down** past:
   - Statistics cards
   - LC Validation section
   - Demo Audit section
   - Health Check section
   - Custom Audit section
3. You'll see: **"🔬 Advanced Forensic Audit (UCP 600)"**
4. Below that is the **"Download Corrected LC"** button

---

## 🎯 How to Use the Download Button

### Step 1: Scroll to Advanced Forensic Audit
```
Scroll down on the page
```

### Step 2: Paste LC with Spelling Errors
```
Example:
LETTER OF CREDIT
LC Number: LC-2025-001
Benificiary: Assam Tea Exports Ltd  ← Spelling error
Applicant: Global Imports Inc
Amout: USD 50,000  ← Spelling error
```

### Step 3: Paste Invoice
```
Paste your invoice text
```

### Step 4: Click "Run Advanced Audit"
```
System will:
- Fix spelling errors (Benificiary → Beneficiary)
- Run 6 compliance tests
- Detect discrepancies
- Calculate risk score
- Show results
```

### Step 5: Click "Download Corrected LC"
```
The button will appear after audit completes
Click it to download corrected_lc.txt
```

---

## 📊 What You'll See

### After Clicking "Run Advanced Audit":

```
AUDIT SUMMARY: COMPLIANT - No discrepancies found

Risk Score: 0/100

Logic Checks:
  - MATH CHECK: PASS
  - DATE LOGIC: PASS
  - INCOTERM LOGIC: PASS
  - INDIAN COMPLIANCE: PASS

Discrepancies: 0 total
  - Critical: 0
  - Major: 0
  - Minor: 0

[Download Corrected LC] ← Button appears here!
```

---

## 🔧 Spelling Errors That Get Fixed

When you paste an LC with these errors, they are automatically corrected:

| Misspelled | Corrected |
|-----------|-----------|
| Benificiary | Beneficiary |
| Amout | Amount |
| Curency | Currency |
| Descripion | Description |
| Shipement | Shipment |
| Aloud | Allowed |
| Transihment | Transshipment |
| Discrepency | Discrepancy |
| And 22 more... | |

---

## 📥 Download File Details

### What You Get:
- **Filename:** `corrected_lc.txt`
- **Format:** Plain text
- **Content:** LC with all spelling errors fixed
- **Location:** Your Downloads folder

### Example Download:
```
LETTER OF CREDIT
LC Number: LC-2025-001
Beneficiary: Assam Tea Exports Ltd  ← Fixed!
Applicant: Global Imports Inc
Amount: USD 50,000  ← Fixed!
Currency: USD
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Latest Shipment Date: 31-12-2025
Expiry Date: 31-01-2026
```

---

## ✅ Checklist

- [ ] Open http://localhost:8080/web_tester.html
- [ ] Scroll down to find "Advanced Forensic Audit"
- [ ] Paste LC with spelling errors
- [ ] Paste Invoice
- [ ] Click "Run Advanced Audit"
- [ ] Wait for results
- [ ] Click "Download Corrected LC"
- [ ] Check Downloads folder for corrected_lc.txt

---

## 🆘 Troubleshooting

### Issue: Can't find Advanced Forensic Audit section
**Solution:** Scroll down more. It's at the bottom of the page.

### Issue: Download button doesn't appear
**Solution:** Make sure audit completes successfully. Button appears after results.

### Issue: Download doesn't work
**Solution:** 
- Check browser console (F12)
- Try a different browser
- Clear browser cache

### Issue: Spelling errors not fixed
**Solution:** 
- Check if error is in the 30+ list
- Refresh page and try again
- Check backend is running (port 8000)

---

## 🚀 Quick Start

```
1. http://localhost:8080/web_tester.html
2. Scroll down
3. Find "Advanced Forensic Audit"
4. Paste LC + Invoice
5. Click "Run Advanced Audit"
6. Click "Download Corrected LC"
7. Done! File downloads
```

---

## 📞 System Status

✅ **Backend Server:** Running on port 8000
✅ **Web Tester:** Running on port 8080
✅ **Advanced Auditor:** Active and working
✅ **Download Feature:** Active and working
✅ **Spelling Fixer:** Active and working

---

**Everything is working! Just scroll down to find the Advanced Forensic Audit section.** 🎉
