#!/usr/bin/env python3
"""
Simple HTTP Server for Alice Pisa Demo
Run this to access the demo on mobile browser
"""

import http.server
import socketserver
import webbrowser
import socket
import os

def get_local_ip():
    """Get local IP address"""
    try:
        # Connect to a remote server to get local IP
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except:
        return "localhost"

def start_server():
    PORT = 8000
    
    # Change to current directory
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    
    Handler = http.server.SimpleHTTPRequestHandler
    
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        local_ip = get_local_ip()
        
        print("=" * 50)
        print("🌾 Alice Pisa Project Server Started!")
        print("=" * 50)
        print(f"📱 Mobile Access: http://{local_ip}:{PORT}/")
        print(f"💻 Computer Access: http://localhost:{PORT}/")
        print("=" * 50)
        print("📋 Instructions:")
        print("1. Make sure your phone and computer are on same WiFi")
        print("2. Open mobile browser")
        print(f"3. Go to: http://{local_ip}:{PORT}/")
        print("4. Choose Alice Pisa Main App!")
        print("=" * 50)
        print("Press Ctrl+C to stop server")
        print("=" * 50)
        
        # Auto-open in browser
        webbrowser.open(f"http://localhost:{PORT}/")
        
        httpd.serve_forever()

if __name__ == "__main__":
    start_server()