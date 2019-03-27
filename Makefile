DIR="docs"

gitbook:
	Rscript --quiet _render.R "bookdown::gitbook"

pdf:
	Rscript --quiet _render.R "bookdown::pdf_book"

all: pdf gitbook epub

serve:
	Rscript --quiet -e "servr::httd('docs', port = 5555, host = '0.0.0.0')"

clean:
	rm -f Estimation-Paper.Rmd
	rm -f Estimation-Paper.log
	rm -f Estimation-Paper.spl
	rm -f Estimation-Paper.tex
	rm -f Estimation-Paper.pdf
	rm -f .DS_Store
	rm -rf _bookdown_files

cleanall:
	make clean && rm -rf $(DIR)

epub:
	Rscript --quiet _render.R "bookdown::epub_book"

.PHONY: all app

