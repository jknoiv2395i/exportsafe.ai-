import asyncio
import shutil
import tempfile
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from utils.audit_engine import AuditEngine

app = FastAPI(title="ExportSafe AI Backend - UCP 600 Auditor")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize audit engine
audit_engine = AuditEngine()

@app.get("/")
def home():
    return {
        "status": "ExportSafe AI Backend Online",
        "version": "1.0",
        "mode": "UCP 600 Deterministic Auditing"
    }

@app.get("/health")
def health():
    return {"status": "healthy"}

async def read_file_content(file: UploadFile) -> str:
    """Read uploaded file content"""
    try:
        content = await file.read()
        # Try to decode as text (for text files)
        try:
            return content.decode('utf-8')
        except:
            # For PDFs, return as is (will be handled by LlamaParse if available)
            return content.decode('latin-1', errors='ignore')
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error reading file: {str(e)}")

@app.post("/audit")
async def audit_documents(
    lc_file: UploadFile = File(...),
    invoice_file: UploadFile = File(...)
):
    """
    Complete UCP 600 audit endpoint
    Accepts: Letter of Credit PDF/text and Commercial Invoice PDF/text
    Returns: Audit results with discrepancies and risk score
    """
    try:
        print(f"[AUDIT] Received LC: {lc_file.filename}")
        print(f"[AUDIT] Received Invoice: {invoice_file.filename}")
        
        # Read file contents
        lc_text = await read_file_content(lc_file)
        invoice_text = await read_file_content(invoice_file)
        
        print(f"[AUDIT] LC text length: {len(lc_text)} chars")
        print(f"[AUDIT] Invoice text length: {len(invoice_text)} chars")
        
        # Run audit
        print("[AUDIT] Starting UCP 600 audit...")
        result = audit_engine.audit(lc_text, invoice_text)
        
        print(f"[AUDIT] Audit complete. Status: {result['status']}, Risk: {result['risk_score']}")
        print(f"[AUDIT] Discrepancies found: {len(result['discrepancies'])}")
        
        # Format response
        response = {
            "status": result['status'],
            "risk_score": result['risk_score'],
            "risk_level": result['risk_level'],
            "recommendation": result['recommendation'],
            "discrepancies": result['discrepancies'],
            "breakdown": result['breakdown'],
        }
        
        return response
        
    except Exception as e:
        print(f"[ERROR] Audit failed: {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Audit failed: {str(e)}")

@app.post("/audit/demo")
async def audit_demo():
    """
    Demo endpoint with hardcoded LC and Invoice
    """
    lc_demo = """
LETTER OF CREDIT
LC Number: LC-2025-001
Beneficiary: Assam Tea Exports Ltd
Applicant: Global Imports Inc
Amount: USD 50,000
Currency: USD
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Latest Shipment Date: 31-12-2025
Expiry Date: 31-01-2026
"""
    
    invoice_demo = """
COMMERCIAL INVOICE
Invoice Number: INV-2025-001
Invoice Date: 15-12-2025
Issuer: Assam Tea Exports Ltd
Buyer: Global Imports Inc
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Quantity: 1000 KGS
Unit Price: USD 50
Total Amount: USD 50,000
Shipment Date: 10-12-2025
"""
    
    result = audit_engine.audit(lc_demo, invoice_demo)
    
    return {
        "status": result['status'],
        "risk_score": result['risk_score'],
        "risk_level": result['risk_level'],
        "recommendation": result['recommendation'],
        "discrepancies": result['discrepancies'],
        "breakdown": result['breakdown'],
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)