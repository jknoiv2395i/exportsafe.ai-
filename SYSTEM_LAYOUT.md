# Web Tester Layout - Where Everything Is Located

## 📱 Page Layout (Top to Bottom)

```
┌─────────────────────────────────────────────────────────────┐
│                   EXPORTSAFE AI - WEB TESTER                │
│                                                             │
│  Statistics Cards (Top)                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Total Audits: 3 │ Passed: 3 │ Failed: 0 │ Avg: 774ms │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌──────────────────────┬──────────────────────┐            │
│  │                      │                      │            │
│  │  ✅ LC VALIDATION    │  📝 DEMO AUDIT       │            │
│  │  (Left side)         │  (Right side)        │            │
│  │                      │                      │            │
│  │  [Validate LC]       │  [Run Demo Audit]    │            │
│  │                      │                      │            │
│  │  [Results]           │  [Results]           │            │
│  │                      │                      │            │
│  └──────────────────────┴──────────────────────┘            │
│                                                             │
│  ┌──────────────────────┐                                   │
│  │  🏥 HEALTH CHECK     │                                   │
│  │  (Left side)         │                                   │
│  │                      │                                   │
│  │  [Check Health]      │                                   │
│  │  [Results]           │                                   │
│  └──────────────────────┘                                   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  📝 CUSTOM AUDIT (Full width)                       │   │
│  │  [LC Tab] [Invoice Tab] [Upload Files Tab]          │   │
│  │                                                     │   │
│  │  [Paste LC Text]                                    │   │
│  │  [Paste Invoice Text]                               │   │
│  │                                                     │   │
│  │  [Run Custom Audit]                                 │   │
│  │  [Results]                                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  🔬 ADVANCED FORENSIC AUDIT (UCP 600) ← YOU ARE HERE│   │
│  │  (Full width - SCROLL DOWN TO SEE THIS)             │   │
│  │                                                     │   │
│  │  Forensic-level compliance checking with            │   │
│  │  automatic spelling fixes and corrected LC download │   │
│  │                                                     │   │
│  │  [Paste LC Text]                                    │   │
│  │  [Paste Invoice Text]                               │   │
│  │                                                     │   │
│  │  [Run Advanced Audit]                               │   │
│  │                                                     │   │
│  │  [Results Box]                                      │   │
│  │  ┌─────────────────────────────────────────────┐   │   │
│  │  │ AUDIT SUMMARY: COMPLIANT                    │   │   │
│  │  │ Risk Score: 0/100                           │   │   │
│  │  │ Logic Checks: PASS/PASS/PASS/PASS           │   │   │
│  │  │ Discrepancies: 0                            │   │   │
│  │  └─────────────────────────────────────────────┘   │   │
│  │                                                     │   │
│  │  [Download Corrected LC] ← DOWNLOAD BUTTON HERE!   │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 Where to Find Download Button

### Current View (From Your Screenshot)
```
You are seeing:
- Statistics cards (top)
- LC Validation section (left)
- Demo Audit section (right)
- Health Check section (left)
- Custom Audit section (full width)
```

### What You Need to Do
```
SCROLL DOWN ↓↓↓
```

### After Scrolling Down
```
You will see:
- 🔬 Advanced Forensic Audit (UCP 600)
  - Paste LC Text
  - Paste Invoice Text
  - [Run Advanced Audit] button
  - Results box
  - [Download Corrected LC] button ← HERE!
