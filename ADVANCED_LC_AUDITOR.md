# Advanced LC Auditor - Forensic-Level Trade Finance Compliance ✅

## Overview

The **Advanced LC Auditor** implements forensic-level compliance checking following:
- ✅ **UCP 600** (Uniform Customs and Practice for Documentary Credits)
- ✅ **ISBP 745** (International Standard Banking Practice)
- ✅ **Doctrine of Strict Compliance**
- ✅ **Indian RBI/FEMA/GST Regulations**

---

## Six Core Audit Tests

### TEST 1: THE "MIRROR MATCH" TEST (Critical)
**Purpose:** Verify Description of Goods matches exactly

**What It Checks:**
- Letter-for-letter comparison
- Singular/Plural mismatches (e.g., "Pcs" vs "Pc")
- Extra adjectives (e.g., "Glazed Ceramic Tiles" vs "Ceramic Tiles")
- Punctuation mismatches (e.g., "Grade A" vs "Grade-A")

**Violation Rule:** UCP 600 Article 18 - Doctrine of Strict Compliance

**Example:**
```
LC: "1000 KGS ASSAM TEA BLACK CTC"
Invoice: "1000 KGS ASSAM TEA"
Result: CRITICAL - Description mismatch
```

---

### TEST 2: THE MATHEMATICAL INTEGRITY TEST
**Purpose:** Validate amounts and calculations

**What It Checks:**
- Quantity × Unit Price = Total Amount
- Rounding errors (max 0.01 tolerance)
- Amount tolerance (Article 30):
  - If LC says "About" or "Circa": Allow ±10%
  - If NOT stated: Amount must NOT be exceeded

**Violation Rule:** UCP 600 Article 30 - Amount Tolerance

**Example:**
```
LC Amount: USD 50,000
Invoice Amount: USD 51,000
Tolerance: Not specified
Result: CRITICAL - Amount exceeded
```

---

### TEST 3: THE TEMPORAL LOGIC TEST (Dates)
**Purpose:** Verify all dates are in correct sequence

**Rules:**
- **Rule A:** Invoice Date ≤ Shipment Date
- **Rule B:** Shipment Date ≤ Latest Shipment Date (LC)
- **Rule C:** Presentation Date ≤ Expiry Date
- **Rule D:** Stale Documents (21-day rule)

**Violation Rule:** UCP 600 Article 14c - Temporal Logic

**Example:**
```
Invoice Date: 15-01-2026
Shipment Date: 31-12-2025
Result: CRITICAL - Invoice date after shipment
```

---

### TEST 4: THE GEOSPATIAL TEST (Ports)
**Purpose:** Verify port specifications and transshipment

