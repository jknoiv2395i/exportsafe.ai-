from dataclasses import dataclass
from typing import Optional, Tuple
from decimal import Decimal
import re

@dataclass
class MathValidationResult:
    status: str
    lc_amount: Decimal
    invoice_amount: Decimal
    tolerance_applied: str
    discrepancy_note: str
    discrepancy_percentage: float

class MathEngine:
    '''UCP 600 Article 30: Math validation for LC vs Invoice'''
    
    def __init__(self):
        self.tolerance_patterns = {
            'about': 0.10,
            'approximately': 0.10,
            'circa': 0.10,
            'approx': 0.10,
            'abt': 0.10,
        }
    
    def extract_amount(self, text: str) -> Optional[Decimal]:
        '''Extract monetary amount from text'''
        pattern = r'[\$£€₹]?\s*(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)'
        match = re.search(pattern, text)
        if match:
            amount_str = match.group(1).replace(',', '')
            try:
                return Decimal(amount_str)
            except:
                return None
        return None
    
    def extract_quantity(self, text: str) -> Optional[Decimal]:
        '''Extract quantity from text'''
        pattern = r'(\d+(?:,\d{3})*(?:\.\d+)?)\s*(KGS|UNITS|BOXES|BAGS|TONS|LITERS|PIECES|MT|BLS)'
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            qty_str = match.group(1).replace(',', '')
            try:
                return Decimal(qty_str)
            except:
                return None
        return None
    
    def detect_tolerance(self, lc_description: str) -> Tuple[float, str]:
        '''Detect tolerance keywords in LC'''
        text_lower = lc_description.lower()
        
        for keyword, tolerance in self.tolerance_patterns.items():
            if keyword in text_lower:
                return tolerance, f'+/- {int(tolerance*100)}%'
        
        explicit_pattern = r'tolerance\s*(?:of|:)?\s*\+?/?-?\s*(\d+)%'
        match = re.search(explicit_pattern, text_lower)
        if match:
            tolerance_pct = int(match.group(1)) / 100
            return tolerance_pct, f'+/- {match.group(1)}%'
        
        return 0.0, 'None'
    
    def validate_math(self, lc_amount: Decimal, invoice_amount: Decimal, 
                     lc_description: str) -> MathValidationResult:
        '''Validate: LC Amount >= Invoice Amount (with tolerance)'''
        tolerance, tolerance_str = self.detect_tolerance(lc_description)
        
        min_acceptable = lc_amount * Decimal(1 - tolerance)
        max_acceptable = lc_amount * Decimal(1 + tolerance)
        
        if min_acceptable <= invoice_amount <= max_acceptable:
            status = 'PASS'
            discrepancy_pct = 0.0
            note = f'Invoice amount {invoice_amount} within tolerance of LC {lc_amount}'
        else:
            status = 'FAIL'
            discrepancy_pct = abs((invoice_amount - lc_amount) / lc_amount * 100)
            note = f'Invoice amount {invoice_amount} exceeds LC {lc_amount} by {discrepancy_pct:.2f}%'
        
        return MathValidationResult(
            status=status,
            lc_amount=lc_amount,
            invoice_amount=invoice_amount,
            tolerance_applied=tolerance_str,
            discrepancy_note=note,
            discrepancy_percentage=discrepancy_pct
        )
    
    def validate_currency_precision(self, lc_amount: str, invoice_amount: str) -> Tuple[bool, str]:
        '''Check for currency decimal mismatch'''
        try:
            lc_decimal = Decimal(lc_amount)
            inv_decimal = Decimal(invoice_amount)
            
            if lc_decimal == inv_decimal:
                return True, 'Currency precision matches'
            else:
                return False, f'Currency mismatch: LC {lc_amount} vs Invoice {invoice_amount}'
        except:
            return False, 'Invalid currency format'
