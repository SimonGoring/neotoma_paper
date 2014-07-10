#  PANDOC file:
library(knitr)

knit('Neotoma_paper.Rmd', encoding = "utf-8")
system("pandoc -o neotoma_paper.pdf Neotoma_paper.md")
