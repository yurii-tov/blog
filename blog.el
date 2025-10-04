(setq blog-directory "~/blog")


(defun blog-export-post ()
  (org-mark-element)
  (let* ((post (buffer-substring-no-properties (region-beginning) (region-end)))
         (post (with-temp-buffer
                 (insert post)
                 (beginning-of-buffer)
                 (end-of-line)
                 (newline)
                 (org-timestamp '(16) 'inactive)
                 (open-line 1)
                 (mark-whole-buffer)
                 (org-export-region-to-html)
                 (replace-regexp-in-region
                  "style=\"[^\"]*\"" ""
                  (point-min))
                 (replace-string-in-region
                  "<a href" "<a target=\"blank\" href"
                  (point-min))
                 (beginning-of-buffer)
                 (search-forward "outline-2")
                 (insert " post")
                 (buffer-substring-no-properties
                  (point-min) (point-max)))))
    (deactivate-mark)
    post))


(defun blog-add ()
  (interactive)
  (let ((default-directory blog-directory)
        (post (blog-export-post))
        (file "index.html"))
    (with-temp-buffer
      (insert-file-contents file)
      (beginning-of-buffer)
      (search-forward "<!-- posts -->")
      (newline)
      (insert post)
      (write-file file))))


(defun blog-publish ()
  (interactive)
  (let ((default-directory blog-directory))
    (shell-command "git add * && git commit -m 'post added' && git push")))


(with-eval-after-load 'org
  (keymap-set org-mode-map "C-c C-b" 'blog-add))
