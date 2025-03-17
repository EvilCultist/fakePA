with open('vocab.txt','r') as f:
    data = f.read().strip().split()
with open('words.txt','r') as f:
    worddata = list(map(lambda x:x.strip(),f.readlines()))
with open('vectors.txt','a') as f:
    for j in worddata:
        l = [0]*len(data)
        for i in j.split():
            if len(i) > 2:
                l[data.index(i)] += 1
        string = ''
        for y in l:
            string += str(y)
        f.write(f'{string}\n')
