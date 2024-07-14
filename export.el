#!/usr/bin/emacs --script

(require 'org)


(defconst %output-dir    "./output")
(defconst %static-dir    (concat %output-dir "/static"))
(defconst %poetry-dir    (concat %output-dir "/poetry"))
(defconst %images-dir    (concat %static-dir "/images"))
(defconst %photos-dir    (concat %output-dir "/photos"))
(defconst %projects-dir  (concat %output-dir "/projects"))
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
        ("memory-heap-photos"
         :base-directory       "./photos/"
         :base-extension       "jpg"
         :recursive            t
         :publishing-directory ,%photos-dir
         :publishing-function  org-publish-attachment)
        ("memory-heap-photo-albums"
         :base-directory       "./photos/"
         :base-extension       "org"
         :publishing-directory ,%photos-dir
         :publishing-function  org-html-publish-to-html)

        ;; Guile-SSH
        ("memory-heap-projects-guile-ssh"
         :base-directory       "./projects/guile-ssh/"
         :base-extension       "org"
         :publishing-directory ,(concat %projects-dir "/guile-ssh/")
         :publishing-function  org-html-publish-to-html)
        ("memory-heap-projects-guile-ssh-manual"
         :base-directory       "./projects/guile-ssh/manual/"
         :base-extension       "html"
         :publishing-directory ,(concat %projects-dir "/guile-ssh/manual/")
         :publishing-function  org-publish-attachment)

        ;; Guile-SMC
        ("memory-heap-projects-guile-smc"
         :base-directory       "./projects/guile-smc/"
         :base-extension       "org"
         :publishing-directory ,(concat %projects-dir "/guile-smc/")
         :publishing-function  org-html-publish-to-html)
        ("memory-heap-projects-guile-smc-manual"
         :base-directory       "./projects/guile-smc/manual/"
         :base-extension       "html"
         :publishing-directory ,(concat %projects-dir "/guile-smc/manual/")
         :publishing-function  org-publish-attachment)

        ;; Guile-ICS
        ("memory-heap-projects-guile-ics"
         :base-directory       "./projects/guile-ics/"
         :base-extension       "org"
         :publishing-directory ,(concat %projects-dir "/guile-ics/")
         :publishing-function  org-html-publish-to-html)
        ("memory-heap-projects-guile-ics-manual"
         :base-directory       "./projects/guile-ics/manual/"
         :base-extension       "html"
         :publishing-directory ,(concat %projects-dir "/guile-ics/manual/")
         :publishing-function  org-publish-attachment)

        ;; Guile-DSV
        ("memory-heap-projects-guile-dsv"
         :base-directory       "./projects/guile-dsv/"
         :base-extension       "org"
         :publishing-directory ,(concat %projects-dir "/guile-dsv/")
         :publishing-function  org-html-publish-to-html)
        ("memory-heap-projects-guile-dsv-manual"
         :base-directory       "./projects/guile-dsv/manual/"
         :base-extension       "html"
         :publishing-directory ,(concat %projects-dir "/guile-dsv/manual/")
         :publishing-function  org-publish-attachment)

        ;; Static
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
                                                        template)))
          (notes-file (concat (file-name-directory input-file)
                              (file-name-base input-file)
                              "-notes.org")))
      (let ((result (if (file-exists-p notes-file)
                        (concat result
                                "\n"
                                (get-string-from-file notes-file))
                      result)))
        (princ  (concat
                 (file-name-directory input-file)
                 (file-name-base input-file)
                 "-notes.org\n"))
        (with-temp-file output-file
          (insert result)))
      title)))

(defun generate-output-file-name (year input-file)
  (concat %input-poetry-dir "/" year "/"
          (concat (file-name-base input-file) ".org")))

(defun make-year-header (year)
  (concat "\n* " year "\n"))

(defun make-poetry-record (link title)
  (concat " - [[" link "][" title "]]\n"))

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
                  (directory-files (concat %input-poetry-dir "/" year) nil ".*txt" nil)))
          (reverse (directory-files %input-poetry-dir nil "[0-9]+" nil)))
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

  (org-publish-project "memory-heap-photos")
  (org-publish-project "memory-heap-photo-albums")

  (org-publish-project "memory-heap-projects-guile-ssh")
  (org-publish-project "memory-heap-projects-guile-ssh-manual")

  (org-publish-project "memory-heap-projects-guile-smc")
  (org-publish-project "memory-heap-projects-guile-smc-manual")

  (org-publish-project "memory-heap-projects-guile-ics")
  (org-publish-project "memory-heap-projects-guile-ics-manual")

  (org-publish-project "memory-heap-projects-guile-dsv")
  (org-publish-project "memory-heap-projects-guile-dsv-manual")

  (unless (file-exists-p %static-dir)
    (make-directory %static-dir))
  (unless (file-exists-p (concat %static-dir "/css"))
    (make-directory (concat %static-dir "/css")))
  (org-publish-project "memory-heap-static"))

(generate-poetry)
(export-to-html)

;; Local Variables:
;; mode: Emacs-Lisp
;; End:
