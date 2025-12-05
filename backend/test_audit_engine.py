import pytest
from utils.math_engine import MathEngine
from utils.description_matcher import DescriptionMatcher
from utils.date_validator import DateValidator
from utils.audit_engine import AuditEngine
from decimal import Decimal

class TestMathEngine:
    def test_tolerance_detection(self):
        engine = MathEngine()
        tolerance, label = engine.detect_tolerance('Amount about USD 50,000')
        assert tolerance == 0.10
        assert '+/- 10%' in label
    
    def test_math_validation_pass(self):
        engine = MathEngine()
        result = engine.validate_math(
            Decimal('50000'),
            Decimal('50000'),
            'Amount about USD 50,000'
        )
        assert result.status == 'PASS'
    
    def test_math_validation_fail(self):
        engine = MathEngine()
        result = engine.validate_math(
            Decimal('50000'),
            Decimal('60000'),
            'Amount USD 50,000'
        )
        assert result.status == 'FAIL'

class TestDescriptionMatcher:
    def test_exact_match(self):
        matcher = DescriptionMatcher()
        result = matcher.match_descriptions(
            'Tea Black CTC',
            'Tea Black CTC'
        )
        assert result.status == 'PASS'
    
    def test_word_order_mismatch(self):
        matcher = DescriptionMatcher()
        result = matcher.match_descriptions(
            'Tea Black CTC',
            'Black Tea CTC'
        )
        assert result.status == 'FAIL'
        assert 'Word order' in result.issues[0]

class TestDateValidator:
    def test_invoice_date_validation(self):
        validator = DateValidator()
        from datetime import datetime
        invoice_date = datetime(2025, 12, 15)
        shipment_date = datetime(2025, 12, 10)
        valid, msg = validator.validate_invoice_date(invoice_date, shipment_date)
        assert valid == True
    
    def test_invoice_date_after_shipment_fails(self):
        validator = DateValidator()
        from datetime import datetime
        invoice_date = datetime(2025, 12, 5)
        shipment_date = datetime(2025, 12, 10)
        valid, msg = validator.validate_invoice_date(invoice_date, shipment_date)
        assert valid == False

class TestAuditEngine:
    def test_complete_audit(self):
        engine = AuditEngine()
        lc_text = '''
        LC Number: LC-2025-001
        Beneficiary: Assam Tea Exports Ltd
        Applicant: Global Imports Inc
        Amount: USD 50,000
        Description: 1000 KGS ASSAM TEA BLACK CTC
        Shipment Date: 31-Dec-2025
        Expiry Date: 31-Jan-2026
        '''
        
        invoice_text = '''
        Invoice Number: INV-2025-001
        Invoice Date: 15-Dec-2025
        Issuer: Assam Tea Exports Ltd
        Buyer: Global Imports Inc
        Description: 1000 KGS ASSAM TEA BLACK CTC
        Total Amount: USD 50,000
        '''
        
        result = engine.audit(lc_text, invoice_text)
        assert 'status' in result
        assert 'risk_score' in result
        assert 'discrepancies' in result

if __name__ == '__main__':
    pytest.main([__file__, '-v'])
