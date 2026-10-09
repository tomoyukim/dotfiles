#!/usr/bin/env python3
"""Minimal WOL proxy. Accepts POST /wol from Docker bridge only."""
import os, re, subprocess, json
from http.server import BaseHTTPRequestHandler, HTTPServer


def required_env(name):
    value = os.environ.get(name, "").strip()
    if not value:
        raise SystemExit(f"{name} environment variable is required")
    return value


TOKEN = os.environ.get("WOL_TOKEN", "")
MAC_RE = re.compile(r"^([0-9a-fA-F]{2}[:\-]){5}[0-9a-fA-F]{2}$")


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass

    def send_json(self, code, body):
        data = json.dumps(body).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", len(data))
        self.end_headers()
        self.wfile.write(data)

    def do_POST(self):
        if self.path != "/wol":
            self.send_json(404, {"error": "not found"})
            return

        if TOKEN and self.headers.get("X-Token") != TOKEN:
            self.send_json(403, {"error": "forbidden"})
            return

        length = int(self.headers.get("Content-Length", 0))
        body = json.loads(self.rfile.read(length) or b"{}")
        mac = body.get("mac", "")

        if not MAC_RE.match(mac):
            self.send_json(400, {"error": "invalid mac"})
            return

        subprocess.run(["wakeonlan", mac], check=True)
        self.send_json(200, {"ok": True, "mac": mac})


if __name__ == "__main__":
    host = required_env("WOL_HOST")
    port = int(os.environ.get("WOL_PORT", "9000"))
    print(f"WOL proxy listening on {host}:{port}")
    HTTPServer((host, port), Handler).serve_forever()
