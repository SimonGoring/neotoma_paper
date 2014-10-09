all: word pdf

pdf: Neotoma_paper.Rmd
	Rscript -e "library('rmarkdown'); render('Neotoma_paper.Rmd', 'pdf_document')"

word: Neotoma_paper.Rmd
	Rscript -e "library('rmarkdown'); render('Neotoma_paper.Rmd', 'word_document')"
