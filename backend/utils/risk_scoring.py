from typing import List
from dataclasses import dataclass

@dataclass
class RiskScore:
    overall_score: int
    math_risk: int
    description_risk: int
    date_risk: int
    beneficiary_risk: int
    breakdown: dict

class RiskScoringEngine:
    '''Calculates risk score (0-100) based on discrepancies'''
    
    def __init__(self):
        self.weights = {
            'critical': 40,      # Critical issues = 40 points each
            'high': 20,          # High issues = 20 points each
            'medium': 10,        # Medium issues = 10 points each
            'low': 5,            # Low issues = 5 points each
        }
        self.max_score = 100
    
    def calculate_risk_from_discrepancies(self, discrepancies: List[dict]) -> RiskScore:
        '''Calculate risk score from list of discrepancies'''
        
        total_risk = 0
        math_risk = 0
        description_risk = 0
        date_risk = 0
        beneficiary_risk = 0
        
        for disc in discrepancies:
            severity = disc.get('severity', 'LOW').upper()
            field = disc.get('field', '').upper()
            
            weight = self.weights.get(severity.lower(), 5)
            
            if 'AMOUNT' in field or 'MATH' in disc.get('rule_violated', ''):
                math_risk += weight
            elif 'DESCRIPTION' in field:
                description_risk += weight
            elif 'DATE' in field or 'TEMPORAL' in disc.get('rule_violated', ''):
                date_risk += weight
            elif 'BENEFICIARY' in field or 'APPLICANT' in field:
                beneficiary_risk += weight
            
            total_risk += weight
        
        # Cap at 100
        overall_score = min(total_risk, 100)
        
        return RiskScore(
            overall_score=overall_score,
            math_risk=min(math_risk, 100),
            description_risk=min(description_risk, 100),
            date_risk=min(date_risk, 100),
            beneficiary_risk=min(beneficiary_risk, 100),
            breakdown={
                'total_discrepancies': len(discrepancies),
                'critical_count': len([d for d in discrepancies if d.get('severity') == 'CRITICAL']),
                'high_count': len([d for d in discrepancies if d.get('severity') == 'HIGH']),
                'medium_count': len([d for d in discrepancies if d.get('severity') == 'MEDIUM']),
                'low_count': len([d for d in discrepancies if d.get('severity') == 'LOW']),
            }
        )
    
    def get_risk_level(self, score: int) -> str:
        '''Get risk level description'''
        if score == 0:
            return 'COMPLIANT'
        elif score <= 20:
            return 'LOW_RISK'
        elif score <= 40:
            return 'MEDIUM_RISK'
        elif score <= 70:
            return 'HIGH_RISK'
        else:
            return 'CRITICAL_RISK'
    
    def get_recommendation(self, score: int, has_critical: bool) -> str:
        '''Get recommendation based on risk score'''
        if has_critical:
            return 'REJECT - Critical discrepancies found. Do not proceed.'
        
        if score == 0:
            return 'APPROVE - No discrepancies found.'
        elif score <= 20:
            return 'APPROVE - Minor issues found. Proceed with caution.'
        elif score <= 40:
            return 'REVIEW - Moderate issues found. Requires manual review.'
        elif score <= 70:
            return 'REJECT - Significant issues found. Requires amendment.'
        else:
            return 'REJECT - Critical issues found. Do not proceed.'
