- **take the symtoms from online**
- **use a wordnet to link similiar terms to the term for the input**

eg.
```json
"headache" {
  "headache": 1,
  "head": 0.8,
  "ache": 0.1,
  }
```

- **take the input**<br>
mera sir dukh raha hai
- **translate it**<br>
my head is aching
- **tokenise the input**<br>
my    --> x<br>
head  --> head<br>
is    --> x<br>
aching--> ache<br>

- **compare to symptoms**<br>
headache - 0.9,
stomachache - 0.1,
bleeding - 0.1,

- **Take every symptom above a threashhold value, eg 0.7**
- **Maybe use deep learning + patient data from faker to fine tune the values from wordnet**
