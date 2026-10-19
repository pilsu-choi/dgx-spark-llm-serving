import json, sys, time, urllib.request
prompt = sys.argv[1] if len(sys.argv) > 1 else "Write a Python function that parses an ISO-8601 date string without using datetime, with tests."
body = {"model": "qwen3.8-27b", "messages": [{"role": "user", "content": prompt}],
        "max_tokens": 1024, "stream": True, "stream_options": {"include_usage": True},
        "chat_template_kwargs": {"enable_thinking": False}}
req = urllib.request.Request("http://localhost:8000/v1/chat/completions", json.dumps(body).encode(), {"Content-Type": "application/json"})
t0 = time.time(); first = None; usage = None; text = []
for line in urllib.request.urlopen(req):
    line = line.decode().strip()
    if not line.startswith("data: ") or line == "data: [DONE]": continue
    d = json.loads(line[6:])
    if d.get("usage"): usage = d["usage"]
    for c in d.get("choices", []):
        piece = c["delta"].get("content") or ""
        if piece and first is None: first = time.time()
        text.append(piece)
end = time.time(); n = usage["completion_tokens"]
print("".join(text)[:300].replace("\n", " "), "...")
print(f"TTFT {first-t0:.2f}s | {n} tok | decode {(n-1)/(end-first):.1f} tok/s")
