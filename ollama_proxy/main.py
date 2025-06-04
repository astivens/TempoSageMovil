from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
import httpx

app = FastAPI()

# CORS abierto para demo
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

OLLAMA_URL = "http://localhost:11434/v1/chat/completions"  # Cambia si tu Ollama está en otra IP/puerto

@app.post("/api/chat")
async def chat(request: Request):
    data = await request.json()
    # Adaptar el payload al formato de Ollama
    payload = {
        "model": data.get("model", "llama3"),
        "messages": data.get("messages", []),
        "stream": False
    }
    async with httpx.AsyncClient() as client:
        try:
            response = await client.post(OLLAMA_URL, json=payload, timeout=60)
            response.raise_for_status()
            result = response.json()
            # Adaptar la respuesta al formato que espera Flutter
            ai_message = result["choices"][0]["message"]
            return {"message": ai_message}
        except Exception as e:
            return {"message": {"role": "assistant", "content": f"Error: {str(e)}"}}

@app.get("/")
def root():
    return {"message": "Ollama proxy backend is running."} 