all: markdown word pdf R

pdf: Neotoma_paper.Rmd
	Rscript -e "library('rmarkdown'); render('Neotoma_paper.Rmd', 'pdf_document')"

word: Neotoma_paper.Rmd
	Rscript -e "library('rmarkdown'); render('Neotoma_paper.Rmd', 'word_document')"

markdown: Neotoma_paper.Rmd
	Rscript -e "library('rmarkdown'); render('Neotoma_paper.Rmd', 'md_document')"

R: Neotoma_paper.Rmd
	Rscript -e "library('knitr'); purl('Neotoma_paper.Rmd')"
