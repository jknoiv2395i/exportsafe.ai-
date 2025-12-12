#!/usr/bin/env python3
"""Simple web server for serving web_tester.html"""

import http.server
import socketserver
import os

os.chdir('g:\\Export Safe AI 2\\exportsafe.ai-\\backend')

PORT = 8080

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()

Handler = MyHTTPRequestHandler

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    try:
        print(f"[*] Web Server running on http://localhost:{PORT}")
        print(f"[*] Serving files from: {os.getcwd()}")
        print("Press Ctrl+C to stop\n")
    except:
        print(f"[*] Web Server running on http://localhost:{PORT}")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        try:
            print("\n\n[*] Web server stopped")
        except:
            print("\n\n[*] Web server stopped")
