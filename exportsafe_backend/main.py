import os
import json
from typing import Optional, List
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
from dotenv import load_dotenv
import shutil
import tempfile
import requests

# Optional: LlamaParse (has compatibility issues with Python 3.14)
try:
    from llama_parse import LlamaParse
    LLAMA_PARSE_AVAILABLE = True
except Exception as e:
    print(f"LlamaParse not available: {e}")
    LLAMA_PARSE_AVAILABLE = False

# Load environment variables
load_dotenv()

app = FastAPI(title="ExportSafe AI Backend")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Google Gemini
gemini_api_key = os.getenv("GOOGLE_GEMINI_API_KEY")
if not gemini_api_key:
    print("Warning: GOOGLE_GEMINI_API_KEY not found")

# Johnson Protocol System Prompt
JOHNSON_SYSTEM_PROMPT = """
{
  "system_identity": {
    "name": "LC Scanner AI - Johnson Protocol",
    "version": "2.1 Enterprise",
    "codename": "JOHNSON",
    "purpose": "Forensic-grade Letter of Credit (LC) scanning, structure extraction, compliance validation, and bug detection"
  },
  "core_system_prompt": {
    "role": "You are JOHNSON, an elite LC Document Intelligence System. Your mission is to identify, analyze, and report discrepancies, bugs, and compliance issues in Letters of Credit according to ICC UCP 600 and ISBP 745 standards.",
    "operational_mandate": [
      "VALIDATE: First, determine if the provided text actually represents a Letter of Credit and a Commercial Invoice.",
      "SCAN: Perform deep visual and textual analysis",
      "IDENTIFY: Detect bugs, errors, discrepancies, and compliance violations",
      "REPORT: Generate detailed bug reports with severity classification"
    ]
  },
  "output_instruction": "You must output ONLY valid JSON matching the following structure. Do not include markdown formatting like ```json.",
  "required_output_structure": {
    "document_eligibility": {
      "is_eligible": true,
      "reason": "Documents are valid LC and Invoice"
    },
    "executive_summary": {
      "overall_status": "PASS | FAIL | NEEDS_REVISION",
      "confidence_score": 0-100,
      "breakdown": {
        "critical": "number",
        "high": "number",
        "medium": "number",
        "low": "number"
      }
    },
    "detailed_bug_report": [
      {
        "bug_id": "string",
        "severity": "CRITICAL | HIGH | MEDIUM | LOW",
        "field_affected": "string",
        "current_value": "string (what the LC says)",
        "expected_value": "string (what it should say)",
        "explanation": "string (why this is a bug)",
        "ucp_600_reference": "string"
      }
    ]
  }
}
"""

async def extract_text_from_pdf(file: UploadFile) -> str:
    try:
        # Save uploaded file to a temporary file
        with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as tmp_file:
            shutil.copyfileobj(file.file, tmp_file)
            tmp_path = tmp_file.name

        # Use LlamaParse to extract text (if available and configured)
        if LLAMA_PARSE_AVAILABLE and os.getenv("LLAMA_PARSE_API_KEY"):
            parser = LlamaParse(result_type="markdown")
            documents = await parser.aload_data(tmp_path)
            text_content = "\n".join([doc.text for doc in documents])
        else:
            # Fallback: Use pypdf for local extraction (No API key needed)
            # This ensures we read the ACTUAL file content (e.g. "Class Notes") 
            # so Johnson can correctly reject it.
            try:
                from pypdf import PdfReader
                reader = PdfReader(tmp_path)
                text_content = ""
                for page in reader.pages:
                    text_content += page.extract_text() + "\n"
                
                if not text_content.strip():
                    text_content = "[Empty PDF or Scanned Image - Cannot extract text without OCR]"
            except Exception as e:
                print(f"pypdf extraction failed: {e}")
                text_content = "[Error reading PDF content]"
        
        # Clean up temp file
        os.unlink(tmp_path)
        
        return text_content
    except Exception as e:
        print(f"Error extracting text: {e}")
        return f"Error reading {file.filename}"

