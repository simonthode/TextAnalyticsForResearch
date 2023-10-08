##Libraries to Analysis Packages
import pandas as pd
import numpy as np
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from tqdm import tqdm
import PyPDF2
import os

##PDF miner reads text in pdfs better and doesn't string words together
#note, in Python 3 you need to pip install pdfminer.six - it's a wrapper that let's it work in Python 3
from pdfminer.pdfinterp import PDFResourceManager, PDFPageInterpreter
from pdfminer.converter import TextConverter
from pdfminer.layout import LAParams
from pdfminer.pdfpage import PDFPage
from io import StringIO


### Extracting text from text PDF

#PDF Miner extractor
def convert_pdf_to_txt(path):
    rsrcmgr = PDFResourceManager()
    retstr = StringIO()
    codec = 'utf-8'
    laparams = LAParams()
    device = TextConverter(rsrcmgr, retstr, codec=codec, laparams=laparams)
    fp = open(path, 'rb')
    interpreter = PDFPageInterpreter(rsrcmgr, device)
    password = ""
    maxpages = 0
    caching = True
    pagenos=set()

    for page in PDFPage.get_pages(fp, pagenos, maxpages=maxpages, password=password,caching=caching, check_extractable=True):
        interpreter.process_page(page)

    text = retstr.getvalue()
    
    #if(text == ''):
    #    #If cannot extract text then use ocr to extract text
    #    text = OCR_a_PDF(path, rotate = 0)

    fp.close()
    device.close()
    retstr.close()
    return (text)

#Set path
path = './History of Science Texts/'

files = []
# r=root, d=directories, f = files
for r, d, f in os.walk(path):
    for file in f:
        if '.pdf' in file:
            files.append(os.path.join(r, file))

			
#Convert pdfs to text
for file in tqdm(files):
    pdfText = convert_pdf_to_txt(file)
    #docs += extractKeywords(pdfText)
    
    with open(file.replace(".pdf", ".txt"), "w", encoding='utf-8') as text_file:
        print(pdfText, file = text_file)


