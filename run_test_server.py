#!/usr/bin/env python3
"""Simple HTTP server for testing the MatchRecording app"""

import http.server
import socketserver
import os
import sys

PORT = 8000
DIRECTORY = r"C:\Users\fabio\Desktop\APPs\MatchRecording"

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def log_message(self, format, *args):
        sys.stderr.write("[%s] %s\n" % (self.log_date_time_string(), format%args))

if __name__ == "__main__":
    os.chdir(DIRECTORY)
    handler = MyHTTPRequestHandler
    
    with socketserver.TCPServer(("", PORT), handler) as httpd:
        print(f"🚀 Server avviato su http://localhost:{PORT}")
        print(f"📂 Serving da: {DIRECTORY}")
        print(f"📄 Apri: http://localhost:{PORT}/test.html")
        print(f"⏹️  Premi Ctrl+C per fermare\n")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n✋ Server fermato")
            sys.exit(0)
