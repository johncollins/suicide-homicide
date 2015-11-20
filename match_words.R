#install.packages("quanteda")
library(stringdist)

match_wordsets <- function(text1, text2, bijective=F) {
    scorematrix <- stringdistmatrix(text1, text2, method='cosine')
    inds <- apply(scorematrix, 1, which.min)
    scores <- apply(scorematrix, 1, min)
    matched_to = text2[inds]
    score.df <- data.frame(word1=text1, 
                           word2=matched_to,
                           score=scores)
    if (bijective) {
        score.df <- score.df %>% 
            group_by(word2) %>%
            arrange(score) %>%
            do(head(., n=1))
    }
    rownames(score.df) <- seq_len(nrow(score.df))
    score.df
}