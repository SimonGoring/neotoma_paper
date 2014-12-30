
library(devtools)
install_github('rmarkdown', 'rstudio')
install_github('neotoma', 'ropensci')

library(rmarkdown)
render('Neotoma_paper.Rmd', 'word_document')
render('Neotoma_paper.Rmd', 'pdf_document')
