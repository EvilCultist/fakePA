function removeStopwords(inputList, stopwords) {
    // Filter out the words in inputList that are present in stopwords
    return inputList.filter(word => !stopwords.includes(word));
}

function tokenizeString(inputString) {
    // Remove underscores, then match words and convert to lowercase
    const tokens = inputString
        .replace(/_/g, ' ') // Replace underscores with spaces
        .match(/\b[a-zA-Z0-9']+\b/g); // Match words containing letters, digits, and apostrophes

    return tokens ? tokens.map(token => token.toLowerCase()) : [];
}

// Function to compute the dot product of two vectors
function dotProduct(A, B) {

    return A.reduce((sum, a, index) => sum + a * B[index], 0);
  }
  
  // Function to compute the magnitude (or norm) of a vector
function magnitude(A) {
    return Math.sqrt(A.reduce((sum, a) => sum + a * a, 0));
  }
  
  // Function to compute the cosine similarity between two vectors
function cosineSimilarity(A, B) {
    const dot = dotProduct(A, B);
    const magA = magnitude(A);
    const magB = magnitude(B);
    
    // Check to prevent division by zero
    if (magA === 0 || magB === 0) {
      return 0; // If either vector has magnitude 0, return similarity as 0
    }
  
    return dot / (magA * magB);
  }

  // Function to sort an array of vectors based on the cosine similarity to the given vector, with a threshold
function sortVectorsByCosineSimilarity(vectors, targetVector, threshold = 0) {
    // Create an array of tuples: [cosine similarity, index]
    const similarities = vectors.map((vector, index) => {
      const similarity = cosineSimilarity(vector, targetVector);
      return {
        index: index,          // Store the original index
        similarity: similarity // Store the similarity value
      };
    });
  
    // Log similarities for debugging
    console.log('Similarities with Indices:', similarities);
  
    // Filter out vectors with similarity less than the threshold
    const filteredSimilarities = similarities.filter(item => item.similarity >= threshold);
  
    // Log filtered similarities
    console.log('Filtered similarities:', filteredSimilarities);
  
    // Sort the similarities by cosine similarity in descending order
    filteredSimilarities.sort((a, b) => b.similarity - a.similarity);
  
    // Return the indices of the vectors sorted by similarity
    return filteredSimilarities.map(item => item.index);
  }

var vocab = (await (await fetch('/vocab.txt')).text()).split(/\s/); //can also be .json() or .other_set_type
var vectors = await (await fetch('/vectors.txt')).text();
vectors = vectors.split('\n');
var words = (await (await fetch('/words.txt')).text()).split('\n');

const str = "I have a ache in stomach" ;
const tokens = tokenizeString(str);
const stopwords = ["youve", 'have', 'only', "isnt", 'll', 'may', "hadnt", 'their', 'about', "theyll", 'will', 'well', "dont", 'there', 'ain', 'ours', 'ought', 'so', 'having', 'whom', 'all', 'ourselves', 'am', 'what', "mustnt", 'o', 'needn', 'because', "theyd", 'been', 'who', "theyve", 'until', "arent", 'some', 'in', 'i', 'nor', 'other', 'must', 'wheres', 'for', 'them', 'every', 'uh', 'any', 'its', 'evening', 'anybody', 'themselves', 'down', 'hadn', 'd', "doesnt", 'but', "thatll", 'itself', "weve", 'a', 'before', "didnt", 'further', 'under', "neednt", 'isn', "shes", 'you', 'weren', 'won', "ill", 'has', "shed", 'here', 'someone', 'don', 'why', 'how', 'own', 'oops', "couldnt", 'shan', 'sorry', 'during', 'over', 'into', 'most', 'when', 'our', 'these', 'more', 'to', 'with', 'thing', 'of', 'as', 'does', 'can', 'is', 'get', 'his', 'he', "wasnt", 'which', 'your', 'didn', 'hey', 'at', 'ah', 'out', 'mustn', 'hers', 'from', "hes", 'aren', 'I', 'himself', 'mightn', 've', 'both', 'yourself', "youre", 'after', 'same', 'off', 'm', 're', "well", 'this', 'could', "id", "im", 'through', 'wouldn', "youd", 'okay', 'got', 'yours', 'would', 'greetings', 'shouldn', "mightnt", 'then', 'too', 'an', 'below', 'whens', 'wasn', 'my', 'shall', 'hasn', 'him', "hasnt", 'were', 'be', 'doesn', "were", "ive", 'they', 'thanks', 'each', "werent", 'and', "havent", 'against', 'between', 'she', 'the', 'haven', "shell", 'are', "itd", 'whys', 'wow', 'whats', 'hows', "shouldnt", 'might', 'yourselves', 'do', 'again', 'me', "shouldve", 'had', 'very', 'should', 'if', 't', 'hi', "youll", 'being', 'y', "shant", 'myself', 'up', "wont", 'no', 'was', 'hello', 'by', 'such', 'that', 'her', 'than', 'once', "its", 'herself', 'doing', "hed", 'couldn', 'not', 'we', "wed", 'above', 'now', 'few', 'while', 'please', 'on', 'did', 'something', "itll", 'sure', 'those', "hell", 's', 'it', 'morning', 'us', 'theirs', "theyre", 'where', "wouldnt", 'just', 'or', 'ma'];
//console.log(tokens);
const worklist = removeStopwords(tokens, stopwords);
//console.log(worklist);

let matrix = [];

for (let i = 0; i < vectors.length; i++) {
    matrix[i] = Array.from(vectors[i], char => Number(char));    
}
let sentenceVec = vocab.map(word => {
    // Count occurrences of the word in smallerArr if it exists in arr
    return worklist.filter(item => item === word).length;
  });

const threshold = 0.5;
const sortedIndices = sortVectorsByCosineSimilarity(matrix, sentenceVec, threshold);
for (let i = 0; i < sortedIndices.length; i++){
    console.log(words[sortedIndices[i]]);
}