# LC Validation & Error Detection Guide

## Overview

The ExportSafe AI system now includes an **LC Validator** that automatically:
1. ✅ Detects errors in Letter of Credit documents
2. 🔍 Identifies missing or invalid fields
3. 💡 Suggests automatic fixes
4. 📋 Provides detailed error reports

---

## How to Use LC Validation

### Step 1: Access the Web Tester
Open your browser and go to: `http://localhost:8080/web_tester.html`

### Step 2: Click "LC Validation" Tab
You'll see a text area with a sample LC. You can:
- Use the sample LC to test
- Paste your own LC document
- Upload an LC file

### Step 3: Click "Validate LC"
The system will analyze your LC and return:
- ✅ **If Valid**: "LC IS PERFECT!" message
- ⚠️ **If Invalid**: List of errors found with suggestions
- 🔧 **Auto-Fixes**: Automatic fixes available

---

## Error Types Detected

### 1. **MISSING_FIELD** (Critical)
**What it is:** Required field is not found in the LC
**Example:** LC Number, Beneficiary, Amount, etc.
**Auto-Fix:** Suggests adding the missing field

### 2. **INVALID_FORMAT** (High/Critical)
**What it is:** Field exists but has wrong format
**Examples:**
- LC Number too short (< 3 characters)
- Currency code not valid (e.g., "US" instead of "USD")
- Amount without numbers

**Auto-Fix:** Suggests correct format

### 3. **DATE_ERROR** (Critical)
**What it is:** Date-related issues
**Examples:**
- Expiry date is before shipment date
- Only a few days between shipment and expiry

**Auto-Fix:** Suggests extending expiry date

### 4. **AMOUNT_ERROR** (Critical)
**What it is:** Amount-related issues
**Examples:**
- Amount is zero
- Amount is suspiciously small

**Auto-Fix:** Suggests verifying the amount

### 5. **DESCRIPTION_ERROR** (Medium)
**What it is:** Description is incomplete or missing details
**Examples:**
- Description too short
- Missing quantity units (KGS, UNITS, BOXES, etc.)

**Auto-Fix:** Suggests adding quantity and units

---

## Severity Levels

| Level | Meaning | Action |
|-------|---------|--------|
| **CRITICAL** | Must be fixed before LC can be used | Fix immediately |
| **HIGH** | Should be fixed to avoid issues | Fix before submission |
| **MEDIUM** | Should be reviewed | Review and fix if needed |

---

## Auto-Fixes Available

### Fix 1: Add Currency to Amount
**Problem:** Amount shows "50,000" but currency is separate
**Fix:** Change to "USD 50,000"

### Fix 2: Standardize Date Format
**Problem:** Dates in different formats (1/15/2025, 15-01-2025, etc.)
**Fix:** Convert all to DD-MM-YYYY format

### Fix 3: Add Missing Fields
**Problem:** Required field is completely missing
**Fix:** Insert field with template

### Fix 4: Validate Currency Codes
**Problem:** Currency code might not be valid
**Fix:** Confirm it's a valid ISO 4217 code (USD, EUR, GBP, etc.)

---

## Example Validation Results

### ✅ Perfect LC
```
✅ LC IS PERFECT!

Status: COMPLIANT
All required fields present and valid
```

### ⚠️ LC with Errors
```
⚠️ LC CONTAINS ERRORS

Errors Found:
1. MISSING_FIELD: Beneficiary is missing
   💡 Fix: Add Beneficiary to the LC document

2. INVALID_FORMAT: Currency "US" is not a valid ISO code
   💡 Fix: Use valid 3-letter currency code (USD, EUR, GBP, etc.)

3. DATE_ERROR: Expiry Date (31-12-2025) is before Shipment Date (15-01-2026)
   💡 Fix: Expiry Date must be after Shipment Date

🔧 AUTO-FIXES AVAILABLE:
1. Add missing Beneficiary
   Action: Insert Beneficiary field in LC document

2. Standardize currency code
   Action: Confirm "US" is a valid ISO 4217 currency code

3. Fix date order
   Action: Ensure Expiry Date is after Shipment Date
```

