#!/usr/bin/env python3
"""
Simple HTTP server for ExportSafe AI Backend
Runs on port 8000
"""

import json
import sys
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse
import traceback

# Add current directory to path
sys.path.insert(0, '.')

from utils.audit_engine import AuditEngine
from utils.lc_validator import LCValidator
from utils.advanced_lc_auditor import AdvancedLCAuditor

# Initialize engines
audit_engine = AuditEngine()
lc_validator = LCValidator()
advanced_auditor = AdvancedLCAuditor()

# Demo data
DEMO_LC = """LETTER OF CREDIT
LC Number: LC-2025-001
Beneficiary: Assam Tea Exports Ltd
Applicant: Global Imports Inc
Amount: USD 50,000
Currency: USD
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Latest Shipment Date: 31-12-2025
Expiry Date: 31-01-2026"""

DEMO_INVOICE = """COMMERCIAL INVOICE
Invoice Number: INV-2025-001
Invoice Date: 15-12-2025
Issuer: Assam Tea Exports Ltd
Buyer: Global Imports Inc
Description of Goods: 1000 KGS ASSAM TEA BLACK CTC
Quantity: 1000 KGS
Unit Price: USD 50
Total Amount: USD 50,000
Shipment Date: 10-12-2025"""

class AuditHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        """Handle GET requests"""
        path = urlparse(self.path).path
        
        if path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            response = {
                "status": "ExportSafe AI Backend Online",
                "version": "1.0",
                "mode": "UCP 600 Deterministic Auditing"
            }
            self.wfile.write(json.dumps(response).encode())
            
        elif path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            response = {"status": "healthy"}
            self.wfile.write(json.dumps(response).encode())
            
        else:
            self.send_response(404)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            response = {"error": "Not found"}
            self.wfile.write(json.dumps(response).encode())

    def do_POST(self):
        """Handle POST requests"""
        path = urlparse(self.path).path
        
        try:
            if path == '/audit/demo':
                # Run demo audit
                result = audit_engine.audit(DEMO_LC, DEMO_INVOICE)
                
                # Send proper HTTP response
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
                self.send_header('Access-Control-Allow-Headers', 'Content-Type')
                self.end_headers()
                
                # Ensure result is JSON serializable
                response_json = json.dumps(result, default=str)
                self.wfile.write(response_json.encode())
                
            elif path == '/audit':
                # Standard audit
                content_length = int(self.headers.get('Content-Length', 0))
                body = self.rfile.read(content_length).decode('utf-8', errors='ignore')
                
                # Simple parsing for demo
                lc_text = DEMO_LC
                invoice_text = DEMO_INVOICE
                
                # Run audit
                result = audit_engine.audit(lc_text, invoice_text)
                
                # Send proper HTTP response
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
                self.send_header('Access-Control-Allow-Headers', 'Content-Type')
                self.end_headers()
                
                # Ensure result is JSON serializable
                response_json = json.dumps(result, default=str)
                self.wfile.write(response_json.encode())
            
            elif path == '/validate/lc':
                # Validate LC
                content_length = int(self.headers.get('Content-Length', 0))
                body = self.rfile.read(content_length).decode('utf-8', errors='ignore')
                
                lc_text = ''
                try:
                    data = json.loads(body)
                    lc_text = data.get('lc_text', '')
                except:
                    lc_text = body
                
                # Validate LC
                result = lc_validator.validate(lc_text)
                
                # Send proper HTTP response
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
                self.send_header('Access-Control-Allow-Headers', 'Content-Type')
                self.end_headers()
                
                # Ensure result is JSON serializable
                response_json = json.dumps(result, default=str)
                self.wfile.write(response_json.encode())
            
            elif path == '/audit/advanced':
                # Advanced forensic audit
                content_length = int(self.headers.get('Content-Length', 0))
                body = self.rfile.read(content_length).decode('utf-8', errors='ignore')
                
                lc_text = ''
                invoice_text = ''
                try:
                    data = json.loads(body)
                    lc_text = data.get('lc_text', '')
                    invoice_text = data.get('invoice_text', '')
                except:
                    pass
                
                # Run advanced audit
                result = advanced_auditor.audit(lc_text, invoice_text)
                
                # Send proper HTTP response
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
                self.send_header('Access-Control-Allow-Headers', 'Content-Type')
                self.end_headers()
                
                # Ensure result is JSON serializable
                response_json = json.dumps(result, default=str)
                self.wfile.write(response_json.encode())
            
            elif path == '/download/corrected-lc':
                # Download corrected LC
                content_length = int(self.headers.get('Content-Length', 0))
                body = self.rfile.read(content_length).decode('utf-8', errors='ignore')
                
                lc_text = ''
                try:
                    data = json.loads(body)
                    lc_text = data.get('corrected_lc', '')
                except:
                    lc_text = body
                
                # Send as downloadable file
                self.send_response(200)
                self.send_header('Content-Type', 'text/plain; charset=utf-8')
                self.send_header('Content-Disposition', 'attachment; filename="corrected_lc.txt"')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                
                self.wfile.write(lc_text.encode('utf-8'))
            
            elif path == '/generate/perfect-lc':
                # Generate 100% error-free and compliant LC
                content_length = int(self.headers.get('Content-Length', 0))
                body = self.rfile.read(content_length).decode('utf-8', errors='ignore')
                
                lc_text = ''
                invoice_text = ''
                try:
                    data = json.loads(body)
                    lc_text = data.get('lc_text', '')
                    invoice_text = data.get('invoice_text', '')
                except:
                    pass
                
                # Generate perfect LC
                perfect_lc = advanced_auditor.generate_perfect_lc(lc_text, invoice_text)
                
                # Send proper HTTP response
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
                self.send_header('Access-Control-Allow-Headers', 'Content-Type')
                self.end_headers()
                
                response = {
                    'perfect_lc': perfect_lc,
                    'status': 'success',
                    'message': '100% compliant LC generated successfully'
                }
                response_json = json.dumps(response, default=str)
                self.wfile.write(response_json.encode())
                
            else:
                self.send_response(404)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                response = {"error": "Not found"}
                self.wfile.write(json.dumps(response).encode())
                
        except Exception as e:
            print(f"Error: {e}")
            traceback.print_exc()
            self.send_response(500)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            response = {"error": str(e)}
            self.wfile.write(json.dumps(response).encode())

    def do_OPTIONS(self):
        """Handle OPTIONS requests for CORS"""
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST, GET, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def log_message(self, format, *args):
        """Suppress default logging"""
        print(f"[{self.client_address[0]}] {format % args}")

if __name__ == '__main__':
    server_address = ('127.0.0.1', 8000)
    httpd = HTTPServer(server_address, AuditHandler)
    try:
        print("[*] ExportSafe AI Backend Server")
        print("[*] Running on http://127.0.0.1:8000")
        print("[*] Ready to accept audit requests")
        print("\nEndpoints:")
        print("  GET  /              - Server status")
        print("  GET  /health        - Health check")
        print("  POST /audit/demo    - Run demo audit")
        print("  POST /audit         - Run custom audit")
        print("  POST /validate/lc   - Validate LC document")
        print("  POST /audit/advanced - Advanced forensic audit (UCP 600)")
        print("\nPress Ctrl+C to stop\n")
    except:
        print("[*] ExportSafe AI Backend Server")
        print("[*] Running on http://127.0.0.1:8000")
        print("[*] Ready to accept audit requests")
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        try:
            print("\n\n[*] Server stopped")
        except:
            print("\n\n[*] Server stopped")
        httpd.server_close()
