symptoms = [
    "Tightness in Chest",
    "Cold Sweats",
    "Lightheadedness",
    "Shortness of Breath (Dyspnea)",
    "Pain Radiating to Jaw",
    "Fatigue",
    "Palpitations",
    "Nausea and Vomiting",
    "Swelling in Legs and Ankles",
    "Cough with Pink Frothy Sputum",
    "Chest Discomfort",
    "Heartburn",
    "Cyanosis (Bluish Skin or Lips)",
    "Chest Tenderness",
    "Irregular Heartbeat",
    "Back Pain",
    "Extreme Thirst",
    "Pain in Left Shoulder",
    "Difficulty Sleeping (Orthopnea)",
    "Fainting (Syncope)",
    "Rapid Heart Rate",
    "Persistent Cough",
    "Numbness in Arms",
    "Weakness in Legs",
    "Difficulty Breathing During Activity",
    "Leg Cramps",
    "Pounding Heartbeat",
    "Excessive Urination at Night",
    "Blurry Vision",
    "Cold Hands and Feet",
    "Pain in Upper Abdomen",
    "Chest Heaviness",
    "Dry Mouth",
    "Pale Skin",
    "Pain in Right Side of Chest",
    "Hot Flushes",
    "Racing Heart",
    "Pain Between Shoulder Blades",
    "Jaw Pain",
    "Breathing Difficulties During Sleep",
    "Sore Throat",
    "Dizziness with Activity",
    "Elevated Blood Pressure",
    "Numbness in Face",
    "Restlessness",
    "Chronic Fatigue",
    "Swollen Abdomen",
    "Unexplained Weight Loss",
    "Chest Stabbing Pain",
    "Hiccups",
    "Coughing Up Blood",
    "Difficulty Swallowing",
    "Excessive Snoring",
    "Elevated Heart Rate at Rest",
    "Heart Murmur",
    "Persistent Fatigue with No Relief",
    "Acid Reflux",
    "Gasping for Air",
    "Chronic Swelling of the Abdomen",
    "Dull Chest Pain",
    "Sweating Without Exertion",
    "Blackouts or Loss of Vision",
    "Excessive Thirst",
    "Numbness in Feet",
    "Pale or Ashen Face",
    "Cold Extremities",
    "Bloating and Fullness in the Stomach",
    "Racing Pulse",
    "Pain in Left Arm",
    "Fever",
    "Pain in the Neck",
    "Anxiety and Chest Tightness",
    "Faintness or Lightheadedness with Standing",
    "Hoarseness",
    "Persistent Pain in Chest with Movement",
    "Dry Skin",
    "Severe Headache",
    "Sudden Weight Gain",
    "Leg Weakness",
    "Lack of Appetite",
    "Pain in the Right Shoulder",
    "Persistent Throat Clearing",
    "Loss of Balance",
    "Chest Pain After Eating",
    "Pain in Lower Abdomen",
    "Sudden Shortness of Breath",
    "Persistent Hiccups",
    "Severe Back Pain",
    "Unexplained Coldness in Hands or Feet",
    "Sweaty Palms", "pressure in chest" , "squeezing in chest", "angina", "myocardial infarction", "coronary artery disease", "excessive sweating",
"shock", "faintness", "dizziness", "hypotension","sensation of not getting enough air", "pain that starts in the chest","pain moves to jaw and neck", "persistent tiredness",
"heart failure", "irregular heartbeat","rapid heartbeat","fluttering chest", "pounding chest","discomfort stomach","queasiness","swelling",
"frothy pink tinged sputum","fluid in lungs","mild pain in chest", ""]



# defaultPrompt = 'what is bigger pi square or g'
with open("default_prompt.txt", 'r') as f:
    lines = f.readlines()
    defaultPromptPart1 = "".join(lines[:5])
    defaultPromptPart2 = "".join(lines[5:])



# Patient - "hey I am dying"
# you: {
# 	"status": "PLEASE REPROMPT",
# 	"reprompt with": "Please explain your situation in more detail so I can redirect you to the appropriate doctor"
# }

# Here are some examples of typical patient interactions you should handle:
# Example 1:
# Patient: "I’ve had a cough and cold for a few days."
# you: {
# 	"status": "OK",
# 	"symptoms": [
# 		"cough",
# 		"cold"
# 	]
# }
# Example 2:
# Patient: "I’m feeling pain."
# Chatbot: {
# 	"status": "PLEASE REPROMPT",
# 	"reprompt with": "Please explain where you are experiencing pain"


", ".join(symptoms)


stri = "you can only choose from specific list of symptoms"
prompts = defaultPromptPart1 + stri + ", ".join(symptoms) + defaultPromptPart2


