import re
from fuzzywuzzy import fuzz
import nltk
from itertools import combinations as combos
from copy import deepcopy

# Download NLTK resources (Only needs to be run once)
nltk.download('stopwords')

# Expanded stopwords list
expanded_stopwords = [
    'hello', 'hi', 'hey', 'greetings', 'morning', 'evening', 'okay', 'thanks', 
    'please', 'sorry', 'sure', 'wow', 'oops', 'ah', 'uh', 'well', 'I', 'you', 
    'me', 'your', 'my', 'the', 'a', 'an', 'is', 'it', 'to', 'of', 'and', 'for', 
    'on', 'at', 'by', 'with', 'about', 'as', 'from', 'but', 'not', 'this', 
    'that', 'which', 'who', 'whom', 'their', 'ours', 'ourselves', 'they', 
    'them', 'we', 'us', 'ourselves', 'all', 'any', 'how', 'how’s', 'what', 'what’s', 
    'where', 'where’s', 'when', 'when’s', 'why', 'why’s', 'can', 'could', 'will', 
    'would', 'shall', 'should', 'may', 'might', 'must', 'ought', 'each', 'every', 
    'anybody', 'someone', 'thing', 'something','got','get'
]

# Combine with NLTK stopwords
stopwords = set(nltk.corpus.stopwords.words('english')) | set(expanded_stopwords)

# List of symptoms directly in code
symptoms_list = []
with open('try.txt','r') as f:
    symptoms_list.extend(f.read().split('\n'))

# Beautify the input text (remove stopwords, punctuation)
def beautify_string(text):
    text = text.lower()  # Convert to lowercase
    text = re.sub(r'\W', ' ', text)  # Remove punctuation
    text = re.sub(r'\s+', ' ', text)  # Replace multiple spaces with a single space
    words = text.split()  # Tokenize into words
    words = [word for word in words if word not in stopwords]  # Remove stopwords
    return words

# Function to check for symptoms in the user input
def check_symptoms_optimization(user_input, symptoms_list, threshold=55):
    user_input_words = beautify_string(user_input)
    found_symptoms = []

    # Check fuzzy matching with symptoms list
    for symptom in symptoms_list:
        if fuzz.partial_ratio(' '.join(user_input_words), symptom.lower()) > threshold:
            found_symptoms.append(symptom)
    return found_symptoms, user_input_words

def check_symptoms(user_input,symptoms_list,threshold=55):
    symptoms_list,user_input = check_symptoms_optimization(user_input,symptoms_list,30)
    ansset = set()
    inp_dict =  dict()
    for i in user_input:
        inp_dict[i] = set(check_symptoms_optimization(i,symptoms_list,80)[0])

    keys_dict = list(inp_dict.keys())
    for i in keys_dict:
        if len(inp_dict[i]) == 0:
            del inp_dict[i]
    keys_dict = list(inp_dict.keys())
    i = 5
    while i != 0:
        combinations = combos(keys_dict,i)
        for combo in combinations:
            newset = deepcopy(inp_dict[combo[0]])
            for y in range(i):
                if y == 0:
                    continue
                newset.intersection_update(inp_dict[combo[y]])
            if len(newset):
                ansset = ansset|newset
    
        i -= 1

    tempset = deepcopy(ansset)
    for symptoms in tempset:
        le_count = 0
        for keywords in keys_dict:
            for eachword in symptoms.split():
                # print(keywords,eachword)
                if re.match(keywords,eachword) != None:
                    le_count += 1
                    break
        if (le_count/len(symptoms.split())) < threshold/100:
            ansset.remove(symptoms)

    if len(ansset) == 0:
        return [' '.join(user_input)]
    return ansset


# Main chatbot loop
def chatbot():
    print("Welcome to the Health Chatbot!")
    print("Tell me your symptoms or type 'exit' to quit.")
    
    while True:
        # Take user input
        user_input = input("You: ")
        
        if user_input.lower() == 'exit':
            print("Goodbye!")
            break
        
        # Check for symptoms
        check_symptoms(user_input, symptoms_list)

if __name__ == '__main__':
    # Run the chatbot
    chatbot()
