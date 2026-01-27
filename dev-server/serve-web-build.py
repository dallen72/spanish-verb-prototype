#!/usr/bin/env python3
"""
Local Development Server for Godot Web Builds

This script serves the Godot web build locally for development and testing.
Web builds require an HTTP server due to browser security restrictions.

Usage:
    python serve-web-build.py [--port PORT] [--build-dir DIR] [--mode MODE]

Examples:
    python serve-web-build.py
    python serve-web-build.py --port 8080
    python serve-web-build.py --build-dir game/build/web-debug
    python serve-web-build.py --mode release
"""

import http.server
import socketserver
import os
import sys
import argparse
from pathlib import Path


class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """Custom request handler with better logging and MIME type support."""
    
    def end_headers(self):
        # Add CORS headers for local development
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', '*')
        super().end_headers()
    
    def log_message(self, format, *args):
        """Override to provide cleaner log output."""
        sys.stderr.write(f"[{self.log_date_time_string()}] {format % args}\n")


def find_build_directory(build_dir=None, mode='debug'):
    """Find the web build directory."""
    script_dir = Path(__file__).parent
    
    if build_dir:
        build_path = Path(build_dir)
        if build_path.is_absolute():
            return build_path
        return script_dir / build_path
    
    # Default locations to check
    default_paths = [
        script_dir / 'game' / 'build' / f'web-{mode}',
        script_dir / 'build' / f'web-{mode}',
        script_dir / f'web-{mode}',
    ]
    
    for path in default_paths:
        if path.exists() and path.is_dir():
            return path
    
    return None


def main():
    parser = argparse.ArgumentParser(
        description='Serve Godot web build locally for development',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )
    parser.add_argument(
        '--port', '-p',
        type=int,
        default=8000,
        help='Port to serve on (default: 8000)'
    )
    parser.add_argument(
        '--build-dir', '-d',
        type=str,
        default=None,
        help='Path to web build directory (default: auto-detect)'
    )
    parser.add_argument(
        '--mode', '-m',
        type=str,
        choices=['debug', 'release'],
        default='debug',
        help='Build mode to look for (default: debug)'
    )
    parser.add_argument(
        '--host',
        type=str,
        default='localhost',
        help='Host to bind to (default: localhost)'
    )
    
    args = parser.parse_args()
    
    # Find build directory
    build_dir = find_build_directory(args.build_dir, args.mode)
    
    if not build_dir:
        print("❌ Error: Could not find web build directory!")
        print("\nPlease either:")
        print(f"  1. Export a web build to game/build/web-{args.mode}/")
        print(f"  2. Use --build-dir to specify the path to your web build")
        print("\nTo export a web build in Godot:")
        print("  1. Open the project in Godot")
        print("  2. Go to Project > Export")
        print("  3. Select 'Web' platform")
        print("  4. Click 'Export Project'")
        print(f"  5. Export to game/build/web-{args.mode}/")
        sys.exit(1)
    
    if not (build_dir / 'index.html').exists():
        print(f"⚠️  Warning: index.html not found in {build_dir}")
        print("   The web build may be incomplete.")
    
    # Change to build directory
    os.chdir(build_dir)
    
    # Create server
    try:
        with socketserver.TCPServer((args.host, args.port), CustomHTTPRequestHandler) as httpd:
            print("=" * 60)
            print("🚀 Godot Web Build Server")
            print("=" * 60)
            print(f"📁 Serving: {build_dir}")
            print(f"🌐 URL:      http://{args.host}:{args.port}/")
            print(f"📄 Main:     http://{args.host}:{args.port}/index.html")
            print("=" * 60)
            print("\nPress Ctrl+C to stop the server\n")
            
            httpd.serve_forever()
    except OSError as e:
        if e.errno == 48 or "Address already in use" in str(e):
            print(f"❌ Error: Port {args.port} is already in use!")
            print(f"   Try using a different port: python serve-web-build.py --port {args.port + 1}")
        else:
            print(f"❌ Error: {e}")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n\n👋 Server stopped. Goodbye!")
        sys.exit(0)


if __name__ == '__main__':
    main()
