from typing import Dict, List
from decimal import Decimal
from datetime import datetime
from utils.lc_parser import LCParser
from utils.invoice_parser import InvoiceParser
from utils.math_engine import MathEngine
from utils.description_matcher import DescriptionMatcher
from utils.date_validator import DateValidator
from utils.discrepancy_identifier import DiscrepancyIdentifier
from utils.risk_scoring import RiskScoringEngine

class AuditEngine:
    '''Complete UCP 600 audit engine'''
    
    def __init__(self):
        self.math_engine = MathEngine()
        self.description_matcher = DescriptionMatcher()
        self.date_validator = DateValidator()
        self.discrepancy_identifier = DiscrepancyIdentifier()
        self.risk_engine = RiskScoringEngine()
    
    def audit(self, lc_text: str, invoice_text: str) -> Dict:
        '''
        Complete audit of LC vs Invoice
        Returns: {status, risk_score, discrepancies, details}
        '''
        
        # Parse documents
        lc_parser = LCParser(lc_text)
        invoice_parser = InvoiceParser(invoice_text)
        
        lc_data = lc_parser.parse()
        invoice_data = invoice_parser.parse()
        
        self.discrepancy_identifier.clear()
        
        # 1. Math Validation (Article 30)
        self._validate_math(lc_data, invoice_data)
        
        # 2. Description Matching (Article 18)
        self._validate_description(lc_data, invoice_data)
        
        # 3. Date Validation
        self._validate_dates(lc_data, invoice_data)
        
        # 4. Beneficiary/Applicant Check
        self._validate_parties(lc_data, invoice_data)
        
        # Calculate risk score
        discrepancies = self.discrepancy_identifier.to_dict_list()
        risk_score = self.risk_engine.calculate_risk_from_discrepancies(discrepancies)
        
        # Determine overall status
        critical_discs = self.discrepancy_identifier.get_critical_discrepancies()
        overall_status = 'FAIL' if (critical_discs or risk_score.overall_score > 50) else 'PASS'
        
        return {
            'status': overall_status,
            'risk_score': risk_score.overall_score,
            'risk_level': self.risk_engine.get_risk_level(risk_score.overall_score),
            'recommendation': self.risk_engine.get_recommendation(
                risk_score.overall_score, 
                len(critical_discs) > 0
            ),
            'discrepancies': discrepancies,
            'breakdown': {
                'math_risk': risk_score.math_risk,
                'description_risk': risk_score.description_risk,
                'date_risk': risk_score.date_risk,
                'beneficiary_risk': risk_score.beneficiary_risk,
                'total_discrepancies': len(discrepancies),
                'critical': len(critical_discs),
            },
            'lc_data': lc_data,
            'invoice_data': invoice_data,
        }
    
    def _validate_math(self, lc_data: Dict, invoice_data: Dict) -> None:
        '''Validate amounts'''
        lc_amount_str = lc_data.get('amount', '')
        invoice_amount_str = invoice_data.get('total_amount', '')
        
        if not lc_amount_str or not invoice_amount_str:
            self.discrepancy_identifier.add_discrepancy(
                field='Amount',
                lc_value=lc_amount_str or 'NOT FOUND',
                invoice_value=invoice_amount_str or 'NOT FOUND',
                rule='UCP 600 Article 30',
                severity='HIGH',
                description='Amount not found in document'
            )
            return
        
        try:
            lc_amount = Decimal(lc_amount_str.replace(',', '').replace('$', '').strip())
            invoice_amount = Decimal(invoice_amount_str.replace(',', '').replace('$', '').strip())
            
            lc_desc = lc_data.get('description', '')
            result = self.math_engine.validate_math(lc_amount, invoice_amount, lc_desc)
            
            if result.status == 'FAIL':
                self.discrepancy_identifier.add_math_discrepancy(
                    lc_amount=str(lc_amount),
                    invoice_amount=str(invoice_amount),
                    tolerance=result.tolerance_applied,
                    note=result.discrepancy_note
                )
        except Exception as e:
            self.discrepancy_identifier.add_discrepancy(
                field='Amount',
                lc_value=lc_amount_str,
                invoice_value=invoice_amount_str,
                rule='UCP 600 Article 30',
                severity='MEDIUM',
                description=f'Error parsing amounts: {str(e)}'
            )
    
    def _validate_description(self, lc_data: Dict, invoice_data: Dict) -> None:
        '''Validate goods description'''
        lc_desc = lc_data.get('description', '')
        invoice_desc = invoice_data.get('description', '')
        
        if not lc_desc or not invoice_desc:
            self.discrepancy_identifier.add_discrepancy(
                field='Description',
                lc_value=lc_desc or 'NOT FOUND',
                invoice_value=invoice_desc or 'NOT FOUND',
                rule='UCP 600 Article 18',
                severity='HIGH',
                description='Description not found'
            )
            return
        
        match = self.description_matcher.match_descriptions(lc_desc, invoice_desc)
        
        if match.status == 'FAIL':
            self.discrepancy_identifier.add_description_discrepancy(
                lc_desc=lc_desc,
                invoice_desc=invoice_desc,
                similarity=match.match_percentage,
                issues=match.issues
            )
    
    def _validate_dates(self, lc_data: Dict, invoice_data: Dict) -> None:
        '''Validate dates'''
        invoice_date_str = invoice_data.get('invoice_date')
        shipment_date_str = lc_data.get('shipment_date')
        expiry_date_str = lc_data.get('expiry_date')
        
        date_validator = DateValidator()
        invoice_date = date_validator.parse_date(invoice_date_str) if invoice_date_str else None
        shipment_date = date_validator.parse_date(shipment_date_str) if shipment_date_str else None
        expiry_date = date_validator.parse_date(expiry_date_str) if expiry_date_str else None
        
        result = date_validator.validate_dates(invoice_date, shipment_date, expiry_date)
        
        if result.status == 'FAIL':
            for issue in result.issues:
                self.discrepancy_identifier.add_date_discrepancy(
                    field='Dates',
                    lc_value=str(shipment_date or expiry_date or 'N/A'),
                    invoice_value=str(invoice_date or 'N/A'),
                    issue=issue
                )
    
    def _validate_parties(self, lc_data: Dict, invoice_data: Dict) -> None:
        '''Validate beneficiary and applicant'''
        lc_beneficiary = (lc_data.get('beneficiary') or '').upper()
        invoice_issuer = (invoice_data.get('issuer') or '').upper()
        
        if lc_beneficiary and invoice_issuer:
            if lc_beneficiary not in invoice_issuer and invoice_issuer not in lc_beneficiary:
                self.discrepancy_identifier.add_beneficiary_discrepancy(
                    lc_beneficiary=lc_data.get('beneficiary', ''),
                    invoice_issuer=invoice_data.get('issuer', '')
                )
        
        lc_applicant = (lc_data.get('applicant') or '').upper()
        invoice_buyer = (invoice_data.get('buyer') or '').upper()
        
        if lc_applicant and invoice_buyer:
            if lc_applicant not in invoice_buyer and invoice_buyer not in lc_applicant:
                self.discrepancy_identifier.add_applicant_discrepancy(
                    lc_applicant=lc_data.get('applicant', ''),
                    invoice_buyer=invoice_data.get('buyer', '')
                )
