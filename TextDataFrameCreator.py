##Analysis Packages
import pandas as pd
import numpy as np
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from tqdm import tqdm
import PyPDF2

from nltk.corpus import PlaintextCorpusReader
import ftfy
import os

##PDF miner reads text in pdfs better and doesn't string words together
#note, in Python 3 you need to pip install pdfminer.six - it's a wrapper that let's it work in Python 3
from pdfminer.pdfinterp import PDFResourceManager, PDFPageInterpreter
from pdfminer.converter import TextConverter
from pdfminer.layout import LAParams
from pdfminer.pdfpage import PDFPage
from io import StringIO

#Set path
path = './History of Science Texts'

# Create Corpus
my_corpus = PlaintextCorpusReader(path, '.*\.txt')

#List of texts in corpus
corpus_names = my_corpus.fileids()

#Create text dataframe
reviews = []
for fileid in my_corpus.fileids():
    filename = fileid
    reviews.append((filename, my_corpus.raw(fileid)))

df = pd.DataFrame(reviews, columns=['filename', 'text'])


## Cleanse text
stop_words = set(stopwords.words('english')) #Get stop words

df['text'] = df['text'].apply(lambda x : ftfy.fix_text(x)) #Fix text with ftfy
df['text'] = df['text'].replace('\n', ' ', regex=True) #Replace /n with spaces
df['text'] = df['text'].apply(lambda x : x.strip()) #Strip whitespace
#df['text'] = df['text'].apply(lambda x : x.lower()) #lower case
#df['text'] = df['text'].apply(lambda x : word_tokenize(x)) #Tokenise strings
#df['text'] = df['text'].apply(lambda x : [t for t in x if not t in stop_words]) #Remove stopwords
#df['text'] = df['text'].apply(lambda x : [t for t in x if t.isalpha()]) #Remove non-alpha text


#Save tidy_text
df.to_excel('./tidy_df.xlsx', index = False)


