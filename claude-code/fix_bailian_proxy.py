import http.server
import socketserver
import urllib.request
import json
import re
import sys

PORT = 8080
BAILIAN_URL = "https://ws-cmiyln8urfjxmgv9.cn-beijing.maas.aliyuncs.com/compatible-mode/v1/chat/completions"
BAILIAN_API_KEY = "<YOUR_BAILIAN_API_KEY>"

class ProxyHandler(http.server.BaseHTTPRequestHandler):
    def do_HEAD(self):
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Connection', 'close')
        self.end_headers()

    def do_GET(self):
        if "/models" in self.path:
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Connection', 'close')
            self.end_headers()
            models_response = {
                "data": [
                    {
                        "type": "model",
                        "id": "claude-opus-4-8[1m]",
                        "display_name": "Opus 4.8"
                    },
                    {
                        "type": "model",
                        "id": "claude-3-5-sonnet-20241022",
                        "display_name": "Claude 3.5 Sonnet"
                    }
                ]
            }
            self.wfile.write(json.dumps(models_response).encode('utf-8'))
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        try:
            content_length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(content_length)
            
            try:
                data = json.loads(body)
                
                if "tool_choice" in data and isinstance(data["tool_choice"], dict):
                    if data["tool_choice"].get("type") == "auto":
                        data["tool_choice"] = "auto"
                    else:
                        del data["tool_choice"]
                
                if "tools" in data:
                    new_tools = []
                    for tool in data["tools"]:
                        if "input_schema" in tool:
                            new_tools.append({
                                "type": "function",
                                "function": {
                                    "name": tool.get("name", ""),
                                    "description": tool.get("description", ""),
                                    "parameters": tool.get("input_schema", {})
                                }
                            })
                        else:
                            new_tools.append(tool)
                    data["tools"] = new_tools
                
                if "thinking" in data:
                    del data["thinking"]
                    
                data["model"] = "glm-5.2"
                
                # Always force streaming for this proxy translation to work
                data["stream"] = True
                    
                new_body = json.dumps(data).encode('utf-8')
            except Exception as e:
                print("Error parsing JSON:", e)
                new_body = body

            req = urllib.request.Request(BAILIAN_URL, data=new_body)
            for k, v in self.headers.items():
                k_lower = k.lower()
                if k_lower not in ['host', 'content-length', 'accept-encoding', 'x-api-key', 'authorization']:
                    req.add_header(k, v)
            
            req.add_header('Authorization', f'Bearer {BAILIAN_API_KEY}')

            try:
                with urllib.request.urlopen(req) as response:
                    self.send_response(response.status)
                    for k, v in response.headers.items():
                        if k.lower() not in ['transfer-encoding', 'content-length', 'connection']:
                            self.send_header(k, v)
                    self.send_header('Content-Type', 'text/event-stream; charset=utf-8')
                    self.send_header('Connection', 'keep-alive')
                    self.end_headers()
                    
                    self.wfile.write(b'event: message_start\ndata: {"type": "message_start", "message": {"id": "msg_1", "type": "message", "role": "assistant", "content": [], "model": "glm-5.2", "stop_reason": null, "stop_sequence": null, "usage": {"input_tokens": 10, "output_tokens": 0}}}\n\n')
                    self.wfile.write(b'event: content_block_start\ndata: {"type": "content_block_start", "index": 0, "content_block": {"type": "text", "text": ""}}\n\n')
                    self.wfile.flush()
                    
                    while True:
                        line = response.readline()
                        if not line:
                            break
                        
                        line_str = line.decode('utf-8').strip()
                        if line_str.startswith('data: '):
                            json_str = line_str[6:]
                            if json_str == '[DONE]':
                                continue
                            try:
                                chunk_data = json.loads(json_str)
                                if 'choices' in chunk_data and len(chunk_data['choices']) > 0:
                                    delta = chunk_data['choices'][0].get('delta', {})
                                    if 'content' in delta and delta['content']:
                                        content = delta['content']
                                        anthropic_chunk = {
                                            "type": "content_block_delta",
                                            "index": 0,
                                            "delta": {
                                                "type": "text_delta",
                                                "text": content
                                            }
                                        }
                                        self.wfile.write(f'event: content_block_delta\ndata: {json.dumps(anthropic_chunk)}\n\n'.encode('utf-8'))
                                        self.wfile.flush()
                            except Exception as e:
                                pass

                    self.wfile.write(b'event: content_block_stop\ndata: {"type": "content_block_stop", "index": 0}\n\n')
                    self.wfile.write(b'event: message_delta\ndata: {"type": "message_delta", "delta": {"stop_reason": "end_turn", "stop_sequence": null}, "usage": {"output_tokens": 100}}\n\n')
                    self.wfile.write(b'event: message_stop\ndata: {"type": "message_stop"}\n\n')
                    self.wfile.flush()
            except urllib.error.HTTPError as e:
                self.send_response(e.code)
                for k, v in e.headers.items():
                    if k.lower() not in ['transfer-encoding', 'content-length', 'connection']:
                        self.send_header(k, v)
                self.send_header('Connection', 'close')
                self.end_headers()
                self.wfile.write(e.read())
                self.wfile.flush()
        except Exception as e:
            print(f"Server exception: {e}")

socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("", PORT), ProxyHandler) as httpd:
    httpd.serve_forever()
