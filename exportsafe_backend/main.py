import os
import json
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
import shutil
import tempfile
import google.generativeai as genai

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
if gemini_api_key:
    genai.configure(api_key=gemini_api_key)
    # Using gemini-2.0-flash as it is available in the user's account
    gemini_model = genai.GenerativeModel('gemini-2.0-flash')
else:
    gemini_model = None
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
        
        if gemini_model:
            prompt = f"{JOHNSON_SYSTEM_PROMPT}\n\nANALYZE THESE DOCUMENTS:\n\nLetter of Credit Content:\n{lc_text}\n\nCommercial Invoice Content:\n{invoice_text}"
            
            # Retry Loop with Fallback
            models_to_try = ['gemini-2.0-flash', 'gemini-1.5-flash']
            response_text = ""
            
            import time
            
            for model_name in models_to_try:
                try:
                    print(f"Trying AI Model: {model_name}...")
                    current_model = genai.GenerativeModel(model_name)
                    response = current_model.generate_content(prompt)
                    response_text = response.text
                    break # Success!
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

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
