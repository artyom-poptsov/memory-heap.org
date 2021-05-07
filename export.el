#!/usr/bin/emacs --script

(require 'org)


(defconst %output-dir    "./output")
(defconst %static-dir    (concat %output-dir "/static"))
(defconst %poetry-dir    (concat %output-dir "/poetry"))
(defconst %images-dir    (concat %static-dir "/images"))
(defconst %poetry-page-template   "poetry-page-template.org")
(defconst %poetry-list-template   "poetry-list-template.org")

(defconst %input-poetry-dir "./poetry/")


(setq org-publish-project-alist
      `(("memory-heap"
         :base-directory       "."
         :publishing-function  org-html-publish-to-html
         :publishing-directory ,%output-dir
         :section-numbers      nil
         :table-of-contents    nil)
        ("memory-heap-poetry"
         :base-directory       "./poetry/"
         :base-extension       "org"
         :publishing-function  org-html-publish-to-html
         :publishing-directory ,%poetry-dir
         :section-numbers      nil
         :table-of-contents    nil
         :recursive            t)
        ("memory-heap-static"
         :base-directory       "./static/"
         :base-extension       any
         :recursive            t
         :publishing-directory ,%static-dir
         :publishing-function  org-publish-attachment)))


(defun get-string-from-file (path)
  "Return filePath's file content."
  (with-temp-buffer
    (insert-file-contents path)
    (buffer-string)))

(defun read-lines (path)
  "Return a list of lines of a file at filePath."
  (with-temp-buffer
    (insert-file-contents path)
    (split-string (buffer-string) "\n" t)))

(defun replace-in-string (what with in)
  (replace-regexp-in-string (regexp-quote what) with in nil 'fixedcase))


(defun write-poetry (template input-file output-file)
  (let* ((content          (get-string-from-file input-file))
         (title            (car (read-lines input-file))))
    (princ (concat "      title: " title "\n"))
    (let ((result (replace-in-string "{{text}}"
                                     content
                                     (replace-in-string "{{title}}"
                                                        title
                                                        template))))
    (with-temp-file output-file
      (insert result)))
    title))

(defun generate-output-file-name (year input-file)
  (concat %input-poetry-dir "/" year "/"
          (concat (file-name-base input-file) ".org")))

(defun make-year-header (year)
  (concat "\n* " year "\n"))

(defun make-poetry-record (link title)
  (concat "** [[" link "][" title "]]\n"))

(defun generate-poetry ()
  (let ((template (get-string-from-file %poetry-page-template))
        (list-template (get-string-from-file %poetry-list-template))
        (list-result   ""))
    (princ "generating poetry org-files ...\n")
    (mapc (lambda (year)
            (princ (concat "  processing " year " ...\n"))
            (setq list-result (concat list-result (make-year-header year)))
            (mapc (lambda (input-file)
                    (princ (concat "    processing " input-file " ...\n"))
                    (let ((title (write-poetry template
                                               (concat %input-poetry-dir "/" year "/" input-file)
                                               (generate-output-file-name year input-file))))
                      (setq list-result (concat
                                         list-result
                                         (make-poetry-record
                                          (concat "./poetry/" year "/"
                                                  (file-name-base input-file) ".html")
                                          title)))))
                  (directory-files (concat %input-poetry-dir "/" year) nil ".*txt" t)))
          (directory-files %input-poetry-dir nil "[0-9]+" t))
    (let ((output (replace-in-string "{{content}}" list-result list-template)))
      (with-temp-file "poetry.org"
        (insert output)))))


(defun export-to-html ()
    (unless (file-exists-p %output-dir)
      (make-directory %output-dir))
  (org-publish-project "memory-heap")

  (unless (file-exists-p %poetry-dir)
    (make-directory %poetry-dir))
  (org-publish-project "memory-heap-poetry")

  (unless (file-exists-p %static-dir)
    (make-directory %static-dir))
  (org-publish-project "memory-heap-static"))

(generate-poetry)
(export-to-html)

;; Local Variables:
;; mode: Emacs-Lisp
;; End:

