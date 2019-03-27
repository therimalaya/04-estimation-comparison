DIR="docs"

gitbook:
	Rscript --quiet _render.R "bookdown::gitbook"

pdf:
	Rscript --quiet _render.R "bookdown::pdf_book"

all: pdf gitbook epub

serve:
	Rscript --quiet -e "servr::httd('docs', port = 5555, host = '0.0.0.0')"

clean:
	rm -rf $(DIR) && rm main*.* && rm -rf _bookdown_files

epub:
	Rscript --quiet _render.R "bookdown::epub_book"

.PHONY: all app