**What It Checks:**
- Port of Loading matches LC requirement
- Port is valid (e.g., if "Any Indian Port", verify it's in India)
- Transshipment clauses:
  - If LC says "Not allowed", flag any transshipment mention

**Violation Rule:** UCP 600 Article 44E - Port Specification

**Example:**
```
LC: "Port of Loading: Nhava Sheva"
Invoice: "Port of Loading: Mumbai"
Result: CRITICAL - Port mismatch
```

---

### TEST 5: INCOTERM CONSISTENCY
**Purpose:** Verify freight and insurance charges match incoterm

**Rules:**
- **FOB:** No freight/insurance in invoice
- **CIF:** MUST include freight and insurance
- **CFR:** MUST include freight

**Violation Rule:** Incoterm Rules

**Example:**
```
LC Incoterm: FOB
Invoice: Contains freight charges
Result: MAJOR - FOB should not have freight
```

---

### TEST 6: INDIAN REGULATORY CHECK
**Purpose:** Verify GST, IEC, HSN, and FEMA compliance

**What It Checks:**
- **GSTIN:** Valid 15-digit format
- **IEC Code:** Importer-Exporter Code present
- **HSN Code:** 6-8 digit Harmonized System code
- **IGST:** Not charged under LUT/Bond
- **FEMA:** Payment terms ≤ 9 months

**Violation Rule:** RBI/FEMA/GST Compliance

**Example:**
```
GSTIN: Missing
IEC: Missing
HSN: Missing
Result: MAJOR - Indian compliance issues
```

---

## Error Severity Levels

| Level | Impact | Action |
|-------|--------|--------|
| **CRITICAL** | Fatal discrepancy | REJECT payment |
| **MAJOR** | Significant issue | Require amendment |
| **MINOR** | Minor variation | Review and approve |

---

## Risk Score Calculation

```
Risk Score = (Critical × 30) + (Major × 15) + (Minor × 5)
Maximum: 100
```

**Score Interpretation:**
- **0-20:** Low risk - Approve
- **21-50:** Medium risk - Review required
- **51-80:** High risk - Amendment needed
- **81-100:** Critical risk - Reject

---

## API Usage

### Request
```bash
POST http://localhost:8000/audit/advanced
Content-Type: application/json

{
  "lc_text": "LETTER OF CREDIT\nLC Number: LC-2025-001\n...",
  "invoice_text": "INVOICE\nInvoice Number: INV-001\n..."
}
```

### Response Format
```json
{
  "audit_summary": "FATAL DISCREPANCIES FOUND - 2 Critical, 1 Major issues",
  "risk_score": 75,
  "logic_checks": {
    "math_check": "FAIL",
    "date_logic": "PASS",
    "incoterm_logic": "FAIL",
    "indian_compliance": "FAIL"
  },
  "discrepancies": [
    {
      "severity": "CRITICAL",
      "category": "TEXT",
      "field": "Description of Goods",
      "lc_requirement": "1000 KGS ASSAM TEA BLACK CTC",
      "document_value": "1000 KGS ASSAM TEA",
      "violation_rule": "UCP 600 Article 18",
      "explanation": "Description in invoice does NOT match LC",
      "suggested_fix": "Change to: 1000 KGS ASSAM TEA BLACK CTC"
    }
  ],
  "total_discrepancies": 3,
  "critical_count": 2,
  "major_count": 1,
  "minor_count": 0
}
```

---

## Discrepancy Categories

| Category | What It Checks | Severity |
|----------|----------------|----------|
| **TEXT** | Description mismatches | CRITICAL |
| **MATH** | Amount/calculation errors | CRITICAL |
| **DATE** | Date logic violations | CRITICAL |
| **COMPLIANCE** | Port, incoterm, transshipment | MAJOR |
| **INDIAN_REGULATORY** | GST, IEC, HSN, FEMA | MAJOR |

---

## Example Audit Report

### Perfect LC vs Invoice
```json
{
  "audit_summary": "COMPLIANT - No discrepancies found",
  "risk_score": 0,
  "logic_checks": {
    "math_check": "PASS",
    "date_logic": "PASS",
    "incoterm_logic": "PASS",
    "indian_compliance": "PASS"
  },
  "discrepancies": [],
  "total_discrepancies": 0,
  "critical_count": 0,
  "major_count": 0,
  "minor_count": 0
}
```

### LC with Discrepancies
```json
{
  "audit_summary": "FATAL DISCREPANCIES FOUND - 1 Critical, 2 Major issues",
  "risk_score": 60,
  "logic_checks": {
    "math_check": "FAIL",
    "date_logic": "PASS",
    "incoterm_logic": "FAIL",
    "indian_compliance": "FAIL"
  },
  "discrepancies": [
    {
      "severity": "CRITICAL",
      "category": "TEXT",
      "field": "Description of Goods",
      "lc_requirement": "1000 KGS ASSAM TEA BLACK CTC",
      "document_value": "1000 KGS ASSAM TEA",
      "violation_rule": "UCP 600 Article 18",
      "explanation": "Description mismatch",
      "suggested_fix": "Change to: 1000 KGS ASSAM TEA BLACK CTC"
    },
    {
      "severity": "MAJOR",
      "category": "MATH",
      "field": "Amount",
      "lc_requirement": "USD 50,000",
      "document_value": "USD 51,000",
      "violation_rule": "UCP 600 Article 30",
      "explanation": "Amount exceeds LC",
      "suggested_fix": "Reduce to USD 50,000 or obtain amendment"
    },
    {
      "severity": "MAJOR",
      "category": "INDIAN_REGULATORY",
      "field": "GSTIN",
      "lc_requirement": "Valid 15-digit GSTIN",
      "document_value": "GSTIN not found",
      "violation_rule": "Indian GST Compliance",
      "explanation": "Missing GSTIN",
      "suggested_fix": "Add GSTIN in format: XX AAAPG0000XXXXX"
    }
  ],
  "total_discrepancies": 3,
  "critical_count": 1,
  "major_count": 2,
  "minor_count": 0
}
```

---

## Key Features

✅ **6 Comprehensive Tests** - All critical compliance areas
✅ **UCP 600 Compliant** - Follows international standards
✅ **Strict Compliance** - Letter-for-letter matching
✅ **Indian Regulations** - GST, IEC, HSN, FEMA checks
✅ **Risk Scoring** - Quantified risk assessment
✅ **Detailed Reports** - Specific violations and fixes
✅ **Automatic Fixes** - Suggested corrections
✅ **JSON Output** - Machine-readable format

---

## Audit Workflow

```
1. User uploads LC and Invoice
   ↓
2. System extracts data from both documents
   ↓
3. Run 6 compliance tests:
   - Mirror Match Test
   - Mathematical Integrity Test
   - Temporal Logic Test
   - Geospatial Test
   - Incoterm Consistency Test
   - Indian Regulatory Check
   ↓
4. Calculate risk score
   ↓
5. Generate audit summary
   ↓
6. Return detailed JSON report
   ↓
7. User reviews discrepancies
   ↓
8. User applies suggested fixes
   ↓
9. Re-audit to confirm compliance
```

---

## Compliance Standards

### UCP 600 Articles
- **Article 14:** Data consistency across documents
- **Article 18:** Description of goods must match exactly
- **Article 20:** Transshipment rules
- **Article 30:** Amount tolerance
- **Article 44C:** Latest shipment date
- **Article 44E:** Port of loading

### Indian Regulations
- **GST Compliance:** GSTIN validation
- **RBI/FEMA:** IEC code, payment terms
- **Customs:** HSN code validation
- **Export Rules:** LUT/Bond provisions

---

## Status: PRODUCTION READY ✅

The Advanced LC Auditor is fully operational and ready for:
- ✅ Forensic-level compliance auditing
- ✅ UCP 600 enforcement
- ✅ Indian regulatory compliance
- ✅ Risk assessment
- ✅ Payment authorization decisions

---

**Last Updated:** December 8, 2025
**Version:** 1.0 (Advanced Forensic Auditor)
**Standards:** UCP 600, ISBP 745, RBI/FEMA/GST
