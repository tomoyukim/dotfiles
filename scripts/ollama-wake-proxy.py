#!/usr/bin/env python3
"""Transparent Ollama proxy with Wake-on-LAN wake-up."""

import json
import os
import socket
import sys
import threading
import time
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


def required_env(name):
    value = os.environ.get(name, "").strip()
    if not value:
        raise SystemExit(f"{name} environment variable is required")
    return value


OLLAMA_HOST = required_env("OLLAMA_HOST")
OLLAMA_PORT = int(os.environ.get("OLLAMA_PORT", "11434"))

WOL_URL = required_env("WOL_URL")
WOL_TOKEN = os.environ.get("WOL_TOKEN", "")
GPU_MAC = required_env("GPU_MAC")
BOOT_TIMEOUT = int(os.environ.get("BOOT_TIMEOUT", "90"))

# HostとDocker bridgeなど、必要な待ち受けアドレスを環境変数で指定する
LISTEN_HOSTS = tuple(
    host.strip()
    for host in required_env("LISTEN_HOSTS").split(",")
    if host.strip()
)

LISTEN_PORT = int(os.environ.get("LISTEN_PORT", "11435"))

# 空の場合はproxy認証なし
# 設定した場合、Authorization: Bearer *** が必須
PROXY_TOKEN = os.environ.get("PROXY_TOKEN", "")

HOP_BY_HOP = {
    "connection",
    "keep-alive",
    "proxy-authenticate",
    "proxy-authorization",
    "te",
    "trailers",
    "transfer-encoding",
    "upgrade",
}

# 複数リクエストによる重複WOLを防止
_WAKE_LOCK = threading.Lock()


class ReusableThreadingHTTPServer(ThreadingHTTPServer):
    allow_reuse_address = True
    daemon_threads = True


def log(message):
    print(message, flush=True)


def is_ollama_up():
    try:
        with socket.create_connection(
            (OLLAMA_HOST, OLLAMA_PORT),
            timeout=3,
        ):
            return True
    except OSError:
        return False


def send_wol():
    payload = json.dumps({"mac": GPU_MAC}).encode("utf-8")

    request = urllib.request.Request(
        WOL_URL,
        data=payload,
        headers={
            "Content-Type": "application/json",
            "X-Token": WOL_TOKEN,
        },
        method="POST",
)

    try:
        with urllib.request.urlopen(request, timeout=5) as response:
            response.read()

        log(f"WOL sent -> {GPU_MAC}")
        return True

    except Exception as error:
        log(f"WOL send failed: {error}")
        return False


def ensure_awake():
    if is_ollama_up():
        return True

    # GPU起動待ち中に別リクエストが来ても、WOLを重複送信しない
    with _WAKE_LOCK:
        # 別のリクエストが先に起動した可能性を再確認
        if is_ollama_up():
            return True

        log("Ollama unreachable - sending WOL...")

        if not send_wol():
            return False

        deadline = time.monotonic() + BOOT_TIMEOUT

        while time.monotonic() < deadline:
            time.sleep(3)

            if is_ollama_up():
                log("Ollama up.")
                return True

    log(f"Ollama did not come up within {BOOT_TIMEOUT}s.")
    return False


class ProxyHandler(BaseHTTPRequestHandler):
    # Ollamaのstreaming responseでHTTP/1.1のフレーミング問題を避ける
    protocol_version = "HTTP/1.0"

    def log_message(self, fmt, *args):
        # 通常のアクセスログは抑制
        pass

    def is_authorized(self):
        if not PROXY_TOKEN:
            return True

        expected = f"Bearer {PROXY_TOKEN}"
        return self.headers.get("Authorization") == expected

    def send_json_error(self, status, message):
        body = json.dumps(
            {"error": message}
        ).encode("utf-8")

        self.send_response(status)
        self.send_header(
            "Content-Type",
            "application/json",
        )
        self.send_header(
            "Content-Length",
            str(len(body)),
        )
        self.send_header("Connection", "close")
        self.end_headers()
        self.wfile.write(body)

    def forward(self):
        if not self.is_authorized():
            self.send_json_error(401, "unauthorized")
            return

        if not ensure_awake():
            self.send_json_error(
                503,
"GPU unavailable after WOL timeout",
            )
            return

        try:
            content_length = int(
                self.headers.get("Content-Length", "0")
            )
        except ValueError:
            self.send_json_error(
                400,
                "invalid Content-Length",
            )
            return

        request_body = (
            self.rfile.read(content_length)
            if content_length
            else None
        )

        upstream_url = (
            f"http://{OLLAMA_HOST}:{OLLAMA_PORT}{self.path}"
        )

        forwarded_headers = {
            key: value
            for key, value in self.headers.items()
            if key.lower()
            not in HOP_BY_HOP | {
                "host",
                # proxy用tokenをOllamaへ転送しない
                "authorization",
            }
        }

        request = urllib.request.Request(
            upstream_url,
            data=request_body,
            headers=forwarded_headers,
            method=self.command,
        )

        try:
            response = urllib.request.urlopen(
                request,
                timeout=180,
            )

        except urllib.error.HTTPError as error:
            # upstreamの4xx/5xxもレスポンスとして中継
            response = error

        except Exception as error:
            log(f"Upstream request failed: {error}")
            self.send_json_error(
                502,
                "upstream request failed",
            )
            return

        try:
            self.send_response(response.status)

            for key, value in response.headers.items():
                if key.lower() not in HOP_BY_HOP:
                    self.send_header(key, value)

            self.end_headers()

            while chunk := response.read(8192):
                self.wfile.write(chunk)
                self.wfile.flush()

        except BrokenPipeError:
            log("Client disconnected while receiving response")

        finally:
            response.close()

    do_GET = forward
    do_POST = forward
    do_PUT = forward
    do_DELETE = forward
    do_HEAD = forward
    do_OPTIONS = forward


def serve(host):
    server = ReusableThreadingHTTPServer(
        (host, LISTEN_PORT),
        ProxyHandler,
    )

    log(
        f"Ollama wake proxy listening on "
        f"{host}:{LISTEN_PORT} -> "
        f"{OLLAMA_HOST}:{OLLAMA_PORT}"
    )

    try:
        server.serve_forever()
    finally:
        server.server_close()


def main():
    if not LISTEN_HOSTS:
        raise SystemExit(
            "LISTEN_HOSTS must contain at least one address"
        )

    threads = []

    for host in LISTEN_HOSTS:
        thread = threading.Thread(
            target=serve,
            args=(host,),
            name=f"http-{host}",
            daemon=True,
        )
        thread.start()
        threads.append(thread)

    try:
        for thread in threads:
            thread.join()

    except KeyboardInterrupt:
        log("Stopping...")
        sys.exit(0)


if __name__ == "__main__":
    main()
