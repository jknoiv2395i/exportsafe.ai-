from dataclasses import dataclass
from typing import List, Tuple
from difflib import SequenceMatcher
import re

@dataclass
class DescriptionMatch:
    status: str
    lc_description: str
    invoice_description: str
    match_percentage: float
    issues: List[str]
    severity: str

class DescriptionMatcher:
    '''UCP 600 Article 18: Description must correspond exactly'''
    
    def __init__(self):
        self.match_threshold = 0.95  # 95% match required
    
    def normalize_text(self, text: str) -> str:
        '''Normalize text for comparison'''
        text = text.upper().strip()
        text = re.sub(r'\s+', ' ', text)
        text = re.sub(r'[^\w\s]', '', text)
        return text
    
    def extract_key_terms(self, description: str) -> set:
        '''Extract key terms from description'''
        normalized = self.normalize_text(description)
        words = normalized.split()
        return set(words)
    
    def check_word_order(self, lc_desc: str, inv_desc: str) -> Tuple[bool, str]:
        '''Check if word order matches exactly'''
        lc_norm = self.normalize_text(lc_desc)
        inv_norm = self.normalize_text(inv_desc)
        
        if lc_norm == inv_norm:
            return True, 'Word order matches exactly'
        
        lc_words = lc_norm.split()
        inv_words = inv_norm.split()
        
        if set(lc_words) == set(inv_words):
            return False, f'Word order mismatch: LC={lc_desc} vs Invoice={inv_desc}'
        
        return False, 'Different words used'
    
    def check_key_terms(self, lc_desc: str, inv_desc: str) -> Tuple[bool, List[str]]:
        '''Check if all key terms from LC are in Invoice'''
        lc_terms = self.extract_key_terms(lc_desc)
        inv_terms = self.extract_key_terms(inv_desc)
        
        missing_terms = lc_terms - inv_terms
        extra_terms = inv_terms - lc_terms
        
        issues = []
        if missing_terms:
            issues.append(f'Missing terms: {missing_terms}')
        if extra_terms:
            issues.append(f'Extra terms: {extra_terms}')
        
        return len(missing_terms) == 0, issues
    
    def calculate_similarity(self, lc_desc: str, inv_desc: str) -> float:
        '''Calculate similarity percentage using SequenceMatcher'''
        lc_norm = self.normalize_text(lc_desc)
        inv_norm = self.normalize_text(inv_desc)
        
        matcher = SequenceMatcher(None, lc_norm, inv_norm)
        return matcher.ratio() * 100
    
    def match_descriptions(self, lc_description: str, invoice_description: str) -> DescriptionMatch:
        '''
        Match LC description with Invoice description
        Article 18: Must correspond exactly
        '''
        issues = []
        
        word_order_match, order_msg = self.check_word_order(lc_description, invoice_description)
        if not word_order_match:
            issues.append(order_msg)
        
        key_terms_match, term_issues = self.check_key_terms(lc_description, invoice_description)
        if not key_terms_match:
            issues.extend(term_issues)
        
        similarity = self.calculate_similarity(lc_description, invoice_description)
        
        if similarity >= self.match_threshold * 100 and word_order_match:
            status = 'PASS'
            severity = 'LOW'
        elif similarity >= 80:
            status = 'FAIL'
            severity = 'MEDIUM'
            issues.append(f'Similarity only {similarity:.1f}%, requires 95%+')
        else:
            status = 'FAIL'
            severity = 'HIGH'
            issues.append(f'Significant mismatch: {similarity:.1f}% similarity')
        
        return DescriptionMatch(
            status=status,
            lc_description=lc_description,
            invoice_description=invoice_description,
            match_percentage=similarity,
            issues=issues,
            severity=severity
        )
