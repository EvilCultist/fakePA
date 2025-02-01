import json
import requests
import os
from symptoms import prompts

OLLAMA_MODEL = "llama3.2:latest"

# defaultPrompt = 'what is bigger pi square or g'
with open("default_prompt.txt", 'r') as f:
    defaultPrompt = "".join(f.readlines())

diff_port = os.getenv("OLLAMA_HOST")

def getSymptoms(pin, DEBUG=False):
    prompt = defaultPrompt + pin
    # prompt = prompts + prompt
    if diff_port:
        url = "http://" + os.getenv("OLLAMA_HOST") + "/api/generate"
    else:
        url = "http://localhost:11434/api/generate"
    headers = {
            "Content-Type": "application/json"
    }

    while True:
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
            try:
                actual_response = json.loads(actual_response)
            except:
                prompt = defaultPrompt + "make sure your output contains only valid json, and nothing else, now, what would you say if your input was - " + pin
            print(actual_response)
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

