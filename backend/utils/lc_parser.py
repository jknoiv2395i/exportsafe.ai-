from typing import Optional, Dict
import re
from datetime import datetime

class LCParser:
    '''Parses Letter of Credit to extract key fields'''
    
    def __init__(self, lc_text: str):
        self.text = lc_text
        self.data = {}
    
    def extract_lc_number(self) -> Optional[str]:
        '''Extract LC number (e.g., MT700, LC-12345)'''
        patterns = [
            r'LC\s*(?:No\.?|Number)?\s*[:=]?\s*([A-Z0-9\-]+)',
            r'Letter\s+of\s+Credit\s*[:=]?\s*([A-Z0-9\-]+)',
        ]
        for pattern in patterns:
            match = re.search(pattern, self.text, re.IGNORECASE)
            if match:
                return match.group(1).strip()
        return None
    
    def extract_beneficiary(self) -> Optional[str]:
        '''Extract beneficiary name (Field 59)'''
        patterns = [
            r'Beneficiary\s*[:=]?\s*([^\n]+)',
            r'Field\s+59\s*[:=]?\s*([^\n]+)',
        ]
        for pattern in patterns:
            match = re.search(pattern, self.text, re.IGNORECASE)
            if match:
                return match.group(1).strip()
        return None
    
    def extract_applicant(self) -> Optional[str]:
        '''Extract applicant/buyer name (Field 50)'''
        patterns = [
            r'Applicant\s*[:=]?\s*([^\n]+)',
            r'Field\s+50\s*[:=]?\s*([^\n]+)',
            r'Buyer\s*[:=]?\s*([^\n]+)',
        ]
        for pattern in patterns:
            match = re.search(pattern, self.text, re.IGNORECASE)
            if match:
                return match.group(1).strip()
        return None
    
    def extract_amount(self) -> Optional[str]:
        '''Extract LC amount'''
        patterns = [
            r'Amount\s*[:=]?\s*(?:USD|EUR|GBP|INR)?\s*([\d,]+(?:\.\d{2})?)',
            r'LC\s+Amount\s*[:=]?\s*(?:USD|EUR|GBP|INR)?\s*([\d,]+(?:\.\d{2})?)',
            r'(?:USD|EUR|GBP|INR)\s+([\d,]+(?:\.\d{2})?)',
        ]
        for pattern in patterns:
            match = re.search(pattern, self.text, re.IGNORECASE)
            if match:
                return match.group(1).strip()
        return None
    
    def extract_currency(self) -> Optional[str]:
        '''Extract currency code (USD, EUR, GBP, INR)'''
        patterns = [
            r'(USD|EUR|GBP|INR|JPY|CHF|CAD|AUD)',
        ]
        for pattern in patterns:
            match = re.search(pattern, self.text, re.IGNORECASE)
            if match:
                return match.group(1).upper()
        return 'USD'
    
    def extract_description(self) -> Optional[str]:
        '''Extract goods description (Field 45A)'''
        patterns = [
            r'Description\s+of\s+Goods\s*[:=]?\s*([^\n]+)(?:\n|$)',
            r'Field\s+45A\s*[:=]?\s*([^\n]+)(?:\n|$)',
        ]
        for pattern in patterns:
            match = re.search(pattern, self.text, re.IGNORECASE)
            if match:
                return match.group(1).strip()
        return None
    
    def extract_shipment_date(self) -> Optional[str]:
        '''Extract latest shipment date (Field 44C)'''
        patterns = [
            r'Latest\s+Shipment\s+Date\s*[:=]?\s*(\d{1,2}[-/]\d{1,2}[-/]\d{4})',
            r'Field\s+44C\s*[:=]?\s*(\d{1,2}[-/]\d{1,2}[-/]\d{4})',
        ]
        for pattern in patterns:
            match = re.search(pattern, self.text, re.IGNORECASE)
            if match:
                return match.group(1).strip()
        return None
    
    def extract_expiry_date(self) -> Optional[str]:
        '''Extract LC expiry date (Field 31D)'''
        patterns = [
            r'Expiry\s+Date\s*[:=]?\s*(\d{1,2}[-/]\d{1,2}[-/]\d{4})',
            r'Field\s+31D\s*[:=]?\s*(\d{1,2}[-/]\d{1,2}[-/]\d{4})',
        ]
        for pattern in patterns:
            match = re.search(pattern, self.text, re.IGNORECASE)
            if match:
                return match.group(1).strip()
        return None
    
    def extract_incoterms(self) -> Optional[str]:
        '''Extract incoterms (CIF, FOB, CFR, etc.)'''
        patterns = [
            r'(CIF|FOB|CFR|CPT|CIP|DAP|DDP|FCA|EXW)',
        ]
        for pattern in patterns:
            match = re.search(pattern, self.text, re.IGNORECASE)
            if match:
                return match.group(1).upper()
        return None
    
    def parse(self) -> Dict:
        '''Parse all LC fields'''
        self.data = {
            'lc_number': self.extract_lc_number(),
            'beneficiary': self.extract_beneficiary(),
            'applicant': self.extract_applicant(),
            'amount': self.extract_amount(),
            'currency': self.extract_currency(),
            'description': self.extract_description(),
            'shipment_date': self.extract_shipment_date(),
            'expiry_date': self.extract_expiry_date(),
            'incoterms': self.extract_incoterms(),
        }
        return self.data
