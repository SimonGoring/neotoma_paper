
library(devtools)
install_github('rmarkdown', 'rstudio')
library(rmarkdown)
render('Neotoma_paper.Rmd', 'word_document')