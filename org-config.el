;; org-config.el --- custom org-mode settings and additional packages -*- lexical-binding: t; -*-

;;; ORG MODE
;; A GNU Emacs major mode for keeping notes, authoring documents,
;; computational notebooks, literate programming, maintaining to-do
;; lists, planning projects, and more — in a fast and effective plain
;; text system.
(use-package org
  :straight (org :type git :host github :repo "emacs-straight/org-mode")
  :defer t
  :mode ("\\.org\\'" . org-mode)
  :commands (org-mode org-agenda org-capture)
  :general
  (general-nmap
   "<leader> a" 'org-agenda
   "<leader> c" 'org-capture)
  :general-config
  (:keymaps 'org-mode-map
	    "C-M-<up>" 'org-up-element
	    "C-z" 'org-cycle-list-bullet)
  (general-nmap ;; Org open controls
    "<leader> o j" 'org-clock-goto
    "<leader> o l" 'org-clock-in-last
    "<leader> o i" 'org-clock-in
    "<leader> o o" 'org-clock-out
    "<leader> o a" 'org-agenda
    "<leader> o c" 'org-capture)
  (general-nmap :keymaps 'org-mode-map ;; Reproduce doom's org menu
    "<localleader> '" #'org-edit-special
    "<localleader> *" #'org-ctrl-c-star
    "<localleader> +" #'org-ctrl-c-minus
    "<localleader> ," #'org-switchb
    "<localleader> ." #'org-goto
    "<localleader> #" #'org-update-statistics-cookies
    "<localleader> @" #'org-cite-insert
    "<localleader> A" #'org-archive-subtree-default
    "<localleader> e" #'org-export-dispatch
    "<localleader> f" #'org-footnote-action
    "<localleader> h" #'org-toggle-heading
    "<localleader> i" #'org-toggle-item
    "<localleader> I" #'org-id-get-create
    "<localleader> k" #'org-babel-remove-result
    "<localleader> n" #'org-store-link
    "<localleader> q" #'org-set-tags-command
    "<localleader> t" #'org-todo
    "<localleader> T" #'org-todo-list
    "<localleader> x" #'org-toggle-checkbox
    "<localleader> a a" #'org-attach
    "<localleader> a d" #'org-attach-delete-one
    "<localleader> a D" #'org-attach-delete-all
    "<localleader> a n" #'org-attach-new
    "<localleader> a o" #'org-attach-open
    "<localleader> a O" #'org-attach-open-in-emacs
    "<localleader> a r" #'org-attach-reveal
    "<localleader> a R" #'org-attach-reveal-in-emacs
    "<localleader> a u" #'org-attach-url
    "<localleader> a s" #'org-attach-set-directory
    "<localleader> a S" #'org-attach-sync
    "<localleader> b -" #'org-table-insert-hline
    "<localleader> b a" #'org-table-align
    "<localleader> b b" #'org-table-blank-field
    "<localleader> b c" #'org-table-create-or-convert-from-region
    "<localleader> b e" #'org-table-edit-field
    "<localleader> b f" #'org-table-edit-formulas
    "<localleader> b h" #'org-table-field-info
    "<localleader> b s" #'org-table-sort-lines
    "<localleader> b r" #'org-table-recalculate
    "<localleader> b R" #'org-table-recalculate-buffer-tables
    "<localleader> b d c" #'org-table-delete-column
    "<localleader> b d r" #'org-table-kill-row
    "<localleader> b i c" #'org-table-insert-column
    "<localleader> b i h" #'org-table-insert-hline
    "<localleader> b i r" #'org-table-insert-row
    "<localleader> b i H" #'org-table-hline-and-move
    "<localleader> b t f" #'org-table-toggle-formula-debugger
    "<localleader> b t o" #'org-table-toggle-coordinate-overlays
    "<localleader> c c" #'org-clock-cancel
    "<localleader> c d" #'org-clock-mark-default-task
    "<localleader> c e" #'org-clock-modify-effort-estimate
    "<localleader> c E" #'org-set-effort
    "<localleader> c g" #'org-clock-goto
    "<localleader> c G" (lambda (&rest _ (interactive) (org-clock-goto 'select)))
    "<localleader> c i" #'org-clock-in
    "<localleader> c I" #'org-clock-in-last
    "<localleader> c o" #'org-clock-out
    "<localleader> c r" #'org-resolve-clocks
    "<localleader> c R" #'org-clock-report
    "<localleader> c t" #'org-evaluate-time-range
    "<localleader> c =" #'org-clock-timestamps-up
    "<localleader> c -" #'org-clock-timestamps-down
    "<localleader> d d" #'org-deadline
    "<localleader> d s" #'org-schedule
    "<localleader> d t" #'org-time-stamp
    "<localleader> d T" #'org-time-stamp-inactive
    "<localleader> g c" #'org-clock-goto
    "<localleader> g C" (lambda (&rest _ (interactive) (org-clock-goto 'select)))
    "<localleader> g i" #'org-id-goto
    "<localleader> g r" #'org-refile-goto-last-stored
    "<localleader> g x" #'org-capture-goto-last-stored
    "<localleader> l i" #'org-id-store-link
    "<localleader> l l" #'org-insert-link
    "<localleader> l L" #'org-insert-all-links
    "<localleader> l s" #'org-store-link
    "<localleader> l S" #'org-insert-last-stored-link
    "<localleader> l t" #'org-toggle-link-display
    "<localleader> P a" #'org-publish-all
    "<localleader> P f" #'org-publish-current-file
    "<localleader> P p" #'org-publish
    "<localleader> P P" #'org-publish-current-project
    "<localleader> P s" #'org-publish-sitemap
    "<localleader> r" #'org-refile
    "<localleader> R" #'org-refile-reverse
    "<localleader> s a" #'org-toggle-archive-tag
    "<localleader> s b" #'org-tree-to-indirect-buffer
    "<localleader> s c" #'org-clone-subtree-with-time-shift
    "<localleader> s d" #'org-cut-subtree
    "<localleader> s h" #'org-promote-subtree
    "<localleader> s j" #'org-move-subtree-down
    "<localleader> s k" #'org-move-subtree-up
    "<localleader> s l" #'org-demote-subtree
    "<localleader> s n" #'org-narrow-to-subtree
    "<localleader> s r" #'org-refile
    "<localleader> s s" #'org-sparse-tree
    "<localleader> s A" #'org-archive-subtree-default
    "<localleader> s N" #'widen
    "<localleader> s S" #'org-sort
    "<localleader> p d" #'org-priority-down
    "<localleader> p p" #'org-priority
    "<localleader> p u" #'org-priority-up)
  :hook ((org-mode . (lambda () (electric-indent-local-mode -1)))
         (org-mode  . turn-on-visual-line-mode)
         (org-agenda-mode . hl-line-mode)
         (org-agenda-mode . (lambda () (add-hook 'window-configuration-change-hook 'org-agenda-align-tags nil t)))
         (org-agenda-after-show . org-show-entry))
  :custom
  (org-beamer-mode t) ;; Export to beamer
  (org-catch-invisible-edits 'show)
  (org-complete-tags-always-offer-all-agenda-tags t) ;; Always use all tags from Agenda files in capture
  (org-edit-timestamp-down-means-later nil)
  (org-export-coding-system 'utf-8)
  (org-export-kill-product-buffer-when-displayed t)
  (org-fast-tag-selection-single-key 'expert)
  (org-hide-leading-stars nil)
  (org-html-validation-link nil)
  (org-imenu-depth 2)
  (org-indent-mode "noindent")
  (org-log-done t)
  (org-startup-indented nil)
  (org-support-shift-select t)
  (org-tags-column 50)
  (org-directory "~/org")
  (org-default-notes-file "~/org/inbox.org")
  ;; org-agenda:
  (org-agenda-files (list
                     "~/org/todo.org"
                     "~/org/inbox.org"))
  (org-agenda-compact-blocks t)
  (org-agenda-start-on-weekday 1)
  (org-agenda-span 7)
  (org-agenda-start-day nil)
  (org-agenda-include-diary t)
  (org-agenda-sorting-strategy
   '((agenda habit-down time-up effort-up category-keep)
     (todo category-up effort-up)
     (tags category-up effort-up)
     (search category-up)))
  (org-agenda-window-setup 'current-window)
  (org-agenda-custom-commands
   `(("N" "Notes" tags "NOTE"
      ((org-agenda-overriding-header "Notes")
       (org-tags-match-list-sublevels t)))))
  (setq-default org-agenda-clockreport-parameter-plist '(:link t :maxlevel 3))
  ;; org-archive:
  (org-archive-mark-done nil)
  (org-archive-location "%s_archive::* Archive")
  ;; org-capture:
  (org-capture-templates
   `(("t" "todo" entry (file+headline "" "Inbox") ; "" => `org-default-notes-file'
      "* TODO %?\n%t\n%i\n")))
  ;; org-refile:
  (org-refile-use-cache nil)
  (org-refile-targets '((nil :maxlevel . 5) (org-agenda-files :maxlevel . 5)))
  ;; Targets start with the file name - allows creating level 1 tasks
  (org-refile-use-outline-path t)
  (org-outline-path-complete-in-steps nil)
  ;; Allow refile to create parent tasks with confirmation
  (org-refile-allow-creating-parent-nodes 'confirm)
  ;; org-todo:
  (org-todo-keywords
   (quote ((sequence "TODO(t)" "|" "DONE(d!/!)")
           )))
  (org-todo-repeat-to-state "TODO")
  (org-todo-keyword-faces
   (quote (("NEXT" :inherit warning)
           ("PROJECT" :inherit font-lock-string-face))))
  (org-use-property-inheritance t) ;; Inherit properties from parents
  ;; org-cite:
  (org-cite-global-bibliography (list dotfiles-bibliography))
  (org-cite-export-processors '((t csl)))
  (org-cite-csl-styles-dir "~/.csl")
  :config
  ;; Open file links in the same frame:
  (setf (alist-get 'file org-link-frame-setup) #'find-file)
  ;; Open .docx files using macOS/XDG open:
  (add-to-list 'org-file-apps `("\\.docx\\'" . ,(if (eq system-type 'darwin) "open %s" "xdg-open %s")))
  ;; org-refile configuration:
  (advice-add 'org-refile :after (lambda (&rest _) (org-save-all-org-buffers)))
  ;; Exclude DONE state tasks from refile targets
  (defun sanityinc/verify-refile-target ()
    "Exclude todo keywords with a done state from refile targets."
    (not (member (nth 2 (org-heading-components)) org-done-keywords)))
  (setq org-refile-target-verify-function 'sanityinc/verify-refile-target)
  (defun sanityinc/org-refile-anywhere (&optional goto default-buffer rfloc msg)
    "A version of `org-refile' which allows refiling to any subtree."
    (interactive "P")
    (let ((org-refile-target-verify-function))
      (org-refile goto default-buffer rfloc msg)))
  (defun sanityinc/org-agenda-refile-anywhere (&optional goto rfloc no-update)
    "A version of `org-agenda-refile' which allows refiling to any subtree."
    (interactive "P")
    (let ((org-refile-target-verify-function))
      (org-agenda-refile goto rfloc no-update)))
  ;; Custom add-ons:
  (defun ap/org-summary-todo (n-done n-not-done)
    "Switch entry to DONE when all subentries are done, to TODO otherwise.

N-DONE is the number of done elements; N-NOT-DONE is the number of
not done."
    (let (org-log-done org-log-states)  ; turn off logging
      (org-todo (if (= n-not-done 0) "DONE" "TODO"))))
  (defun ap/org-checkbox-todo ()
    "Switch header TODO state to DONE when all checkboxes are ticked.

Switch to TODO otherwise"
    (let ((todo-state (org-get-todo-state)) beg end)
      (unless (not todo-state)
        (save-excursion
          (org-back-to-heading t)
          (setq beg (point))
          (end-of-line)
          (setq end (point))
          (goto-char beg)
          (if (re-search-forward "\\[\\([0-9]*%\\)\\]\\|\\[\\([0-9]*\\)/\\([0-9]*\\)\\]"
                                 end t)
              (if (match-end 1)
                  (if (equal (match-string 1) "100%")
                      (unless (string-equal todo-state "DONE")
                        (org-todo 'done))
                    (unless (string-equal todo-state "TODO")
                      (org-todo 'todo)))
                (if (and (> (match-end 2) (match-beginning 2))
                         (equal (match-string 2) (match-string 3)))
                    (unless (string-equal todo-state "DONE")
                      (org-todo 'done))
                  (unless (string-equal todo-state "TODO")
                    (org-todo 'todo)))))))))
  (add-hook 'org-after-todo-statistics-hook 'ap/org-summary-todo)
  (add-hook 'org-checkbox-statistics-hook 'ap/org-checkbox-todo)
  (defun ap/wrap-dotimes (fn)
    "Wrap FN in a dotimes loop to make it repeatable with universal arguments."
    (let ((fn fn)) #'(lambda (&optional c)
                       (interactive "p")
                       (dotimes (_ c) (funcall fn)))))
  (define-key org-mode-map (kbd "M-<up>") (ap/wrap-dotimes 'org-metaup))
  (define-key org-mode-map (kbd "M-<down>") (ap/wrap-dotimes 'org-metadown)))


;;; OX PANDOC
;; This is another exporter that translates Org-mode file to various
;; other formats via Pandoc.
(use-package ox-pandoc
  :straight t
  :after org
  :init
  (add-to-list 'org-export-backends 'pandoc)
  (setq org-pandoc-options
        `((standalone . t)
          (mathjax . t)
          (variable . "revealjs-url=https://revealjs.com"))))


;;; CITEPROC EL
;; citeproc-el is an Emacs Lisp library for rendering citations and
;; bibliographies in styles described in the Citation Style Language
;; (CSL), an XML-based, open format to describe the formatting of
;; bibliographic references (see http://citationstyles.org/ for
;; further information on CSL).
;;
;; The library implements most of the CSL 1.0.2 specification,
;; including such features as citation disambiguation, cite collapsing
;; and subsequent author substitution, and passes more than 70% of the
;; tests in the CSL Test Suite. In addition to the standard CSL-JSON
;; data format, citeproc-el has rudimentary support for reading
;; bibliographic data from BibTeX, biblatex and org-bibtex
;; bibliographies and can produce output in several formats including
;; HTML and org-mode markup (see Supported output formats for the full
;; list).
(use-package citeproc
  :straight t
  :after (org))


;;; CITAR
;; Citar provides a highly-configurable completing-read front-end to
;; browse and act on BibTeX, BibLaTeX, and CSL JSON bibliographic
;; data, and LaTeX, markdown, and org-cite editing support.
(use-package citar
  :straight t
  :after (org)
  :hook ((org-mode md-mode markdown-mode latex-mode) . citar-capf-setup)
  :general
  (general-nivmap :keymaps '(org-mode-map markdown-mode-map md-mode-map)
	"<C-c> @" 'citar-insert-citation)
  (general-nmap
	"<leader> n o n" 'citar-open-notes
	"<leader> n o f" 'citar-open-files)
  :custom
  (org-cite-insert-processor 'citar)
  (org-cite-follow-processor 'citar)
  (org-cite-activate-processor 'citar)
  (citar-bibliography org-cite-global-bibliography)
  :config
  (add-to-list 'citar-file-open-functions '("pdf" . citar-file-open-external))
  ;; Run `citar-org-update-pre-suffix' after inserting a citation to immediately
  ;; set its prefix and suffix
  (advice-add 'org-cite-insert :after #'(lambda (args)
										  (save-excursion
											(left-char) ; First move point inside citation
											(citar-org-update-pre-suffix)))))


;;; CITAR EMBARK
;; companion package, that provides contextual actions in the
;; minibuffer, and also at-point in org, markdown, and LaTeX buffers.
(use-package citar-embark
  :defer t
  :straight t
  :after (citar embark)
  :diminish citar-embark-mode
  :custom
  (citar-at-point-function 'embark-act)
  :config
  (citar-embark-mode))


;;; ORG ROAM
;; Org-roam is a plain-text knowledge management system. It brings
;; some of Roam's more powerful features into the Org-mode ecosystem.
;;
;; Org-roam borrows principles from the Zettelkasten method, providing
;; a solution for non-hierarchical note-taking. It should also work as
;; a plug-and-play solution for anyone already using Org-mode for
;; their personal wiki.
(use-package org-roam
  :defer t
  :straight t
  :custom
  (org-roam-capture-templates
   '(("d" "default" plain
	  "%?"
	  :target
	  (file+head
	   "%<%Y%m%d%H%M%S>-${slug}.org"
	   "#+title: ${title}\n")
	  :unnarrowed t)
	 ("r" "Zotero Reference" plain
	  "%?"
	  :target
	  (file+head
	   "${citar-citekey}.org"
	   "#+title: Notes on ${citar-title} (${citar-citekey})\n#+subtitle:${citar-author}, ${citar-date}\n#+created: %U\n#+last_modified: %U\n\n")
	  :unnarrowed t)))
  (org-roam-directory "~/org/org-roam")
  :general
  (general-nmap
	"<leader> n l" 'org-roam-buffer-toggle
	"<leader> n c" 'org-roam-capture
	"<leader> n f" 'org-roam-node-find
	"<leader> n g" 'org-roam-graph
	"<leader> n i" 'org-roam-node-insert
	"<leader> n a r" 'org-roam-alias-remove
	"<leader> n a a" 'org-roam-alias-add
	;; Dailies
	"<leader> n d D" 'org-roam-dailies-capture-date
	"<leader> n d N" 'org-roam-dailies-capture-today
	"<leader> n d T" 'org-roam-dailies-capture-tomorrow
	"<leader> n d f" 'org-roam-dailies-goto-date
	"<leader> n d t" 'org-roam-dailies-goto-tomorrow
	"<leader> n d y" 'org-roam-dailies-goto-yesterday
	"<leader> n d n" 'org-roam-dailies-goto-today
	"<leader> n d b" 'org-roam-dailies-goto-previous-note
	"<leader> n d f" 'org-roam-dailies-goto-next-note)
  :config
  ;; If you're using a vertical completion framework, you might want a more informative completion interface
  (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-db-autosync-mode)
  ;; If using org-roam-protocol
  (require 'org-roam-protocol))


;; Use pdfannots to extract note information from PDFs
(defun org-get-pdfannots ()
  "Use pdfannots to extract note infrom from linked PDF files and store in a note document"
  (interactive)
  (let* ((pdf-file (org-entry-get 1 "NOTER_DOCUMENT"))
		 (cite-key (or (org-entry-get 1 "CUSTOM_ID") "cite-key"))
		 (markdown-output (if
							  (and (string-match ".pdf$" pdf-file)
								   (file-exists-p pdf-file))
							  (shell-command-to-string
							   (format "pixi run -m %s pdfannots %s -f json | jq -r \".[] | \\\"> \\(.text) [@cite-key, p. \\(if .page_label == null then .page else .page_label end)]\n\\\"\" | pandoc -f markdown -t org --wrap=none | sed -e \"s/@cite-key/@%s/\"" (shell-quote-argument (expand-file-name (concat user-emacs-directory "pixi.toml"))) (shell-quote-argument (expand-file-name pdf-file)) (shell-quote-argument cite-key)))
							"")))
	(if (> (length markdown-output) 0)
		(save-excursion (goto-char (point-max))
						(search-backward "\n# Autogenerated notes start here" nil t)
						(delete-region (point) (point-max))
						(insert "\n# Autogenerated notes start here\n\n" markdown-output))
	  (message "Could not find a PDF in NOTER_DOCUMENT."))))


;;; CITAR ORG ROAM
;; This package integrates org-roam with citar; use M-x citar-open-notes to create notes for a citation
(use-package citar-org-roam
  :straight t
  :diminish citar-org-roam-mode
  :custom
  (citar-org-roam-capture-template-key "r")
  (citar-org-roam-note-title-template "")
  (citar-org-roam-template-fields
   '((:citar-citekey "key")
     (:citar-file "file")
     (:citar-title "title")
     (:citar-author "author" "editor")
     (:citar-date "date" "year" "issued")
     (:citar-pages "pages")
     (:citar-type "=type=")))
  :config
  (citar-org-roam-mode)
  ;; Configure org-noter
  (defun citar-add-org-noter-document-property(key &optional entry)
    "Set various properties PROPERTIES drawer when new Citar note is created."
    (interactive)
    (let* ((file-list-temp (list (citar--select-resource key :files t)))
           (file-path-temp (string-replace (getenv "HOME") "~" (alist-get 'file file-list-temp)))
           (cite-author (cdr (citar-get-field-with-value '(author) key)))
           (cite-url (cdr (citar-get-field-with-value '(url) key))) )
      (when (string-match ".pdf$" file-path-temp)
        (org-set-property "NOTER_DOCUMENT" file-path-temp))
      (org-set-property "CUSTOM_ID" key)
      (org-set-property "AUTHOR" cite-author)
      (org-roam-ref-add (concat "@" key))
      (org-id-get-create)))
  (advice-add 'citar-create-note :after #'citar-add-org-noter-document-property))


;; TODO - integrate org-noter with citar (https://github.com/emacs-citar/citar/wiki/Notes-configuration#org-noter)
;; TODO - integrate org-pdftools with org-noter (https://github.com/fuxialexander/org-pdftools)
;;        (this is supposed to allow synchronizing org-noters notes with org-roam notes)


;;; CONSULT ORG ROAM
;; This is a collection of functions to operate org-roam with the help
;; of consult and its live preview feature. You can use it to search,
;; filter and find notes, preview backlinks as well as forward links,
;; and sift through currently open org-roam buffers.
(use-package consult-org-roam
  :straight t
  :diminish consult-org-roam-mode
  :config
  (require 'consult-org-roam)
  ;; Activate the minor mode
  (consult-org-roam-mode 1)
  :custom
  ;; Use `ripgrep' for searching with `consult-org-roam-search'
  (consult-org-roam-grep-func #'consult-ripgrep)
  ;; Configure a custom narrow key for `consult-buffer'
  (consult-org-roam-buffer-narrow-key ?r)
  ;; Display org-roam buffers right after non-org-roam buffers
  ;; in consult-buffer (and not down at the bottom)
  (consult-org-roam-buffer-after-buffers t)
  :config
  ;; Eventually suppress previewing for certain functions
  (consult-customize
   consult-org-roam-forward-links
   :preview-key "M-.")
  :general
  ;; Define some convenient keybindings as an addition
  (general-nmap
	"<leader> n e" 'consult-org-roam-file-find
	"<leader> n b" 'consult-org-roam-backlinks-recursive
	"<leader> n L" 'consult-org-roam-forward-links
	"<leader> n r" 'consult-org-roam-search))


;;; ORG AUTOLIST
;; org-autolist makes org-mode lists behave more like lists in
;; non-programming editors such as Google Docs, MS Word, and OS X
;; Notes.
;;
;; When editing a list item, pressing "Return" will insert a new list
;; item automatically. This works for both bullet points and
;; checkboxes, so there's no need to think about whether to use
;; M-<return> or M-S-<return>. Similarly, pressing "Backspace" at the
;; beginning of a list item deletes the bullet / checkbox, and moves
;; the cursor to the end of the previous line.
(use-package org-autolist
  :straight t
  :hook (org-mode . org-autolist-mode))


;;; EVIL ORG MODE
;; Supplemental evil-mode key-bindings to Emacs org-mode.
(use-package evil-org
  :straight t
  :diminish (evil-org-mode)
  :after org
  :hook (org-mode . (lambda () evil-org-mode))
  :general-config
  (:states 'motion :keymaps 'org-agenda-mode-map
           "gl" 'avy-goto-line
           "c" 'org-agenda-capture
           "b" 'org-agenda-earlier
           "f" 'org-agenda-later)
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))
