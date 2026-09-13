;;; init-evil.el --- Configuration files for evil -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;; EVIL
;; The `evil' package provides Vim emulation within Emacs, allowing
;; users to edit text in a modal way, similar to how Vim
;; operates. This setup configures `evil-mode' to enhance the editing
;; experience.
(use-package evil
  :ensure t
  :init
  (setq
   evil-undo-system 'undo-fu
   evil-want-fine-undo t
   evil-want-Y-yank-to-eol t
   evil-want-integration t      ;; Integrate `evil' with other Emacs features (optional as it's true by default).
   evil-want-keybinding nil     ;; Disable default keybinding to set custom ones.
   evil-want-C-u-scroll t       ;; Makes C-u scroll
   evil-want-C-i-jump nil
   evil-want-C-u-delete t)       ;; Makes C-u delete on insert mode
  :general-config
  ("C-c u" 'universal-argument)
  (:keymaps 'universal-argument-map
			"C-c u" 'universal-argument-more
			"C-u" 'universal-argument-more)
  (:states 'motion
		   "C-e" #'end-of-line)
  (general-nivmap
	"M-l" 'evil-shift-right-line
	"M-h" 'evil-shift-left-line)
  (:states 'insert
	"C-y" 'yank
	"M-y" 'yank-pop)
  (:states 'insert :keymaps 'org-mode-map
	"C-y" 'org-yank)
  (:states 'insert
	"C-t" nil ;; unbind C-t for indentation
	"C->" 'evil-shift-right-line
	"C-<" 'evil-shift-left-line
	"C-d" 'delete-char)
  (general-vmap :keymaps 'emacs-lisp-mode-map
	"gx" 'eval-region)
  (general-nmap :keymaps 'emacs-lisp-mode-map
	"gx" 'evil-eval-region)
  ;; Universal argument support:
  (general-nmap
    "<leader> b a" 'evil-buffer ;; Open consult buffer list
    "<leader> b b" 'bury-buffer ;; Bury the buffer (remove from tabline)
    "<leader> b B" 'ibuffer ;; Open Ibuffer
    "<leader> b k" 'evil-delete-buffer ;; Kill current buffer
    "<leader> b K" (lambda () (interactive) (evil-delete-buffer (current-buffer) t)) ;; Kill current buffer
    "<leader> b s" 'scratch-buffer ;; Save buffer
    "<leader> b w" 'evil-delete-buffer ;; Kill current buffer
    "<leader> b W" (lambda () (interactive) (evil-delete-buffer (current-buffer) t)) ;; Kill current buffer

    "<leader> e d" 'project-dired
	"<leader> e f" 'dired-jump

    "<leader> f f" 'affe-find
	"<leader> f F" 'find-file
    "<leader> f g" 'affe-grep
	"<leader> f G" (lambda () (interactive) (affe-grep default-directory (thing-at-point 'word t)))
    ;; "<leader> f G" 'consult-git-grep
    "<leader> f h" 'consult-info
	"<leader> f l" 'consult-line
	"<leader> f L" 'consult-goto-line
	"<leader> f m" 'consult-project-hunks
	"<leader> f M" 'consult-hunks
    "<leader> f r" 'consult-ripgrep
    "<leader> f o h" 'consult-org-agenda
    "<leader> f o H" 'consult-org-heading
	"<leader> f b" 'consult-buffer

    ;; Project management keybindings
    "<leader> p b" 'consult-project-buffer ;; Consult project buffer
    "<leader> p p" 'project-switch-project ;; Switch project
    "<leader> p f" 'project-find-file ;; Find file in project
    "<leader> p g" 'project-find-regexp ;; Find regexp in project
    "<leader> p k" 'project-kill-buffers ;; Kill project buffers
    "<leader> p D" 'project-dired ;; Dired for project

    ;; Yank from kill ring
    "<leader> P" 'consult-yank-from-kill-ring

    ;; Diagnostic navigation
    "<leader> x x" 'consult-flycheck;; Gives you something like `trouble.nvim'
    ;; Dired commands for file management
    "<leader> x d" 'dired
    "<leader> x j" 'dired-jump
    "<leader> x f" 'find-file

    ;; Magit keybindings for Git integration
    "<leader> v g" 'magit-status      ;; Open Magit status
    "<leader> v l" 'magit-log-current ;; Show current log
    "<leader> v d" 'magit-diff-buffer-file ;; Show diff for the current file
    "<leader> v D" 'diff-hl-show-hunk ;; Show diff for a hunk
    "<leader> v b" 'vc-annotate       ;; Annotate buffer with version control info

	;; Embark
	"<leader> ." 'embark-act

    ;; Help keybindings
    "<leader> h m" 'describe-mode ;; Describe current mode
    "<leader> h f" 'describe-function ;; Describe function
    "<leader> h v" 'describe-variable ;; Describe variable
    "<leader> h k" 'describe-key ;; Describe key

    ;; Custom example. Formatting with prettier tool.
    "<leader> m p"
    (lambda ()
      (interactive)
      (shell-command (concat "prettier --write " (shell-quote-argument (buffer-file-name))))
      (revert-buffer t t t)))
  (general-nmap
    ;; Tab navigation
    "] t" 'tab-next ;; Go to next tab
    "[ t" 'tab-previous ;; Go to previous tab
    ;; Buffer management keybindings
    "] b" 'switch-to-next-buffer ;; Switch to next buffer
    "[ b" 'switch-to-prev-buffer ;; Switch to previous buffer
    "] d" 'ap/next-error ;; Go to next Flymake error
    "[ d" 'ap/prev-error ;; Go to previous Flymake error
    ;; Diff-HL navigation for version control
    "] c" 'diff-hl-next-hunk ;; Next diff hunk
    "[ c" 'diff-hl-previous-hunk) ;; Previous diff hunk

  :config
  ;; Set the leader key to space for easier access to custom commands. (setq evil-want-leader t)
  (evil-set-leader nil (kbd "SPC"))
  (evil-set-leader nil (kbd ",") t)

  (define-advice forward-evil-paragraph (:around (orig-fun &rest args))
    (let ((paragraph-start (default-value 'paragraph-start))
          (paragraph-separate (default-value 'paragraph-separate))
          (paragraph-ignore-fill-prefix t))
      (apply orig-fun args)))

  (evil-define-operator evil-eval-region (beg end)
    "evaluate the region."
    (eval-region beg end))

  (evil-define-text-object +evil:whole-buffer-txtobj (count &optional _beg _end type)
    "Text object to select the whole buffer."
    (evil-range (point-min) (point-max) type))

  (general-define-key :keymaps 'evil-inner-text-objects-map
		      "g" '+evil:whole-buffer-txtobj
		      :keymaps 'evil-outer-text-objects-map
		      "g" '+evil:whole-buffer-txtobj)

  (defvar-keymap evil-window-repeat-map
    :repeat t
    "+" 'evil-window-increase-height
    "-" 'evil-window-decrease-height
    ">" 'evil-window-increase-width
    "<" 'evil-window-decrease-width
    "=" 'balance-windows)

(defun ap/kill-current-buffer-and-window ()
  "Kill the current buffer and close its window."
  (interactive)
  (if (> (length (window-list)) 1)
      (progn
        (kill-buffer (current-buffer))
        (delete-window))
    ;; If it's the last window, just kill the buffer
    (kill-buffer (current-buffer))))

  ;; Enable evil mode
  (evil-mode 1))


;; EVIL COLLECTION
;; The `evil-collection' package enhances the integration of
;; `evil-mode' with various built-in and third-party packages. It
;; provides a better modal experience by remapping keybindings and
;; commands to fit the `evil' style.
(use-package evil-collection
  :after evil
  :ensure t
  :diminish 'evil-collection-unimpaired-mode
  :custom
  (evil-collection-binding-overrides '((find-usages :enabled nil)))
  :init
  (evil-collection-init))


;;; EVIL GHOSTEL
;; Evil bindings for ghostel
(use-package evil-ghostel
  :ensure t
  :after (ghostel evil)
  :hook (ghostel-mode . evil-ghostel-mode)
  :custom
  (evil-ghostel-escape 'evil) ; make ESC always switches to evil normal state
  :config
  ;; Make C-q the literal-key escape hatch in insert state.
  (evil-define-key 'insert evil-ghostel-mode-map
	(kbd "C-q") #'ghostel-send-next-key))


;;; EVIL ORG MODE
;; Supplemental evil-mode key-bindings to Emacs org-mode.
(use-package evil-org
  :ensure t
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


;; EVIL SURROUND
;; The `evil-surround' package provides text object surround
;; functionality for `evil-mode'. This allows for easily adding,
;; changing, or deleting surrounding characters such as parentheses,
;; quotes, and more.
;;
;; With this you can change 'hello there' with ci'" to have
;; "hello there" and cs"<p> to get <p>hello there</p>.
;; More examples here:
;; - https://github.com/emacs-evil/evil-surround?tab=readme-ov-file#examples
(use-package evil-surround
  :ensure t
  :after evil-collection
  :config
  (global-evil-surround-mode 1))


;;; EMBRACE.EL
;; Add/Change/Delete pairs based on expand-region.
(use-package embrace
  :ensure t
  :hook (org-mode . embrace-org-mode-hook)
  :general
  ("C-," 'embrace-commander))


;;; EVIL EMBRACE
;; This package provides evil integration of embrace.el. Since
;; evil-surround provides a similar set of features as embrace.el,
;; this package aims at adding the goodies of embrace.el to
;; evil-surround and making evil-surround even better.
(use-package evil-embrace
  :ensure t
  :after evil-surround
  :config
  (evil-embrace-enable-evil-surround-integration))


;;; EVIL NERD COMMENTER
;; A Nerd Commenter emulation, help you comment code efficiently. For
;; example, you can press “99,ci” to comment out 99 lines.
(use-package evil-nerd-commenter
  :ensure t
  :general
  ([remap comment-line] #'evilnc-comment-or-uncomment-lines)
  (general-nvmap "gc" #'evilnc-comment-operator)
  (:keymaps 'evil-inner-text-objects-map
            "c" 'evilnc-inner-comment)
  (:keymaps 'evil-outer-text-objects-map
            "c" 'evilnc-outer-comment))


;;; EVIL NUMBERS
;; + Increment / Decrement binary, octal, decimal and hex literals
;; + Works like C-a/C-x in vim, i.e. searches for number up to eol
;;   and then increments or decrements and keep zero padding up
;;   (unlike in vim)
;; + When a region is active, as in evil’s visual mode, all the
;;   numbers within that region will be incremented/decremented (unlike
;;   in vim)
(use-package evil-numbers
  :ensure t
  :general
  (general-nivmap
	"C-c +" 'evil-numbers/inc-at-pt
	"C-c =" 'evil-numbers/inc-at-pt
	"C-c -" 'evil-numbers/dec-at-pt
	"C-c C-+" 'evil-numbers/inc-at-pt-incremental
	"C-c C-=" 'evil-numbers/inc-at-pt-incremental
	"C-c C--" 'evil-numbers/dec-at-pt-incremental)
  :config
  (defvar-keymap evil-numbers-repeat-map
	:repeat t
	"+" 'evil-numbers/inc-at-pt
	"=" 'evil-numbers/inc-at-pt
	"C-=" 'evil-numbers/inc-at-pt-incremental
	"C-+" 'evil-numbers/inc-at-pt-incremental
	"C--" 'evil-numbers/dec-at-pt-incremental
	"-" 'evil-numbers/dec-at-pt))


;; EVIL MATCHIT
;; The `evil-matchit' package extends `evil-mode' by enabling
;; text object matching for structures such as parentheses, HTML
;; tags, and other paired delimiters. This makes it easier to
;; navigate and manipulate code blocks.
;; Just use % for jumping between matching structures to check it out.
(use-package evil-matchit
  :ensure t
  :after evil-collection
  :config
  (global-evil-matchit-mode 1))


;;; TARGETS.EL
;; This package is like a combination of the targets, TextObjectify,
;; anyblock, and expand-region vim plugins.
(use-package targets
  :ensure nil
  :vc (targets :url "https://github.com/noctuid/targets.el")
  :config
  (targets-setup t)
  (targets-setup t)
  (targets-define-composite-to anyblock
	(("(" ")" pair)
	 ("[" "]" pair)
	 ("{" "}" pair)
	 ("<" ">" pair)
	 ("\"" "\"" quote)
	 ("'" "'" quote)
	 ("`" "`" quote)
	 ("“" "”" quote))
	:bind t
	:keys "b")
  (targets-define-composite-to anyquote
	(("'" "'" quote)
	 ("\"" "\"" quote)
	 ("`" "`" quote)
	 ("‘" "’" quote)
	 ("“" "”" quote))
	:bind t
	:keys "q"))


;;; EVIL BETTER VISUAL LINE
;; This package will allow you to easily navigate through your file,
;; as you might expect when using the ‘j’ and ‘k’ keys, while you’re
;; in visual-line-mode.
;;
;; This is a custom revision of
;; https://github.com/YourFin/evil-better-visual-line
(use-package evil-better-visual-line
  :ensure nil
  :commands (evil-better-visual-line-next-line
             evil-better-visual-line-previous-line)
  :general
  (:states '(normal operator visual)
		  "j" 'evil-better-visual-line-next-line
		  "k" 'evil-better-visual-line-previous-line))


;;; EVIL GOGGLES
;; evil-goggles-mode displays a visual hint when editing with evil.
(use-package evil-goggles
  :ensure t
  :diminish evil-goggles-mode
  :config
  (setq evil-goggles-pulse nil)
  (evil-goggles-mode)
  (evil-goggles-use-diff-faces))


;; Override evil-replace-register with a function that uses evil-paste and override evil-paste-pop to allow
;; evil-replace-with-register to count as a paste command.
(use-package evil-replace-with-register
  :ensure t
  :custom
  (evil-replace-with-register-key (kbd "gr"))
  :config

  (evil-define-operator evil-replace-with-register (count beg end type register)
    "Replacing an existing text with the contents of a register"
    :move-point nil
    (interactive "<vc><R><x>")
    (setq count (or count 1))
    (goto-char beg)
    (if (eq type 'block)
        (evil-apply-on-block
         (lambda (begcol endcol)
           (let ((maxcol (evil-column (line-end-position))))
             (when (< begcol maxcol)
               (setq endcol (min endcol maxcol))
               (let ((beg (evil-move-to-column begcol nil t))
                     (end (evil-move-to-column endcol nil t)))
                 (delete-region beg end)
                 (evil-visual-paste count register))
               (setq last-command 'evil-visual-paste))))
         beg end t)
      (delete-region beg end)
      (evil-paste-before count register)
      (setq last-command 'evil-paste-before)
      (when (and evil-replace-with-register-indent (/= (line-number-at-pos beg) (line-number-at-pos)))
        ;; indent if more then one line was inserted
        (save-excursion
          (evil-indent beg (point))))))

  (advice-add 'evil-paste-pop :override
                (lambda (count)
                  "Replace the just-yanked stretch of killed text with a different stretch.
  This command is allowed only immediatly after a `yank',
  `evil-paste-before', `evil-paste-after' or `evil-paste-pop'.
  This command uses the same paste command as before, i.e., when
  used after `evil-paste-after' the new text is also yanked using
  `evil-paste-after', used with the same paste-count argument.

  The COUNT argument inserts the COUNTth previous kill.  If COUNT
  is negative this is a more recent kill."
                  (interactive "p")
                  (unless (memq last-command
                                '(evil-paste-after
                                  evil-paste-before
                                  evil-visual-paste
                                  evil-replace-with-register))
                    (user-error "Previous command was not an evil-paste: %s" last-command))
                  (unless evil-last-paste
                    (user-error "Previous paste command used a register"))
                  (when (not (eq last-command 'evil-replace-with-register))
                    (evil-undo-pop))
                  (goto-char (nth 2 evil-last-paste))
                  (setq this-command (nth 0 evil-last-paste))
                  ;; use temporary kill-ring, so the paste cannot modify it
                  (let ((kill-ring (list (current-kill
                                          (if (and (> count 0) (nth 5 evil-last-paste))
                                              ;; if was visual paste then skip the
                                              ;; text that has been replaced
                                              (1+ count)
                                            count))))
                        (kill-ring-yank-pointer kill-ring))
                    (when (eq last-command 'evil-visual-paste)
                      (let ((evil-no-display t))
                        (evil-visual-restore)))
                    (funcall (nth 0 evil-last-paste) (nth 1 evil-last-paste))
                    ;; if this was a visual paste, then mark the last paste as NOT
                    ;; being the first visual paste
                    (when (eq last-command 'evil-visual-paste)
                      (setcdr (nthcdr 4 evil-last-paste) nil)))))

  (evil-define-key '(visual normal) 'global evil-replace-with-register-key 'evil-replace-with-register))


;;; EVIL TEXTOBJ ENTIRE
;; "Entire Buffer" text objects for emacs `evil`
(use-package evil-textobj-entire
  :ensure t
  :custom
  (evil-textobj-entire-key "g"))


;;; EVIL LION
;; This package provides gl and gL align operators: gl MOTION CHAR and
;; right-align gL MOTION CHAR.
;;
;; Use CHAR / to enter regular expression if a single character
;; wouldn't suffice.
;;
;; Use CHAR RET to align with align.el's default rules for the active
;; major mode.
(use-package evil-lion
  :ensure t
  :config
  (evil-lion-mode))


;;; UNDO FU
;; Simple, stable linear undo with redo for Emacs.
;;
;; This is a lightweight wrapper for Emacs built-in undo system,
;; adding convenient undo/redo without losing access to the full undo
;; history, allowing you to visit all previous states of the document
;; if you need.
;;
;; The changes compared to Emacs undo are as follows:
;;
;; + Redo will not pass the initial undo action.
;; + Redo will not undo (unlike Emacs redo which traverses previous
;;   undo/redo steps).
;; + These constraints can be temporarily disabled by pressing C-g
;;   before undo or redo.
;;
;; Note that this doesn't interfere with Emacs internal undo data,
;; which can be error prone.
(use-package undo-fu
  :ensure t
  :hook (after-init . undo-fu-mode)
  :custom
  ;; Increase undo history limits to reduce likelihood of data loss
  (undo-limit 400000)           ; 400kb (default is 160kb)
  (undo-strong-limit 3000000)   ; 3mb   (default is 240kb)
  (undo-outer-limit 48000000)  ; 48mb  (default is 24mb)
  :config
  (define-minor-mode undo-fu-mode
    "Enables `undo-fu' for the current session."
    :keymap (let ((map (make-sparse-keymap)))
              (define-key map [remap undo] #'undo-fu-only-undo)
              (define-key map [remap redo] #'undo-fu-only-redo)
              (define-key map (kbd "C-_")     #'undo-fu-only-undo)
              (define-key map (kbd "M-_")     #'undo-fu-only-redo)
              (define-key map (kbd "C-M-_")   #'undo-fu-only-redo-all)
              (define-key map (kbd "C-x r u") #'undo-fu-session-save)
              (define-key map (kbd "C-x r U") #'undo-fu-session-recover)
              map)
    :init-value nil
    :global t))


;;; UNDO FU SESSION
;; Save & recover undo steps between Emacs sessions.
;;
;; This package writes undo/redo information upon file save which is
;; restored where possible when the file is loaded again.
(use-package undo-fu-session
  :ensure t
  :hook (undo-fu-mode  . undo-fu-session-global-mode)
  :custom
  (undo-fu-session-directory (concat user-emacs-directory "undo-fu-session/"))
  (undo-fu-session-incompatible-files '("\\.gpg$" "/COMMIT_EDITMSG\\'" "/git-rebase-todo\\'"))
  :config
  (when (executable-find "zstd")
    ;; There are other algorithms available, but zstd is the fastest, and speed
    ;; is our priority within Emacs
    (setq undo-fu-session-compression 'zst)))


;;; BETTER JUMPER
;; A configurable jump list implementation for Emacs that can be used
;; to easily jump back to previous locations.
(use-package better-jumper
  :ensure t
  :diminish (better-jumper-mode better-jumper-local-mode)
  :general
  (:states 'normal
           "C-o" 'better-jumper-jump-backward
           "C-i" 'better-jumper-jump-forward)
  :config
  (better-jumper-mode +1))


(provide 'init-evil)
;;; init-evil.el ends here
