all: cv
	emacs --script ./export.el

cv:
	emacs \
		--batch \
		-q \
		--eval '(progn (find-file "cv.org") (org-latex-export-to-pdf))'
