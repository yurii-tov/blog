(setq blog-directory "~/blog")


(defun blog-export-post ()
  (require 'ox-html)
  (org-mark-element)
  (let* ((title (org-get-heading t))
         (post (buffer-substring-no-properties (region-beginning) (region-end)))
         (id (string-replace ":" "" (format-time-string "%F_%T")))
         (timestamp (format-time-string "%F %T"))
         (post (with-temp-buffer
                 (insert post)
                 (beginning-of-buffer)
                 (end-of-line)
                 (newline)
                 (insert (format "[%s]" timestamp))
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
    `((id . ,id)
      (title . ,title)
      (timestamp . ,timestamp)
      (post . ,post))))


(defun blog-add ()
  (interactive)
  (let* ((post (blog-export-post))
         (default-directory blog-directory)
         (index "index.html")
         (file (format "posts/%s/post.html" (cdr (assoc 'id post))))
         (link (format "<div class=\"post-link\">
        <span class=\"timestamp\">[%s]</span
        ><a href=\"posts/%s/post.html\">%s</a>
      </div>"
                       (cdr (assoc 'timestamp post))
                       (cdr (assoc 'id post))
                       (cdr (assoc 'title post)))))
    (make-directory (file-name-parent-directory file) t)
    (with-temp-buffer
      (insert-file-contents "post.html")
      (beginning-of-buffer)
      (search-forward "<!-- post -->")
      (newline)
      (insert (cdr (assoc 'post post)))
      (write-file file))
    (with-temp-buffer
      (insert-file-contents index)
      (beginning-of-buffer)
      (search-forward "<!-- posts -->")
      (newline)
      (insert link)
      (write-file index))))


(defun blog-publish ()
  (interactive)
  (let ((default-directory blog-directory))
    (shell-command "git add * && git commit -m 'post added' && git push")))


(with-eval-after-load 'org
  (keymap-set org-mode-map "C-c C-b" 'blog-add))