@app.post("/audit")
async def audit_documents(
    lc_file: UploadFile = File(...),
    invoice_file: UploadFile = File(...)
):
    try:
        # 1. Extract Text
        lc_text = await extract_text_from_pdf(lc_file)
        invoice_text = await extract_text_from_pdf(invoice_file)

        if not lc_text or not invoice_text:
             raise HTTPException(status_code=500, detail="Failed to extract text from documents")

        # 2. Send to AI (Johnson Protocol)
        response_text = ""
        
        if gemini_api_key:
            prompt = f"{JOHNSON_SYSTEM_PROMPT}\n\nANALYZE THESE DOCUMENTS:\n\nLetter of Credit Content:\n{lc_text}\n\nCommercial Invoice Content:\n{invoice_text}"
            
            # Retry Loop with Fallback
            models_to_try = ['gemini-1.5-flash']
            response_text = ""
            
            import time
            
            for model_name in models_to_try:
                try:
                    print(f"Trying AI Model (REST): {model_name}...")
                    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={gemini_api_key}"
                    payload = {
                        "contents": [{
                            "parts": [{"text": prompt}]
                        }]
                    }
                    
                    response = requests.post(url, json=payload)
                    response_json = response.json()
                    
                    if "candidates" in response_json and response_json["candidates"]:
                        response_text = response_json["candidates"][0]["content"]["parts"][0]["text"]
                        break # Success!
                    else:
                        print(f"API Error with {model_name}: {response_json}")
                        continue

                except Exception as e:
                    error_str = str(e).lower()
                    if "quota" in error_str or "429" in error_str or "resource exhausted" in error_str:
                        print(f"Quota hit for {model_name}. Switching/Retrying...")
                        time.sleep(2) # Short wait before fallback
                        continue
                    else:
                        print(f"Error with {model_name}: {e}")
                        # If it's not a quota error, it might be a model error, try next.
                        continue
            
            if not response_text:
                 # Ensure we have a valid fallback if all AI calls fail
                 print("All AI models failed or quota exhausted.")
                 return {
                    "status": "FAIL",
                    "risk_score": 50,
                    "discrepancies": [
                        {
                            "field": "System",
                            "lc_value": "N/A",
                            "inv_value": "N/A",
                            "reason": "AI Service Busy (Quota Exceeded). Please try again in 30 seconds."
                        }
                    ]
                }

        else:
             # Mock response for testing without API key
             return {
                "status": "FAIL",
                "risk_score": 85,
                "discrepancies": [
                    {
                        "field": "System",
                        "lc_value": "N/A",
                        "inv_value": "N/A",
                        "reason": "No AI Model Configured"
                    }
                ]
            }

        # 3. Parse and Map JSON
        try:
            # Clean up potential markdown formatting
            clean_json = response_text
            if "```json" in clean_json:
                clean_json = clean_json.split("```json")[1].split("```")[0].strip()
            elif "```" in clean_json:
                clean_json = clean_json.split("```")[1].split("```")[0].strip()
            
            johnson_data = json.loads(clean_json)
            
            # Map Johnson Protocol output to AuditReport format
            eligibility = johnson_data.get("document_eligibility", {})
            is_eligible = eligibility.get("is_eligible", True)
            eligibility_reason = eligibility.get("reason", "")

            if not is_eligible:
                return {
                    "status": "FAIL",
                    "risk_score": 100,
                    "discrepancies": [
                        {
                            "field": "Document Eligibility",
                            "lc_value": "Invalid Document Type",
                            "inv_value": "N/A",
                            "reason": f"CRITICAL: {eligibility_reason}"
                        }
                    ]
                }

            executive_summary = johnson_data.get("executive_summary", {})
            detailed_bugs = johnson_data.get("detailed_bug_report", [])
            
            # Map Status
            overall_status = executive_summary.get("overall_status", "FAIL")
            mapped_status = "PASS" if overall_status == "PASS" else "FAIL"
            
            # Calculate Risk Score (Simple heuristic based on bugs)
            breakdown = executive_summary.get("breakdown", {})
            critical_count = breakdown.get("critical", 0)
            high_count = breakdown.get("high", 0)
            medium_count = breakdown.get("medium", 0)
            
            # Risk score calculation: Critical=25, High=10, Medium=5
            calculated_risk = (critical_count * 25) + (high_count * 10) + (medium_count * 5)
            risk_score = min(calculated_risk, 100)
            
            # Map Discrepancies
            mapped_discrepancies = []
            for bug in detailed_bugs:
                mapped_discrepancies.append({
                    "field": bug.get("field_affected", "Unknown"),
                    "lc_value": bug.get("current_value", "N/A"),
                    "inv_value": bug.get("expected_value", "N/A"),
                    "reason": f"[{bug.get('severity', 'LOW')}] {bug.get('explanation', '')} ({bug.get('ucp_600_reference', '')})"
                })

            return {
                "status": mapped_status,
                "risk_score": risk_score,
                "discrepancies": mapped_discrepancies
            }

        except json.JSONDecodeError:
             print(f"Failed to parse JSON: {response_text}")
             return {
                 "status": "FAIL", 
                 "risk_score": 100, 
                 "discrepancies": [{"field": "System", "lc_value": "N/A", "inv_value": "N/A", "reason": "Failed to parse Johnson Protocol response"}]
             }

    except Exception as e:
        print(f"Error processing audit: {e}")
        raise HTTPException(status_code=500, detail=str(e))