---

## Required Fields

Every valid LC must contain:

| Field | Description | Example |
|-------|-------------|---------|
| **LC Number** | Unique identifier | LC-2025-001 |
| **Beneficiary** | Who receives payment | Assam Tea Exports Ltd |
| **Applicant** | Who applies for LC | Global Imports Inc |
| **Amount** | Credit amount | USD 50,000 |
| **Currency** | Currency code | USD |
| **Description** | What's being shipped | 1000 KGS ASSAM TEA |
| **Shipment Date** | When goods ship | 31-12-2025 |
| **Expiry Date** | When LC expires | 31-01-2026 |

---

## Validation API Endpoint

### Request
```bash
POST http://localhost:8000/validate/lc
Content-Type: application/json

{
  "lc_text": "LETTER OF CREDIT\nLC Number: LC-2025-001\n..."
}
```

### Response
```json
{
  "is_valid": false,
  "errors": [
    {
      "type": "MISSING_FIELD",
      "field": "beneficiary",
      "message": "Beneficiary is missing",
      "severity": "CRITICAL",
      "suggestion": "Add Beneficiary to the LC document"
    }
  ],
  "auto_fixes": [
    {
      "type": "MISSING_FIELD_FIX",
      "description": "Add missing Beneficiary",
      "action": "Insert Beneficiary field in LC document",
      "priority": "CRITICAL"
    }
  ],
  "extracted_fields": {
    "lc_number": "LC-2025-001",
    "beneficiary": null,
    "applicant": "Global Imports Inc",
    ...
  },
  "total_errors": 1,
  "total_auto_fixes": 1
}
```

---

## Best Practices

### ✅ DO:
- Use standard field names (LC Number, Beneficiary, etc.)
- Use valid 3-letter currency codes (USD, EUR, GBP)
- Ensure expiry date is after shipment date
- Include quantity units in description (KGS, UNITS, BOXES)
- Use consistent date format (DD-MM-YYYY)

### ❌ DON'T:
- Leave required fields empty
- Use invalid currency codes
- Have expiry before shipment
- Use vague descriptions
- Mix date formats

---

## Workflow for Users

```
1. Paste or Upload LC
   ↓
2. Click "Validate LC"
   ↓
3. Check Results
   ├─ If Valid → Ready to use ✅
   └─ If Invalid → Review Errors
       ↓
4. Review Error List
   ├─ Read error message
   ├─ Check suggestion
   └─ Apply fix
       ↓
5. Re-validate
   ├─ If Valid → Ready to use ✅
   └─ If Still Invalid → Repeat steps 4-5
```

---

## Common Issues & Solutions

### Issue: "LC Number is too short"
**Cause:** LC Number has less than 3 characters
**Solution:** Use a longer, more descriptive LC Number (e.g., LC-2025-001)

### Issue: "Currency is not a valid ISO code"
**Cause:** Currency is abbreviated incorrectly (e.g., "US" instead of "USD")
**Solution:** Use valid 3-letter code: USD, EUR, GBP, JPY, INR, AUD, CAD, CHF, CNY, SEK

### Issue: "Expiry Date is before Shipment Date"
**Cause:** Dates are in wrong order
**Solution:** Ensure expiry date is after shipment date

### Issue: "Amount is zero"
**Cause:** Amount field contains 0
**Solution:** Enter valid amount greater than zero

### Issue: "Description does not include quantity units"
**Cause:** Description lacks units like KGS, UNITS, BOXES
**Solution:** Add quantity and units (e.g., "1000 KGS ASSAM TEA")

---

## Next Steps

After validation:
1. ✅ Fix any errors found
2. 📋 Re-validate to confirm
3. 🔄 Run full audit against invoice
4. 📊 View detailed discrepancy report

---

## Support

For issues or questions:
1. Check the error message and suggestion
2. Review this guide for the error type
3. Apply the suggested auto-fix
4. Re-validate to confirm

**Status:** ✅ LC Validation System Active
**Version:** 1.0
**Last Updated:** December 8, 2025
