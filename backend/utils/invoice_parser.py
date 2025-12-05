from typing import Optional, Dict
import re

class InvoiceParser:
    '''Parses Commercial Invoice to extract key fields'''
    
    def __init__(self, invoice_text: str):
        self.text = invoice_text
        self.data = {}
    
    def extract_invoice_number(self) -> Optional[str]:
        '''Extract invoice number'''
        patterns = [
            r'Invoice\s+(?:No\.?|Number)?\s*[:=]?\s*([A-Z0-9\-/]+)',
            r'Inv\s*[:=]?\s*([A-Z0-9\-/]+)',
        ]
        for pattern in patterns:
            match = re.search(pattern, self.text, re.IGNORECASE)
            if match:
                return match.group(1).strip()
        return None
    
    def extract_invoice_date(self) -> Optional[str]:
        '''Extract invoice date'''
        patterns = [
            r'Invoice\s+Date\s*[:=]?\s*(\d{1,2}[-/]\d{1,2}[-/]\d{4})',
            r'Date\s*[:=]?\s*(\d{1,2}[-/]\d{1,2}[-/]\d{4})',
        ]
        for pattern in patterns:
            match = re.search(pattern, self.text, re.IGNORECASE)
            if match:
                return match.group(1).strip()
        return None
    
    def extract_issuer(self) -> Optional[str]:
        '''Extract invoice issuer/seller'''
        patterns = [
            r'Issued\s+by\s*[:=]?\s*([^\n]+)',
            r'Seller\s*[:=]?\s*([^\n]+)',
            r'Exporter\s*[:=]?\s*([^\n]+)',
        ]
        for pattern in patterns:
            match = re.search(pattern, self.text, re.IGNORECASE)
            if match:
                return match.group(1).strip()
        return None
    
    def extract_buyer(self) -> Optional[str]:
        '''Extract invoice buyer/consignee'''
        patterns = [
            r'Buyer\s*[:=]?\s*([^\n]+)',
            r'Bill\s+To\s*[:=]?\s*([^\n]+)',
            r'Consignee\s*[:=]?\s*([^\n]+)',
        ]
        for pattern in patterns:
            match = re.search(pattern, self.text, re.IGNORECASE)
            if match:
                return match.group(1).strip()
        return None
    
    def extract_description(self) -> Optional[str]:
        '''Extract goods description'''
        patterns = [
            r'Description\s+(?:of\s+)?Goods?\s*[:=]?\s*([^\n:]+?)(?:\n|$)',
            r'Item\s+Description\s*[:=]?\s*([^\n:]+?)(?:\n|$)',
        ]
        for pattern in patterns:
            match = re.search(pattern, self.text, re.IGNORECASE)
            if match:
                desc = match.group(1).strip()
                # Stop at common field markers
                if '\n' in desc:
                    desc = desc.split('\n')[0].strip()
                return desc
        return None
    
    def extract_quantity(self) -> Optional[str]:
        '''Extract quantity'''
        patterns = [
            r'Quantity\s*[:=]?\s*([\d,]+(?:\.\d+)?)\s*(KGS|UNITS|BOXES|BAGS|TONS|LITERS|PIECES|MT|BLS)',
            r'Qty\s*[:=]?\s*([\d,]+(?:\.\d+)?)',
        ]
        for pattern in patterns:
            match = re.search(pattern, self.text, re.IGNORECASE)
            if match:
                return match.group(1).strip()
        return None
    
    def extract_unit_price(self) -> Optional[str]:
        '''Extract unit price'''
        patterns = [
            r'Unit\s+Price\s*[:=]?\s*([\$£€₹]?\s*[\d,]+(?:\.\d{2})?)',
            r'Price\s+per\s+(?:KG|UNIT|BOX)\s*[:=]?\s*([\$£€₹]?\s*[\d,]+(?:\.\d{2})?)',
        ]
        for pattern in patterns:
            match = re.search(pattern, self.text, re.IGNORECASE)
            if match:
                return match.group(1).strip()
        return None
    
    def extract_total_amount(self) -> Optional[str]:
        '''Extract total invoice amount'''
        patterns = [
            r'Total\s+(?:Amount|Invoice)\s*[:=]?\s*(?:USD|EUR|GBP|INR)?\s*([\d,]+(?:\.\d{2})?)',
            r'Grand\s+Total\s*[:=]?\s*(?:USD|EUR|GBP|INR)?\s*([\d,]+(?:\.\d{2})?)',
            r'(?:USD|EUR|GBP|INR)\s+([\d,]+(?:\.\d{2})?)\s*(?:Total|Amount)',
        ]
        for pattern in patterns:
            match = re.search(pattern, self.text, re.IGNORECASE)
            if match:
                return match.group(1).strip()
        return None
    
    def extract_currency(self) -> Optional[str]:
        '''Extract currency code'''
        patterns = [
            r'(USD|EUR|GBP|INR|JPY|CHF|CAD|AUD)',
        ]
        for pattern in patterns:
            match = re.search(pattern, self.text, re.IGNORECASE)
            if match:
                return match.group(1).upper()
        return 'USD'
    
    def extract_shipment_date(self) -> Optional[str]:
        '''Extract shipment/bill of lading date'''
        patterns = [
            r'(?:Bill\s+of\s+Lading|B/L|Shipment)\s+Date\s*[:=]?\s*(\d{1,2}[-/]\d{1,2}[-/]\d{4})',
            r'Shipped\s+on\s*[:=]?\s*(\d{1,2}[-/]\d{1,2}[-/]\d{4})',
        ]
        for pattern in patterns:
            match = re.search(pattern, self.text, re.IGNORECASE)
            if match:
                return match.group(1).strip()
        return None
    
    def parse(self) -> Dict:
        '''Parse all invoice fields'''
        self.data = {
            'invoice_number': self.extract_invoice_number(),
            'invoice_date': self.extract_invoice_date(),
            'issuer': self.extract_issuer(),
            'buyer': self.extract_buyer(),
            'description': self.extract_description(),
            'quantity': self.extract_quantity(),
            'unit_price': self.extract_unit_price(),
            'total_amount': self.extract_total_amount(),
            'currency': self.extract_currency(),
            'shipment_date': self.extract_shipment_date(),
        }
        return self.data
