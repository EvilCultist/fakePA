vocab = set()
with open('try.txt','r') as f:
    data = f.readlines()
for i in data:
    for j in i.split():
        if len(j) > 2:
            vocab.add(j)
with open('vocab.txt','w') as f:
    for i in vocab:
        f.write(f'{i} ')
