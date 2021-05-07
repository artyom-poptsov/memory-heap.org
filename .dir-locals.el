((nil . ((org-publish-project-alist
          . (("memory-heap"
               :base-directory "./"
               :publishing-function org-html-publish-to-html
               :publishing-directory "./output/"
               :section-numbers nil
               :table-of-contents nil
               :style "<link rel=\"stylesheet\"
                href=\"static/css/mystyle.css\"
                type=\"text/css\"/>")
              ("images"
               :base-directory "~/images/"
               :base-extension "jpg\\|gif\\|png"
               :publishing-directory "./output/static/images/"
               :publishing-function org-publish-attachment)))
         (org-html-postamble-format
          . (("ru"
              "\
<table style=\"width: 100%%\"><tr><td>
<p class=\"date\">Updated: %d</p>\n<p class=\"creator\">%c</p>\n
<p class=\"validation\">
Made with <a href=\"https://lispers.org/\" class=\"lambda\">λ</a>
</td>
</tr></table>"))))))
