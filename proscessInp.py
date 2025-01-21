import json
import requests
import os

OLLAMA_MODEL = "llama3.2:latest"

# defaultPrompt = 'what is bigger pi square or g'
with open("default_prompt.txt", 'r') as f:
    defaultPrompt = "".join(f.readlines())

diff_port = os.getenv("OLLAMA_HOST")

def getSymptoms(prompt, DEBUG=False):
    prompt = defaultPrompt + prompt
    if diff_port:
        url = "http://" + os.getenv("OLLAMA_HOST") + "/api/generate"
    else:
        url = "http://localhost:11434/api/generate"

    headers = {
            "Content-Type": "application/json"
    }

    data = {
            "model": OLLAMA_MODEL,
            "prompt": prompt,
            "stream": False
    }

    response = requests.post(url, headers=headers, data=json.dumps(data))

    if response.status_code == 200:
        txtOut = response.text
        data = json.loads(txtOut)
        actual_response = data["response"]
        actual_response = json.loads(actual_response)
        if DEBUG:
            print(actual_response["status"])
            if actual_response["status"]=="OK":
                print(actual_response["symptoms"])
            else:
                print(actual_response["reprompt with"])
        return actual_response
    else:
        print("status code: \t", response.status_code)
        print(response.text)
        return {"status": response.status_code, "why": response.text}

