from fastapi import FastAPI, Request
from fastapi.responses import StreamingResponse
import httpx
import uvicorn
import json

app = FastAPI()
client = httpx.AsyncClient(timeout=600.0)

@app.api_route("/{path:path}", methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD"])
async def proxy(request: Request, path: str):
    headers = dict(request.headers)
    headers.pop("host", None)
    headers.pop("content-length", None)
    
    url = f"http://127.0.0.1:4001/{path}"
    
    try:
        body = await request.json()
        # 1. Cap max_tokens to 32768 for Bailian limits
        if "max_tokens" in body and isinstance(body["max_tokens"], int) and body["max_tokens"] > 32768:
            body["max_tokens"] = 32768
            
        # 2. Drop 'thinking' block to avoid Bailian compatible-mode crashes
        if "thinking" in body:
            del body["thinking"]
            
        req = client.build_request(request.method, url, json=body, headers=headers)
    except json.JSONDecodeError:
        # If it's not JSON, just forward it as is
        req = client.build_request(request.method, url, content=await request.body(), headers=headers)
    
    resp = await client.send(req, stream=True)
    return StreamingResponse(resp.aiter_raw(), status_code=resp.status_code, headers=resp.headers)

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=4000)