from pydantic import BaseModel, Field

class LCRequest(BaseModel):
    prompt: Optional[str] = None
    beneficiary: Optional[str] = None
    amount: Optional[str] = None
    terms: Optional[str] = None

class Party(BaseModel):
    name: str = Field(description="Full legal name")
    address: str = Field(description="Full physical address")

class Bank(BaseModel):
    name: str
    address: str
    swift_code: Optional[str] = None

class ShipmentDetails(BaseModel):
    port_of_loading: str
    port_of_discharge: str
    latest_shipment_date: Optional[str] = None
    partial_shipment: str = Field(description="Allowed or Prohibited")
    transshipment: str = Field(description="Allowed or Prohibited")

class LCResponse(BaseModel):
    lc_number: str = "PENDING"
    issue_date: str
    expiry_date: str
    expiry_place: str
    applicant: Party
    beneficiary: Party
    issuing_bank: Bank
    advising_bank: Optional[Bank] = None
    currency: str
    amount: str
    description_of_goods: str
    incoterms: str
    shipment_details: ShipmentDetails
    required_documents: List[str]
    additional_conditions: List[str]
    ucp600_statement: str = "Subject to UCP 600"

# Intelligent LC Generator System Prompt
LC_GENERATOR_SYSTEM_PROMPT = """
ROLE
You are the "Expert Trade Finance Architect" (Codename: ARCHITECT). You are capable of drafting perfect, UCP 600 compliant Letters of Credit by synthesizing data from multiple trade documents (Invoices, Packing Lists, Bills of Lading, etc.).

YOUR GOAL
Generate a formal, error-free Letter of Credit (MT700 format elements) by extracting and cross-referencing data from the provided documents.

INPUT DATA
You will receive raw text extracted from multiple PDF documents uploaded by the user.
The user has selected the route: {route_type}

RULES
1. **Source of Truth**: Trust the Commercial Invoice for amounts and goods description. Trust the Transport Document (BL/AWB) for ports and dates.
2. **Cross-Reference**: Ensure the LC amount matches the Invoice total. Ensure shipment dates form a logical timeline.
3. **UCP 600 Strictness**:
   - "About" or "Circa" allows +/- 10% in quantity/amount.
   - Transshipment/Partial Shipment defaults to "ALLOWED" unless context suggests otherwise.
4. **Missing Data**: If a critical field (like Beneficiary Bank) is completely missing from the docs, generate a realistic placeholder (e.g., "[BENEFICIARY BANK NAME]").

OUTPUT (STRICT JSON)
Return ONLY this JSON:
{
    "lc_number": "Generate a unique format like LC-YYYY-XXXX",
    "issue_date": "YYYY-MM-DD (Today)",
    "expiry_date": "YYYY-MM-DD (Calculated: Latest Shipment + 21 days)",
    "expiry_place": "Country of Beneficiary",
    "applicant": { "name": "...", "address": "..." },
    "beneficiary": { "name": "...", "address": "..." },
    "issuing_bank": { "name": "...", "address": "...", "swift_code": "..." },
    "advising_bank": { "name": "...", "address": "...", "swift_code": "..." },
    "currency": "USD",
    "amount": "0.00",
    "description_of_goods": " Precise description from Invoice...",
    "incoterms": "e.g., CIF Shanghai",
    "shipment_details": {
        "port_of_loading": "...",
        "port_of_discharge": "...",
        "latest_shipment_date": "YYYY-MM-DD",
        "partial_shipment": "ALLOWED" | "PROHIBITED",
        "transshipment": "ALLOWED" | "PROHIBITED"
    },
    "required_documents": [
        "Commercial Invoice (Original + 3 Copies)",
        "Packing List (Original + 3 Copies)",
        "Full Set Clean On Board Bill of Lading"
    ],
    "additional_conditions": [
        "All banking charges outside issuing bank are for beneficiary's account",
        "Documents must be presented within 21 days after shipment date"
    ],
    "ucp600_statement": "Subject to UCP 600"
}
"""

