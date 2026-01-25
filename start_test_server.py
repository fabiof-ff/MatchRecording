#!/usr/bin/env python3
"""
Match Recording Test Server - Launcher Interattivo
Avvia il server HTTP e apre il browser automaticamente
"""

import http.server
import socketserver
import webbrowser
import os
import sys
import time
from threading import Thread

PORT = 8000
HOST = 'localhost'
DIRECTORY = r"C:\Users\fabio\Desktop\APPs\MatchRecording"
TEST_FILE = f"http://{HOST}:{PORT}/test_recording.html"

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def log_message(self, format, *args):
        # Formato log personalizzato
        sys.stderr.write(f"[{self.log_date_time_string()}] {format % args}\n")

def start_server():
    """Avvia il server HTTP"""
    os.chdir(DIRECTORY)
    handler = MyHTTPRequestHandler
    
    try:
        with socketserver.TCPServer(("", PORT), handler) as httpd:
            print(f"\n✓ Server avviato su http://{HOST}:{PORT}")
            print(f"✓ Serving da: {DIRECTORY}")
            print(f"✓ Test file: {TEST_FILE}\n")
            print("━" * 60)
            httpd.serve_forever()
    except OSError as e:
        if "Address already in use" in str(e):
            print(f"\n⚠️  Porta {PORT} già in uso")
            print("   Prova a:")
            print("   1. Chiudere il processo usando la porta")
            print("   2. Usare una porta diversa")
            print("\n   Comando per trovare il processo:")
            print(f"   netstat -ano | findstr :{PORT}")
        else:
            print(f"\n❌ Errore: {e}")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n\n✋ Server fermato")
        sys.exit(0)

def open_browser():
    """Apre il browser dopo un breve delay"""
    time.sleep(2)
    try:
        webbrowser.open(TEST_FILE)
        print(f"✓ Browser aperto: {TEST_FILE}\n")
    except Exception as e:
        print(f"⚠️  Non riesco ad aprire il browser automaticamente")
        print(f"   Apri manualmente: {TEST_FILE}\n")

if __name__ == "__main__":
    print("\n" + "━" * 60)
    print("  ⚽ MATCH RECORDING - TEST SERVER")
    print("━" * 60)
    
    # Avvia server in thread separato
    server_thread = Thread(target=start_server, daemon=True)
    server_thread.start()
    
    # Apri browser
    browser_thread = Thread(target=open_browser, daemon=True)
    browser_thread.start()
    
    # Mantieni il programma in esecuzione
    try:
        server_thread.join()
    except KeyboardInterrupt:
        print("\n\n✋ Server fermato")
        sys.exit(0)
