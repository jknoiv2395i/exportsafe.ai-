from dataclasses import dataclass
from typing import Optional, Tuple
from datetime import datetime, timedelta
import re

@dataclass
class DateValidationResult:
    status: str
    invoice_date: Optional[datetime]
    shipment_date: Optional[datetime]
    lc_expiry_date: Optional[datetime]
    issues: list
    severity: str

class DateValidator:
    '''UCP 600 Temporal validation: Dates must be in correct sequence'''
    
    def parse_date(self, date_str: str) -> Optional[datetime]:
        '''Parse date from various formats'''
        if not date_str:
            return None
        
        date_formats = [
            '%d-%m-%Y',
            '%d/%m/%Y',
            '%Y-%m-%d',
            '%d %b %Y',
            '%d %B %Y',
            '%d.%m.%Y',
        ]
        
        for fmt in date_formats:
            try:
                return datetime.strptime(date_str.strip(), fmt)
            except ValueError:
                continue
        
        return None
    
    def extract_date(self, text: str) -> Optional[datetime]:
        '''Extract date from text'''
        patterns = [
            r'(\d{1,2}[-/]\d{1,2}[-/]\d{4})',
            r'(\d{1,2}\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{4})',
        ]
        
        for pattern in patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                return self.parse_date(match.group(1))
        
        return None
    
    def validate_invoice_date(self, invoice_date: datetime, shipment_date: datetime) -> Tuple[bool, str]:
        '''
        Article 18: Invoice date must be <= Shipment date
        Invoice cannot be dated before shipment
        '''
        if invoice_date <= shipment_date:
            return True, f'Invoice date {invoice_date.date()} is valid (on or before shipment {shipment_date.date()})'
        else:
            days_diff = (invoice_date - shipment_date).days
            return False, f'Invoice dated {days_diff} days AFTER shipment - VIOLATION'
    
    def validate_presentation_date(self, invoice_date: datetime, presentation_deadline: datetime) -> Tuple[bool, str]:
        '''
        Article 48: Presentation must be within deadline (typically 21 days after shipment)
        '''
        if invoice_date <= presentation_deadline:
            return True, f'Invoice within presentation deadline'
        else:
            days_late = (invoice_date - presentation_deadline).days
            return False, f'Invoice {days_late} days AFTER presentation deadline'
    
    def validate_lc_expiry(self, current_date: datetime, lc_expiry: datetime) -> Tuple[bool, str]:
        '''
        Article 31: LC must not be expired
        '''
        if current_date <= lc_expiry:
            days_remaining = (lc_expiry - current_date).days
            return True, f'LC valid for {days_remaining} more days'
        else:
            days_expired = (current_date - lc_expiry).days
            return False, f'LC expired {days_expired} days ago'
    
    def validate_dates(self, invoice_date: Optional[datetime], 
                      shipment_date: Optional[datetime],
                      lc_expiry_date: Optional[datetime]) -> DateValidationResult:
        '''
        Validate all date relationships
        '''
        issues = []
        severity = 'LOW'
        status = 'PASS'
        
        if not invoice_date:
            issues.append('Invoice date not found')
            severity = 'HIGH'
            status = 'FAIL'
        
        if not shipment_date:
            issues.append('Shipment date not found')
            severity = 'HIGH'
            status = 'FAIL'
        
        if not lc_expiry_date:
            issues.append('LC expiry date not found')
            severity = 'MEDIUM'
        
        # Validate invoice vs shipment
        if invoice_date and shipment_date:
            valid, msg = self.validate_invoice_date(invoice_date, shipment_date)
            if not valid:
                issues.append(msg)
                severity = 'HIGH'
                status = 'FAIL'
        
        # Validate LC expiry
        if lc_expiry_date:
            current = datetime.now()
            valid, msg = self.validate_lc_expiry(current, lc_expiry_date)
            if not valid:
                issues.append(msg)
                severity = 'HIGH'
                status = 'FAIL'
        
        return DateValidationResult(
            status=status,
            invoice_date=invoice_date,
            shipment_date=shipment_date,
            lc_expiry_date=lc_expiry_date,
            issues=issues,
            severity=severity
        )
