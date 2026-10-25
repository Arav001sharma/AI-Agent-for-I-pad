#!/usr/bin/env python3
import http.server
import socketserver
import os
import socket
import sys

PORT = 8080
DIRECTORY = os.path.join(os.path.dirname(__file__), "ipad-pwa")

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        # Enable CORS and video streaming headers
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Cache-Control', 'no-cache')
        super().end_headers()

def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('8.8.8.8', 80))
        ip = s.getsockname()[0]
    except Exception:
        ip = '127.0.0.1'
    finally:
        s.close()
    return ip

if __name__ == '__main__':
    local_ip = get_ip()
    os.chdir(DIRECTORY)
    
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print("=" * 65)
        print("🤖 LIL AGENTS FOR IPAD PRO SERVER RUNNING")
        print("=" * 65)
        print(f"\n👉 OPEN THIS URL ON YOUR IPAD SAFARI:\n")
        print(f"    http://{local_ip}:{PORT}\n")
        print("=" * 65)
        print("📱 HOW TO INSTALL IN YOUR IPAD DOCK:")
        print(" 1. Open the URL above in Safari on your iPad.")
        print(" 2. Tap the Share button (square with arrow pointing up).")
        print(" 3. Tap 'Add to Home Screen'.")
        print(" 4. Drag the 'Lil Agents' icon straight into your iPad Dock!")
        print(" 5. Tap it anytime to run Bruce & Jazz in Stage Manager or Fullscreen.")
        print("=" * 65)
        print("\nPress Ctrl+C to stop the server.\n")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nServer stopped.")
