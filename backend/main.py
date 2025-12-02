import os
import json
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from llama_parse import LlamaParse
from anthropic import Anthropic
from dotenv import load_dotenv
import shutil
import tempfile

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

# Initialize Clients
# Note: Ensure ANTHROPIC_API_KEY and LLAMA_PARSE_API_KEY are in .env
anthropic = Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))

SYSTEM_PROMPT = """
You are a UCP 600 Trade Finance Auditor.
Compare the 'Letter of Credit' vs 'Invoice'.

Rules:
1. Description of Goods must match exactly (Article 18).
2. Invoice Date must be <= Shipment Date.
3. Total Amount must be <= LC Amount (unless tolerance).

Output JSON format:
{
  "status": "PASS" | "FAIL",
  "risk_score": 0-100,
  "discrepancies": [{"field": "...", "lc_value": "...", "inv_value": "...", "reason": "..."}]
}
"""

async def extract_text_from_pdf(file: UploadFile) -> str:
    try:
        # Save uploaded file to a temporary file
        with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as tmp_file:
            shutil.copyfileobj(file.file, tmp_file)
            tmp_path = tmp_file.name

        # Use LlamaParse to extract text
        # Initialize LlamaParse here to pick up the API key from env
        parser = LlamaParse(result_type="markdown")
        documents = await parser.aload_data(tmp_path)
        
        text_content = "\n".join([doc.text for doc in documents])
        
        # Clean up temp file
        os.unlink(tmp_path)
        
        return text_content
    except Exception as e:
        print(f"Error extracting text: {e}")
        # Fallback or re-raise
        return ""

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
             # For demo purposes if extraction fails (e.g. no API key), use dummy text or fail
             if not os.getenv("LLAMA_PARSE_API_KEY"):
                 print("Warning: LLAMA_PARSE_API_KEY not found. Using dummy text.")
                 lc_text = "Dummy LC Text"
                 invoice_text = "Dummy Invoice Text"
             else:
                 raise HTTPException(status_code=500, detail="Failed to extract text from documents")

        # 2. Send to Claude
        if not os.getenv("ANTHROPIC_API_KEY"):
             # Mock response for testing without API key
             return {
                "status": "FAIL",
                "risk_score": 85,
                "discrepancies": [
                    {
                        "field": "Description of Goods",
                        "lc_value": "Tea Black CTC",
                        "inv_value": "Black Tea CTC",
                        "reason": "Word order mismatch violates Article 18"
                    }
                ]
            }

        message = anthropic.messages.create(
            model="claude-3-5-sonnet-20240620",
            max_tokens=1024,
            system=SYSTEM_PROMPT,
            messages=[
                {
                    "role": "user",
                    "content": f"Letter of Credit Content:\n{lc_text}\n\nCommercial Invoice Content:\n{invoice_text}"
                }
            ]
        )

        # 3. Parse and Return JSON
        response_text = message.content[0].text
        try:
            # Attempt to parse JSON from the response
            # Claude might wrap it in ```json ... ```
            if "```json" in response_text:
                json_str = response_text.split("```json")[1].split("```")[0].strip()
            elif "{" in response_text:
                json_str = response_text[response_text.find("{"):response_text.rfind("}")+1]
            else:
                json_str = response_text

            return json.loads(json_str)
        except json.JSONDecodeError:
             return {
                 "status": "FAIL", 
                 "risk_score": 100, 
                 "discrepancies": [{"field": "System", "lc_value": "N/A", "inv_value": "N/A", "reason": "Failed to parse AI response"}]
             }

    except Exception as e:
        print(f"Error processing audit: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
