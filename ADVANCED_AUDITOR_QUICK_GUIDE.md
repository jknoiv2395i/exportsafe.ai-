# Advanced LC Auditor - Quick Reference Guide

## 🚀 Quick Start

### API Endpoint
```bash
POST http://localhost:8000/audit/advanced
```

### Request Format
```json
{
  "lc_text": "LETTER OF CREDIT\nLC Number: ...",
  "invoice_text": "INVOICE\nInvoice Number: ..."
}
```

### Response Format
```json
{
  "audit_summary": "FATAL DISCREPANCIES FOUND - X Critical, Y Major",
  "risk_score": 0-100,
  "logic_checks": {
    "math_check": "PASS/FAIL",
    "date_logic": "PASS/FAIL",
    "incoterm_logic": "PASS/FAIL",
    "indian_compliance": "PASS/FAIL"
  },
  "discrepancies": [...],
  "total_discrepancies": N,
  "critical_count": N,
  "major_count": N,
  "minor_count": N
}
```

---

## 6 Forensic Tests

### 1️⃣ MIRROR MATCH TEST
**What:** Description of Goods must match exactly
**Severity:** CRITICAL
**Checks:**
- Letter-for-letter comparison
- Singular/plural mismatches
- Extra adjectives
- Punctuation differences

**Example:**
```
LC: "1000 KGS ASSAM TEA BLACK CTC"
Invoice: "1000 KGS ASSAM TEA"
Result: CRITICAL - Mismatch
```

---

### 2️⃣ MATHEMATICAL INTEGRITY TEST
**What:** Amount and calculation validation
**Severity:** CRITICAL
**Checks:**
- Quantity × Unit Price = Total Amount
- Amount tolerance (±10% if "About" specified)
- Rounding errors (max 0.01)

**Example:**
```
LC Amount: USD 50,000
Invoice Amount: USD 51,000
Tolerance: None specified
Result: CRITICAL - Amount exceeded
```

---

### 3️⃣ TEMPORAL LOGIC TEST
**What:** Date sequence validation
**Severity:** CRITICAL
**Checks:**
- Invoice Date ≤ Shipment Date
- Shipment Date ≤ Latest Shipment Date (LC)
- Presentation Date ≤ Expiry Date
- 21-day stale document rule

**Example:**
```
Invoice Date: 15-01-2026
Shipment Date: 31-12-2025
Result: CRITICAL - Invoice after shipment
```

---

### 4️⃣ GEOSPATIAL TEST
**What:** Port and transshipment validation
**Severity:** CRITICAL/MAJOR
**Checks:**
- Port of loading matching
- Port validity (e.g., "Any Indian Port")
- Transshipment clause compliance

**Example:**
```
LC Port: Nhava Sheva
Invoice Port: Mumbai
Result: CRITICAL - Port mismatch
```

---

### 5️⃣ INCOTERM CONSISTENCY TEST
**What:** Freight and insurance validation
**Severity:** MAJOR
**Checks:**
- FOB: No freight/insurance
- CIF: Must have freight and insurance
- CFR: Must have freight

**Example:**
```
LC: FOB
Invoice: Contains freight charges
Result: MAJOR - FOB shouldn't have freight
```

---

### 6️⃣ INDIAN REGULATORY CHECK
**What:** GST, IEC, HSN, FEMA compliance
**Severity:** MAJOR
**Checks:**
- GSTIN: 15-digit format
- IEC Code: Present and valid
- HSN Code: 6-8 digits
- IGST: Not charged under LUT/Bond
- FEMA: Payment terms ≤ 9 months

**Example:**
```
GSTIN: Missing
IEC: Missing
HSN: Missing
Result: MAJOR - Multiple compliance issues
```

---

## Risk Score Guide

```
Risk Score = (Critical × 30) + (Major × 15) + (Minor × 5)
Maximum: 100
```

| Score | Risk Level | Action |
|-------|-----------|--------|
| 0-20 | LOW | ✅ Approve |
| 21-50 | MEDIUM | 🔍 Review |
| 51-80 | HIGH | ⚠️ Amendment needed |
| 81-100 | CRITICAL | ❌ Reject |

---

## Severity Levels

| Level | Impact | Points | Action |
|-------|--------|--------|--------|
| **CRITICAL** | Fatal discrepancy | +30 | REJECT |
| **MAJOR** | Significant issue | +15 | AMEND |
| **MINOR** | Minor variation | +5 | REVIEW |

---

## Discrepancy Categories

| Category | Checks | Severity |
|----------|--------|----------|
| **TEXT** | Description mismatches | CRITICAL |
| **MATH** | Amount/calculation errors | CRITICAL |
| **DATE** | Date logic violations | CRITICAL |
| **COMPLIANCE** | Port, incoterm, transshipment | MAJOR |
| **INDIAN_REGULATORY** | GST, IEC, HSN, FEMA | MAJOR |

---

## Audit Summary Verdicts

### ✅ COMPLIANT
```
"audit_summary": "COMPLIANT - No discrepancies found"
"risk_score": 0
"discrepancies": []
Action: APPROVE PAYMENT
```

### ⚠️ MINOR ISSUES
```
"audit_summary": "MINOR DISCREPANCIES FOUND - 2 minor issues"
"risk_score": 10
"minor_count": 2
Action: REVIEW AND APPROVE
```

