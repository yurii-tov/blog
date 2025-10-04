(defun blog-export-post ()
  (org-mark-element)
  (let* ((post (buffer-substring-no-properties (region-beginning) (region-end)))
         (post (with-temp-buffer
                 (insert post)
                 (mark-whole-buffer)
                 (org-export-region-to-html)
                 (beginning-of-buffer)
                 (search-forward "outline-2")
                 (insert " post")
                 (buffer-substring-no-properties
                  (point-min) (point-max)))))
    (deactivate-mark)
    post))


(defun blog-add ()
  (interactive)
  (let ((post (blog-export-post)))
    (with-current-buffer "index.html"
      (beginning-of-buffer)
      (search-forward "<!-- posts -->")
      (open-line 1)
      (insert post)
      (save-buffer))))
