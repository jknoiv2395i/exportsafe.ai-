#!/usr/bin/env python3
"""Test spelling error detection in LC validator"""

import sys
sys.path.insert(0, '.')

from utils.lc_validator import LCValidator

# Test cases
test_cases = [
    {
        'name': 'Spelling Error: benificiary',
        'lc': '''LETTER OF CREDIT
LC Number: LC-2025-001
Benificiary: Assam Tea Exports Ltd
Applicant: Global Imports Inc
Amount: USD 50,000
Currency: USD
Description of Goods: 1000 KGS ASSAM TEA
Shipment Date: 31-12-2025
Expiry Date: 31-01-2026'''
    },
    {
        'name': 'Spelling Error: amout',
        'lc': '''LETTER OF CREDIT
LC Number: LC-2025-001
Beneficiary: Assam Tea Exports Ltd
Applicant: Global Imports Inc
Amout: USD 50,000
Currency: USD
Description of Goods: 1000 KGS ASSAM TEA
Shipment Date: 31-12-2025
Expiry Date: 31-01-2026'''
    },
    {
        'name': 'Multiple Spelling Errors',
        'lc': '''LETTER OF CREDIT
LC Number: LC-2025-001
Benificiary: Assam Tea Exports Ltd
Aplcant: Global Imports Inc
Amout: USD 50,000
Curency: USD
Descripion of Goods: 1000 KGS ASSAM TEA
Shipement Date: 31-12-2025
Expiry Date: 31-01-2026'''
    },
    {
        'name': 'Malformed Input',
        'lc': 'This is not a valid LC at all'
    },
    {
        'name': 'Empty Input',
        'lc': ''
    }
]

validator = LCValidator()

print("=" * 60)
print("LC VALIDATOR - SPELLING ERROR DETECTION TEST")
print("=" * 60)

for test in test_cases:
    print(f"\n📋 Test: {test['name']}")
    print("-" * 60)
    
    result = validator.validate(test['lc'])
    
    print(f"✓ Valid: {result['is_valid']}")
    print(f"✓ Total Errors: {result['total_errors']}")
    print(f"✓ Total Auto-Fixes: {result['total_auto_fixes']}")
    
    if result['errors']:
        print("\n🔴 Errors Found:")
        for i, error in enumerate(result['errors'], 1):
            print(f"  {i}. [{error['type']}] {error['message']}")
            print(f"     Severity: {error['severity']}")
            print(f"     💡 Fix: {error['suggestion']}")
    
    if result['auto_fixes']:
        print("\n🔧 Auto-Fixes:")
        for i, fix in enumerate(result['auto_fixes'], 1):
            print(f"  {i}. {fix['description']}")
            print(f"     Action: {fix['action']}")

print("\n" + "=" * 60)
print("✅ ALL TESTS COMPLETED")
print("=" * 60)
