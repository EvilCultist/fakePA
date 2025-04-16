from os import system

with open('words.txt','r') as f:
    worddata = list(map(lambda x:x.strip(),f.readlines()))
for symp in worddata:
    system("curl http://localhost:11434/api/embeddings -d" + " '{" + f'"model": "mxbai-embed-large", "prompt": "Represent this sentence for searching relevant passages: {symp}"' + "}'" + ">> temp.txt")
    system("printf '\n' >> temp.txt")
