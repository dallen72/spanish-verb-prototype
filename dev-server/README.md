### Web Build (Local Development)

To test the web build locally, you need to serve it through an HTTP server due to browser security restrictions.

1. **Export a web build** in Godot:
   - Go to Project > Export
   - Select "Web" platform
   - Click "Export Project"
   - Export to `game/build/web-debug/` (or `web-release/` for release builds)

2. **Start the local server**:
   ```bash
   python serve-web-build.py
   ```
   
   Or with custom options:
   ```bash
   python serve-web-build.py --port 8080 --mode debug
   ```

3. **Open in browser**:
   - Navigate to `http://localhost:8000/` (or your custom port)
   - The game will load automatically

**Server Options:**
- `--port, -p`: Port number (default: 8000)
- `--build-dir, -d`: Custom build directory path
- `--mode, -m`: Build mode - 'debug' or 'release' (default: debug)
- `--host`: Host to bind to (default: localhost)
