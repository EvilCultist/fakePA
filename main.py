import requests
import json
import re

def fetch_and_save_symptoms():
    fhir_valueset_url = "https://build.fhir.org/ig/HL7/fhir-COVID19Library-ig/ValueSet-covid19-signs-1nd-symptoms-value-set.json"

    try:
        response = requests.get(fhir_valueset_url)
        response.raise_for_status()

        valueset_data = response.json()

        symptoms = []
        for concept in valueset_data.get("compose", {}).get("include", []):
            for item in concept.get("concept", []):
                symptom = item.get("display", "Unknown Symptom").lower().strip()
                symptom = re.sub(r'[^\w\s]', '', symptom)
                symptom = symptom.replace("finding", "").strip()
                if symptom:
                    symptoms.append(symptom)

        with open("symptoms.json", "w") as json_file:
            json.dump(symptoms, json_file, indent=4)

        print(f"Saved {len(symptoms)} symptoms to 'symptoms.json'.")
    except Exception as e:
        print(f"An error occurred: {e}")

fetch_and_save_symptoms()

def load_symptoms():
    try:
        with open("symptoms.json", "r") as file:
            symptoms = json.load(file)
        print("Symptoms successfully loaded.")
        return symptoms
    except FileNotFoundError:
        print("Symptoms file not found. Please ensure 'symptoms.json' exists.")
        return []
    except json.JSONDecodeError:
        print("Error decoding the symptoms file.")
        return []

symptoms = load_symptoms()

def find_matching_symptoms(user_input, symptoms):
    matched = []
    user_input_normalized = re.sub(r'[^\w\s]', '', user_input.lower().strip())
    for symptom in symptoms:
        if symptom in user_input_normalized:
            matched.append(symptom.capitalize())
    return matched


def ask_severity_questions(symptom):
    print(f"Chatbot: Can you describe the severity of your {symptom.lower()}? (e.g., mild, moderate, severe)")
    severity = input("You: ").strip()
    print(f"Chatbot: Thank you for sharing. ({severity})")

    print(f"Chatbot: How frequently do you experience {symptom.lower()}? (e.g., occasionally, daily, constantly)")
    frequency = input("You: ").strip()
    print(f"Chatbot: Thank you for sharing. ({frequency})")

    print(f"Chatbot: When did your {symptom.lower()} start? (e.g., 2 days ago, 1 week ago)")
    duration = input("You: ").strip()
    print(f"Chatbot: Thank you for sharing. ({duration})")

def chatbot():
    if not symptoms:
        print("Unable to load symptoms. Exiting chatbot.")
        return

    print("Chatbot: Hi! Please describe your symptoms.")
    while True:
        user_input = input("You: ").strip()
        if user_input.lower() in ["exit", "quit"]:
            print("Chatbot: Thank you! Take care and feel better!")
            break

        matches = find_matching_symptoms(user_input, symptoms)
        if matches:
            print(f"Chatbot: Based on your input, I found these related symptoms: {', '.join(matches)}.")
            for match in matches:
                ask_severity_questions(match)
            print("Chatbot: Would you like to share more symptoms or exit?")
        else:
            print("Chatbot: I'm sorry, I couldn't match your symptoms. Could you please describe them in more detail?")


chatbot()


