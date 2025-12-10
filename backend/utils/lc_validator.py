"""
LC Validator - Detects errors in Letter of Credit documents
and suggests automatic fixes
"""

import re
from typing import Dict, List, Tuple
from datetime import datetime
from difflib import SequenceMatcher

class LCValidator:
    """Validates LC documents and identifies errors"""
    
    def __init__(self):
        self.required_fields = {
            'lc_number': 'LC Number',
            'beneficiary': 'Beneficiary',
            'applicant': 'Applicant',
            'amount': 'Amount',
            'currency': 'Currency',
            'description': 'Description of Goods',
            'shipment_date': 'Latest Shipment Date',
            'expiry_date': 'Expiry Date'
        }
        
        # Common field name variations (misspellings)
        self.field_variations = {
            'lc_number': ['lc number', 'lc no', 'lc#', 'letter of credit number', 'lc_no', 'lc no.', 'lc num'],
            'beneficiary': ['beneficiary', 'benificiary', 'beneficary', 'benificiary', 'beneficiary name'],
            'applicant': ['applicant', 'aplcant', 'applicent', 'applicant name'],
            'amount': ['amount', 'amout', 'ammount', 'credit amount', 'lc amount'],
            'currency': ['currency', 'curency', 'curr', 'currency code'],
            'description': ['description', 'descripion', 'discription', 'description of goods', 'goods description'],
            'shipment_date': ['shipment date', 'shipment', 'ship date', 'shipment_date', 'latest shipment'],
            'expiry_date': ['expiry date', 'expiry', 'exp date', 'expiry_date', 'expiration date']
        }
        
        self.errors = []
        self.auto_fixes = []
        self.spelling_errors = []
    
    def validate(self, lc_text: str) -> Dict:
        """
        Validate LC and return errors and auto-fixes
        """
        self.errors = []
        self.auto_fixes = []
        self.spelling_errors = []
        
        try:
            # Check for empty input
            if not lc_text or not lc_text.strip():
                return {
                    'is_valid': False,
                    'errors': [{
                        'type': 'EMPTY_INPUT',
                        'message': 'LC text is empty',
                        'severity': 'CRITICAL',
                        'suggestion': 'Please paste or upload an LC document'
                    }],
                    'auto_fixes': [],
                    'extracted_fields': {},
                    'total_errors': 1,
                    'total_auto_fixes': 0
                }
            
            # Detect spelling errors in field names
            self._detect_spelling_errors(lc_text)
            
            # Extract fields (with fuzzy matching for misspelled fields)
            extracted = self._extract_fields(lc_text)
            
            # Check for missing fields
            self._check_missing_fields(extracted)
            
            # Check for invalid formats
            self._check_field_formats(extracted)
            
            # Check for date issues
            self._check_dates(extracted)
            
            # Check for amount issues
            self._check_amounts(extracted)
            
            # Check for description issues
            self._check_description(extracted)
            
            # Check for LC condition issues
            self._check_lc_conditions(lc_text)
            
            # Add spelling errors to error list
            self.errors.extend(self.spelling_errors)
            
            # Generate auto-fixes
            self._generate_auto_fixes(extracted, lc_text)
            
            return {
                'is_valid': len(self.errors) == 0,
                'errors': self.errors,
                'auto_fixes': self.auto_fixes,
                'extracted_fields': extracted,
                'total_errors': len(self.errors),
                'total_auto_fixes': len(self.auto_fixes)
            }
            
        except Exception as e:
            # Handle any unexpected errors gracefully
            return {
                'is_valid': False,
                'errors': [{
                    'type': 'PARSING_ERROR',
                    'message': f'Error parsing LC: {str(e)}',
                    'severity': 'HIGH',
                    'suggestion': 'Please check the LC format and try again'
                }],
                'auto_fixes': [],
                'extracted_fields': {},
                'total_errors': 1,
                'total_auto_fixes': 0
            }
    
    def _detect_spelling_errors(self, text: str):
        """Detect spelling errors in field names and content"""
        text_lower = text.lower()
        
        # Check for common misspellings - Field names
        field_misspellings = {
            'benificiary': ('beneficiary', 'Beneficiary'),
            'beneficary': ('beneficiary', 'Beneficiary'),
            'benificiary': ('beneficiary', 'Beneficiary'),
            'aplcant': ('applicant', 'Applicant'),
            'applicent': ('applicant', 'Applicant'),
            'amout': ('amount', 'Amount'),
            'ammount': ('amount', 'Amount'),
            'curency': ('currency', 'Currency'),
            'descripion': ('description', 'Description'),
            'discription': ('description', 'Description'),
            'shipement': ('shipment', 'Shipment'),
            'expiry': ('expiry', 'Expiry'),
        }
        
        # Check for common misspellings - Content words
        content_misspellings = {
            'aloud': ('allowed', 'Allowed'),
            'transihment': ('transshipment', 'Transshipment'),
            'transhipment': ('transshipment', 'Transshipment'),
            'discrepency': ('discrepancy', 'Discrepancy'),
            'discrepancies': ('discrepancies', 'Discrepancies'),
            'recieve': ('receive', 'Receive'),
            'occured': ('occurred', 'Occurred'),
            'seperate': ('separate', 'Separate'),
            'neccessary': ('necessary', 'Necessary'),
            'accomodate': ('accommodate', 'Accommodate'),
            'reciever': ('receiver', 'Receiver'),
            'garentee': ('guarantee', 'Guarantee'),
            'garantee': ('guarantee', 'Guarantee'),
            'instrction': ('instruction', 'Instruction'),
            'instrctions': ('instructions', 'Instructions'),
            'conditon': ('condition', 'Condition'),
            'conditons': ('conditions', 'Conditions'),
            'documnet': ('document', 'Document'),
            'documnets': ('documents', 'Documents'),
            'submision': ('submission', 'Submission'),
            'submited': ('submitted', 'Submitted'),
            'expiery': ('expiry', 'Expiry'),
            'expiration': ('expiration', 'Expiration'),
        }
        
        # Check field name misspellings
        for misspelled, (correct, display) in field_misspellings.items():
            if misspelled in text_lower:
                self.spelling_errors.append({
                    'type': 'SPELLING_ERROR',
                    'field': misspelled,
                    'message': f'Spelling error in field name: "{misspelled}"',
                    'severity': 'MEDIUM',
                    'suggestion': f'Change "{misspelled}" to "{correct}"'
                })
        
        # Check content word misspellings
        for misspelled, (correct, display) in content_misspellings.items():
            if misspelled in text_lower:
                self.spelling_errors.append({
                    'type': 'SPELLING_ERROR',
                    'field': misspelled,
                    'message': f'Spelling error: "{misspelled}" found in content',
                    'severity': 'MEDIUM',
                    'suggestion': f'Change "{misspelled}" to "{correct}"'
                })
    
    def _extract_fields(self, text: str) -> Dict:
        """Extract fields from LC text"""
        extracted = {}
        
        # LC Number
        match = re.search(r'LC\s*(?:Number|No\.?)\s*[:=]\s*([A-Z0-9\-]+)', text, re.IGNORECASE)
        extracted['lc_number'] = match.group(1).strip() if match else None
        
        # Beneficiary
        match = re.search(r'Beneficiary\s*[:=]\s*([^\n]+)', text, re.IGNORECASE)
        extracted['beneficiary'] = match.group(1).strip() if match else None
        
        # Applicant
        match = re.search(r'Applicant\s*[:=]\s*([^\n]+)', text, re.IGNORECASE)
        extracted['applicant'] = match.group(1).strip() if match else None
        
        # Amount
        match = re.search(r'Amount\s*[:=]\s*([A-Z]{3}\s*[\d,\.]+)', text, re.IGNORECASE)
        extracted['amount'] = match.group(1).strip() if match else None
        
        # Currency
        match = re.search(r'Currency\s*[:=]\s*([A-Z]{3})', text, re.IGNORECASE)
        extracted['currency'] = match.group(1).strip() if match else None
        
        # Description
        match = re.search(r'Description\s*(?:of\s*Goods)?\s*[:=]\s*([^\n]+)', text, re.IGNORECASE)
        extracted['description'] = match.group(1).strip() if match else None
        
        # Shipment Date
        match = re.search(r'(?:Latest\s*)?Shipment\s*Date\s*[:=]\s*(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})', text, re.IGNORECASE)
        extracted['shipment_date'] = match.group(1).strip() if match else None
        
        # Expiry Date
        match = re.search(r'Expiry\s*Date\s*[:=]\s*(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})', text, re.IGNORECASE)
        extracted['expiry_date'] = match.group(1).strip() if match else None
        
        return extracted
    
    def _check_missing_fields(self, extracted: Dict):
        """Check for missing required fields"""
        for field, label in self.required_fields.items():
            if not extracted.get(field):
                self.errors.append({
                    'type': 'MISSING_FIELD',
                    'field': field,
                    'message': f'{label} is missing',
                    'severity': 'CRITICAL',
                    'suggestion': f'Add {label} to the LC document'
                })
    
    def _check_field_formats(self, extracted: Dict):
        """Check for invalid field formats"""
        
        # Check LC Number format
        if extracted.get('lc_number'):
            if len(extracted['lc_number']) < 3:
                self.errors.append({
                    'type': 'INVALID_FORMAT',
                    'field': 'lc_number',
                    'message': 'LC Number is too short',
                    'severity': 'HIGH',
                    'suggestion': 'LC Number should be at least 3 characters'
                })
        
        # Check Currency format
        if extracted.get('currency'):
            if not re.match(r'^[A-Z]{3}$', extracted['currency']):
                self.errors.append({
                    'type': 'INVALID_FORMAT',
                    'field': 'currency',
                    'message': f'Currency "{extracted["currency"]}" is not a valid ISO code',
                    'severity': 'HIGH',
                    'suggestion': 'Use valid 3-letter currency code (USD, EUR, GBP, etc.)'
                })
        
        # Check Amount format
        if extracted.get('amount'):
            if not re.search(r'[\d,\.]+', extracted['amount']):
                self.errors.append({
                    'type': 'INVALID_FORMAT',
                    'field': 'amount',
                    'message': 'Amount does not contain valid numbers',
                    'severity': 'CRITICAL',
                    'suggestion': 'Amount should be in format: USD 50,000 or USD 50000.00'
                })
    
    def _check_dates(self, extracted: Dict):
        """Check for date-related issues"""
        
        shipment_date = extracted.get('shipment_date')
        expiry_date = extracted.get('expiry_date')
        
        if shipment_date and expiry_date:
            try:
                # Parse dates
                ship_date = self._parse_date(shipment_date)
                exp_date = self._parse_date(expiry_date)
                
                if ship_date and exp_date:
                    # Check if expiry is after shipment
                    if exp_date < ship_date:
                        self.errors.append({
                            'type': 'DATE_ERROR',
                            'field': 'dates',
                            'message': f'Expiry Date ({expiry_date}) is before Shipment Date ({shipment_date})',
                            'severity': 'CRITICAL',
                            'suggestion': 'Expiry Date must be after Shipment Date'
                        })
                    
                    # Check if dates are too close
                    days_diff = (exp_date - ship_date).days
                    if days_diff < 7:
                        self.errors.append({
                            'type': 'DATE_WARNING',
                            'field': 'dates',
                            'message': f'Only {days_diff} days between shipment and expiry',
                            'severity': 'MEDIUM',
                            'suggestion': 'Consider extending expiry date for processing time'
                        })
            except:
                pass
    
    def _check_amounts(self, extracted: Dict):
        """Check for amount-related issues"""
        
        amount = extracted.get('amount')
        if amount:
            # Extract numeric value
            match = re.search(r'([\d,\.]+)', amount)
            if match:
                amount_str = match.group(1).replace(',', '')
                try:
                    amount_val = float(amount_str)
                    
                    if amount_val == 0:
                        self.errors.append({
                            'type': 'AMOUNT_ERROR',
                            'field': 'amount',
                            'message': 'Amount is zero',
                            'severity': 'CRITICAL',
                            'suggestion': 'Amount must be greater than zero'
                        })
                    
                    if amount_val < 100:
                        self.errors.append({
                            'type': 'AMOUNT_WARNING',
                            'field': 'amount',
                            'message': f'Amount is very small (${amount_val})',
                            'severity': 'MEDIUM',
                            'suggestion': 'Verify amount is correct'
                        })
                except:
                    pass
    
    def _check_description(self, extracted: Dict):
        """Check for description issues"""
        
        description = extracted.get('description')
        if description:
            if len(description) < 5:
                self.errors.append({
                    'type': 'DESCRIPTION_ERROR',
                    'field': 'description',
                    'message': 'Description is too short',
                    'severity': 'MEDIUM',
                    'suggestion': 'Provide detailed description of goods'
                })
            
            # Check for common missing info
            if not re.search(r'\d+\s*(KGS|UNITS|BOXES|BAGS|TONS|LITERS|PIECES|MT|BLS)', description, re.IGNORECASE):
                self.errors.append({
                    'type': 'DESCRIPTION_WARNING',
                    'field': 'description',
                    'message': 'Description does not include quantity units',
                    'severity': 'MEDIUM',
                    'suggestion': 'Include quantity and units (e.g., 1000 KGS)'
                })
    
    def _check_lc_conditions(self, text: str):
        """Check for common LC condition issues"""
        text_lower = text.lower()
        
        # Check for restrictive conditions
        restrictive_keywords = ['restricted', 'not negotiable', 'non-negotiable', 'restricted negotiation']
        for keyword in restrictive_keywords:
            if keyword in text_lower:
                self.errors.append({
                    'type': 'CONDITION_WARNING',
                    'field': 'conditions',
                    'message': f'LC contains restrictive condition: "{keyword}"',
                    'severity': 'HIGH',
                    'suggestion': 'Review if this restriction is acceptable'
                })
        
        # Check for partial shipment restrictions
        if 'partial shipment' in text_lower and 'not allowed' in text_lower:
            self.errors.append({
                'type': 'SHIPMENT_ERROR',
                'field': 'shipment',
                'message': 'Partial shipment is not allowed',
                'severity': 'HIGH',
                'suggestion': 'Ensure full shipment is possible or negotiate partial shipment'
            })
        
        # Check for transshipment restrictions
        if 'transshipment' in text_lower and 'not allowed' in text_lower:
            self.errors.append({
                'type': 'TRANSSHIPMENT_ERROR',
                'field': 'transshipment',
                'message': 'Transshipment is not allowed',
                'severity': 'HIGH',
                'suggestion': 'Ensure direct shipment is possible or negotiate transshipment'
            })
    
    def _generate_auto_fixes(self, extracted: Dict, original_text: str):
        """Generate automatic fixes for common errors"""
        
        # Fix 1: Missing currency in amount
        if extracted.get('amount') and extracted.get('currency'):
            amount = extracted['amount']
            currency = extracted['currency']
            if not amount.startswith(currency):
                self.auto_fixes.append({
                    'type': 'FORMAT_FIX',
                    'description': 'Add currency code to amount',
                    'action': f'Change "{amount}" to "{currency} {amount}"',
                    'priority': 'HIGH'
                })
        
        # Fix 2: Standardize date format
        if extracted.get('shipment_date'):
            date_str = extracted['shipment_date']
            if not re.match(r'\d{2}-\d{2}-\d{4}', date_str):
                self.auto_fixes.append({
                    'type': 'FORMAT_FIX',
                    'description': 'Standardize date format to DD-MM-YYYY',
                    'action': f'Convert date "{date_str}" to DD-MM-YYYY format',
                    'priority': 'MEDIUM'
                })
        
        # Fix 3: Add missing fields with templates
        for field, label in self.required_fields.items():
            if not extracted.get(field):
                self.auto_fixes.append({
                    'type': 'MISSING_FIELD_FIX',
                    'description': f'Add missing {label}',
                    'action': f'Insert {label} field in LC document',
                    'priority': 'CRITICAL'
                })
        
        # Fix 4: Standardize currency codes
        if extracted.get('currency'):
            currency = extracted['currency']
            valid_currencies = ['USD', 'EUR', 'GBP', 'JPY', 'INR', 'AUD', 'CAD', 'CHF', 'CNY', 'SEK']
            if currency not in valid_currencies:
                self.auto_fixes.append({
                    'type': 'VALIDATION_FIX',
                    'description': f'Verify currency code "{currency}"',
                    'action': f'Confirm "{currency}" is a valid ISO 4217 currency code',
                    'priority': 'HIGH'
                })
    
    def _parse_date(self, date_str: str):
        """Parse date string in various formats"""
        formats = ['%d-%m-%Y', '%d/%m/%Y', '%m-%d-%Y', '%m/%d/%Y', '%Y-%m-%d']
        
        for fmt in formats:
            try:
                return datetime.strptime(date_str, fmt)
            except:
                continue
        
        return None
