all: cv.pdf
	emacs --script ./export.el

cv.pdf: cv.org
	@emacs \
		--batch \
		-q \
		--eval '(progn (find-file "cv.org") (org-latex-export-to-pdf))'

clean:
	rm cv.pdf
	rm -rf output