```

---

## 📍 Navigation Guide

### Step 1: Current Position
```
You are at the top of the page
Seeing: Statistics, LC Validation, Demo Audit, Health Check
```

### Step 2: Scroll Down
```
Scroll down past the Custom Audit section
```

### Step 3: Find Advanced Forensic Audit
```
You'll see: "🔬 Advanced Forensic Audit (UCP 600)"
```

### Step 4: Use the Section
```
1. Paste LC with spelling errors
2. Paste Invoice
3. Click "Run Advanced Audit"
4. Wait for results
5. Click "Download Corrected LC"
```

---

## 🔍 Visual Indicators

### Look for These Text Labels:
- **"🔬 Advanced Forensic Audit (UCP 600)"** ← Section header
- **"Forensic-level compliance checking..."** ← Section description
- **"Run Advanced Audit"** ← Button to run audit
- **"Download Corrected LC"** ← Download button (appears after audit)

---

## 📊 Section Details

### Advanced Forensic Audit Section Contains:

1. **Section Title**
   ```
   🔬 Advanced Forensic Audit (UCP 600)
   ```

2. **Description**
   ```
   Forensic-level compliance checking with automatic spelling 
   fixes and corrected LC download
   ```

3. **Input Fields**
   ```
   - Letter of Credit (Paste Text)
   - Commercial Invoice (Paste Text)
   ```

4. **Action Button**
   ```
   [Run Advanced Audit]
   ```

5. **Results Box**
   ```
   Shows:
   - Audit Summary
   - Risk Score
   - Logic Checks
   - Discrepancies
   ```

6. **Download Button** (Appears after audit)
   ```
   [Download Corrected LC]
   ```

---

## ✅ Verification Checklist

- [ ] Web Tester is open: http://localhost:8080/web_tester.html
- [ ] Backend server is running on port 8000
- [ ] You can see Statistics cards at the top
- [ ] You can see LC Validation section
- [ ] You can see Demo Audit section
- [ ] You can see Custom Audit section
- [ ] You need to SCROLL DOWN to see Advanced Forensic Audit
- [ ] After scrolling, you'll see the Download button

---

## 🚀 Quick Navigation

### Using Keyboard:
```
Press: Ctrl + End (Jump to bottom of page)
Or: Scroll wheel down multiple times
```

### Using Mouse:
```
Click and drag scrollbar to bottom
Or: Use scroll wheel to scroll down
```

---

## 📝 What Happens When You Click Download

1. **Before Audit:**
   - Download button is hidden

2. **During Audit:**
   - Button shows "Running Advanced Audit..."
   - Processing the LC and Invoice

3. **After Audit:**
   - Results appear in box
   - Download button appears (green button)
   - Shows: "Download Corrected LC"

4. **When You Click Download:**
   - File `corrected_lc.txt` downloads
   - Contains corrected LC with all spelling fixes
   - Appears in your Downloads folder

---

## 🎓 Example Flow

```
1. Open: http://localhost:8080/web_tester.html
   ↓
2. Scroll down to Advanced Forensic Audit section
   ↓
3. Paste LC:
   LETTER OF CREDIT
   LC Number: LC-2025-001
   Benificiary: Assam Tea Exports Ltd  ← Error
   Amout: USD 50,000  ← Error
   ↓
4. Paste Invoice
   ↓
5. Click "Run Advanced Audit"
   ↓
6. System fixes spelling errors:
   Benificiary → Beneficiary
   Amout → Amount
   ↓
7. Results show:
   AUDIT SUMMARY: COMPLIANT
   Risk Score: 0/100
   ↓
8. Click "Download Corrected LC"
   ↓
9. File downloads: corrected_lc.txt
   ↓
10. Open file to see corrected LC:
    LETTER OF CREDIT
    LC Number: LC-2025-001
    Beneficiary: Assam Tea Exports Ltd  ← Fixed!
    Amount: USD 50,000  ← Fixed!
```

---

## 🆘 If You Still Can't Find It

### Check These:
1. **Browser:** Are you using http://localhost:8080/web_tester.html?
2. **Scroll:** Have you scrolled all the way down?
3. **Backend:** Is port 8000 running?
4. **Cache:** Try Ctrl+F5 to refresh

### Try This:
```
Press Ctrl+F (Find)
Type: "Advanced Forensic"
Press Enter
Browser will jump to the section
```

---

**The Download Button is there! Just scroll down to find it!** 🎉