### 🔴 MAJOR ISSUES
```
"audit_summary": "MAJOR DISCREPANCIES FOUND - 2 major issues"
"risk_score": 30
"major_count": 2
Action: REQUIRE AMENDMENT
```

### ❌ FATAL ISSUES
```
"audit_summary": "FATAL DISCREPANCIES FOUND - 1 Critical, 2 Major"
"risk_score": 75
"critical_count": 1
"major_count": 2
Action: REJECT PAYMENT
```

---

## Common Discrepancies

### Description Mismatches
```
LC: "1000 KGS ASSAM TEA BLACK CTC"
Invoice: "1000 KGS ASSAM TEA"
Fix: Add "BLACK CTC" to invoice description
```

### Amount Exceeded
```
LC: USD 50,000
Invoice: USD 51,000
Fix: Reduce invoice amount to USD 50,000
```

### Date Logic Error
```
Invoice Date: 15-01-2026
Shipment Date: 31-12-2025
Fix: Change invoice date to on or before 31-12-2025
```

### Port Mismatch
```
LC: Nhava Sheva
Invoice: Mumbai
Fix: Change to Nhava Sheva or get LC amendment
```

### Incoterm Mismatch
```
LC: FOB
Invoice: CIF (with freight)
Fix: Change to FOB and remove freight charges
```

### Missing GSTIN
```
GSTIN: Not found
Fix: Add GSTIN in format: XX AAAPG0000XXXXX
```

---

## Logic Checks

| Check | What It Validates | Status |
|-------|------------------|--------|
| **math_check** | Amount, quantity, calculations | PASS/FAIL |
| **date_logic** | Date sequences, temporal rules | PASS/FAIL |
| **incoterm_logic** | Freight, insurance consistency | PASS/FAIL |
| **indian_compliance** | GST, IEC, HSN, FEMA rules | PASS/FAIL |

---

## Compliance Standards

### UCP 600 Articles
- **Article 14:** Data consistency
- **Article 18:** Description matching
- **Article 20:** Transshipment
- **Article 30:** Amount tolerance
- **Article 44C:** Latest shipment date
- **Article 44E:** Port of loading

### ISBP 745
- Strict compliance doctrine
- Document consistency rules

### Indian Regulations
- GST (GSTIN validation)
- RBI/FEMA (IEC, payment terms)
- Customs (HSN code)
- Export rules (LUT/Bond)

---

## Example Audit Report

### Input
```json
{
  "lc_text": "LC Number: LC-2025-001\nDescription: 1000 KGS ASSAM TEA BLACK CTC\nAmount: USD 50,000",
  "invoice_text": "Invoice Number: INV-001\nDescription: 1000 KGS ASSAM TEA\nAmount: USD 50,000"
}
```

### Output
```json
{
  "audit_summary": "FATAL DISCREPANCIES FOUND - 1 Critical",
  "risk_score": 30,
  "logic_checks": {
    "math_check": "FAIL",
    "date_logic": "PASS",
    "incoterm_logic": "PASS",
    "indian_compliance": "PASS"
  },
  "discrepancies": [
    {
      "severity": "CRITICAL",
      "category": "TEXT",
      "field": "Description of Goods",
      "lc_requirement": "1000 KGS ASSAM TEA BLACK CTC",
      "document_value": "1000 KGS ASSAM TEA",
      "violation_rule": "UCP 600 Article 18",
      "explanation": "Description mismatch - fatal discrepancy",
      "suggested_fix": "Change to: 1000 KGS ASSAM TEA BLACK CTC"
    }
  ],
  "total_discrepancies": 1,
  "critical_count": 1,
  "major_count": 0,
  "minor_count": 0
}
```

---

## Decision Matrix

| Risk Score | Discrepancies | Decision |
|-----------|---------------|----------|
| 0 | None | ✅ APPROVE |
| 1-20 | Minor only | ✅ APPROVE |
| 21-50 | Major only | ⚠️ REVIEW |
| 51-80 | Major + Minor | ⚠️ AMEND |
| 81-100 | Critical | ❌ REJECT |

---

## Quick Troubleshooting

### Issue: "Description mismatch detected"
**Solution:** Ensure invoice description matches LC exactly, character-for-character

### Issue: "Amount exceeded"
**Solution:** Reduce invoice amount to not exceed LC amount (unless tolerance specified)

### Issue: "Date logic error"
**Solution:** Ensure invoice date ≤ shipment date ≤ LC latest shipment date

### Issue: "Port mismatch"
**Solution:** Change invoice port to match LC requirement

### Issue: "Incoterm mismatch"
**Solution:** Change invoice incoterm to match LC

### Issue: "Missing GSTIN/IEC/HSN"
**Solution:** Add required Indian compliance fields to invoice

---

## Status: PRODUCTION READY ✅

The Advanced LC Auditor is fully operational and ready for:
- ✅ Forensic-level compliance auditing
- ✅ UCP 600 enforcement
- ✅ Indian regulatory compliance
- ✅ Risk assessment
- ✅ Payment authorization

---

**Last Updated:** December 8, 2025
**Version:** 1.0
**Standards:** UCP 600, ISBP 745, RBI/FEMA/GST
