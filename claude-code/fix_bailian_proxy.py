import http.server
import socketserver
import urllib.request
import sys

CC_SWITCH_PORT = 15721
PORT = 8080

class ProxyHandler(http.server.BaseHTTPRequestHandler):
    def do_HEAD(self):
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Connection', 'close')
        self.end_headers()

    def proxy_request(self):
        try:
            content_length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(content_length) if content_length > 0 else b''
            
            url = f"http://127.0.0.1:{CC_SWITCH_PORT}{self.path}"
            req = urllib.request.Request(url, data=body, method=self.command)
            
            for k, v in self.headers.items():
                if k.lower() not in ['host']:
                    req.add_header(k, v)
                    
            try:
                with urllib.request.urlopen(req) as response:
                    self.send_response(response.status)
                    for k, v in response.headers.items():
                        self.send_header(k, v)
                    self.end_headers()
                    
                    while True:
                        chunk = response.read(4096)
                        if not chunk:
                            break
                        self.wfile.write(chunk)
                        self.wfile.flush()
            except urllib.error.HTTPError as e:
                self.send_response(e.code)
                for k, v in e.headers.items():
                    self.send_header(k, v)
                self.end_headers()
                self.wfile.write(e.read())
                self.wfile.flush()
        except Exception as e:
            print(f"Error: {e}")

    def do_GET(self):
        self.proxy_request()

    def do_POST(self):
        self.proxy_request()

socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("", PORT), ProxyHandler) as httpd:
    httpd.serve_forever()
