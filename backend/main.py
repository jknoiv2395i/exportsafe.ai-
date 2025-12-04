import asyncio
from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="ExportSafe AI Backend (Demo Mode)")

# Configure CORS so your Flutter app can talk to this server
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def home():
    return {"status": "ExportSafe AI Demo Brain is Online"}

@app.post("/audit")
async def audit_documents(
    lc_file: UploadFile = File(...), 
    invoice_file: UploadFile = File(...)
):
    # 1. Log that we received files (for your debugging)
    print(f"Received LC: {lc_file.filename}")
    print(f"Received Invoice: {invoice_file.filename}")
    
    # 2. Simulate "AI Processing Time"
    # We wait 3 seconds so the user sees the cool loading animation in the app
    await asyncio.sleep(3)
    
    # 3. Return a Hardcoded "Success" Report
    # This JSON matches exactly what your Flutter app expects
    # You can change the "discrepancies" list to show different errors if you want
    return {
        "status": "PASS", 
        "risk_score": 15,
        "summary": "Documents appear compliant with UCP 600. Minor warning detected regarding Port name.",
        "discrepancies": [
            {
                "field": "Port of Loading",
                "lc_value": "Any Indian Port",
                "invoice_value": "Kolkata (Calcutta)",
                "reason": "Technically valid, but ensure 'India' is mentioned in Certificate of Origin to avoid bank queries.",
                "severity": "LOW"
            }
        ]
    }

if __name__ == "__main__":
    import uvicorn
    # Use port 8000 for local testing, Render will auto-assign a port in production
    uvicorn.run(app, host="0.0.0.0", port=8000)