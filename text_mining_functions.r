## Text Mining Functions

## Created by Simon thode

## Date: October 2023  

## Table of Contents:

# 1) Word_frequency: looks for word frequency in text held in a particular column
# 2) Function to count up bigrams - two word pharases - as they appear in the text column (excludes stopwords)
# 3) Function to create a network graph based from a text data frame - with minimal vertices and a search term included
# 4) Creates word vectors from a corpus


#Load libraries
library(pdftools)
library(tidytext)
library(dplyr)
library(tidyr)
library(readxl)
library(tm)
library(stopwords)
library(ggraph)
library(ggplot2)
library(igraph)
library(text2vec)


#Set up a remove_words vector - removes stopwords
remove_words <- stopwords("en", source = "snowball")
remove_words <- append(remove_words, letters) #append individual letters to the remove words_list


#1) function that takes a text dataframe and counts up common words in the text column; frequency notes the minimum frequency word to include
Word_frequency <- function(data, column, freq = 5) { 
  
  columnH <- deparse(substitute(column)) #Add quotes - eval(parse(column)) is the opposite
  
  #Summarise original dataset by variable 
  values <- data %>% count(!!enquo(column))
  colnames(values) <- c(columnH, "Rows")
  
  #Single words frame - Split corpus into words and remove stop words 
  corpus <- data %>% 
    unnest_tokens(word, text) %>% 
    filter(!(word %in% remove_words)) %>% 
    group_by(!!enquo(column))

  #Count 
  word_counts <- corpus %>% 
    count(word, sort = TRUE) %>% 
    filter(n > freq)
  
  word_counts <- word_counts %>% 
    left_join(values) %>% 
    mutate(percent = round(n / Rows, 3)) 
  
  #Rename
  colnames(word_counts) <- c(columnH, "Word", "Mentions", "Rows", "How many responses mention it") 
  
  return(word_counts)

}



#2) Function to count up bigrams - two word pharases - as they appear in the text column
Bigram_frequency <- function(data, column, freq = 2) { 
  
  columnH <- deparse(substitute(column)) #Add quotes - eval(parse(column)) is the opposite
  
  #Create bigram frame 
  bigrams_df <- text_df %>% 
    unnest_tokens(bigram, text, token = "ngrams", n = 2) %>%
    separate(bigram, c("word1", "word2"), sep = " ") %>%
    filter(!(word1 %in% remove_words)) %>% 
    filter(!(word2 %in% remove_words)) %>% 
    filter(!grepl('^\\d+$', word1)) %>%
    filter(!grepl('^\\d+$', word2)) %>%
    filter(!is.na(word1) & !is.na(word2)) %>%
    group_by(!!enquo(column))
    #unite(bigram, word1, word2, sep = " ") #unites the two words into a single column

  #Count 
  bigram_counts <- bigrams_df %>% 
    unite(bigram, word1, word2, sep = " ") %>%
    count(bigram, sort = TRUE) %>% 
    filter(n > freq)
  
  colnames(bigram_counts) <- c(columnH, "Concept", "Number of specific mentions") #
  
  return(bigram_counts)

}



#3) Function to create a network graph based from a text data frame - with minimal vertices and a search term included
create_network_graph <- function(data = text_df, column = "text", search_term = "prison", filter = 20, Heading = "Heading", graph_type = "g2") {
  
  #Subset data 
  temp <- data %>% 
    filter(grepl(search_term, text, ignore.case = TRUE))
  
  #Create bigram frame - script from above 
  bigrams_df <- temp %>% 
    unnest_tokens(bigram, text, token = "ngrams", n = 2) %>%
    separate(bigram, c("word1", "word2"), sep = " ") %>%
    filter(!(word1 %in% remove_words)) %>% 
    filter(!(word2 %in% remove_words)) %>% 
    filter(!grepl('^\\d+$', word1)) %>%
    filter(!grepl('^\\d+$', word2)) %>%
    filter(!is.na(word1) & !is.na(word2)) %>%
    #group_by(!!enquo(column))
    unite(bigram, word1, word2, sep = " ")
   
  #Split bigram words into two columns 
  bigrams_separated <- bigrams_df %>%
    separate(bigram, c("word1", "word2"), sep = " ")
  
  #Filter out stop words 
  bigrams_filtered <- bigrams_separated %>%
    filter(!word1 %in% stop_words$word) %>%
    filter(!word2 %in% stop_words$word)
  
  #Count up bigrams
  bigram_counts <- bigrams_filtered %>% 
    count(word1, word2, sort = TRUE)
  
  #Create a network graph that keeps only those with above n repetitions 
  bigram_graph <- bigram_counts %>% 
    filter(n > filter) %>%
    graph_from_data_frame()
  
  if(graph_type == "g1") {
    
    #Set up graph one
    g1 <- ggraph(bigram_graph, layout = "fr") +
      geom_edge_link(aes(label = n),
                     edge_colour = "royalblue",
                     angle_calc = "along"
                     ) +
      geom_node_point(size = 5) +
      geom_node_text(aes(label = name),
                     vjust = 1,
                     hjust = 1,
                     repel = TRUE,
                     point.padding = unit(0.2, "lines")) +
      labs(title = "Word Relations in Open Text Responses", x = "Year of observation", y = "Number of individuals") +
      theme_minimal() +
      theme(axis.text.x = element_blank(),
            axis.text.y = element_blank(),
            strip.text = element_blank(),
            text = element_blank())
    
    return(g1)
    
    
  }
  
  if(graph_type == "g2") {
    
    #Set up graph two 
    a <- grid::arrow(type = "closed", length = unit(.15, "inches"))
    g2 <- ggraph(bigram_graph, layout = "fr") +
      geom_edge_link(aes(edge_alpha = n, label = n),
                     show.legend = FALSE,
                     arrow = a,
                     end_cap = circle(.07, 'inches'),
                     angle_calc = "along") +
      geom_node_point(color = "lightblue", size = 5) +
      geom_node_text(aes(label = name), vjust = 1, hjust = 1, size = 4, repel = TRUE) +
      theme_void()
    
    return(g2)
    
  }

  

}



# 4) Creates word vectors from a corpus
word_vector_function <- function(data = text_df) {
  
  #Single words frame - Split corpus into words and remove stop words 
  corpus <- data %>% 
    unnest_tokens(word, text) %>% 
    #anti_join(stop_words) %>%
    #filter(!(word %in% remove_words)) %>% 
    group_by(filename)
  
  
  corpus_words = list(corpus$word)
  it = itoken(corpus_words, progressbar = FALSE)
  corpus_vocab = create_vocabulary(it)
  corpus_vocab = prune_vocabulary(corpus_vocab, term_count_min = 5)
  
  
  #Map words to indices
  vectorizer = vocab_vectorizer(corpus_vocab)
  
  #Use window of 10 for context words
  corpus_tcm = create_tcm(it, vectorizer, skip_grams_window = 10)
  
  glove = GlobalVectors$new(rank = 50, x_max = 20)
  corpus_wv_main = glove$fit_transform(corpus_tcm, n_iter = 200, convergence_tol = 0.00001)
  
  corpus_wv_context = glove$components
  corpus_word_vectors = corpus_wv_main + t(corpus_wv_context)
  
  return(corpus_word_vectors)
  
}



vector_output <- function(Terms, word_vectors) {
  
  cosine_similarity <- sim2(x = word_vectors, y = Terms, method = "cosine", norm = "l2")
  
  Related_Words <- head(sort(cosine_similarity[,1], decreasing = TRUE), 10) %>% as.data.frame()
  
  return(Related_Words)
  
}



