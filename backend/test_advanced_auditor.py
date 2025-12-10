#!/usr/bin/env python3
"""Test Advanced LC Auditor - Forensic-Level Compliance"""

import sys
sys.path.insert(0, '.')

from utils.advanced_lc_auditor import AdvancedLCAuditor
import json

# Test cases
test_cases = [
    {
        'name': 'Perfect LC vs Invoice (COMPLIANT)',
        'lc': '''LETTER OF CREDIT
LC Number: LC-2025-001
Beneficiary: Assam Tea Exports Ltd
Applicant: Global Imports Inc
Amount: USD 50,000
Currency: USD
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Latest Shipment Date: 31-12-2025
Expiry Date: 31-01-2026
Port of Loading: Nhava Sheva
Incoterm: FOB
Transshipment: Not allowed''',
        'invoice': '''INVOICE
Invoice Number: INV-2025-001
Invoice Date: 25-12-2025
Exporter: Assam Tea Exports Ltd
Importer: Global Imports Inc
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Quantity: 1000 KGS
Unit Price: USD 50
Total Amount: USD 50,000
Shipment Date: 31-12-2025
Port of Loading: Nhava Sheva
Incoterm: FOB
GSTIN: 18AABCT1234A1Z0
IEC: 0712345678
HSN Code: 090240'''
    },
    {
        'name': 'Description Mismatch (CRITICAL)',
        'lc': '''LETTER OF CREDIT
LC Number: LC-2025-002
Beneficiary: Assam Tea Exports Ltd
Applicant: Global Imports Inc
Amount: USD 50,000
Currency: USD
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Latest Shipment Date: 31-12-2025
Expiry Date: 31-01-2026''',
        'invoice': '''INVOICE
Invoice Number: INV-2025-002
Invoice Date: 25-12-2025
Exporter: Assam Tea Exports Ltd
Importer: Global Imports Inc
Description of Goods: 1000 KGS ASSAM TEA
Quantity: 1000 KGS
Unit Price: USD 50
Total Amount: USD 50,000
Shipment Date: 31-12-2025
GSTIN: 18AABCT1234A1Z0
IEC: 0712345678
HSN Code: 090240'''
    },
    {
        'name': 'Amount Exceeded (CRITICAL)',
        'lc': '''LETTER OF CREDIT
LC Number: LC-2025-003
Beneficiary: Assam Tea Exports Ltd
Applicant: Global Imports Inc
Amount: USD 50,000
Currency: USD
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Latest Shipment Date: 31-12-2025
Expiry Date: 31-01-2026''',
        'invoice': '''INVOICE
Invoice Number: INV-2025-003
Invoice Date: 25-12-2025
Exporter: Assam Tea Exports Ltd
Importer: Global Imports Inc
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Quantity: 1000 KGS
Unit Price: USD 51
Total Amount: USD 51,000
Shipment Date: 31-12-2025
GSTIN: 18AABCT1234A1Z0
IEC: 0712345678
HSN Code: 090240'''
    },
    {
        'name': 'Date Logic Error (CRITICAL)',
        'lc': '''LETTER OF CREDIT
LC Number: LC-2025-004
Beneficiary: Assam Tea Exports Ltd
Applicant: Global Imports Inc
Amount: USD 50,000
Currency: USD
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Latest Shipment Date: 31-12-2025
Expiry Date: 31-01-2026''',
        'invoice': '''INVOICE
Invoice Number: INV-2025-004
Invoice Date: 15-01-2026
Exporter: Assam Tea Exports Ltd
Importer: Global Imports Inc
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Quantity: 1000 KGS
Unit Price: USD 50
Total Amount: USD 50,000
Shipment Date: 31-12-2025
GSTIN: 18AABCT1234A1Z0
IEC: 0712345678
HSN Code: 090240'''
    },
    {
        'name': 'Missing Indian Compliance (MAJOR)',
        'lc': '''LETTER OF CREDIT
LC Number: LC-2025-005
Beneficiary: Assam Tea Exports Ltd
Applicant: Global Imports Inc
Amount: USD 50,000
Currency: USD
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Latest Shipment Date: 31-12-2025
Expiry Date: 31-01-2026''',
        'invoice': '''INVOICE
Invoice Number: INV-2025-005
Invoice Date: 25-12-2025
Exporter: Assam Tea Exports Ltd
Importer: Global Imports Inc
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Quantity: 1000 KGS
Unit Price: USD 50
Total Amount: USD 50,000
Shipment Date: 31-12-2025'''
    },
    {
        'name': 'Incoterm Mismatch (MAJOR)',
        'lc': '''LETTER OF CREDIT
LC Number: LC-2025-006
Beneficiary: Assam Tea Exports Ltd
Applicant: Global Imports Inc
Amount: USD 50,000
Currency: USD
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Latest Shipment Date: 31-12-2025
Expiry Date: 31-01-2026
Incoterm: FOB''',
        'invoice': '''INVOICE
Invoice Number: INV-2025-006
Invoice Date: 25-12-2025
Exporter: Assam Tea Exports Ltd
Importer: Global Imports Inc
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Quantity: 1000 KGS
Unit Price: USD 50
Total Amount: USD 50,000
Shipment Date: 31-12-2025
Incoterm: CIF
Freight: USD 5,000
Insurance: USD 500
GSTIN: 18AABCT1234A1Z0
IEC: 0712345678
HSN Code: 090240'''
    }
]

auditor = AdvancedLCAuditor()

print("=" * 80)
print("ADVANCED LC AUDITOR - FORENSIC-LEVEL COMPLIANCE TEST")
print("=" * 80)

for i, test in enumerate(test_cases, 1):
    print(f"\n{'='*80}")
    print(f"TEST {i}: {test['name']}")
    print(f"{'='*80}")
    
    result = auditor.audit(test['lc'], test['invoice'])
    
    print(f"\nAudit Summary: {result['audit_summary']}")
    print(f"Risk Score: {result['risk_score']}/100")
    
    print("\nLogic Checks:")
    for check, status in result['logic_checks'].items():
        print(f"  - {check.replace('_', ' ').title()}: {status}")
    
    print(f"\nDiscrepancies: {result['total_discrepancies']} total")
    print(f"  - Critical: {result['critical_count']}")
    print(f"  - Major: {result['major_count']}")
    print(f"  - Minor: {result['minor_count']}")
    
    if result['discrepancies']:
        print("\nDetailed Discrepancies:")
        for j, disc in enumerate(result['discrepancies'], 1):
            print(f"\n  {j}. [{disc['severity']}] {disc['category']}")
            print(f"     Field: {disc['field']}")
            print(f"     LC Requirement: {disc['lc_requirement']}")
            print(f"     Document Value: {disc['document_value']}")
            print(f"     Violation: {disc['violation_rule']}")
            print(f"     Explanation: {disc['explanation']}")
            print(f"     Fix: {disc['suggested_fix']}")

print("\n" + "=" * 80)
print("ALL TESTS COMPLETED")
print("=" * 80)
