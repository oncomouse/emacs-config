;;; consult-project-hunks.el --- Search git hunks project-wide with consult
;;; -*- lexical-binding: t; -*-

(require 'consult)
(require 'cl-lib)

(defcustom consult-project-hunks-command
  "git --no-pager diff --no-color HEAD"
  "Shell command emitting the project diff.
Must be standard unified diff output, run from the repo root."
  :type 'string
  :group 'consult)

(defun consult-project-hunks--parse (diff)
  "Parse unified DIFF text into ((FILE START . TEXT) ...) in file order."
  (let (results current-file current)
    (dolist (line (split-string diff "\n"))
      (cond
       ((string-match "\\`\\+\\+\\+\\s-+\\(?:[ab]/\\)?\\(.+\\)\\'" line)
        (setq current-file (match-string 1 line)
              current nil))
       ((string-match
         "\\`@@\\s-+-[0-9]+\\(?:,[0-9]+\\)?\\s-+\\+\\([0-9]+\\)\\(?:,[0-9]+\\)?\\s-+@@"
         line)
        (push (list current-file (string-to-number (match-string 1 line)))
              results)
        (setq current (car results)))
       ((and current (> (length line) 0) (not (cddr current))
             (memq (aref line 0) '(?  ?+ ?-)))
        (setcdr (cdr current) (substring line 1)))))
    (nreverse results)))

(defun consult-project-hunks--root ()
  "Return the git repo root as a directory string, or nil."
  (ignore-errors
    (let ((root (string-trim
                 (shell-command-to-string "git rev-parse --show-toplevel"))))
      (file-truename root))))

(defun consult-project-hunks--candidates (diff root)
  "Build `consult-location' candidates from DIFF for project ROOT.
Each candidate carries a live marker in its `consult-location' text
property, exactly like `consult-grep'."
  (let ((candidates)
        (index 0))
    (dolist (e (consult-project-hunks--parse diff) (nreverse candidates))
      (pcase-let* ((`(,file ,start . ,text) e)
                   (path (expand-file-name file root))
                   (buf (or (get-file-buffer path)
                            (and (file-exists-p path)
                                 (find-file-noselect path)))))
        (when buf
          (setq index (1+ index))
          (with-current-buffer buf
            (let ((marker (copy-marker
                           (save-excursion
                             (goto-char (point-min))
                             (forward-line (1- start))
                             (point)))))
              (push (consult--location-candidate
                     (consult--format-file-line-match file start (or text ""))
                     marker start index)
                    candidates))))))))

(defun consult-project-hunks ()
  "Search git hunks across the current project and jump to them."
  (interactive)
  (let ((root (consult-project-hunks--root)))
    (unless root (user-error "Not inside a git repository"))
    (let* ((default-directory root)
           (diff (shell-command-to-string consult-project-hunks-command))
           (candidates (consult-project-hunks--candidates diff root)))
      (unless candidates (user-error "No changes found in this project"))
      (consult--jump
       (consult--read candidates
                      :prompt "Go to hunk: "
                      :sort nil
                      :require-match t
                      :category 'consult-location
                      :lookup #'consult--lookup-location
                      :state (consult--jump-state))))))

(provide 'consult-project-hunks)
;;; consult-project-hunks.el ends here
