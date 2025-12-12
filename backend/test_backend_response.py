#!/usr/bin/env python3
"""Test backend response format"""

import sys
sys.path.insert(0, '.')

from utils.advanced_lc_auditor import AdvancedLCAuditor
import json

auditor = AdvancedLCAuditor()

# Test with perfect LC
lc_text = """LETTER OF CREDIT
LC Number: LC-2025-001
Beneficiary: Assam Tea Exports Ltd
Applicant: Global Imports Inc
Amount: USD 50,000
Currency: USD
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Latest Shipment Date: 31-12-2025
Expiry Date: 31-01-2026
Port of Loading: Nhava Sheva
Incoterm: FOB"""

invoice_text = """COMMERCIAL INVOICE
Invoice Number: INV-2025-001
Invoice Date: 15-12-2025
Issuer: Assam Tea Exports Ltd
Buyer: Global Imports Inc
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Quantity: 1000 KGS
Unit Price: USD 50
Total Amount: USD 50,000
Shipment Date: 10-12-2025
Port of Loading: Nhava Sheva
GSTIN: 18AABCT1234A1Z0
IEC: 0712345678
HSN Code: 090240"""

print("=" * 80)
print("TESTING BACKEND RESPONSE FORMAT")
print("=" * 80)

result = auditor.audit(lc_text, invoice_text)

print("\nResponse Type:", type(result))
print("\nResponse Keys:", list(result.keys()) if isinstance(result, dict) else "Not a dict!")

print("\nFull Response:")
print(json.dumps(result, indent=2, default=str))

print("\n" + "=" * 80)
print("CHECKING REQUIRED FIELDS")
print("=" * 80)

required_fields = [
    'audit_summary',
    'risk_score',
    'logic_checks',
    'discrepancies',
    'total_discrepancies',
    'critical_count',
    'major_count',
    'minor_count',
    'corrected_lc'
]

for field in required_fields:
    if field in result:
        value = result[field]
        if isinstance(value, str) and len(value) > 100:
            print(f"✅ {field}: Present (length: {len(value)})")
        else:
            print(f"✅ {field}: {value}")
    else:
        print(f"❌ {field}: MISSING!")

print("\n" + "=" * 80)
print("TEST COMPLETE")
print("=" * 80)
