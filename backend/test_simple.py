#!/usr/bin/env python3
"""Simple test to verify audit engine works"""

import sys
sys.path.insert(0, '.')

from utils.audit_engine import AuditEngine

# Test data
lc_text = """
LETTER OF CREDIT
LC Number: LC-2025-001
Beneficiary: Assam Tea Exports Ltd
Applicant: Global Imports Inc
Amount: USD 50,000
Currency: USD
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Latest Shipment Date: 31-12-2025
Expiry Date: 31-01-2026
"""

invoice_text = """
COMMERCIAL INVOICE
Invoice Number: INV-2025-001
Invoice Date: 15-12-2025
Issuer: Assam Tea Exports Ltd
Buyer: Global Imports Inc
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Quantity: 1000 KGS
Unit Price: USD 50
Total Amount: USD 50,000
Shipment Date: 10-12-2025
"""

try:
    print("Initializing Audit Engine...")
    engine = AuditEngine()
    
    print("Running audit...")
    result = engine.audit(lc_text, invoice_text)
    
    print("\n✅ AUDIT RESULT:")
    print(f"Status: {result.get('status')}")
    print(f"Risk Score: {result.get('risk_score')}")
    print(f"Discrepancies: {len(result.get('discrepancies', []))}")
    print(f"\nFull Result:\n{result}")
    
except Exception as e:
    print(f"\n❌ ERROR: {e}")
    import traceback
    traceback.print_exc()
