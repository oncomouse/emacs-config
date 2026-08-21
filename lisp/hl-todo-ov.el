;;; hl-todo-ov.el --- Highlight TODO and similar keywords using overlays -*- lexical-binding:t -*-

;; Copyright (C) 2013-2026 Jonas Bernoulli
;; Ported to overlays by automated conversion

;; Author: Jonas Bernoulli <emacs.hl-todo@jonas.bernoulli.dev>
;; Homepage: https://github.com/tarsius/hl-todo
;; Keywords: convenience

;; Package-Version: 3.9.4-ov
;; Package-Requires: (
;;     (emacs    "28.1")
;;     (compat   "31.0")
;;     (cond-let  "1.1")
;;     (ov       "1.0"))

;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; This is a port of hl-todo.el from font-lock to overlays using ov.el.
;; It highlights TODO and similar keywords in comments and strings using overlays.

;;; Code:

(require 'compat)
(require 'cond-let)
(require 'ov)
(eval-when-compile (require 'subr-x))
(eval-when-compile (require 'cl-lib))

(defvar grep-find-template)
(declare-function grep-read-files "grep" (regexp))
(declare-function flymake-make-diagnostic "flymake")

(define-obsolete-variable-alias 'hl-todo--syntax-table
  'hl-todo-syntax-table "Hl-Todo 3.9.0")

(defgroup hl-todo nil
  "Highlight TODO and similar keywords in comments and strings."
  :group 'font-lock-extra-types)

(defface hl-todo
  '((t (:bold t :foreground "#cc9393")))
  "Base face used to highlight TODO and similar keywords."
  :group 'hl-todo)

(defcustom hl-todo-include-modes '(prog-mode text-mode conf-mode)
  "Major-modes in which `hl-todo-mode' is activated."
  :package-version '(hl-todo . "3.7.0")
  :group 'hl-todo
  :type '(repeat function))

(defcustom hl-todo-exclude-modes '(org-mode)
  "Major-modes in which `hl-todo-mode' is not activated."
  :package-version '(hl-todo . "3.1.0")
  :group 'hl-todo
  :type '(repeat function))

(defcustom hl-todo-text-modes '(text-mode)
  "Major-modes that are considered text-modes."
  :package-version '(hl-todo . "2.1.0")
  :group 'hl-todo
  :type '(repeat function))

(defcustom hl-todo-keyword-faces
  '(("HOLD"   . "#d0bf8f")
    ("TODO"   . "#cc9393")
    ("NEXT"   . "#dca3a3")
    ("THEM"   . "#dc8cc3")
    ("PROG"   . "#7cb8bb")
    ("OKAY"   . "#7cb8bb")
    ("DONT"   . "#5f7f5f")
    ("FAIL"   . "#8c5353")
    ("DONE"   . "#afd8af")
    ("NOTE"   . "#d0bf8f")
    ("MAYBE"  . "#d0bf8f")
    ("KLUDGE" . "#d0bf8f")
    ("HACK"   . "#d0bf8f")
    ("TEMP"   . "#d0bf8f")
    ("WIP"    . "#d0bf8f")
    ("FIXME"  . "#cc9393")
    ("DEBUG"  . "#cc9393")
    ("XXXX*"  . "#cc9393"))
  "An alist mapping keywords to colors/faces used to display them."
  :package-version '(hl-todo . "3.5.0")
  :group 'hl-todo
  :type '(repeat (cons (string :tag "Keyword")
                       (choice :tag "Face   "
                               (string :tag "Color")
                               (sexp :tag "Face"))))
  :set (lambda (symbol value)
         (set-default-toplevel-value symbol value)
         (dolist (buf (buffer-list))
           (with-current-buffer buf
             (when (and (bound-and-true-p hl-todo-mode)
                        (boundp 'hl-todo--regexp))
               (setq hl-todo--regexp nil)
               (hl-todo-mode -1)
               (hl-todo-mode 1))))))

(defface hl-todo-flymake-type '((t :inherit font-lock-keyword-face))
  "Face used for the Flymake diagnostics type `hl-todo-flymake'."
  :group 'hl-todo)

(defcustom hl-todo-color-background nil
  "Whether to emphasize keywords using the background color."
  :package-version '(hl-todo . "3.1.0")
  :group 'hl-todo
  :type 'boolean)

(defcustom hl-todo-keyword-delimiters 'symbol
  "Delimiters placed around the regexp used to match keywords."
  :package-version '(hl-todo . "3.9.0")
  :group 'hl-todo
  :type '(choice (const :tag "Wrap with \\_<...\\_>" symbol)
                 (const :tag "Wrap with \\<...\\>" word)
                 (const :tag "No delimiters" nil)))

(defcustom hl-todo-wrap-movement nil
  "Whether movement commands wrap around when there are no more matches."
  :package-version '(hl-todo . "3.4.0")
  :group 'hl-todo
  :type 'boolean)

(defcustom hl-todo-highlight-punctuation ""
  "String of characters to highlight after keywords."
  :package-version '(hl-todo . "2.0.0")
  :group 'hl-todo
  :type 'string)

(defcustom hl-todo-require-punctuation nil
  "Whether to require punctuation after keywords."
  :package-version '(hl-todo . "3.3.0")
  :group 'hl-todo
  :type 'boolean)

(defvar hl-todo-syntax-table (copy-syntax-table text-mode-syntax-table)
  "Syntax table used while searching for TODO keywords.")

(defvar-local hl-todo--regexp nil)

(defsubst hl-todo--regexp (&optional no-symbol)
  "Return regular expression matching TODO or similar keyword."
  (or hl-todo--regexp (hl-todo--setup-regexp no-symbol)))

(defun hl-todo--setup-regexp (&optional no-symbol)
  "Setup keyword regular expression."
  (when-let ((bomb (assoc "???" hl-todo-keyword-faces)))
    (setq hl-todo-keyword-faces (delete bomb hl-todo-keyword-faces)))
  (setq hl-todo--regexp
        (concat "\\("
                (pcase hl-todo-keyword-delimiters
                  ('symbol (if no-symbol "\\<" "\\_<"))
                  ('word   "\\<")
                  (_       ""))
                "\\(" (mapconcat #'car hl-todo-keyword-faces "\\|") "\\)"
                (pcase hl-todo-keyword-delimiters
                  ('symbol (if no-symbol "\\>" "\\_>"))
                  ('word   "\\>")
                  (_       ""))
                (and (not (equal hl-todo-highlight-punctuation ""))
                     (concat "[" hl-todo-highlight-punctuation "]"
                             (if hl-todo-require-punctuation
                                 (if no-symbol "\\+" "+")
                               "*")))
                "\\)")))

(defun hl-todo--inside-comment-or-string-p ()
  "Check syntax state if point is located inside comment or string literal."
  (nth 8 (syntax-ppss)))

(defun hl-todo--get-face ()
  "Return face for current keyword during font locking."
  (let ((keyword (match-string 2)))
    (hl-todo--combine-face
     (cdr (or
           (assoc keyword hl-todo-keyword-faces)
           (compat-call assoc keyword hl-todo-keyword-faces
                        (lambda (a b)
                          (string-match-p (format "\\`%s\\'" a) b))))))))

(defun hl-todo--combine-face (color)
  "Combine COLOR string with `hl-todo' default face."
  (if (stringp color)
      `((,(if hl-todo-color-background :background :foreground)
         ,color)
        hl-todo)
    color))

(defun hl-todo--overlay-apply ()
  "Create overlay for current match if inside comment/string or text mode."
  (when (or (apply #'derived-mode-p hl-todo-text-modes)
            (save-excursion
              (goto-char (match-beginning 1))
              (hl-todo--inside-comment-or-string-p)))
    (let* ((beg (match-beginning 1))
           (end (match-end 1))
           (face (hl-todo--get-face)))
      ;; Clear existing hl-todo overlay at this region
      (ov-clear beg end 'hl-todo t)
      ;; Create new overlay
      (ov beg end
          'face face
          'hl-todo t
          'priority 5000))))

(defvar hl-todo--overlay-keywords
  `((,(lambda (bound) (hl-todo--search nil bound))
     (1 (hl-todo--overlay-apply) prepend t)))
  "Font-lock keywords that create overlays for hl-todo.")

(defvar-keymap hl-todo-mode-map
  :doc "Keymap for `hl-todo-mode'.")

;;;###autoload
(define-minor-mode hl-todo-mode
  "Highlight TODO and similar keywords in comments and strings using overlays."
  :lighter ""
  :keymap hl-todo-mode-map
  :group 'hl-todo
  (if hl-todo-mode
      (progn
        (font-lock-add-keywords nil hl-todo--overlay-keywords t)
        (font-lock-flush))
    (font-lock-remove-keywords nil hl-todo--overlay-keywords)
    (ov-clear 'hl-todo))
  (font-lock-mode 1))

;;;###autoload
(define-globalized-minor-mode global-hl-todo-mode
  hl-todo-mode hl-todo--turn-on-mode-if-desired)

(defun hl-todo--turn-on-mode-if-desired ()
  "Enable local minor mode `hl-todo-mode' if test succeeds."
  (when (and (apply #'derived-mode-p hl-todo-include-modes)
             (not (apply #'derived-mode-p hl-todo-exclude-modes))
             (not (bound-and-true-p enriched-mode))
             (not (string-prefix-p " *temp*" (buffer-name))))
    (hl-todo-mode 1)))

;; Movement commands - unchanged from original
;;;###autoload
(defun hl-todo-next (arg)
  "Jump to the next TODO or similar keyword."
  (interactive "p")
  (if (< arg 0)
      (hl-todo-previous (- arg))
    (while (and (> arg 0)
                (not (eobp))
                (progn
                  (when (let ((case-fold-search nil))
                          (looking-at (hl-todo--regexp)))
                    (goto-char (match-end 0)))
                  (or (hl-todo--search)
                      (if hl-todo-wrap-movement
                          nil
                        (user-error "No more matches")))))
      (decf arg))
    (when (> arg 0)
      (let ((pos (save-excursion
                   (goto-char (point-min))
                   (let ((hl-todo-wrap-movement nil))
                     (hl-todo-next arg))
                   (point))))
        (goto-char pos)))))

(defun hl-todo--search (&optional regexp bound backward)
  "Search for keyword REGEXP, optionally up to BOUND and BACKWARD."
  (unless regexp
    (setq regexp (hl-todo--regexp)))
  (cl-block nil
    (while (let ((case-fold-search nil)
                 (syntax-ppss-table (syntax-table)))
             (with-syntax-table hl-todo-syntax-table
               (funcall (if backward #'re-search-backward #'re-search-forward)
                        regexp bound t)))
      (cond ((or (apply #'derived-mode-p hl-todo-text-modes)
                 (hl-todo--inside-comment-or-string-p))
             (cl-return t))
            ((and bound (funcall (if backward #'<= #'>=) (point) bound))
             (cl-return nil))))))

;;;###autoload
(defun hl-todo-previous (arg)
  "Jump to the previous TODO or similar keyword."
  (interactive "p")
  (if (< arg 0)
      (hl-todo-next (- arg))
    (while (and (> arg 0)
                (not (bobp))
                (let ((start (point)))
                  (hl-todo--search (concat (hl-todo--regexp) "\\=") nil t)
                  (or (hl-todo--search nil nil t)
                      (progn (goto-char start)
                             (if hl-todo-wrap-movement
                                 nil
                               (user-error "No more matches"))))))
      (goto-char (match-end 0))
      (decf arg))
    (when (> arg 0)
      (let ((pos (save-excursion
                   (goto-char (point-max))
                   (let ((hl-todo-wrap-movement nil))
                     (hl-todo-previous arg))
                   (point))))
        (goto-char pos)))))

;;;###autoload
(defun hl-todo-occur ()
  "Use `occur' to find all TODO or similar keywords."
  (interactive)
  (with-syntax-table hl-todo-syntax-table
    (occur (hl-todo--regexp))))

;;;###autoload
(defun hl-todo-rgrep (regexp &optional files dir confirm)
  "Use `rgrep' to find all TODO or similar keywords."
  (interactive
    (progn
      (require 'grep)
      (grep-compute-defaults)
      (unless grep-find-template
        (error "grep.el: No `grep-find-template' available"))
      (let ((regexp (with-temp-buffer (hl-todo--regexp t))))
        (list regexp
              (grep-read-files regexp)
              (read-directory-name "Base directory: " nil default-directory t)
              current-prefix-arg))))
  (rgrep regexp files dir confirm))

;;;###autoload
(defun hl-todo-flymake (report-fn &rest _plist)
  "Flymake backend for `hl-todo-mode'."
  (let ((diags nil)
        (buf (current-buffer))
        (comment (concat (regexp-quote comment-start) "\\s-+")))
    (when hl-todo-mode
      (save-excursion
        (save-restriction
          (save-match-data
            (goto-char (point-min))
            (while (hl-todo--search)
              (let ((keyword (match-string 1))
                    (beg (match-beginning 0))
                    (end (pos-eol))
                    (bol (pos-bol)))
                (save-excursion
                  (goto-char beg)
                  (unless (looking-back comment bol)
                    (goto-char bol)
                    (when (and (not (looking-at-p "\\S-"))
                               (re-search-forward "\\S-" beg t))
                      (forward-char -1))
                    (re-search-forward comment beg t)
                    (setq beg (point))))
                (push (hl-todo-make-flymake-diagnostic
                       buf beg end (buffer-substring-no-properties beg end)
                       keyword)
                      diags)))))))
    (funcall report-fn (nreverse diags))))

(defun hl-todo-make-flymake-diagnostic (locus beg end text _keyword)
  (flymake-make-diagnostic locus beg end 'hl-todo-flymake text))

(put 'hl-todo-flymake 'flymake-category 'flymake-note)
(put 'hl-todo-flymake 'flymake-type-name "todo")
(put 'hl-todo-flymake 'face nil)
(put 'hl-todo-flymake 'mode-line-face 'hl-todo-flymake-type)

;;;###autoload
(defun hl-todo-insert (keyword)
  "Read a TODO or similar keyword and insert it at point."
  (interactive
    (list (completing-read
           "Insert keyword: "
           (mapcan (pcase-lambda (`(,keyword . ,face))
                     (and (equal (regexp-quote keyword) keyword)
                          (list (propertize keyword 'face
                                            (hl-todo--combine-face face)))))
                   hl-todo-keyword-faces))))
  (let ((keyword (if (and hl-todo-require-punctuation
                          (length= hl-todo-highlight-punctuation 1))
                     (concat keyword hl-todo-highlight-punctuation)
                   keyword)))
    (cond
      ((hl-todo--inside-comment-or-string-p)
       (insert (concat (and (not (memq (char-before) '(?\s ?\t))) " ")
                       keyword
                       (and (not (memq (char-after) '(?\s ?\t ?\n))) " "))))
      ((and (eolp)
            (not (looking-back "^[\s\t]*" (line-beginning-position) t)))
       (insert (concat (and (not (memq (char-before) '(?\s ?\t))) " ")
                       (format "%s %s " comment-start keyword))))
      (t
       (goto-char (line-beginning-position))
       (insert (cond ((derived-mode-p 'lisp-mode 'emacs-lisp-mode)
                      (format "%s%s %s" comment-start comment-start keyword))
                     ((string-suffix-p " " comment-start)
                      (format "%s%s" comment-start keyword))
                     (t
                      (format "%s %s" comment-start keyword))))
       (unless (looking-at "[\s\t]*$")
         (save-excursion (insert "\n")))
       (indent-region (line-beginning-position) (line-end-position))))))

;;;###autoload
(defun hl-todo-search-and-highlight ()
  "Highlight TODO and similar keywords starting at point."
  (let ((case-fold-search nil)
        (regexp (hl-todo--regexp)))
    (while (re-search-forward regexp nil t)
      (when (or (apply #'derived-mode-p hl-todo-text-modes)
                (hl-todo--inside-comment-or-string-p))
        (let ((beg (match-beginning 1))
              (end (match-end 1))
              (face (hl-todo--get-face)))
          (ov-clear beg end 'hl-todo t)
          (ov beg end 'face face 'hl-todo t 'priority 5000))))))

(provide 'hl-todo-ov)
;;; hl-todo-ov.el ends here
