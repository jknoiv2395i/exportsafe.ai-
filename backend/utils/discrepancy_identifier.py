from dataclasses import dataclass
from typing import List
from enum import Enum

class SeverityLevel(Enum):
    LOW = 'LOW'
    MEDIUM = 'MEDIUM'
    HIGH = 'HIGH'
    CRITICAL = 'CRITICAL'

@dataclass
class Discrepancy:
    field: str
    lc_value: str
    invoice_value: str
    rule_violated: str
    severity: str
    description: str

class DiscrepancyIdentifier:
    '''Identifies and categorizes discrepancies between LC and Invoice'''
    
    def __init__(self):
        self.discrepancies: List[Discrepancy] = []
    
    def add_discrepancy(self, field: str, lc_value: str, invoice_value: str,
                       rule: str, severity: str, description: str) -> None:
        '''Add a discrepancy'''
        disc = Discrepancy(
            field=field,
            lc_value=lc_value,
            invoice_value=invoice_value,
            rule_violated=rule,
            severity=severity,
            description=description
        )
        self.discrepancies.append(disc)
    
    def add_math_discrepancy(self, lc_amount: str, invoice_amount: str, 
                            tolerance: str, note: str) -> None:
        '''Add math validation discrepancy'''
        self.add_discrepancy(
            field='Total Amount',
            lc_value=lc_amount,
            invoice_value=invoice_amount,
            rule='UCP 600 Article 30 (Math Validation)',
            severity='HIGH',
            description=f'{note}. Tolerance: {tolerance}'
        )
    
    def add_description_discrepancy(self, lc_desc: str, invoice_desc: str,
                                   similarity: float, issues: List[str]) -> None:
        '''Add description mismatch discrepancy'''
        self.add_discrepancy(
            field='Description of Goods',
            lc_value=lc_desc,
            invoice_value=invoice_desc,
            rule='UCP 600 Article 18 (Strict Compliance)',
            severity='HIGH',
            description=f'Similarity: {similarity:.1f}%. Issues: {", ".join(issues)}'
        )
    
    def add_date_discrepancy(self, field: str, lc_value: str, invoice_value: str,
                            issue: str) -> None:
        '''Add date validation discrepancy'''
        self.add_discrepancy(
            field=field,
            lc_value=lc_value,
            invoice_value=invoice_value,
            rule='UCP 600 Article 18/31 (Temporal Validation)',
            severity='HIGH',
            description=issue
        )
    
    def add_beneficiary_discrepancy(self, lc_beneficiary: str, invoice_issuer: str) -> None:
        '''Add beneficiary mismatch'''
        self.add_discrepancy(
            field='Beneficiary/Issuer',
            lc_value=lc_beneficiary,
            invoice_value=invoice_issuer,
            rule='UCP 600 Article 18 (Beneficiary Check)',
            severity='CRITICAL',
            description='Invoice must be issued by LC beneficiary'
        )
    
    def add_applicant_discrepancy(self, lc_applicant: str, invoice_buyer: str) -> None:
        '''Add applicant/buyer mismatch'''
        self.add_discrepancy(
            field='Applicant/Buyer',
            lc_value=lc_applicant,
            invoice_value=invoice_buyer,
            rule='UCP 600 Article 18 (Applicant Check)',
            severity='CRITICAL',
            description='Invoice must be made out to LC applicant'
        )
    
    def get_all_discrepancies(self) -> List[Discrepancy]:
        '''Get all discrepancies'''
        return self.discrepancies
    
    def get_critical_discrepancies(self) -> List[Discrepancy]:
        '''Get only critical discrepancies'''
        return [d for d in self.discrepancies if d.severity == 'CRITICAL']
    
    def get_high_severity_discrepancies(self) -> List[Discrepancy]:
        '''Get high and critical discrepancies'''
        return [d for d in self.discrepancies if d.severity in ['HIGH', 'CRITICAL']]
    
    def clear(self) -> None:
        '''Clear all discrepancies'''
        self.discrepancies = []
    
    def to_dict_list(self) -> List[dict]:
        '''Convert to dictionary list for JSON serialization'''
        return [
            {
                'field': d.field,
                'lc_value': d.lc_value,
                'invoice_value': d.invoice_value,
                'rule_violated': d.rule_violated,
                'severity': d.severity,
                'description': d.description
            }
            for d in self.discrepancies
        ]