@app.post("/generate-lc", response_model=LCResponse)
async def generate_lc(
    files: List[UploadFile] = File(...),
    route_type: str = "Maritime"
):
    """
    Generates a formal Letter of Credit draft by analyzing uploaded trade documents.
    """
    try:
        # 1. Extract Text from ALL Valid Files
        combined_text = ""
        for file in files:
            if file.filename.lower().endswith('.pdf'):
                text = await extract_text_from_pdf(file)
                combined_text += f"\n--- DOCUMENT: {file.filename} ---\n{text}\n"
        
        if not combined_text.strip():
             # Fallback for empty/invalid upload
             pass 

        # 2. Construct AI Prompt
        final_prompt = LC_GENERATOR_SYSTEM_PROMPT.format(route_type=route_type) + f"\n\nEXTRACTED DATA FROM DOCUMENTS:\n{combined_text}"

        models_to_try = ['gemini-1.5-flash']
        
        for model_name in models_to_try:
            try:
                # Direct REST API Fallback
                import requests
                
                print(f"Architect Drafting LC (REST API - Model: {model_name})...")
                url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={gemini_api_key}"
                
                payload = {
                    "contents": [{
                        "parts": [{"text": final_prompt}]
                    }],
                    "generationConfig": {
                        "response_mime_type": "application/json",
                        "response_schema": {
                            "type": "OBJECT",
                            "properties": {
                                "lc_number": {"type": "STRING"},
                                "issue_date": {"type": "STRING"},
                                "expiry_date": {"type": "STRING"},
                                "expiry_place": {"type": "STRING"},
                                "applicant": {"type": "OBJECT", "properties": {"name": {"type": "STRING"}, "address": {"type": "STRING"}}},
                                "beneficiary": {"type": "OBJECT", "properties": {"name": {"type": "STRING"}, "address": {"type": "STRING"}}},
                                "issuing_bank": {"type": "OBJECT", "properties": {"name": {"type": "STRING"}, "address": {"type": "STRING"}, "swift_code": {"type": "STRING"}}},
                                "currency": {"type": "STRING"},
                                "amount": {"type": "STRING"},
                                "description_of_goods": {"type": "STRING"},
                                "incoterms": {"type": "STRING"},
                                "shipment_details": {"type": "OBJECT", "properties": {
                                    "port_of_loading": {"type": "STRING"},
                                    "port_of_discharge": {"type": "STRING"},
                                    "latest_shipment_date": {"type": "STRING"},
                                    "partial_shipment": {"type": "STRING"},
                                    "transshipment": {"type": "STRING"}
                                }},
                                "required_documents": {"type": "ARRAY", "items": {"type": "STRING"}},
                                "additional_conditions": {"type": "ARRAY", "items": {"type": "STRING"}},
                                "ucp600_statement": {"type": "STRING"}
                            }
                        }
                    }
                }
                
                response = requests.post(url, json=payload)
                response_json = response.json()
                
                if "candidates" in response_json and response_json["candidates"]:
                    raw_text = response_json["candidates"][0]["content"]["parts"][0]["text"]
                    clean_json = raw_text
                    
                    # Robust JSON extraction
                    try:
                        start_idx = clean_json.find('{')
                        end_idx = clean_json.rfind('}')
                        if start_idx != -1 and end_idx != -1:
                            clean_json = clean_json[start_idx : end_idx + 1]
                        
                        return LCResponse.model_validate_json(clean_json)
                    except Exception as parse_error:
                         print(f"JSON Parse Error: {parse_error}")
                         continue
                else:
                    print(f"API Error: {response_json}")
                    continue

            except Exception as e:
                print(f"Model {model_name} failed: {str(e)}")
                continue

        # Fallback if AI fails
        print("All AI models failed, using manual fallback.")
        return LCResponse(
            lc_number="FALLBACK-001",
            issue_date="2024-01-01",
            expiry_date="2024-04-01",
            expiry_place="London, UK",
            applicant=Party(name="Unknown Applicant", address="N/A"),
            beneficiary=Party(name="Unknown Beneficiary", address="N/A"),
            issuing_bank=Bank(name="Demo Bank", address="N/A"),
            currency="USD",
            amount="0.00",
            description_of_goods="AI Generation Failed - Please check backend logs or API Key.",
            incoterms="N/A",
            shipment_details=ShipmentDetails(port_of_loading="N/A", port_of_discharge="N/A", partial_shipment="Allowed", transshipment="Allowed"),
            required_documents=[],
            additional_conditions=[]
        )

    except Exception as e:
        print(f"Error generating LC: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# Forensic Auditor System Prompt
FORENSIC_AUDITOR_PROMPT = """
ROLE
You are the "Chief Trade Finance Forensic Auditor" (Codename: HAWKEYE). You are the world's most pedantic, unforgiving, and detail-oriented expert in ICC UCP 600, ISBP 745, and Incoterms 2020. You have zero tolerance for errors.

THE INPUT
You will receive raw text from a Letter of Credit (LC) and related documents.
CRITICAL ASSUMPTION: The input text is likely RIGGED with subtle typos, logical errors, OCR artifacts, and data inconsistencies. Your job is to EXPOSE them all.
Do NOT assume the document is correct. Assume it is BROKEN until proven otherwise.

YOUR MISSION
Perform a deep, line-by-line FORENSIC AUTOPSY of the text.
1.  **TYPO HUNTER**: Find every single spelling mistake (e.g., "Banl" -> "Bank", "Dolars" -> "Dollars", "Unite States" -> "United States").
2.  **DATA CONSISTENCY**: Check if amounts match (words vs figures). Check if proper names are consistent.
3.  **LOGIC CHECK**: 
    - Expiry Date CANNOT be before Issue Date.
    - Latest Shipment Date CANNOT be after Expiry Date.
    - Port of Loading and Discharge must make geographic sense.
4.  **UCP 600 COMPLIANCE**: Flag ambiguity. "Approximate" amount must be +/- 10%.

OUTPUT FORMAT (STRICT JSON)
Return ONLY this JSON. No markdown lines, no chat.
{
  "status": "CRITICAL_FAIL" | "PASS" | "WARNING",
  "risk_score": 0-100,
  "summary": "Detailed executive summary of the findings.",
  "corrected_lc_data": {
    "lc_number": "Extracted & Corrected Number",
    "amount": "Normalized Amount (e.g., 50000.00)",
    "currency": "Currency Code (e.g., USD)",
    "expiry_date": "YYYY-MM-DD",
    "latest_shipment_date": "YYYY-MM-DD",
    "beneficiary": "Corrected Beneficiary Name",
    "applicant": "Corrected Applicant Name"
  },
  "discrepancies": [
    {
      "field": "Exact field name (e.g., '40E - Applicable Rules')",
      "original_text": "The exact substring from input",
      "corrected_value": "What it SHOULD be",
      "issue_type": "TYPO" | "LOGIC" | "UCP_VIOLATION" | "MISSING" | "DATA_MISMATCH",
      "severity": "HIGH" | "MEDIUM" | "LOW",
      "explanation": "Precise explanation (e.g., 'Misspelled 'Irrevocable' as 'Irevocable'')."
    }
  ],
  "refined_lc_text": "Reconstruct the PERFECT, clean, typo-free version of the LC text here."
}
"""

@app.post("/forensic-audit")
async def forensic_audit(
    lc_file: UploadFile = File(...),
    invoice_file: UploadFile = File(...)
):
    try:
        # 1. Extract Text
        lc_text = await extract_text_from_pdf(lc_file)
        invoice_text = await extract_text_from_pdf(invoice_file)

        if not lc_text or not invoice_text:
             raise HTTPException(status_code=500, detail="Failed to extract text from documents")

        # 2. Send to AI
        if gemini_api_key:
            prompt = f"{FORENSIC_AUDITOR_PROMPT}\n\nANALYZE THESE DOCUMENTS:\n\nLetter of Credit Content:\n{lc_text}\n\nCommercial Invoice Content:\n{invoice_text}"
            
            # Robust Retry Logic
            models_to_try = ['gemini-1.5-flash']
            import time
            
            for model_name in models_to_try:
                try:
                    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={gemini_api_key}"
                    payload = {
                        "contents": [{
                            "parts": [{"text": prompt}]
                        }],
                         "generationConfig": {
                            "response_mime_type": "application/json"
                        }
                    }
                    
                    print(f"Forensic Auditor Requesting {model_name}...")
                    response = requests.post(url, json=payload)
                    response_json = response.json()
                    
                    if "candidates" in response_json and response_json["candidates"]:
                        clean_json = response_json["candidates"][0]["content"]["parts"][0]["text"]
                        
                        # Cleanup markdown
                        if "```json" in clean_json:
                            clean_json = clean_json.split("```json")[1].split("```")[0].strip()
                        elif "```" in clean_json:
                            clean_json = clean_json.split("```")[1].split("```")[0].strip()
                            
                        data = json.loads(clean_json)
                        return data
                    else:
                        print(f"API Error with {model_name}: {response_json}")
                        # Check for specific errors
                        if "error" in response_json:
                             err_msg = str(response_json["error"]).lower()
                             if "quota" in err_msg or "429" in err_msg or "resource exhausted" in err_msg:
                                 time.sleep(2)
                                 continue
                        continue

                except Exception as e:
                    print(f"Model {model_name} failed: {e}")
                    time.sleep(1)
                    continue

            # If all fail
            print("All AI Forensic models failed.")
            return {
                "status": "CRITICAL_FAIL",
                "risk_score": 100,
                "summary": "AI Audit process failed due to server error (All Retries Failed).",
                "corrected_lc_data": {},
                "discrepancies": [],
                "refined_lc_text": "Error generating report."
            }
        else:
             return {
                "status": "WARNING",
                "risk_score": 50,
                "summary": "Demo Mode: AI not configured.",
                "corrected_lc_data": {
                     "lc_number": "DEMO-123",
                     "amount": "50000.00"
                },
                "discrepancies": [],
                "refined_lc_text": "Demo text only."
            }


# Analyze & Audit System Prompt
    except Exception as e:
        print(f"Error in forensic audit: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# Analyze & Audit System Prompt ("DLML Algorithm")
ANALYZE_DOCUMENTS_PROMPT = """
### SYSTEM IDENTITY
**Identity:** DLML-v9 (Deep Language Machine Learning) Forensic Engine.
**Module:** Trade Finance "Crack" Detection & Reconstruction.
**Objective:** Execute the "Perfect Audit" protocol to identify micro-discrepancies, logical cracks, and compliance voids in Trade Finance documents (LC vs Invoice/BL).

### ALGORITHMIC PROTOCOL
1.  **VECTOR SCAN (Visual & Textual):**
    *   Ingest the raw visual patterns of the LC and Subject Document.
    *   Detect OCR artifacts (e.g., `l` vs `1`, `0` vs `O`).
    *   **CRITICAL STEP:** Fix all OCR errors in memory before analysis.

2.  **SEMANTIC DIFFERENTIAL ANALYSIS ("Crack Finding"):**
    *   Compare `LC.Beneficiary` vs `Invoice.Beneficiary`. (Exact string match required).
    *   Compare `LC.Amount` vs `Invoice.Total`. (Math verification).
    *   Compare `LC.Port` vs `BL.Port`.
    *   **Logic Check:** `Shipment Date` <= `Expiry Date`. If not, flag as logical crack.
    *   **Spelling Engine:** Detect subtle typos (e.g., "Shippment" -> "Shipment").

3.  **RECONSTRUCTION (The Fix):**
    *   Generate `refined_lc_text`: The mathematically perfect, grammatically correct, UCP-600 compliant version of the LC.
    *   **Rule:** If a discrepancy exists, the `refined_lc_text` MUST contain the *corrected* version that aligns with the Invoice/BL (assuming Invoice is true) OR makes the LC consistent with itself.

4.  **REPORT GENERATION:**
    *   Construct a `bank_ready_report` that is polite but firm, citing UCP 600 articles where applicable.

### OUTPUT JSON (STRICT)
{{
  "status": "FAIL" | "PASS",
  "risk_score": 0-100,
  "discrepancies": [
    {{
      "field": "Field Name", 
      "original_text": "Exact text from document", 
      "corrected_value": "The DLML corrected value", 
      "explanation": "Technical explanation of the crack/discrepancy (e.g., 'Typographic divergence detected').", 
      "severity": "CRITICAL" | "MAJOR" | "MINOR"
    }}
  ],
  "refined_lc_text": "The full, perfect LC text...",
  "bank_ready_report": {{
      "subject": "Discrepancy Notice: LC-[Number]", 
      "body_text": "Dear Trade Finance Officer,\\n\\nOur DLML Forensic Audit has detected the following irregularities..." 
  }}
}}
"""

@app.post("/analyze-documents")
async def analyze_documents(
    lc_file: UploadFile = File(...),
    subject_file: UploadFile = File(...)
):
    try:
        # 1. Extract Text
        lc_text = await extract_text_from_pdf(lc_file)
        subject_text = await extract_text_from_pdf(subject_file)

        if not lc_text or not subject_text:
             raise HTTPException(status_code=500, detail="Failed to extract text from documents")

        # 2. Send to AI
        if gemini_api_key:
            prompt = f"{ANALYZE_DOCUMENTS_PROMPT}\n\nANALYZE THESE DOCUMENTS:\n\n--- AUTHORITY DOCUMENT (LC) ---\n{lc_text}\n\n--- SUBJECT DOCUMENT (Invoice/BL) ---\n{subject_text}"
            
            try:
                # Use gemini-1.5-flash for speed/efficiency
                url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={gemini_api_key}"
                payload = {
                    "contents": [{
                        "parts": [{"text": prompt}]
                    }],
                    "generationConfig": {
                        "response_mime_type": "application/json"
                    }
                }
                
                response = requests.post(url, json=payload)
                response_json = response.json()
                
                if "candidates" in response_json and response_json["candidates"]:
                    clean_json = response_json["candidates"][0]["content"]["parts"][0]["text"]
                    
                    # Cleanup markdown if still present despite mime_type
                    if "```json" in clean_json:
                        clean_json = clean_json.split("```json")[1].split("```")[0].strip()
                    elif "```" in clean_json:
                        clean_json = clean_json.split("```")[1].split("```")[0].strip()
                        
                    return json.loads(clean_json)
                else:
                    raise Exception(f"API Error: {response_json}")

            except Exception as e:
                print(f"Analyze Audit Failed: {e}")
                return {
                    "status": "FAIL",
                    "risk_score": 100,
                    "discrepancies": [{"field": "System", "original_text": "N/A", "corrected_value": "N/A", "explanation": f"AI Error: {str(e)}", "severity": "CRITICAL"}],
                    "refined_lc_text": "Analysis disrupted.",
                    "bank_ready_report": {"subject": "System Error", "body_text": "Could not complete analysis."}
                }
        else:
             # Mock Response
             return {
                "status": "FAIL",
                "risk_score": 75,
                "discrepancies": [
                    {
                        "field": "Beneficiary Name", 
                        "original_text": "ExpotSafe Ltd", 
                        "corrected_value": "ExportSafe Ltd", 
                        "explanation": "Spelling error in beneficiary name.", 
                        "severity": "CRITICAL"
                    }
                ],
                "refined_lc_text": "This is a demo refined LC text because no API Key was found.",
                "bank_ready_report": { 
                    "subject": "Discrepancy Note - Import LC 123456", 
                    "body_text": "Dear Bank,\\n\\nPlease find attached the corrected documents..." 
                }
            }

    except Exception as e:
        print(f"Error in analyze documents: {e}")
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
