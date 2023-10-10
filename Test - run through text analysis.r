##
## Text analysis of historical research
##

# Created by Simon Thode, October 2023


#Clear work space
rm(list=ls())

#Load functions
source('./text_mining_functions.r')

#Set work directory
setwd("./")

#Load a tidy data frame - texts read into a data set, with text in a column labelled 'text'
#You can use the python scripts to do this:
# - PDFtoText.py: converts PDFs in the folder into text files. The text in text file format are easier to manipulate
# - TextDataFrameCreator.py: Puts text files from the folder into a dataset format and saves it

#Import the tidy data frame version of the text here
text_df <- read_excel('./tidy_df.xlsx')

## NOTE, the tidy text format was created using the python scripts listed above

#Convert tidy text into a tibble
text_df <- tibble(filename = text_df$filename,
                  text = text_df$text)

#Check word frequency of the texts
Word_frequency(text_df, "text", freq = 50)

#Check bigrams of the text
Bigram_frequency(text_df, "text", freq = 10)

#Produce network graph of the text
create_network_graph(data = text_df, column = "text", search_term = "*", filter = 15, graph_type = "g2")


