;;; consult-hunks.el --- Jump to git hunks with consult  -*- lexical-binding: t; -*-

;;; Commentary:

;; Provides `consult-hunks', a command to search and jump to modified
;; git hunks in the current buffer, using `diff-hl' to find them and
;; `consult' to complete, preview, and jump.

;;; Code:

(require 'consult)
(require 'diff-hl)
(require 'cl-lib)

(defun consult-hunks--candidates ()
  "Collect hunk candidates for the current buffer."
  (let ((hunks (cl-remove-if-not
                (lambda (o) (overlay-get o 'diff-hl-hunk))
                (overlays-in (point-min) (point-max))))
        (candidates))
    (save-excursion
      (dolist (o (sort hunks
                       (lambda (a b) (< (overlay-start a) (overlay-start b)))))
        (goto-char (overlay-start o))
        (let* ((marker (point-marker))
               (line (line-number-at-pos))
               (str (consult--buffer-substring (line-beginning-position)
                                               (line-end-position)
                                               'fontify)))
          (unless (string-blank-p str)
            (push (consult--location-candidate str marker line marker)
                  candidates)))))
    (nreverse candidates)))

(defun consult-hunks ()
  "Search and jump to modified git hunks in the current buffer.

Uses `diff-hl' to locate hunks and `consult' for completion with live
preview. Requires `diff-hl-mode' to be active in the buffer."
  (interactive)
  (let ((candidates (consult-hunks--candidates)))
    (unless candidates
      (user-error "No changes found in this buffer"))
    (consult--jump
     (consult--read candidates
                    :prompt "Go to hunk: "
                    :annotate (consult--line-fontify (line-number-at-pos))
                    :category 'consult-location
                    :sort nil
                    :require-match t
                    :lookup #'consult--line-match
                    :state (consult--jump-state)))))

(provide 'consult-hunks)
;;; consult-hunks.el ends here
