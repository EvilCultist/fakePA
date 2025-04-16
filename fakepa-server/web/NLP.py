import json,re,os

#VARIABLES
stopwords = ["youve", 'have', 'only', "isnt", 'll', 'may', "hadnt", 'their', 'about', "theyll", 'will', 'well', "dont", 'there', 'ain', 'ours', 'ought', 'so', 'having', 'whom', 'all', 'ourselves', 'am', 'what', "mustnt", 'o', 'needn', 'because', "theyd", 'been', 'who', "theyve", 'until', "arent", 'some', 'in', 'i', 'nor', 'other', 'must', 'wheres', 'for', 'them', 'every', 'uh', 'any', 'its', 'evening', 'anybody', 'themselves', 'down', 'hadn', 'd', "doesnt", 'but', "thatll", 'itself', "weve", 'a', 'before', "didnt", 'further', 'under', "neednt", 'isn', "shes", 'you', 'weren', 'won', "ill", 'has', "shed", 'here', 'someone', 'don', 'why', 'how', 'own', 'oops', "couldnt", 'shan', 'sorry', 'during', 'over', 'into', 'most', 'when', 'our', 'these', 'more', 'to', 'with', 'thing', 'of', 'as', 'does', 'can', 'is', 'get', 'his', 'he', "wasnt", 'which', 'your', 'didn', 'hey', 'at', 'ah', 'out', 'mustn', 'hers', 'from', "hes", 'aren', 'I', 'himself', 'mightn', 've', 'both', 'yourself', "youre", 'after', 'same', 'off', 'm', 're', "well", 'this', 'could', "id", "im", 'through', 'wouldn', "youd", 'okay', 'got', 'yours', 'would', 'greetings', 'shouldn', "mightnt", 'then', 'too', 'an', 'below', 'whens', 'wasn', 'my', 'shall', 'hasn', 'him', "hasnt", 'were', 'be', 'doesn', "were", "ive", 'they', 'thanks', 'each', "werent", 'and', "havent", 'against', 'between', 'she', 'the', 'haven', "shell", 'are', "itd", 'whys', 'wow', 'whats', 'hows', "shouldnt", 'might', 'yourselves', 'do', 'again', 'me', "shouldve", 'had', 'very', 'should', 'if', 't', 'hi', "youll", 'being', 'y', "shant", 'myself', 'up', "wont", 'no', 'was', 'hello', 'by', 'such', 'that', 'her', 'than', 'once', "its", 'herself', 'doing', "hed", 'couldn', 'not', 'we', "wed", 'above', 'now', 'few', 'while', 'please', 'on', 'did', 'something', "itll", 'sure', 'those', "hell", 's', 'it', 'morning', 'us', 'theirs', "theyre", 'where', "wouldnt", 'just', 'or', 'ma']
symptoms_word_emb = []
worddata = []
threshold = 0.85

#FUNCTIONS

def cos_sim(a,b):
    summ,moda,modb = 0,0,0
    for i in range(len(a)):
        summ += a[i]*b[i]
        moda += a[i]*a[i]
        modb += b[i]*b[i]
    return summ/((moda*modb)**(0.5))

def beautify_string(text):
    text = text.lower()  # Convert to lowercase
    text = re.sub(r'\W', ' ', text)  # Remove punctuation
    text = re.sub(r'\s+', ' ', text)  # Replace multiple spaces with a single space
    words = text.split()  # Tokenize into words
    words = [word for word in words if word not in stopwords]  # Remove stopwords
    return words

with open('vectors.txt','r') as f:
    data = f.read().split('}')[:-1]
    for i in data:
        symptoms_word_emb.append(json.loads(i+'}')['embedding'])

with open('words.txt','r') as f:
    worddata = [x.strip() for x in f.readlines()]

sentence = input("Enter your ailment ")
sentenceList = beautify_string(sentence)
symplist = []
temp = []

# print(sentenceList)
for word in sentenceList:
    os.system("curl http://localhost:11434/api/embeddings -d" + " '{" + f'"model": "mxbai-embed-large", "prompt": "Represent this sentence for searching relevant passages: {word}"' + "}'" + "> sentence_embedding.txt")
    with open('sentence_embedding.txt','r') as f:
        embeddingdata = json.loads(f.read())['embedding']
    print(len(symptoms_word_emb),len(worddata))
    for index,i in enumerate(symptoms_word_emb):
        x = cos_sim(embeddingdata,i)
        if x > threshold  and worddata[index] != 'pain':
            if len(temp) == 0:
                temp.append((x,worddata[index]))
            else:
                if temp[0][0] < x:
                    temp[0] = (x,worddata[index])
    symplist.extend(temp)
    temp.clear()
        
# print(symplist)


