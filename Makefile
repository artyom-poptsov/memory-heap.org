all: cv
	emacs --script ./export.el

cv: output/cv.pdf

output/cv.pdf: cv.org
	@emacs \
		--batch \
		-q \
		--eval '(progn (find-file "cv.org") (org-latex-export-to-pdf))'
	mv cv.pdf output/cv.pdf

clean:
	rm -rf output
