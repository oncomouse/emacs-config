;;; init.el --- Emacs-Kick --- A feature rich Emacs config for (neo)vi(m)mers -*- lexical-binding: t; -*-
;; Author: Rahul Martim Juliato

;; Version: 0.2.0
;; Package-Requires: ((emacs "30.1"))
;; License: GPL-2.0-or-later

;;; Commentary:
;;; Code:

;; Performance Hacks
;; Emacs is an Elisp interpreter, and when running programs or packages,
;; it can occasionally experience pauses due to garbage collection.
;; By increasing the garbage collection threshold, we reduce these pauses
;; during heavy operations, leading to smoother performance.
(setq gc-cons-threshold #x40000000)

;; Set the maximum output size for reading process output, allowing for larger data transfers.
(setq read-process-output-max (* 1024 1024 4))

;; Do I really need a speedy startup?
;; Well, this config launches Emacs in about ~0.3 seconds,
;; which, in modern terms, is a miracle considering how fast it starts
;; with external packages.
;; It wasn’t until the recent introduction of tools for lazy loading
;; that a startup time of less than 20 seconds was even possible.
;; Other fast startup methods were introduced over time.
;; You may have heard of people running Emacs as a server,
;; where you start it once and open multiple clients instantly connected to that server.
;; Some even run Emacs as a systemd or sysV service, starting when the machine boots.
;; While this is a great way of using Emacs, we WON’T be doing that here.
;; I think 0.3 seconds is fast enough to avoid issues that could arise from
;; running Emacs as a server, such as 'What version of Node is my LSP using?'.
;; Again, this setup configures Emacs much like how a Vimmer would configure Neovim.


;; Emacs comes with a built-in package manager (`package.el'), and we'll use it
;; when it makes sense. However, `straight.el' is a bit more user-friendly and
;; reproducible, especially for newcomers and shareable configs like emacs-kick.
;; So we bootstrap it here.
(setq package-enable-at-startup nil) ;; Disables the default package manager.

;; Bootstraps `straight.el'
(setq straight-check-for-modifications nil)
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
(straight-use-package '(project :type built-in))
(straight-use-package 'use-package)

(use-package general
  :straight t
  :config
  (general-evil-setup)
  (general-create-definer general-nivmap :states '(normal insert visual)))

;; In Emacs, a package is a collection of Elisp code that extends the editor's functionality,
;; much like plugins do in Neovim. We need to import this package to add package archives.
(require 'package)

;; Add MELPA (Milkypostman's Emacs Lisp Package Archive) to the list of package archives.
;; This allows you to install packages from this widely-used repository, similar to how
;; pip works for Python or npm for Node.js. While Emacs comes with ELPA (Emacs Lisp
;; Package Archive) configured by default, which contains packages that meet specific
;; licensing criteria, MELPA offers a broader range of packages and is considered the
;; standard for Emacs users. You can also add more package archives later as needed.
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; Define a global customizable variable `ek-use-nerd-fonts' to control the use of
;; Nerd Fonts symbols throughout the configuration. This boolean variable allows
;; users to easily enable or disable the use of symbols from Nerd Fonts, providing
;; flexibility in appearance settings. By setting it to `t', we enable Nerd Fonts
;; symbols; setting it to `nil' would disable them.
(defcustom ek-use-nerd-fonts t
  "Configuration for using Nerd Fonts Symbols."
  :type 'boolean
  :group 'appearance)


;; From now on, you'll see configurations using the `use-package` macro, which
;; allows us to organize our Emacs setup in a modular way. These configurations
;; look like this:
;;
;; (use-package some-package
;;   :ensure t     ;; Ensure the package is installed (used with package.el).
;;   :straight t   ;; Use straight.el to install and manage this package.
;;   :config       ;; Configuration settings for the package.
;;   ;; Additional settings can go here.
;; )
;;
;; This approach simplifies package management, enabling us to easily control
;; both built-in (first-party) and external (third-party) packages. While Emacs
;; is a vast and powerful editor, using `use-package`—especially in combination
;; with `straight.el`—helps streamline our configuration for better organization,
;; reproducibility, and customization. As we proceed, you'll see smaller
;; `use-package` declarations for specific packages, which will help us enable
;; the desired features and improve our workflow.


;;; EMACS
;;  This is biggest one. Keep going, plugins (oops, I mean packages) will be shorter :)
(use-package emacs
  :ensure nil
  :custom                                         ;; Set custom variables to configure Emacs behavior.
  (confirm-kill-emacs 'yes-or-no-p)               ;; Ask before quitting Emacs
  (column-number-mode t)                          ;; Display the column number in the mode line.
  (auto-save-default nil)                         ;; Disable automatic saving of buffers.
  (create-lockfiles nil)                          ;; Prevent the creation of lock files when editing.
  (delete-by-moving-to-trash t)                   ;; Move deleted files to the trash instead of permanently deleting them.
  (delete-selection-mode 1)                       ;; Enable replacing selected text with typed text.
  (display-line-numbers-type 'relative)           ;; Use relative line numbering in programming modes.
  (global-auto-revert-non-file-buffers t)         ;; Automatically refresh non-file buffers.
  (history-length 100)                            ;; Set the length of the command history.
  (inhibit-startup-message t)                     ;; Disable the startup message when Emacs launches.
  (initial-scratch-message "")                    ;; Clear the initial message in the *scratch* buffer.
  (ispell-dictionary "en_US")                     ;; Set the default dictionary for spell checking.
  (make-backup-files nil)                         ;; Disable creation of backup files.
  (pixel-scroll-precision-mode t)                 ;; Enable precise pixel scrolling.
  (pixel-scroll-precision-use-momentum nil)       ;; Disable momentum scrolling for pixel precision.
  (ring-bell-function 'ignore)                    ;; Disable the audible bell.
  (split-width-threshold 300)                     ;; Prevent automatic window splitting if the window width exceeds 300 pixels.
  (switch-to-buffer-obey-display-actions t)       ;; Make buffer switching respect display actions.
  (tab-always-indent 'complete)                   ;; Make the TAB key complete text instead of just indenting.
  (tab-width 4)                                   ;; Set the tab width to 4 spaces.
  (treesit-font-lock-level 4)                     ;; Use advanced font locking for Treesit mode.
  (truncate-lines t)                              ;; Enable line truncation to avoid wrapping long lines.
  (use-dialog-box nil)                            ;; Disable dialog boxes in favor of minibuffer prompts.
  (use-short-answers t)                           ;; Use short answers in prompts for quicker responses (y instead of yes)
  (sentence-end-double-space nil)                 ;; It's no longer the 1980s, Emacs
  ;; (warning-minimum-level :emergency)              ;; Set the minimum level of warnings to display.

  :hook                                           ;; Add hooks to enable specific features in certain modes.
  (before-save . delete-trailing-whitespace)      ;; Delete trailing spaces on save

  :general-config
  ("M-o" 'other-window)
  ("C-x C-r" 'recentf)
  :config
  ;; By default emacs gives you access to a lot of *special* buffers, while navigating with [b and ]b,
  ;; this might be confusing for newcomers. This settings make sure ]b and [b will always load a
  ;; file buffer. To see all buffers use <leader> SPC, <leader> b l, or <leader> b i.
  (defun skip-these-buffers (_window buffer _bury-or-kill)
    "Function for `switch-to-prev-buffer-skip'."
    (string-match "\\*[^*]+\\*" (buffer-name buffer)))
  (setq switch-to-prev-buffer-skip 'skip-these-buffers)


  ;; Configure font settings based on the operating system.
  ;; Ok, this kickstart is meant to be used on the terminal, not on GUI.
  ;; But without this, I fear you could start Graphical Emacs and be sad
  (set-face-attribute 'default nil :family "JetBrainsMono Nerd Font"  :height 145)
  (when (eq system-type 'darwin)       ;; Check if the system is macOS.
	(setq mac-command-modifier 'meta)  ;; Set the Command key to act as the Meta key.
	(set-face-attribute 'default nil :family "JetBrainsMono Nerd Font" :height 175))
  (set-face-attribute 'variable-pitch nil :family "FiraSans" :height 145)
  (set-face-attribute 'fixed-pitch nil :family (face-attribute 'default :family))

  ;; Use C-h A to describe-face
  (with-eval-after-load 'help
    (define-key help-map "A" 'describe-face))

  ;; Save manual customizations to a separate file instead of cluttering `init.el'.
  ;; You can M-x customize, M-x customize-group, or M-x customize-themes, etc.
  ;; The saves you do manually using the Emacs interface would overwrite this file.
  ;; The following makes sure those customizations are in a separate file.
  (setq custom-file (locate-user-emacs-file "custom-vars.el")) ;; Specify the custom file path.
  (load custom-file 'noerror 'nomessage)                       ;; Load the custom file quietly, ignoring errors.

  ;; Makes Emacs vertical divisor the symbol │ instead of |.
  (set-display-table-slot standard-display-table 'vertical-border (make-glyph-code ?│))

  ;; Add a load-path entry for the user directory:
  (add-to-list 'load-path (locate-user-emacs-file "lisp") t)

  :init                        ;; Initialization settings that apply before the package is loaded.
  (tool-bar-mode -1)           ;; Disable the tool bar for a cleaner interface.
  (menu-bar-mode -1)           ;; Disable the menu bar for a more streamlined look.

  (when scroll-bar-mode
    (scroll-bar-mode -1))      ;; Disable the scroll bar if it is active.

  (global-display-line-numbers-mode +1) ;; Display line numbers everywhere
  (global-hl-line-mode 1)               ;; Enable highlight of the current line
  (global-auto-revert-mode 1)           ;; Enable global auto-revert mode to keep buffers up to date with their corresponding files.
  (indent-tabs-mode nil)                ;; Disable the use of tabs for indentation (use spaces instead).
  (recentf-mode 1)                      ;; Enable tracking of recently opened files.
  (savehist-mode 1)                     ;; Enable saving of command history.
  (save-place-mode 1)                   ;; Enable saving the place in files for easier return.
  (winner-mode 1)                       ;; Enable winner mode to easily undo window configuration changes.
  (xterm-mouse-mode 1)                  ;; Enable mouse support in terminal mode.
  (file-name-shadow-mode 1)             ;; Enable shadowing of filenames for clarity.

  ;; Set the default coding system for files to UTF-8.
  (modify-coding-system-alist 'file "" 'utf-8)

  ;; Add a hook to run code after Emacs has fully initialized.
  (add-hook 'after-init-hook
            (lambda ()
              (message "Emacs has fully loaded. This code runs after startup.")

              ;; Insert a welcome message in the *scratch* buffer displaying loading time and activated packages.
              (with-current-buffer (get-buffer-create "*scratch*")
                (insert (format
                         ";;    Welcome to Emacs!
;;
;;    Loading time : %s
;;    Packages     : %s
"
                         (emacs-init-time)
                         (number-to-string (length package-activated-list))))))))


;;; PURCELL FULLFRAME MODE
;; Display some modes in full-frame
(defun sanityinc/display-buffer-full-frame (buffer alist)
  "If it's not visible, display buffer full-frame, saving the prior window config.
The saved config will be restored when the window is quit later.
BUFFER and ALIST are as for `display-buffer-full-frame'."
  (let ((initial-window-configuration (current-window-configuration)))
	(or (display-buffer-reuse-window buffer alist)
		(let ((full-window (display-buffer-full-frame buffer alist)))
		  (prog1
			  full-window
			(set-window-parameter full-window 'sanityinc/previous-config initial-window-configuration))))))
(defun sanityinc/maybe-restore-window-configuration (orig &optional kill window)
  "Advice for `quit-window' (ORIG).
Quit WINDOW and bury its buffer.
WINDOW must be a live window and defaults to the selected one.
With prefix argument KILL non-nil, kill the buffer instead of
burying it."
  (let* ((window  (or window (selected-window)))
		 (to-restore (window-parameter window 'sanityinc/previous-config)))
	(set-window-parameter window 'sanityinc/previous-config nil)
	(funcall orig kill window)
	(when to-restore
	  (set-window-configuration to-restore))))
(advice-add 'quit-window :around 'sanityinc/maybe-restore-window-configuration)
(defmacro sanityinc/fullframe-mode (mode)
  "Configure buffers that open in MODE to display in full-frame."
  `(add-to-list 'display-buffer-alist
				(cons (cons 'major-mode ,mode)
					  (list 'sanityinc/display-buffer-full-frame))))


;;; DIRED
;; In Emacs, the `dired' package provides a powerful and built-in file manager
;; that allows you to navigate and manipulate files and directories directly
;; within the editor. If you're familiar with `oil.nvim', you'll find that
;; `dired' offers similar functionality natively in Emacs, making file
;; management seamless without needing external plugins.

;; This configuration customizes `dired' to enhance its usability. The settings
;; below specify how file listings are displayed, the target for file operations,
;; and associations for opening various file types with their respective applications.
;; For example, image files will open with `feh', while audio and video files
;; will utilize `mpv'.
(use-package dired
  :ensure nil                                                ;; This is built-in, no need to fetch it.
  :custom
  (dired-listing-switches "-lah --group-directories-first")  ;; Display files in a human-readable format and group directories first.
  (dired-dwim-target t)                                      ;; Enable "do what I mean" for target directories.
  (dired-guess-shell-alist-user
   '(("\\.\\(png\\|jpe?g\\|tiff\\)" "feh" "xdg-open" "open") ;; Open image files with `feh' or the default viewer.
     ("\\.\\(mp[34]\\|m4a\\|ogg\\|flac\\|webm\\|mkv\\)" "mpv" "xdg-open" "open") ;; Open audio and video files with `mpv'.
     (".*" "open" "xdg-open")))                              ;; Default opening command for other files.
  (dired-kill-when-opening-new-dired-buffer t)               ;; Close the previous buffer when opening a new `dired' instance.
  :config
  (when (eq system-type 'darwin)
    (let ((gls (executable-find "gls")))                     ;; Use GNU ls on macOS if available.
      (when gls
        (setq insert-directory-program gls)))))


;;; DESKTOP
;; Use the desktop library to save the state of Emacs from one session
;; to another. Once you save the Emacs desktop (the buffers, their
;; file names, major modes, buffer positions, and so on) then
;; subsequent Emacs sessions reload the saved desktop.
(use-package desktop
  :ensure nil
  :custom
  (desktop-path (list user-emacs-directory))
  (desktop-auto-save-timeout 600)
  :config
  (desktop-save-mode 1))


;;; TAB LINE
;; The command global-tab-line-mode toggles the display of a tab line
;; on the top screen line of each window. The Tab Line shows special
;; buttons (“tabs”) for each buffer that was displayed in a window,
;; and allows switching to any of these buffers by clicking the
;; corresponding button. Clicking on the + icon adds a new buffer to
;; the window-local tab line of buffers, and clicking on the x icon of
;; a tab deletes it. The mouse wheel on the tab line scrolls the tabs
;; horizontally.
;; Customize catppuccin tab-line styles:
(defun ap/tab-line-goto (n)
  "Switch to the Nth tab (0-indexed) in the current window's tab line."
  (interactive "p")
  (let* ((window (selected-window))
         (buffers (window-parameter window 'tab-line-buffers))
         (tab (nth n buffers)))
    (when tab
      (switch-to-buffer tab))))
(use-package tab-line
  :ensure nil
  :general
  ("C-<iso-lefttab>" 'tab-line-switch-to-prev-tab
   "C-<tab>" 'tab-line-switch-to-next-tab)
  (:keymaps 'tab-line-mode-map
			"M-1" (lambda () (interactive) (ap/tab-line-goto 0))
			"M-2" (lambda () (interactive) (ap/tab-line-goto 1))
			"M-3" (lambda () (interactive) (ap/tab-line-goto 2))
			"M-4" (lambda () (interactive) (ap/tab-line-goto 3))
			"M-5" (lambda () (interactive) (ap/tab-line-goto 4))
			"M-6" (lambda () (interactive) (ap/tab-line-goto 5))
			"M-7" (lambda () (interactive) (ap/tab-line-goto 6))
			"M-8" (lambda () (interactive) (ap/tab-line-goto 7))
			"M-9" (lambda () (interactive) (ap/tab-line-goto 8))
			"M-0" (lambda () (interactive) (ap/tab-line-goto 9)))
  :config
  (setq tab-line-tab-name-function #'tab-line-tab-name-truncated-buffer)
  (global-tab-line-mode 1)
  ;; Use tab-line for previous tab and next tab
  (defalias 'tab-previous 'tab-line-switch-to-prev-tab)
  (defalias 'tab-next 'tab-line-switch-to-next-tab)
  (setq
   tab-line-new-button-show nil
   tab-line-close-button-show nil)
  (set-face-attribute 'tab-line-highlight nil
					  :inherit 'default
					  :background (ap/get-catppuccin-color 'mantle))
  (set-face-attribute 'tab-line-tab-inactive nil
					  :foreground (ap/get-catppuccin-color 'text)
					  :background (ap/get-catppuccin-color 'mantle))
  (set-face-attribute 'tab-line-tab nil
					  :foreground (ap/get-catppuccin-color 'text)
					  :background (ap/get-catppuccin-color 'base))
  (set-face-attribute 'tab-line-tab-modified nil
					  :foreground (ap/get-catppuccin-color 'red))
  (set-face-attribute 'tab-line-tab-current nil
					  :foreground (ap/get-catppuccin-color 'text)
					  :background (ap/get-catppuccin-color 'base)
					  :weight 'bold
					  :slant 'italic))


(use-package repeat
  :ensure nil
  :config
  (repeat-mode 1))


(use-package holidays
  :ensure nil
  :init
  ;; Disable unused holidays:
  (setq
   holiday-hebrew-holidays nil
   holiday-bahai-holidays nil
   holiday-islamic-holidays nil
   holiday-oriental-holidays nil)
  ;; Attach our custom holiday lists:
  (setq holiday-other-holidays
        '((holiday-float 11 4 3 "Thanksgiving Break")
          (holiday-float 11 4 5 "Thanksgiving Break")))
  ;; This gets overwritten somehow:
  (setq calendar-holidays (append holiday-general-holidays holiday-local-holidays
                                  holiday-other-holidays holiday-christian-holidays
                                  holiday-hebrew-holidays holiday-islamic-holidays
                                  holiday-bahai-holidays holiday-oriental-holidays
                                  holiday-solar-holidays))
  :config
  (with-eval-after-load 'org
    (setq org-agenda-include-diary t)))


;;; ISEARCH
;; In this configuration, we're setting up isearch, Emacs's incremental search feature.
;; Since we're utilizing Vim bindings, keep in mind that classic Vim search commands
;; (like `/' and `?') are not bound in the same way. Instead, you'll need to use
;; the standard Emacs shortcuts:
;; - `C-s' to initiate a forward search
;; - `C-r' to initiate a backward search
;; The following settings enhance the isearch experience:
(use-package isearch
  :ensure nil                                  ;; This is built-in, no need to fetch it.
  :config
  (setq isearch-lazy-count t)                  ;; Enable lazy counting to show current match information.
  (setq lazy-count-prefix-format "(%s/%s) ")   ;; Format for displaying current match count.
  (setq lazy-count-suffix-format nil)          ;; Disable suffix formatting for match count.
  (setq search-whitespace-regexp ".*?")        ;; Allow searching across whitespace.
  :bind (("C-s" . isearch-forward)             ;; Bind C-s to forward isearch.
         ("C-r" . isearch-backward)))          ;; Bind C-r to backward isearch.


;;; VC
;; The VC (Version Control) package is included here for awareness and completeness.
;; While its support for Git is limited and generally considered subpar, it is good to know
;; that it exists and can be used for other version control systems like Mercurial,
;; Subversion, and Bazaar.
;; Magit, which is often regarded as the "father" of Neogit, will be configured later
;; for an enhanced Git experience.
;; The keybindings below serve as a reminder of some common VC commands.
;; But don't worry, you can always use `M-x command' :)
(use-package vc
  :ensure nil                        ;; This is built-in, no need to fetch it.
  :defer t
  :bind
  (("C-x v d" . vc-dir)              ;; Open VC directory for version control status.
   ("C-x v =" . vc-diff)             ;; Show differences for the current file.
   ("C-x v D" . vc-root-diff)        ;; Show differences for the entire repository.
   ("C-x v v" . vc-next-action))     ;; Perform the next version control action.
  :config
  ;; Better colors for <leader> g b  (blame file)
  (setq vc-annotate-color-map
        '((20 . "#f5e0dc")
          (40 . "#f2cdcd")
          (60 . "#f5c2e7")
          (80 . "#cba6f7")
          (100 . "#f38ba8")
          (120 . "#eba0ac")
          (140 . "#fab387")
          (160 . "#f9e2af")
          (180 . "#a6e3a1")
          (200 . "#94e2d5")
          (220 . "#89dceb")
          (240 . "#74c7ec")
          (260 . "#89b4fa")
          (280 . "#b4befe"))))


;;; SMERGE
;; Smerge is included for resolving merge conflicts in files. It provides a simple interface
;; to help you keep changes from either the upper or lower version during a merge.
;; This package is built-in, so there's no need to fetch it separately.
;; The keybindings below did not needed to be setted, are here just to show
;; you how to work with it in case you are curious about it.
(use-package smerge-mode
  :ensure nil                                  ;; This is built-in, no need to fetch it.
  :defer t
  :bind (:map smerge-mode-map
              ("C-c ^ u" . smerge-keep-upper)  ;; Keep the changes from the upper version.
              ("C-c ^ l" . smerge-keep-lower)  ;; Keep the changes from the lower version.
              ("C-c ^ n" . smerge-next)        ;; Move to the next conflict.
              ("C-c ^ p" . smerge-previous)))  ;; Move to the previous conflict.


;;; ELDOC
;; Eldoc provides helpful inline documentation for functions and variables
;; in the minibuffer, enhancing the development experience. It can be particularly useful
;; in programming modes, as it helps you understand the context of functions as you type.
;; This package is built-in, so there's no need to fetch it separately.
;; The following line enables Eldoc globally for all buffers.
(use-package eldoc
  :ensure nil          ;; This is built-in, no need to fetch it.
  :init
  (global-eldoc-mode))


;;; WHICH-KEY
;; `which-key' is an Emacs package that displays available keybindings in a
;; popup window whenever you partially type a key sequence. This is particularly
;; useful for discovering commands and shortcuts, making it easier to learn
;; Emacs and improve your workflow. It helps users remember key combinations
;; and reduces the cognitive load of memorizing every command.
(use-package which-key
  :ensure nil     ;; This is built-in, no need to fetch it.
  :defer t        ;; Defer loading Which-Key until after init.
  :diminish which-key-mode
  :hook
  (after-init . which-key-mode)) ;; Enable which-key mode after initialization.


;;; ELECTRIC PAIR
;; `electric-pair' is an Emacs package that automatically types the closing
;; character for paired syntax elements (quotations, brackets, etc).
(use-package electric-pair
  :ensure nil
  :init
  (defun markdown-electric-pair-string-delimiter ()
	(when (and electric-pair-mode
			   (memq last-command-event '(?\* ?\_))
			   (let ((count 0))
				 (while (eq (char-before (- (point) count)) last-command-event)
				   (setq count (1+ count)))
				 (= count 2)))
	  (save-excursion (insert (make-string 2 last-command-event)))))
  :config
  (defun my/text-electric-pair-inhibit (char)
	;; Account for buffer-end weirdness
	(unless (eq (following-char) 0)
	  (or
	   ;; (electric-pair-inhibit-if-helps-balance char)
	   ;; TODO This logic isn't quite right, check out how
	   ;; `electric-pair-inhibit-if-helps-balance' does it.
	   ;; (electric-pair-conservative-inhibit char)
	   ;; Don't pair after before a word
	   (memq (char-syntax (char-before)) '(?w ?.))
	   (memq (char-syntax (following-char)) '(?w ?.))
	   (memq (char-syntax (char-after (- (point) 2))) '(?w ?.)))))
  (setq electric-pair-inhibit-predicate #'my/text-electric-pair-inhibit)
  (modify-syntax-entry ?/ "\"" org-mode-syntax-table)
  (modify-syntax-entry ?* "\"" org-mode-syntax-table)
  (modify-syntax-entry ?= "\"" org-mode-syntax-table)
  (modify-syntax-entry ?+ "\"" org-mode-syntax-table)
  (modify-syntax-entry ?_ "\"" org-mode-syntax-table)
  (modify-syntax-entry ?~ "\"" org-mode-syntax-table)
										; Source - https://stackoverflow.com/a/19715115
										; Posted by Stefan, modified by community. See post 'Timeline' for change history
										; Retrieved 2026-08-19, License - CC BY-SA 3.0
  :hook
  ((org-mode markdown-mode md-mode prog-mode) . electric-pair-mode)
  ((markdown-mode markdown-ts-mode md-mode) . (lambda ()
			   (add-hook 'post-self-insert-hook
						 #'markdown-electric-pair-string-delimiter 'append t)))
  ((markdown-mode markdown-ts-mode md-mode) . (lambda ()
			   (setq-local electric-pair-pairs
						   (append electric-pair-pairs
								   '((?* . ?*)
									 (?_ . ?_)
									 ))))))


;;; COMPLETION PREVIEW
;; This library provides the Completion Preview mode.  This minor mode
;; displays a completion suggestion for the symbol at point in an
;; overlay after point.  Check out the customization group
;; `completion-preview' for user options that you may want to tweak.
(use-package completion-preview
  :ensure nil
  :diminish completion-preview-mode
  :custom
  (completion-preview-minimum-symbol-length 2)
  :hook (((prog-mode org-mode md-mode markdown-mode) . completion-preview-mode)
		 ((prog-mode org-mode md-mode markdown-mode) . completion-preview-echo-mode)
         (org-mode . (lambda ()
                       ;; need to overwrite `completion-preview-commands' to trigger
                       ;; completion-preview
                       (setq-local completion-preview-commands
                                   '(;; self-insert-command
                                     evil-delete-backward-char-and-join
                                     org-self-insert-command
                                     insert-char
                                     delete-backward-char
                                     org-delete-backward-char
                                     backward-delete-char-untabify
                                     analyze-text-conversion
                                     completion-preview-complete)))))
  :general-config
  (:keymaps 'completion-preview-active-mode-map
			"TAB" 'completion-preview-insert
			"M-SPC" 'completion-at-point
            "M-n" 'completion-preview-next-candidate
            "M-p" 'completion-preview-prev-candidate)
  :config

  (setq completion-preview-minimum-symbol-length 3
        completion-preview-message-format nil
        completion-preview-sort-function #'minibuffer-sort-by-history)
  (dolist (cmd '(org-self-insert-command org-delete-backward-char))
    (add-to-list 'completion-preview-commands cmd))

  (defun my/completion-preview-in-minibuffer ()
    "Enable Completion Preview in the minibuffer if Vertico is not active."
    (unless (or (bound-and-true-p vertico--input)
                (memq this-command '(org-ql-find))
                (memq (current-local-map) (list read-passwd-map)))
      (completion-preview-mode 1)))

  ;; From https://github.com/agzam/.doom.d/blob/main/modules/custom/completion/config.el
  (defvar completion-preview-echo-max 5
    "Maximum number of completion-preview candidates shown per echo-area page.")
  (defvar completion-preview--echo-shown nil
  "Non-nil while the echo-area candidate list is on screen.")
  (defface completion-preview-echo-number '((t :foreground "orange"))
    "Face for the index number shown before each echo-list candidate."
    :group 'completion-preview)
  (defvar completion-preview-echo-number-height 1.1
    "Height multiplier applied to the superscript echo-list index numbers.")
  (defconst completion-preview--superscripts ["⁰" "¹" "²" "³" "⁴" "⁵" "⁶" "⁷" "⁸" "⁹"]
    "Superscript glyphs for digits 0-9.")

  (defun completion-preview--superscript (n)
    "Return the natural number N rendered with superscript digits."
    (mapconcat (lambda (c) (aref completion-preview--superscripts (- c ?0)))
               (number-to-string n) ""))

  (defun completion-preview--echo-string ()
    "Return the echo string for the current preview page, or nil when inactive.a
Shows the page of up to `completion-preview-echo-max' candidates containing
the current one (highlighted).  Each candidate is prefixed with its 1-based
on-page index as an orange superscript (the key that inserts it, M-1..M-N),
and a leading/trailing arrow marks more candidates before/after the page."
    (when (bound-and-true-p completion-preview--overlay)
      (let* ((ov completion-preview--overlay)
             (common (or (overlay-get ov 'completion-preview-common) ""))
             (sufs (overlay-get ov 'completion-preview-suffixes))
             (idx (or (overlay-get ov 'completion-preview-index) 0))
             (total (length sufs))
             (size completion-preview-echo-max)
             (start (* (/ idx size) size))
             (end (min total (+ start size)))
             (cands (cl-loop for i from start below end
                             for num = (propertize
                                        (completion-preview--superscript (1+ (- i start)))
                                        'face `((:height ,completion-preview-echo-number-height)
                                                completion-preview-echo-number))
                             for cand = (substring-no-properties
                                         (concat common (nth i sufs)))
                             collect (concat num (if (= i idx)
                                                     (propertize cand 'face 'highlight)
                                                   cand)))))
        (concat (and (< 0 start) "← ")
                (mapconcat #'identity cands "  ")
                (and (< end total) " →")))))

  (defun completion-preview-echo-candidates (&rest _)
    "Echo the current page of completion-preview candidates."
    (if-let* ((str (completion-preview--echo-string)))
        (progn
          (setq completion-preview--echo-shown t)
          (let ((message-log-max nil)) (message "%s" str)))
      (completion-preview-echo-clear)))

  (defun completion-preview-echo-clear (&rest _)
    "Clear the echoed candidate list once the preview is gone."
    (when (and completion-preview--echo-shown
               (not (bound-and-true-p completion-preview--overlay)))
      (setq completion-preview--echo-shown nil)
      (let ((message-log-max nil)) (message nil))))

  (defun completion-preview-insert-indexed (n)
    "Complete with the Nth (1-based) candidate of the visible echo page.
The inline-preview analog of `+corfu-insert-indexed': one press inserts.
Mirrors `completion-preview-insert' (which inserts the shown text and runs
the capf :exit-function) but targets the chosen index directly."
    (when (bound-and-true-p completion-preview--overlay)
      (let* ((ov completion-preview--overlay)
             (base (or (overlay-get ov 'completion-preview-base) ""))
             (beg (overlay-get ov 'completion-preview-beg))
             (end (overlay-get ov 'completion-preview-end))
             (sufs (overlay-get ov 'completion-preview-suffixes))
             (common (or (overlay-get ov 'completion-preview-common) ""))
             (idx (or (overlay-get ov 'completion-preview-index) 0))
             (efn (plist-get (overlay-get ov 'completion-preview-props) :exit-function))
             (size completion-preview-echo-max)
             (target (+ (* (/ idx size) size) (1- n))))
        (when (< target (length sufs))
          (let* ((cand (concat common (nth target sufs)))
                 (skip (- end beg))
                 (visible (if (<= 0 skip (length cand)) (substring cand skip) "")))
            (completion-preview-active-mode -1)
            (goto-char end)
            (insert-and-inherit visible)
            (when (functionp efn)
              (funcall efn (concat base cand) 'finished)))))))

  (defun completion-preview-next-candidate-guard-a (orig &rest args)
    "Hide the preview instead of throwing if cycling hits a stale overlay.
`completion-preview-next-candidate' runs an unguarded `buffer-substring' on
the overlay's stored integer positions; they go stale in buffers rewritten
under it (e.g. eca-chat streaming)."
    (condition-case nil
        (apply orig args)
      (args-out-of-range
       (when (bound-and-true-p completion-preview-active-mode)
         (completion-preview-active-mode -1)))))

  ;; M+number completes with the Nth candidate of the visible page, like
  ;; `+corfu-insert-indexed'.  Bound only here, so `digit-argument' stays
  ;; intact when no preview is shown.
  (defun completion-preview-echo-key-setup ()
    (cond
     (completion-preview-echo-mode
      (keymap-set completion-preview-active-mode-map
                  "M-1" (lambda () (interactive)
                          (completion-preview-insert-indexed 1)))
      (keymap-set completion-preview-active-mode-map
                  "M-2" (lambda () (interactive)
                          (completion-preview-insert-indexed 2)))
      (keymap-set completion-preview-active-mode-map
                  "M-3" (lambda () (interactive)
                          (completion-preview-insert-indexed 3)))
      (keymap-set completion-preview-active-mode-map
                  "M-4" (lambda () (interactive)
                          (completion-preview-insert-indexed 4)))
      (keymap-set completion-preview-active-mode-map
                  "M-5" (lambda () (interactive)
                          (completion-preview-insert-indexed 5))))
     (t (dolist (key '("M-1" "M-2" "M-3" "M-4" "M-5"))
          (keymap-unset completion-preview-active-mode-map key)))))

  (define-minor-mode completion-preview-echo-mode
    "Show completion previews in the echo area."
    :global t
    :lighter ""
    (unless completion-preview-mode
      (message "`completion-preview-echo-mode' requires `completion-preview-mode' \
to be active.")
      (setq completion-preview-echo-mode nil))
    (cond
     (completion-preview-echo-mode
      ;; Popup-less candidate list: echo the current page of candidates.
      ;; `completion-preview--update' is the per-keystroke convergence point;
      ;; guard it since it is a private symbol.
      (completion-preview-echo-key-setup)
      (when (fboundp 'completion-preview--update)
        (advice-add 'completion-preview--update :after
                    #'completion-preview-echo-candidates))
      (advice-add 'completion-preview-next-candidate :after
                  #'completion-preview-echo-candidates)
      (advice-add 'completion-preview-active-mode :after
                  #'completion-preview-echo-clear)
      (advice-add 'completion-preview-next-candidate :around
                  #'completion-preview-next-candidate-guard-a))
     (t (completion-preview-echo-key-setup)
        (advice-remove 'completion-preview--update #'completion-preview-echo-candidates)
        (advice-remove 'completion-preview-next-candidate #'completion-preview-echo-candidates)
        (advice-remove 'completion-preview-active-mode #'completion-preview-echo-clear)
        (advice-remove 'completion-preview-next-candidate
                       #'completion-preview-next-candidate-guard-a)))))


;;; IBUFFER
;; Ibuffer is a built-in Emacs package that allows users to manage and
;; operate on buffers in a Dired-like manner, enabling sorting,
;; filtering, and marking of buffers based on various criteria.
(use-package ibuffer
  :ensure t
  :defer t
  :commands (ibuffer)
  :general
  ("C-x C-b" 'ibuffer)
  :init
  (sanityinc/fullframe-mode 'ibuffer-mode))


;;; ==================== EXTERNAL PACKAGES ====================
;;
;; From this point onward, all configurations will be for third-party packages
;; that enhance Emacs' functionality and extend its capabilities.


;; Load our env file:
(load-library (concat user-emacs-directory "lisp/ap-env.el.gpg"))


;;; RESIZE WINDOW BY ALIST
;; This was generated by GPT-OSS 120B to provide basic customization to popper:
  (defun resize-window-by-alist (win alist)
  "Resize WIN according to ALIST.

ALIST is a list of cons cells (PAT . HEIGHT).

  * PAT  – either a **string** (treated as a regexp) that is matched
           against the *buffer name* shown in WIN, or a **symbol**
           that is compared with the buffer’s `major-mode`.

  * HEIGHT – how tall the window should become.
      - If HEIGHT is an integer ≥ 1, that many *text lines* are used.
      - If HEIGHT is a float between 0 and 1, it is interpreted as a
        proportion of the current frame’s total height (rounded to the
        nearest line).

The first entry whose PAT matches wins; the window is set to the
corresponding HEIGHT and the function returns non‑nil.  If nothing
matches, the window is left unchanged and the function returns nil.

WIN must be a live window object; it can be the selected window,
a window passed from another function, or obtained with any of the
standard Emacs window‑selection utilities."
  (when (window-live-p win)                ; safety – the window may have been deleted
    (let* ((buf          (window-buffer win))
           (buf-name     (buffer-name buf))
           (buf-mode     (with-current-buffer buf major-mode))
           (frame-lines  (frame-height))   ; total text lines in the frame
           (target-height nil))

      ;; -----------------------------------------------------------------
      ;; 1️⃣ Find the first matching entry in ALIST
      ;; -----------------------------------------------------------------
      (catch 'found
        (dolist (entry alist)
          (let ((pat (car entry))
                (h   (cdr entry)))
            (cond
             ;; PAT is a string → regexp match against the buffer name
             ((and (stringp pat)
                   (string-match-p pat buf-name))
              (setq target-height h)
              (throw 'found t))

             ;; PAT is a symbol → compare with the buffer's major mode
             ((and (symbolp pat)
                   (eq buf-mode pat))
              (setq target-height h)
              (throw 'found t))))))

      ;; -----------------------------------------------------------------
      ;; 2️⃣ If we found a match, compute the exact number of lines
      ;; -----------------------------------------------------------------
      (when target-height
        (let ((lines
               (cond
                ;; Float → proportion of the frame height
                ((floatp target-height)
                 (max 1 (round (* frame-lines target-height))))
                ;; Integer → literal line count (clamp to at least 1)
                ((integerp target-height)
                 (max 1 target-height))
                (t
                 (error "HEIGHT must be an integer or a float: %S" target-height)))))

		  ;; -----------------------------------------------------------------
		  ;; 3️⃣ Resize the window *exactly* to that height
		  ;; -----------------------------------------------------------------
		  (set-window-text-height win lines)
		  t)))))


;;; DIMINISH
;; This package implements hiding or abbreviation of the mode line
;; displays (lighters) of minor-modes.
(use-package diminish
  :straight t
  :config
  (diminish 'visual-line-mode)
  (diminish 'eldoc-mode)
  (diminish 'evil-collection-unimpaired-mode))

;;; POPPER
;; Popper is a minor-mode to tame the flood of ephemeral windows Emacs
;; produces, while still keeping them within arm’s reach.
;;
;; Designate any buffer to “popup” status, and it will stay out of
;; your way. Disimss or summon it easily with one key. Cycle through
;; all your “popups” or just the ones relevant to your current buffer.
;; Group popups automatically so you’re presented with the most
;; relevant ones. Useful for many things, including toggling display
;; of REPLs, documentation, compilation or shell output: any buffer
;; you need instant access to but want kept out of your way!
(use-package popper
  :straight t
  :bind (("M-`"   . popper-toggle)
		 ("C-`"   . popper-cycle)
		 ("C-M-`" . popper-toggle-type))
  :custom
  (popper-group-function #'popper-group-by-project)
  (popper-reference-buffers
   '("\\*\\(lsp-help\\|Backtrace\\|Warnings\\|Compile-Log\\|[Hh]elp\\|Messages\\|Bookmark List\\|Occur\\|eldoc.*\\)\\*"
	 "\\*\\(Flymake diagnostics\\|xref\\|ivy\\|Swiper\\|Completions\\)"
	 "Output\\*$"
	 "\\*Async Shell Command\\*"
	 help-mode
	 compilation-mode
	 ghostel-mode))
  (popper-window-height 'ap/custom-popper--fit-window-height)
  :hook
  (after-init . popper-mode)
  (after-init . popper-tab-line-mode)
  :init
  (defvar ap/custom-popper-window-height-alist '((ghostel-mode . 0.45)))
  (defun ap/custom-popper--fit-window-height (win)
	"Use `resize-window-by-alist' to customize buffer height. Otherwise, use
`popper--fit-window-height'."
	(unless (resize-window-by-alist win ap/custom-popper-window-height-alist)
	  (popper--fit-window-height win))))


;;; FLYCHECK
;; Modern on-the-fly syntax checking extension for GNU Emacs.
(defalias 'ap/next-error 'flycheck-next-error)
(defalias 'ap/prev-error 'flycheck-previous-error)
(use-package flycheck
  :ensure t
  :straight t
  :hook (prog-mode . flycheck-mode))


;;; GHOSTEL
;; Provides a termainl using is a terminal emulator for Emacs powered by
;; libghostty-vt, the VT engine behind the Ghostty terminal.
;;
;; It aims to be featureful, fast, robust and correct.
;;
;; Ghostel's features include synchronized output, true color, the Kitty keyboard
;; and graphics protocols, hyperlinks, desktop notifications, progress reports and
;; a lot more.
;;
;; Shell integration (directory tracking, prompt navigation) all works out of the
;; box for bash, zsh, fish and nushell.
(use-package ghostel
  :straight t
  :init
  (setq ghostel-compile-global-mode t)
  (autoload 'ghostel-compile--compilation-start-advice "ghostel-compile")
  (advice-add 'compilation-start :around #'ghostel-compile--compilation-start-advice)
  :hook
  (ghostel-mode . (lambda ()
                   (setq-local global-hl-line-mode nil)
                   (display-line-numbers-mode -1)
                   ;; Clean up the window when the buffer is killed
                   (add-hook 'kill-buffer-hook #'ghostel--close-window-on-kill nil t)))
  :general
  (general-nmap
	"<leader> t t" 'ghostel)
  (:keymaps 'ghostel-semi-char-mode-map
			"M-`" 'popper-toggle
			"M-o" 'other-window))

(defun ghostel--close-window-on-kill ()
  "Remove window if it contains a Ghostel buffer, unless last window."
  (when (derived-mode-p 'ghostel-mode)
    ;; Only delete the window if there are other windows in this frame
    (when (> (length (window-list)) 1)
      (delete-window))))

(use-package evil-ghostel
  :straight (evil-ghostel
			 :type git
			 :host github
			 :repo "dakra/ghostel"
			 :files ("extensions/evil-ghostel/evil-ghostel.el"))
  :after (ghostel evil)
  :hook (ghostel-mode . evil-ghostel-mode)
  :custom
  (evil-ghostel-escape 'evil) ; make ESC always switches to evil normal state
  :config
  ;; Make C-q the literal-key escape hatch in insert state.
  (evil-define-key 'insert evil-ghostel-mode-map
	(kbd "C-q") #'ghostel-send-next-key))


;;; HYDRA
;; Hydras and transient menus both can provide a temporary menu of commands at
;; the bottom of the screen. Hydras can also provide a pop-up menu as alternate
;; mode of operation. Transient menus are currently more popular. Both are
;; useful for getting work done with an unfamiliar package by providing for the
;; execution of commands by clicking on hyperlinks.
(use-package hydra
  :straight t)


;;; VERTICO
;; Vertico enhances the completion experience in Emacs by providing a
;; vertical selection interface for both buffer and minibuffer completions.
;; Unlike traditional minibuffer completion, which displays candidates
;; in a horizontal format, Vertico presents candidates in a vertical list,
;; making it easier to browse and select from multiple options.
;;
;; In buffer completion, `switch-to-buffer' allows you to select from open buffers.
;; Vertico streamlines this process by displaying the buffer list in a way that
;; improves visibility and accessibility. This is particularly useful when you
;; have many buffers open, allowing you to quickly find the one you need.
;;
;; In minibuffer completion, such as when entering commands or file paths,
;; Vertico helps by showing a dynamic list of potential completions, making
;; it easier to choose the correct one without typing out the entire string.
(use-package vertico
  :ensure t
  :straight t
  :hook
  (after-init . vertico-mode)           ;; Enable vertico after Emacs has initialized.
  (minibuffer-setup . vertico-repeat-save)
  :custom
  (vertico-count 10)                    ;; Number of candidates to display in the completion list.
  (vertico-resize nil)                  ;; Disable resizing of the vertico minibuffer.
  (vertico-cycle nil)                   ;; Do not cycle through candidates when reaching the end of the list.
  :general-config
   ("M-R" #'vertico-repeat)
  (:keymaps 'vertico-map
			"M-q" #'vertico-quick-insert
			"C-q" #'vertico-quick-exit
			"M-P" #'vertico-repeat-previous
			"M-N" #'vertico-repeat-next)
  :config
  ;; Customize the display of the current candidate in the completion list.
  ;; This will prefix the current candidate with “» ” to make it stand out.
  ;; Reference: https://github.com/minad/vertico/wiki#prefix-current-candidate-with-arrow
  (advice-add #'vertico--format-candidate :around
              (lambda (orig cand prefix suffix index _start)
                (setq cand (funcall orig cand prefix suffix index _start))
                (concat
                 (if (= vertico--index index)
                     (propertize "» " 'face '(:foreground "#80adf0" :weight bold))
                   "  ")
                 cand))))


;;; ORDERLESS
;; Orderless enhances completion in Emacs by allowing flexible pattern matching.
;; It works seamlessly with Vertico, enabling you to use partial strings and
;; regular expressions to find files, buffers, and commands more efficiently.
;; This combination provides a powerful and customizable completion experience.
(use-package orderless
  :ensure t
  :straight t
  :defer t                                    ;; Load Orderless on demand.
  :after vertico                              ;; Ensure Vertico is loaded before Orderless.
  :init
  (setq completion-styles '(orderless basic)  ;; Set the completion styles.
        completion-category-defaults nil      ;; Clear default category settings.
        completion-category-overrides '((file (styles partial-completion))))) ;; Customize file completion styles.


;;; MARGINALIA
;; Marginalia enhances the completion experience in Emacs by adding
;; additional context to the completion candidates. This includes
;; helpful annotations such as documentation and other relevant
;; information, making it easier to choose the right option.
(use-package marginalia
  :ensure t
  :straight t
  :hook
  (after-init . marginalia-mode))


;;; CONSULT
;; Consult provides powerful completion and narrowing commands for Emacs.
;; It integrates well with other completion frameworks like Vertico, enabling
;; features like previews and enhanced register management. It's useful for
;; navigating buffers, files, and xrefs with ease.
(use-package consult
  :ensure t
  :straight t
  :defer t
  :custom
  (consult-narrow-key "<")
  (consult-widen-key ">")
  :general-config
  ([remap switch-to-buffer]  'consult-buffer
   [remap switch-to-buffer-other-window]  'consult-buffer-other-window
   [remap switch-to-buffer-other-frame]  'consult-buffer-other-frame
   [remap goto-line]  'consult-goto-line
   [remap imenu]  'consult-imenu
   [remap browse-kill-ring]  'consult-yank-from-kill-ring
   [remap recentf]  'consult-recent-file)

  :init
  ;; Enhance register preview with thin lines and no mode line.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult for xref locations with a preview feature.
  (setq xref-show-xrefs-function #'consult-xref
		xref-show-definitions-function #'consult-xref)
  :config
   (defun my/consult-buffer-font (&optional buffer)
   "Pick a font family for BUFFER (default current buffer), with live preview."
   (interactive)
   (let* ((buf (or buffer (current-buffer)))
          (orig-face (buffer-local-value 'buffer-face-mode-face buf))
          (orig-mode (buffer-local-value 'buffer-face-mode buf))
          (selected
           (consult--read
            (font-family-list)
            :prompt (format "Font for %s: " (buffer-name buf))
            :require-match t
            :sort t
            :preview-key 'any
            :default (plist-get orig-face :family)
            :state (lambda (action cand)
                     (when (buffer-live-p buf)
                       (with-current-buffer buf
                         (pcase action
                           ('preview
                            (if cand
                                (progn
                                  (setq buffer-face-mode-face (list :family cand))
                                  (buffer-face-mode 1))
                              (setq buffer-face-mode-face orig-face)
                              (buffer-face-mode (if orig-mode 1 -1)))))))))))
     (when selected
       (with-current-buffer buf
         (setq buffer-face-mode-face (list :family selected))
         (buffer-face-mode 1))))))


(use-package consult-hunks
  :ensure nil
  :commands (consult-hunks))


(use-package consult-project-hunks
  :ensure nil
  :commands (consult-project-hunks))


;;; CONSULT FLYCHECK
;; This package provides the consult-flycheck command, which
;; integrates Consult with Flycheck. Take a look at the Consult README
;; for an extensive documentation.
(use-package consult-flycheck
  :straight t
  :ensure t)


;; AFFE Affe provides an asynchronous fuzzy finder similar to the fzf
;; command-line fuzzy finder, written in pure Elisp. A producer
;; process is started in the background, e.g., find or grep. The
;; output produced by this process is filtered by an external
;; asynchronous Emacs process. The Emacs UI always stays responsive
;; since the work is off-loaded to other processes. The results are
;; presented in the minibuffer using Consult, which allows to quickly
;; select from the available items.
(use-package affe
  :ensure t
  :straight t
  :after (orderless)
  :config
  ;; Manual preview key for `affe-grep'
  (consult-customize affe-grep :preview-key "M-.")
  (defun affe-orderless-regexp-compiler (input _type _ignorecase)
    (setq input (cdr (orderless-compile input)))
    (cons input (apply-partially #'orderless--highlight input t)))
  (setq affe-regexp-compiler #'affe-orderless-regexp-compiler))


;;; EMBARK
;; Embark provides a powerful contextual action menu for Emacs, allowing
;; you to perform various operations on completion candidates and other items.
;; It extends the capabilities of completion frameworks by offering direct
;; actions on the candidates.
;; Just `<leader> .' over any text, explore it :)
(use-package embark
  :ensure t
  :straight t
  :general
  ("C-;" 'embark-act)
  (:keymaps 'vertico-map
			"C-c C-o" 'embark-collect
			"C-c C-e" 'embark-export
			"C-c C-c" 'embark-act)
  (:keymaps 'minibuffer-mode-map
			"C-c C-o" 'embark-collect
			"C-c C-e" 'embark-export)
  :general-config
  (:keymaps 'embark-general-map
			"/" 'consult-ripgrep)
  :config
  ;; Use embark for completion help
  (with-eval-after-load 'which-key
	(setq prefix-help-command #'embark-prefix-help-command))
  (defun embark-which-key-indicator ()
	"An embark indicator that displays keymaps using which-key.
The which-key help message will show the type and value of the
current target followed by an ellipsis if there are further
targets."
	(lambda (&optional keymap targets prefix)
	  (if (null keymap)
		  (which-key--hide-popup-ignore-command)
		(which-key--show-keymap
		 (if (eq (plist-get (car targets) :type) 'embark-become)
			 "Become"
		   (format "Act on %s '%s'%s"
				   (plist-get (car targets) :type)
				   (embark--truncate-target (plist-get (car targets) :target))
				   (if (cdr targets) "…" "")))
		 (if prefix
			 (pcase (lookup-key keymap prefix 'accept-default)
			   ((and (pred keymapp) km) km)
			   (_ (key-binding prefix 'accept-default)))
		   keymap)
		 nil nil t (lambda (binding)
					 (not (string-suffix-p "-argument" (cdr binding))))))))
  (setq embark-indicators
  '(embark-which-key-indicator
    embark-highlight-indicator
    embark-isearch-highlight-indicator))
  (defun embark-hide-which-key-indicator (fn &rest args)
  "Hide the which-key indicator immediately when using the completing-read prompter."
  (which-key--hide-popup-ignore-command)
  (let ((embark-indicators
         (remq #'embark-which-key-indicator embark-indicators)))
    (apply fn args)))
  (advice-add #'embark-completing-read-prompter
			:around #'embark-hide-which-key-indicator))


;;; EMBARK-CONSULT
;; Embark-Consult provides a bridge between Embark and Consult, ensuring
;; that Consult commands, like previews, are available when using Embark.
(use-package embark-consult
  :ensure t
  :straight t) ;; Enable preview in Embark collect mode.


;;; TREESITTER-AUTO
;; Treesit-auto simplifies the use of Tree-sitter grammars in Emacs,
;; providing automatic installation and mode association for various
;; programming languages. This enhances syntax highlighting and
;; code parsing capabilities, making it easier to work with modern
;; programming languages.
(use-package treesit-auto
  :ensure t
  :straight t
  :after emacs
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode t))


;;; MARKDOWN-MODE
;; Markdown Mode provides support for editing Markdown files in Emacs,
;; enabling features like syntax highlighting, previews, and more.
;; It’s particularly useful for README files, as it can be set
;; to use GitHub Flavored Markdown for enhanced compatibility.
;; (use-package markdown-mode
;;   :defer t
;;   :straight t
;;   :ensure t
;;   :mode ("README\\.md\\'" . gfm-mode)            ;; Use gfm-mode for README.md files.
;;   :init (setq markdown-command "pandoc")) ;; Set the Markdown processing command.

(use-package md-mode
  :straight (md-mode :type git :host github :repo "yibie/md-mode")
  :mode ("\\.md\\'" . md-mode)
  :general-config (:states 'motion :keymaps 'md-mode-map
					 "] ]" 'outline-next-visible-heading
					 "[ [" 'outline-previous-visible-heading
					 "[ ]" 'outline-up-heading))


;;; TYPST-TS-MODE
;; Tree Sitter support for Typst. Minimum Emacs version requirement: 29. Its
;; tree-sitter grammar is installed once with `M-x typst-ts-mc-install-grammar'
;; treesit-auto doesn't cover Typst.
(use-package typst-ts-mode
  :straight '(:type git :host codeberg :repo "meow_king/typst-ts-mode" :branch "main")
  :after (transient)
  :custom
  (typst-ts-watch-options "--open")
  (typst-ts-mode-grammar-location (expand-file-name "tree-sitter/libtree-sitter-typst.so" user-emacs-directory))
  (typst-ts-mode-enable-raw-blocks-highlight t))


;;; CORFU
;; Corfu Mode provides a text completion framework for Emacs.
;; It enhances the editing experience by offering context-aware
;; suggestions as you type.
;; Corfu Mode is highly customizable and can be integrated with
;; various modes and languages.
(use-package corfu
  :straight t
  :init
  (setq completion-cycle-threshold 4)
  (setq completion-auto-select 'second-tab)
  :custom
  (corfu-auto nil)                       ;; Only completes when hitting TAB
  ;; (corfu-auto-delay 0)                ;; Delay before popup (enable if corfu-auto is t)
  (corfu-auto-prefix 1)                  ;; Trigger completion after typing 1 character
  (corfu-quit-no-match 'separator)       ;; Quit if no match and no M-SPC
  (corfu-scroll-margin 5)                ;; Margin when scrolling completions
  (corfu-max-width 50)                   ;; Maximum width of completion popup
  (corfu-min-width 50)                   ;; Minimum width of completion popup
  (corfu-popupinfo-delay 0.5)            ;; Delay before showing documentation popup
  :hook (after-init . global-corfu-mode)
  :general
  ("C-x C-o" 'completion-at-point)
  :general-config
  (general-imap :keymaps 'corfu-map
			  "C-c" 'corfu-quit
			  "Tab" 'corfu-insert
			  "C-y" 'corfu-insert
			  "M-t" 'corfu-popupinfo-toggle
			  "M-n" 'corfu-popupinfo-scroll-down
			  "M-p" 'corfu-popupinfo-scroll-up
			  "M-q" #'corfu-quick-complete
			  "C-q" #'corfu-quick-insert
			  "M-m" #'corfu-move-to-minibuffer)
  :config
  (if ek-use-nerd-fonts
	  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))
  (corfu-popupinfo-mode)
  (defun corfu-enable-in-minibuffer ()
    "Enable Corfu in the minibuffer."
    (when (local-variable-p 'completion-at-point-functions)
      ;; (setq-local corfu-auto nil) ;; Enable/disable auto completion
      (setq-local corfu-echo-delay nil ;; Disable automatic echo and popup
                  corfu-popupinfo-delay nil)
      (corfu-mode 1)))
  (add-hook 'minibuffer-setup-hook #'corfu-enable-in-minibuffer)
  (defun corfu-move-to-minibuffer ()
    (interactive)
    (pcase completion-in-region--data
      (`(,beg ,end ,table ,pred ,extras)
       (let ((completion-extra-properties extras)
             completion-cycle-threshold completion-cycling)
         (consult-completion-in-region beg end table pred)))))
  (add-to-list 'corfu-continue-commands #'corfu-move-to-minibuffer)
  (require 'corfu-quick))


;;; LSP
;; Emacs comes with an integrated LSP client called `eglot', which offers basic LSP functionality.
;; However, `eglot' has limitations, such as not supporting multiple language servers
;; simultaneously within the same buffer (e.g., handling both TypeScript, Tailwind and ESLint
;; LSPs together in a React project). For this reason, the more mature and capable
;; `lsp-mode' is included as a third-party package, providing advanced IDE-like features
;; and better support for multiple language servers and configurations.
;;
;; NOTE: To install or reinstall an LSP server, use `M-x install-server RET`.
;;       As with other editors, LSP configurations can become complex. You may need to
;;       install or reinstall the server for your project due to version management quirks
;;       (e.g., asdf or nvm) or other issues.
;;       Fortunately, `lsp-mode` has a great resource site:
;;       https://emacs-lsp.github.io/lsp-mode/
(use-package lsp-mode
  :ensure t
  :straight t
  :defer t
  :hook (;; Replace XXX-mode with concrete major mode (e.g. python-mode)
		 (lsp-mode . lsp-enable-which-key-integration)  ;; Integrate with Which Key
		 ((js-mode                                      ;; Enable LSP for JavaScript
		   tsx-ts-mode                                  ;; Enable LSP for TSX
		   typescript-ts-base-mode                      ;; Enable LSP for TypeScript
		   css-mode                                     ;; Enable LSP for CSS
		   css-ts-mode
		   go-ts-mode                                   ;; Enable LSP for Go
		   js-ts-mode                                   ;; Enable LSP for JavaScript (TS mode)
		   json-ts-mode
		   jsx-ts-mode
		   lua-ts-mode
		   fish-mode
		   svelte-ts-mode
		   python-mode                                  ;; Enable LSP for Python
		   python-ts-mode                               ;; Enable LSP for Python
		   ruby-base-mode                               ;; Enable LSP for Ruby
		   rust-ts-mode                                 ;; Enable LSP for Rust
		   web-mode) . lsp-deferred))                   ;; Enable LSP for Web (HTML)
  (lsp-completion-mode . my/lsp-mode-setup-completion)
  :commands lsp
  :custom
  (lsp-use-plists t)                                    ;; Plists
  (lsp-keymap-prefix "C-c l")                           ;; Set the prefix for LSP commands.
  (lsp-inlay-hint-enable nil)                           ;; Usage of inlay hints.
  (lsp-completion-provider :none)                       ;; Disable the default completion provider.
  (lsp-session-file (locate-user-emacs-file ".lsp-session")) ;; Specify session file location.
  (lsp-log-io nil)                                      ;; Disable IO logging for speed.
  (lsp-idle-delay 0.5)                                  ;; Set the delay for LSP to 0 (debouncing).
  (lsp-keep-workspace-alive nil)                        ;; Disable keeping the workspace alive.
  ;; Core settings
  (lsp-enable-xref t)                                   ;; Enable cross-references.
  (lsp-auto-configure t)                                ;; Automatically configure LSP.
  (lsp-enable-links nil)                                ;; Disable links.
  (lsp-eldoc-enable-hover t)                            ;; Enable ElDoc hover.
  (lsp-enable-file-watchers nil)                        ;; Disable file watchers.
  (lsp-enable-folding nil)                              ;; Disable folding.
  (lsp-enable-imenu t)                                  ;; Enable Imenu support.
  (lsp-enable-indentation nil)                          ;; Disable indentation.
  (lsp-enable-on-type-formatting nil)                   ;; Disable on-type formatting.
  (lsp-enable-suggest-server-download t)                ;; Enable server download suggestion.
  (lsp-enable-symbol-highlighting t)                    ;; Enable symbol highlighting.
  (lsp-enable-text-document-color t)                    ;; Enable text document color.
  ;; Modeline settings
  (lsp-modeline-code-actions-enable nil)                ;; Keep modeline clean.
  (lsp-modeline-diagnostics-enable nil)                 ;; Use `flymake' instead.
  (lsp-modeline-workspace-status-enable t)              ;; Display "LSP" in the modeline when enabled.
  (lsp-signature-doc-lines 1)                           ;; Limit echo area to one line.
  (lsp-eldoc-render-all t)                              ;; Render all ElDoc messages.
  ;; Completion settings
  (lsp-completion-enable t)                             ;; Enable completion.
  (lsp-completion-enable-additional-text-edit t)        ;; Enable additional text edits for completions.
  (lsp-enable-snippet nil)                              ;; Disable snippets
  (lsp-completion-show-kind t)                          ;; Show kind in completions.
  ;; Lens settings
  (lsp-lens-enable t)                                   ;; Enable lens support.
  ;; Headerline settings
  (lsp-headerline-breadcrumb-enable-symbol-numbers t)   ;; Enable symbol numbers in the headerline.
  (lsp-headerline-arrow "▶")                            ;; Set arrow for headerline.
  (lsp-headerline-breadcrumb-enable-diagnostics nil)    ;; Disable diagnostics in headerline.
  (lsp-headerline-breadcrumb-icons-enable nil)          ;; Disable icons in breadcrumb.
  (lsp-headerline-breadcrumb-enable nil)
  ;; Semantic settings
  (lsp-semantic-tokens-enable nil)                     ;; Disable semantic tokens.
  :init
  (defun my/lsp-mode-setup-completion ()
	(setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
		  '(orderless))) ;; Configure orderless
  :config
  ;; Use these for custom lsp servers / servers not supported by lsp-mode:
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection '("uvx" "ruff" "server"))
					:major-modes '(python-mode python-ts-mode)
					:server-id 'ruff-uvx
					:priority 1))
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection '("uvx" "ty" "server"))
					:major-modes '(python-mode python-ts-mode)
					:server-id 'ty-uvx
					:priority 2
					:add-on? t))
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection '("tinymist" "lsp"))
					:major-modes '(typst-ts-mode)
					:server-id 'tinymist
					:priority 2))
  (lsp-register-custom-settings `(("harper-ls.userDictPath" "")))
  (lsp-defcustom lsp-harper-linters-sentence-capilization nil
	"Whether sentences should start with a capital letter"
	:type '(choice (const :tag "Enabled"        t)
				   (const :tag "Disabled"      :json-false)
				   (const :tag "Not Specified" nil))
	:lsp-path "harper-ls.linters.SentenceCapitalization")
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection '("harper-ls" "-s"))
					:major-modes '(org-mode markdown-mode markdown-ts-mode typst-ts-mode)
					:server-id 'harper-ls
					:priority 1
					:add-on? t
					:initialization-options
					'(:userDictPath ""
									:fileDictPath "$XDG_CONFIG_HOME/harper-ls/dictionary.txt"
									:linters (:SpellCheck t
														  :AnA t
														  :Anywhere t
														  :AsFarBackAs t
														  :CorrectNumberSuffix t
														  :Dashes :json-false
														  :LongSentences t
														  :Matcher t
														  :RepeatedWords t
														  :SentenceCapitalization t
														  :Spaces :json-false
														  :SpellCheck t
														  :SpelledNumbers :json-false
														  :UnclosedQuotes t
														  :WrongQuotes :json-false
														  :SpelledNumbers :json-false)
									:rules (:Alongside t
													   :ApartFrom t
													   :Anywhere t
													   :AsFarBackAs t
													   :AsLongAs t
													   :BackInTheDay t
													   :ByAccident t
													   :Cant t
													   :ChangeTack t
													   :Confident t
													   :CriteriaPhenomena t
													   :Didnt t
													   :DoNotWant t
													   :EllipsisLength t
													   :Everybody t
													   :ExpandBecause t
													   :FootTheBill t
													   :Freezing t
													   :GoogleNames t
													   :HadOf t
													   :HelloGreeting t
													   :Holidays t
													   :InMyOpinion t
													   :InRealLife t
													   :ItCan t
													   :IveGotTo t
													   :Koreas t
													   :LastButNotLeast t
													   :LongSentences t
													   :ManagerialReins t
													   :Misunderstood t
													   :MootPoint t
													   :Multicore t
													   :Nothing t
													   :NotTo t
													   :Notwithstanding t
													   :Overall t
													   :PossessiveNoun :json-false
													   :PrayingMantis t
													   :ProperNouns t
													   :RapidFire t
													   :Theres t
													   :ThoughtProcess t
													   :TransposedSpace t
													   :Unless t
													   :VerbToAdjective t)
									:codeActions (:ForceStable :json-false)
									:markdown (:IgnoreLinkTitle :json-false)
									:diagnosticSeverity "hint"
									:dialect "American"
									:isolateEnglish :json-false)))
  (setq c-basic-offset 4)
  ;; Custom configuration for fish-lsp that supports actually
  ;; installing the LSP with NPM (shocking!)
  (lsp-dependency 'fish-language-server
				  '(:system "fish-lsp")
				  '(:npm :package "fish-lsp" :path "fish-lsp"))
  (lsp-register-client
   (make-lsp-client
	:server-id 'fish-language-server
	:new-connection
	(lsp-stdio-connection
	 (lambda () (list (lsp-package-path 'fish-language-server) "start")))
	:activation-fn (lsp-activate-on "fish")
	:major-modes '(fish-mode)
	:download-server-fn
	(lambda (_client callback error-callback _update?)
	  (lsp-package-ensure 'fish-language-server callback error-callback))))
  ;; Disable telemetry:
  (lsp-register-custom-settings '(("redhat.telemetry.enable" nil))))


;;; LSP BIOME
;; lsp-mode client for Biome.
(use-package lsp-biome
    :straight (lsp-biome
			 :type git
			 :host github
			 :repo "cxa/lsp-biome"))


;;; LSP UI
;; This package contains all the higher level UI modules of lsp-mode,
;; like flycheck support and code lenses.
;;
;; By default, lsp-mode automatically activates lsp-ui unless
;; lsp-auto-configure is set to nil.
(use-package lsp-ui
  :straight t)


;;; CAPE
;; Cape provides Completion At Point Extensions which can be used in
;; combination with Corfu, Company or the default completion UI. The
;; completion backends used by completion-at-point are so called
;; completion-at-point-functions (Capfs).
(use-package cape
  :straight t
  :commands (cape-keyword cape-dabbrev)
  :general
  (general-imap
    "C-x C-f" #'cape-file
    "C-x C-k" #'cape-dict)
  :hook ((md-mode markdown-mode org-mode) .
         (lambda ()
           (setq-local completion-at-point-functions (list #'cape-dict #'cape-keyword #'cape-dabbrev)
                       completion-styles '(basic)))))


;;; Diff-HL
;; The `diff-hl' package provides visual indicators for version control changes
;; directly in the margin of the buffer, showing lines added, deleted, or changed.
;; This is useful for tracking modifications while you edit files. When enabled,
;; it automatically activates in every buffer that has a corresponding version
;; control backend, offering a seamless experience.
;;
;; In comparison, Neovim users often rely on plugins like `gitsigns.nvim' or
;; `vim-signify', which provide similar functionalities by displaying Git
;; changes in the gutter and offer additional features like highlighting
;; changed lines and displaying blame information. `diff-hl' aims to provide
;; a comparable experience in Emacs with its own set of customizations.
(use-package diff-hl
  :defer t
  :straight t
  :ensure t
  :hook
  (find-file . (lambda ()
                 (global-diff-hl-mode)           ;; Enable Diff-HL mode for all files.
                 (diff-hl-flydiff-mode)          ;; Automatically refresh diffs.
                 (diff-hl-margin-mode)))         ;; Show diff indicators in the margin.
  :custom
  (diff-hl-side 'left)                           ;; Set the side for diff indicators.
  (diff-hl-margin-symbols-alist '((insert . "│") ;; Customize symbols for each change type.
                                  (delete . "-")
                                  (change . "│")
                                  (unknown . "?")
                                  (ignored . "i"))))


;;; HL TODO
;; Highlight TODO and similar keywords in comments and strings
(use-package hl-todo
  :defer t
  :ensure t
  :after modus-themes
  :straight t
  :hook
  (after-init . global-hl-todo-mode)
  :config
  (setq hl-todo-keyword-faces
		`(("TODO"   . ,(ap/get-catppuccin-color 'base 'teal))
		  ("FIXME"  . ,(ap/get-catppuccin-color 'base 'red))
		  ("HACK"  . ,(ap/get-catppuccin-color 'base 'yellow))
		  ("NOTE"  . ,(ap/get-catppuccin-color 'base 'sky)))))


;;; RAINBOW MODE
;; This minor mode sets background color to strings that match color
;; names, e.g. #0000ff is displayed in white with a blue background.
(use-package ov ;; Required by this patch to rainbow-mode
  :straight t)
(use-package rainbow-mode
  :defer nil
  :straight (rainbow-mode :type git :host github :repo "amosbird/rainbow-mode")
  :diminish rainbow-mode
  :custom
  (rainbow-x-colors nil)
  :hook
  (prog-mode . rainbow-mode))


;;; MAGIT
;; `magit' is a powerful Git interface for Emacs that provides a complete
;; set of features to manage Git repositories. With its intuitive interface,
;; you can easily stage, commit, branch, merge, and perform other Git
;; operations directly from Emacs. Magit’s powerful UI allows for a seamless
;; workflow, enabling you to visualize your repository's history and manage
;; changes efficiently.
;;
;; In the Neovim ecosystem, similar functionality is provided by plugins such as
;; `fugitive.vim', which offers a robust Git integration with commands that
;; allow you to perform Git operations directly within Neovim. Another popular
;; option is `neogit', which provides a more modern and user-friendly interface
;; for Git commands in Neovim, leveraging features like diff views and staging
;; changes in a visual format. Both of these plugins aim to replicate and
;; extend the powerful capabilities that Magit offers in Emacs.
(use-package magit
  :ensure t
  :straight t
  :defer t
  :init
  (sanityinc/fullframe-mode 'magit-status-mode))


;;; XCLIP
;; `xclip' is an Emacs package that integrates the X Window System clipboard
;; with Emacs. It allows seamless copying and pasting between Emacs and other
;; applications using the clipboard. When `xclip' is enabled, any text copied
;; in Emacs can be pasted in other applications, and vice versa, providing a
;; smooth workflow when working across multiple environments.
(use-package xclip
  :ensure t
  :straight t
  :defer t
  :hook
  (after-init . xclip-mode))     ;; Enable xclip mode after initialization.


;; EVIL
;; The `evil' package provides Vim emulation within Emacs, allowing
;; users to edit text in a modal way, similar to how Vim
;; operates. This setup configures `evil-mode' to enhance the editing
;; experience.
(use-package evil
  :ensure t
  :straight t
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
  (general-nivmap
	"M-l" 'evil-shift-right-line
	"M-h" 'evil-shift-left-line)
  (general-imap
	"C-y" 'yank
	"M-y" 'yank-pop)
  (general-imap :keymaps 'org-mode-map
	"C-y" 'org-yank)
  (general-imap
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
  :straight t
  :custom
  (evil-collection-binding-overrides '((find-usages :enabled nil)))
  :init
  (evil-collection-init))


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
  :straight t
  :after evil-collection
  :config
  (global-evil-surround-mode 1))


;;; EMBRACE.EL
;; Add/Change/Delete pairs based on expand-region.
(use-package embrace
  :straight t
  :hook (org-mode . embrace-org-mode-hook)
  :general
  ("C-," 'embrace-commander))


;;; EVIL EMBRACE
;; This package provides evil integration of embrace.el. Since
;; evil-surround provides a similar set of features as embrace.el,
;; this package aims at adding the goodies of embrace.el to
;; evil-surround and making evil-surround even better.
(use-package evil-embrace
  :straight t
  :after evil-surround
  :config
  (evil-embrace-enable-evil-surround-integration))


;;; EVIL NERD COMMENTER
;; A Nerd Commenter emulation, help you comment code efficiently. For
;; example, you can press “99,ci” to comment out 99 lines.
(use-package evil-nerd-commenter
  :straight t
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
  :straight t
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
  :straight t
  :after evil-collection
  :config
  (global-evil-matchit-mode 1))


;;; TARGETS.EL
;; This package is like a combination of the targets, TextObjectify,
;; anyblock, and expand-region vim plugins.
(use-package targets
  :straight (targets :type git :host github :repo "noctuid/targets.el")
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
  :straight t
  :diminish evil-goggles-mode
  :config
  (setq evil-goggles-pulse nil)
  (evil-goggles-mode)
  (evil-goggles-use-diff-faces))


;; Override evil-replace-register with a function that uses evil-paste and override evil-paste-pop to allow
;; evil-replace-with-register to count as a paste command.
(use-package evil-replace-with-register
  :straight t
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
  :straight (evil-textobj-entire :host github :repo "nscoder/evil-textobj-entire")
  :custom
  (evil-textobj-entire-key "g"))


;;; EVIL RSI
;; evil-rsi is intended to be a port of vim-rsi.
;;
;; It brings some essential emacs motion bindings (and potentially
;; RSI...) back.
(use-package evil-rsi
     :straight (evil-rsi :type git :host github :repo "linktohack/evil-rsi")
	 :diminish evil-rsi-mode
     :after evil
     :config
	 (evil-rsi-mode))


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
  :straight t
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
  :straight t
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
  :straight t
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
  :straight t
  :diminish (better-jumper-mode better-jumper-local-mode)
  :general
  (:states 'normal
           "C-o" 'better-jumper-jump-backward
           "C-i" 'better-jumper-jump-forward)
  :config
  (better-jumper-mode +1))


;;; RAINBOW DELIMITERS
;; The `rainbow-delimiters' package provides colorful parentheses, brackets, and braces
;; to enhance readability in programming modes. Each level of nested delimiter is assigned
;; a different color, making it easier to match pairs visually.
(use-package rainbow-delimiters
  :defer t
  :straight t
  :ensure t
  :hook
  (prog-mode . rainbow-delimiters-mode))


;;; DOOM MODELINE
;; The `doom-modeline' package provides a sleek, modern mode-line that is visually appealing
;; and functional. It integrates well with various Emacs features, enhancing the overall user
;; experience by displaying relevant information in a compact format.
(use-package doom-modeline
  :disabled
  :ensure t
  :straight t
  :defer t
  :custom
  (doom-modeline-buffer-file-name-style 'buffer-name)  ;; Set the buffer file name style to just the buffer name (without path).
  (doom-modeline-project-detection 'project)           ;; Enable project detection for displaying the project name.
  (doom-modeline-buffer-name t)                        ;; Show the buffer name in the mode line.
  (doom-modeline-vcs-max-length 25)                    ;; Limit the version control system (VCS) branch name length to 25 characters.
  :config
  (if ek-use-nerd-fonts                                ;; Check if nerd fonts are being used.
      (setq doom-modeline-icon t)                      ;; Enable icons in the mode line if nerd fonts are used.
    (setq doom-modeline-icon nil))                     ;; Disable icons if nerd fonts are not being used.
  :hook
  (after-init . doom-modeline-mode))


;;; NERD ICONS
;; The `nerd-icons' package provides a set of icons for use in Emacs. These icons can
;; enhance the visual appearance of various modes and packages, making it easier to
;; distinguish between different file types and functionalities.
(use-package nerd-icons
  :if ek-use-nerd-fonts                   ;; Load the package only if the user has configured to use nerd fonts.
  :ensure t                               ;; Ensure the package is installed.
  :straight t
  :defer t)                               ;; Load the package only when needed to improve startup time.


;;; NERD ICONS Dired
;; The `nerd-icons-dired' package integrates nerd icons into the Dired mode,
;; providing visual icons for files and directories. This enhances the Dired
;; interface by making it easier to identify file types at a glance.
(use-package nerd-icons-dired
  :if ek-use-nerd-fonts                   ;; Load the package only if the user has configured to use nerd fonts.
  :ensure t                               ;; Ensure the package is installed.
  :straight t
  :defer t                                ;; Load the package only when needed to improve startup time.
  :hook
  (dired-mode . nerd-icons-dired-mode))


;;; NERD ICONS COMPLETION
;; The `nerd-icons-completion' package enhances the completion interfaces in
;; Emacs by integrating nerd icons with completion frameworks such as
;; `marginalia'. This provides visual cues for the completion candidates,
;; making it easier to distinguish between different types of items.
(use-package nerd-icons-completion
  :if ek-use-nerd-fonts                   ;; Load the package only if the user has configured to use nerd fonts.
  :ensure t                               ;; Ensure the package is installed.
  :straight t
  :after (:all nerd-icons marginalia)     ;; Load after `nerd-icons' and `marginalia' to ensure proper integration.
  :config
  (nerd-icons-completion-mode)            ;; Activate nerd icons for completion interfaces.
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup)) ;; Setup icons in the marginalia mode for enhanced completion display.


;;; NERD ICONS TAB-LINE
;; This package uses the nerd-icons package to apply appropriate icons
;; to tab-line tabs.
(use-package tab-line-nerd-icons
  :if ek-use-nerd-fonts
  :ensure t
  :straight t
  :after (:all nerd-icons)
  :config
  (tab-line-nerd-icons-global-mode))


;;; NERD ICONS IBUFFER
;; Display nerd icons in ibuffer.
(use-package nerd-icons-ibuffer
  :if ek-use-nerd-fonts
  :ensure t
  :straight t
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))


;;; NERD ICONS CORFU
;; Nerd-icons-corfu.el is a library for adding icons to completions in
;; Corfu. It uses nerd-icons.el under the hood and, as such, works on
;; both GUI and terminal. Below is a screenshot of the GUI version.
(use-package nerd-icons-corfu
  :if ek-use-nerd-fonts
  :ensure t
  :straight t
  :after (:all corfu))


;;; MODUS THEMES
;; Starting with version 5.0.0 of the `modus-themes', other packages
;; can be built on top to provide their own "Modus" derivatives.
;; For example, this is what I do with my `ef-themes' and
;; `standard-themes' (starting with versions 2.0.0 and 3.0.0,
;; respectively).
;;
;; The `modus-themes-include-derivatives-mode' makes all Modus
;; commands that act on a theme consider all such derivatives, if
;; their respective packages are available and have been loaded.
;;
;; Note that those packages can even completely take over from the
;; Modus themes such that, for example, `modus-themes-rotate' only
;; goes through the Ef themes (to this end, the Ef themes provide
;; the `ef-themes-take-over-modus-themes-mode' and the Standard
;; themes have the `standard-themes-take-over-modus-themes-mode'
;; equivalent).
;;
;; If you only care about the Modus themes, then (i) you do not need
;; to enable the `modus-themes-include-derivatives-mode' and (ii) do
;; not install and activate those other theme packages.
(use-package modus-themes
  :straight t
  :demand t
  :init
  (modus-themes-include-derivatives-mode 1)
  :bind
  (("<f5>" . modus-themes-rotate)
   ("C-<f5>" . modus-themes-select)
   ("M-<f5>" . modus-themes-load-random))
  :config
  ;; Your customizations here.  All customizations must evaluated
  ;; BEFORE loading the theme.
  (setq modus-themes-to-toggle '(modus-operandi modus-vivendi)
        modus-themes-to-rotate modus-themes-items
        modus-themes-mixed-fonts t
        modus-themes-variable-pitch-ui nil
        modus-themes-italic-constructs t
        modus-themes-bold-constructs t
        modus-themes-completions '((t . (bold)))
        modus-themes-prompts '(bold)
        modus-themes-headings
        '((agenda-structure . (variable-pitch light 2.2))
          (agenda-date . (variable-pitch regular 1.3))
          (t . (bold 1.15)))))

;;; MODUS CATPPUCCIN
;; Themes for Emacs based on the Catppuccin palette, built on
;; modus-themes.
(use-package modus-catppuccin
  :straight (:type git
             :repo "http://gitlab.com/magus/modus-catppuccin.git"
             :branch "main")
  :config
  (modus-themes-load-theme 'catppuccin-latte))


(defconst catppuccin-to-modus-colors
  `((base . bg-main)
	(text . fg-main)
	(mantle . bg-mode-line-active)
	(teal . info)
	(red . err)
	(yellow . warning)
	(sky . operator)))
(defun ap/get-catppuccin-color (fg-key &optional bg-key)
  "Get modus colors based on catppuccin keys passed in FG-KEY and BG-KEY."
  (let ((fg-val (modus-themes-get-color-value (alist-get fg-key catppuccin-to-modus-colors)))
		(bg-val (when bg-key (modus-themes-get-color-value (alist-get bg-key catppuccin-to-modus-colors)))))
		(if bg-val
			`(:background ,bg-val
						  :foreground ,fg-val)
		  fg-val)))


;;; STANDARD THEMES
;; The standard-themes are a collection of light and dark themes for
;; GNU Emacs. The standard-light and standard-dark emulate the
;; out-of-the-box looks of Emacs (which technically do NOT constitute
;; a theme) while bringing to them thematic consistency,
;; customizability, and extensibility. Other themes are stylistic
;; variations of those.
(use-package standard-themes
  :straight t)


;;; AVY
;; avy is a GNU Emacs package for jumping to visible text using a
;; char-based decision tree. See also ace-jump-mode and vim-easymotion
;; - avy uses the same idea.
(use-package avy
  :straight t
  :general
  (general-nmap
	"<leader>gb" 'avy-pop-mark
	"<leader>gl" 'avy-goto-line
	"<leader>gg" 'avy-goto-char-timer
	"RET" 'avy-goto-word-0
	"ga" 'avy-goto-char-timer
	"gl" 'avy-goto-line)
  :config
  (defun avy-action-kill-whole-line (pt)
	(save-excursion
	  (goto-char pt)
	  (kill-whole-line))
	(select-window
	 (cdr
	  (ring-ref avy-ring 0)))
	t)
  (defun avy-action-copy-whole-line (pt)
	(save-excursion
	  (goto-char pt)
	  (cl-destructuring-bind (start . end)
		  (bounds-of-thing-at-point 'line)
		(copy-region-as-kill start end)))
	(select-window
	 (cdr
	  (ring-ref avy-ring 0)))
	t)
  (defun avy-action-yank-whole-line (pt)
	(avy-action-copy-whole-line pt)
	(save-excursion (yank))
	t)
  (defun avy-action-mark-to-char (pt)
	(activate-mark)
	(goto-char pt))
  (defun avy-action-flyspell (pt)
	(save-excursion
	  (goto-char pt)
	  (when (require 'flyspell nil t)
		(flyspell-correct-at-point)))
	(select-window
	 (cdr (ring-ref avy-ring 0)))
	t)
  (defun avy-action-teleport-whole-line (pt)
	(avy-action-kill-whole-line pt)
	(save-excursion (yank)) t)
  (defun avy-action-embark (pt)
	(unwind-protect
		(save-excursion
		  (goto-char pt)
		  (embark-act))
	  (select-window
	   (cdr (ring-ref avy-ring 0))))
	t)
  (setf (alist-get ?y avy-dispatch-alist) 'avy-action-yank
		(alist-get ?w avy-dispatch-alist) 'avy-action-copy
		(alist-get ?W avy-dispatch-alist) 'avy-action-copy-whole-line
		(alist-get ?t avy-dispatch-alist) 'avy-action-teleport
		(alist-get ?T avy-dispatch-alist) 'avy-action-teleport-whole-line
		(alist-get ?Y avy-dispatch-alist) 'avy-action-yank-whole-line
		(alist-get ?k avy-dispatch-alist) 'avy-action-kill-stay
		(alist-get ?K avy-dispatch-alist) 'avy-action-kill-whole-line
		(alist-get ?  avy-dispatch-alist) 'avy-action-mark-to-char
		(alist-get ?. avy-dispatch-alist) 'avy-action-flyspell
		(alist-get ?\; avy-dispatch-alist) 'avy-action-embark)
  (setq avy-keys (delete ?k avy-keys)))


;;; ACE WINDOW
;; I'm sure you're aware of the other-window command. While it's great
;; for two windows, it quickly loses its value when there are more
;; windows. You need to call it many times, and since it's not easily
;; predictable, you have to check each time if you're in the window
;; that you wanted.
;;
;; Another approach is to use windmove-left, windmove-up, etc. These
;; are fast and predictable. Their disadvantage is that they need 4
;; key bindings. The default ones are shift+arrows, which are hard to
;; reach.
;;
;; This package aims to take the speed and predictability of windmove
;; and pack it into a single key binding, similar to other-window.
(use-package ace-window
  :straight t
  :general
  ;; ("M-o" 'ace-window)
  ([remap other-window] 'ace-window)
  :custom
  (ace-window-display-mode t)
  (aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (aw-dispatch-alist
   '((?x aw-delete-window "Delete Window")
	 (?m aw-swap-window "Swap Windows")
	 (?M aw-move-window "Move Window")
	 (?c aw-copy-window "Copy Window")
	 (?B aw-switch-buffer-in-window "Select Buffer")
	 (?n aw-flip-window)
	 (?u aw-switch-buffer-other-window "Switch Buffer Other Window")
	 (?c aw-split-window-fair "Split Fair Window")
	 (?v aw-split-window-vert "Split Vert Window")
	 (?b aw-split-window-horz "Split Horz Window")
	 (?o delete-other-windows "Delete Other Windows")
	 (?r aw-window-resize "Resize Window")
	 (?? aw-show-dispatch-help)))
  :config
  ;; Resize window using hydras
  (defhydra hydra-window-resizer (:columns 2)
	"Window Sizing."
	("-" shrink-window-horizontally "horizontal shrink")
	("=" enlarge-window-horizontally "horizontal enlarge")
	("_" shrink-window "vertical shrink")
	("+" enlarge-window "vertical enlarge"))
  (defun aw-window-resize (window)
	"Resize WINDOW using `hydra-window-resizer/body'."
	(aw-switch-to-window window)
	(hydra-window-resizer/body))
  (defun aw-show-dispatch-help ()
	"Display action shortucts in echo area."
	(interactive)
	(message "%s" (mapconcat
				   (lambda (action)
					 (cl-destructuring-bind (key fn &optional description) action
					   (format "%s: %s"
							   (propertize
								(char-to-string key)
								'face 'aw-key-face)
							   (or description fn))))
				   aw-dispatch-alist
				   " "))
	;; Prevent this from replacing any help display
	;; in the minibuffer.
	(let (aw-minibuffer-flag)
	  (mapc #'delete-overlay aw-overlays-back)
	  (call-interactively 'ace-window))))


(defvar dotfiles-bibliography "~/Reading/library.bib")


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
		 (org-mode . (lambda () (setq-local line-spacing 0.1)))
         ((org-mode md-mode markdown-mode markdown-ts-mode)  . turn-on-visual-line-mode)
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
  (add-to-list 'citar-file-open-functions '("pdf" . citar-file-open-external)))
  ;; ;; Run `citar-org-update-pre-suffix' after inserting a citation to immediately
  ;; ;; set its prefix and suffix
  ;; (advice-add 'org-cite-insert :after #'(lambda (args)
  ;; 										  (save-excursion
  ;; 											(left-char) ; First move point inside citation
  ;; 											(citar-org-update-prefix-suffix)))))


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
	   "%<%Y%m%d%H%M%S>-${citar-citekey}.org"
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
							   (format "pixi run -m %s pdfannots %s -f json | jq -r \".[] | \\\"> \\(.text) [@cite-key, p. \\(if .page_label == null then .page else .page_label end)]\n\\\"\" | pandoc -f markdown -t org --wrap=none | sed -e \"s/@cite-key/@%s/\"" (shell-quote-argument (expand-file-name "pixi.toml" user-emacs-directory)) (shell-quote-argument (expand-file-name pdf-file)) (shell-quote-argument cite-key)))
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
  :diminish org-autolist-mode
  :hook (org-mode . org-autolist-mode))


;;; EVIL INDENT PLUS
;; The evil-indent-textobject package provides text objects that
;; select lines with the exact same indentation as the current
;; line. Lines that are either indented more, or which are empty, will
;; interrupt the selection, contrary to expected behavior. This
;; package correctly handles these cases.
(use-package evil-indent-plus
  :straight t
  :after evil
  :config
  (evil-indent-plus-default-bindings))


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


;;; MOVE DUP
;; This package offers convenient editing commands much like Eclipse's
;; ability to move and duplicate lines or rectangular selections.
(use-package move-dup
  :straight t
  :general
  ("M-S-k" 'move-dup-move-lines-up
   "M-S-j" 'move-dup-move-lines-down
   "M-k" 'move-dup-move-lines-up
   "M-j" 'move-dup-move-lines-down
   "C-M-k" 'move-dup-duplicate-up
   "C-M-j" 'move-dup-duplicate-down))


;;; RG.EL
;; Use ripgrep in Emacs.
;;
;; Ripgrep is a replacement for both grep like (search one file) and
;; ag like (search many files) tools. It's fast and versatile and
;; written in Rust. For some introduction and benchmarks, see ripgrep
;; is faster than {grep, ag, git grep, ucg, pt, sift}.
(use-package rg
  :straight t
  :config
  (rg-enable-default-bindings))


;;; SESSION
;; When you start Emacs, package Session restores various variables
;; (e.g., input histories) from your last session. It also provides a
;; menu containing recently changed/visited files and restores the
;; places (e.g., point) of such a file when you revisit it.
(use-package session
  :straight t
  :hook
  (after-init . session-initialize)
  :init
  (setq session-save-file (locate-user-emacs-file ".session"))
  (setq session-name-disable-regexp "\\(?:\\`'/tmp\\|\\.git/[A-Z_]+\\'\\)")
  (setq session-save-file-coding-system 'utf-8))


;;; JINX
;; Jinx is a fast just-in-time spell-checker for Emacs. Jinx
;; highlights misspelled words in the text of the visible portion of
;; the buffer. For efficiency, Jinx highlights misspellings lazily,
;; recognizes window boundaries and text folding, if any. For example,
;; when unfolding or scrolling, only the newly visible part of the
;; text is checked if it has not been checked before. Each misspelling
;; can be corrected from a list of dictionary words presented as a
;; completion menu.
(use-package jinx
  :straight t
  :diminish jinx-mode
  :hook (after-init . global-jinx-mode)
  :custom
  (jinx-languages "en_US")
  :general
  ("M-$" 'jinx-correct
   "C-M-$" 'jinx-languages)
  (general-nmap
    "z=" 'jinx-correct
    "]s" 'jinx-next
    "[s" 'jinx-previous)
  :config
  (with-eval-after-load 'vertico-multiform
    (add-to-list 'vertico-multiform-categories
                 '(jinx grid (vertico-grid-annotate . 20)))))



;;; HIGHLIGHT INDENT GUIDES
;; This minor mode highlights indentation levels via font-lock. Indent
;; widths are dynamically discovered, which means this correctly
;; highlights in any mode, regardless of indent width, even in
;; languages with non-uniform indentation such as Haskell. By default,
;; this mode also inspects your theme dynamically, and automatically
;; chooses appropriate colors for highlighting. This mode works
;; properly around hard tabs and mixed indentation, and it behaves
;; well in large buffers.
(use-package highlight-indent-guides
  :straight t
  :diminish highlight-indent-guides-mode
  :custom
  (highlight-indent-guides-method 'character)
  :hook (prog-mode . highlight-indent-guides-mode))


;;; GPTEL
;; gptel is a simple Large Language Model chat client for Emacs, with
;; support for multiple models and backends. It works in the spirit of
;; Emacs, available at any time and uniformly in any buffer.
(use-package gptel
  :straight t
  :general
  (:states '(normal)
		   "<leader> e g" 'gptel)
  :defer t
  :commands (gptel-send gptel)
  :custom
  (gptel-default-mode 'org-mode)
  :config
  (gptel-make-openai "cubtram"
	:stream t
	:protocol "http"
	:host "cubtram:8080"
	:models '(cubtram))
  (gptel-make-openai "cubtram-nothink"
	:stream t
	:protocol "http"
	:host "cubtram:8080"
	:models '(cubtram)
	:request-params '(:chat_template_kwargs (:enable_thinking :json-false)))
  (gptel-make-openai "OpenRouter"
	:host "openrouter.ai"
	:endpoint "/api/v1/chat/completions"
	:stream t
	:key openrouter-api-key
	:models (gptel-openrouter-get-annotated-models
			 '(z-ai/glm-5.3-flash
			   deepseek/deepseek-v4-flash-0731
			   deepseek/deepseek-v4-pro-0813
			   google/gemini-3.7-flash)))

  (setq gptel-model 'cubtram
		gptel-backend (gptel-get-backend "cubtram-nothink"))

  (gptel-make-preset 'thinking
	:description "Let's burn some tokens!"
	:backend "cubtram"
	:model 'cubtram)
  (gptel-make-preset 'no-thinking
	:description "No thoughts, just vibes"
	:backend "cubtram-nothink"
	:model 'cubtram)
  (gptel-make-preset 'emacs-function
	:description "Get an emacs function"
	:parents '(no-thinking)
	:system "You are an expert in the use of emacs. You will be given a description
of a function and are to reply with your best guess of the name of the
function that satisfies the user's request. Reply only with the name of
the function. Do not offer no explanation and follow-up.")
  (gptel-make-preset 'file-ro
	:description "Provide readonly access to the filestem"
	:tools '(view_file ls glob grep))
  (gptel-make-preset 'buffer
	:description "JIT only: include a buffer following the @buffer cookie

ex: What is in this buffer? @buffer *scratch*"
    :post (lambda ()
            (let ((buf-name (string-trim
                             (buffer-substring-no-properties
                              (point) (line-end-position)))))
              (if (not (buffer-live-p (get-buffer buf-name)))
                  (message "Buffer \"%s\" not live, ignoring @buffer preset"
                           buf-name)
                (delete-region (point) (line-end-position))
                (insert (format "\nIn buffer `%s`:\n\n```\n" buf-name))
                (insert-buffer-substring-no-properties buf-name)
                (insert "\n```\n")))))

  (gptel-make-preset 'file
    :description "JIT only: include a file following the @file cookie"
    :post
    (lambda ()
      (let ((file-name (string-trim
                        (buffer-substring-no-properties
                         (point) (line-end-position)))))
        (cond
         ((file-directory-p file-name)
          (insert (format "\nFiles in directory `%s`:\n\n```\n" file-name))
          (dolist (f (directory-files-recursively file-name "." t t))
            (when (file-readable-p f) (insert f "\n")))
          (insert "```\n"))
         ((file-readable-p file-name)
          (insert "\n")
          (gptel--insert-file-string file-name))
         (t (message "File \"%s\" not readable, ignoring @file preset"
                     file-name)))
        (delete-region (point) (line-end-position)))))
    (gptel-make-preset 'json
    :description "JIT only: use JSON schema following @json cookie"
    :schema '(:eval (buffer-substring-no-properties
                     (point) (point-max)))
    :post (lambda () (delete-region (point) (point-max)))
    :include-reasoning nil)

  (gptel-make-preset 'include
    :description "CONTEXT: Include the filename or buffer following @include"
    :context `(:function ,#'gptel-include-preset--parse-line))

  (defun my/gptel-windows-on-frame ()
    "Return all windows on frame that aren't gptel chat buffers."
    (delq (and-let* ((current-buf (window-buffer (selected-window)))
                     ((buffer-local-value 'gptel-mode current-buf)))
            (selected-window))
          (window-list)))

  (gptel-make-preset 'visible-buffers
    :description "CONTEXT: Include the full text of all buffers visible in the frame."
    :context
    '(:eval (mapcar #'window-buffer (my/gptel-windows-on-frame))))

  (gptel-make-preset 'visible-text
    :description "CONTEXT: Include visible text from all windows in the frame."
    :context
    '(:eval (mapcar (lambda (win) ;; Create (<buffer> :bounds ((start . end)))
                      `(,(window-buffer win)
                        :bounds ((,(window-start win) . ,(window-end win)))))
                    (my/gptel-windows-on-frame)))))


;;; GPTEL PRESET COLLECTION
;; A preset is a named collection of gptel settings and behaviors
;; applied to an LLM query as a unit: they can set or change the
;; backend and model, system message, context sources, response
;; handling, and so on. See the gptel manual
;; (https://gptel.org/manual.html) for details. There is also an
;; extensive YouTube demo (28 minutes).
(use-package gptel-preset-collection
  :straight (:host github :repo "karthink/gptel-preset-collection")
  :after gptel)


;;; GPTEL AGENT
;; This is a collection of tools and prompts to use gptel
;; “agentically” with any LLM, to autonomously perform tasks.
;;
;; It has access to
;;
;; + the web (via basic web search and URL fetching, including YouTube
;;   video descriptions and transcripts),
;; + local files (read/write/edit),
;; + the state of Emacs (documentation and Elisp evaluation),
;; + and Bash, if you are in a POSIX-y environment.
;;
;; By default, all actions except for web search, fetching URLs and
;; reading local files require confirmation. You can change this, add
;; more tools and MCP servers etc as in regular gptel usage.
(use-package gptel-agent
  :after gptel
  :straight (gptel-agent :type git :host github :repo "karthink/gptel-agent"
            :files (:defaults "agents"))
  :defer t
  :init
  (gptel-make-preset 'gptel-agent
    :pre #'gptel-agent-update
    :post (lambda () (gptel-preset 'gptel-agent #'set-local)))
  (gptel-make-preset 'gptel-plan
    :pre #'gptel-agent-update
    :post (lambda () (gptel-preset 'gptel-plan #'set-local)))
  (gptel-make-preset 'skill
    :description "TOOLS: Add skill-reading tool"
    :pre (lambda () (require 'gptel-agent-tools))
    :tools '(:append ("Skill"))
    :system '(:function
              (lambda (sys)
                (concat sys "\n\n" (gptel-agent--skills-system-message
                                    (gptel-agent--update-skills))))))
  (gptel-make-preset 'web
    :description "TOOLS: Add basic web search tools"
    :pre (lambda () (require 'gptel-agent-tools))
    :tools '(:append ("WebSearch" "WebFetch" "YouTube"))
    ;; :system '(:append "\n\nUse the provided tools to search the web for up-to-date information.")
    )
  (gptel-make-preset 'files
    :pre (lambda () (require 'gptel-agent-tools))
    :description "TOOLS: Add file read/write"
    :tools '(:append ("Read" "Glob" "Write" "Edit" "Insert")))
  (gptel-make-preset 'files-ro
    :pre (lambda () (require 'gptel-agent-tools))
    :description "TOOLS: Add file read-only"
    :tools '(:append ("Read" "Glob")))
  (gptel-make-preset 'shell
    :pre (lambda () (require 'gptel-agent-tools))
    :description "TOOLS: Add Bash eval"
    :tools  '(:append ("Bash"))
    ;; :system '(:append "Use the Bash tool to introspect and change the state of the system.")
    )
  (gptel-make-preset 'eval
    :pre (lambda () (require 'gptel-agent-tools))
    :tools  '(:append ("Eval"))
    :system '(:append "Use the Eval tool to change the state of the running Emacs instance.")
    :description "TOOLS: Add eval")
  (gptel-make-preset 'introspect
    :pre (lambda () (require 'gptel-agent-tools-introspection))
    :description "Introspect Emacs with Ragmacs"
    :system
    "You are pair programming with the user in Emacs and on Emacs.

Your job is to dive into Elisp code and understand the APIs and
structure of elisp libraries and Emacs.  Use the provided tools to do
so, but do not make duplicate tool calls for information already
available in the chat.

<tone>
1. Be terse and to the point.  Speak directly.
2. Explain your reasoning.
3. Do NOT hedge or qualify.
4. If you don't know, say you don't know.
5. Do not offer unprompted advice or clarifications.
6. Never apologize.
7. Do NOT summarize your answers.
</tone>

<code_generation>
When generating code:
1. Create a plan first: list briefly the design steps or ideas involved.
2. Use the provided tools to check that functions or variables you use
in your code exist.
3. Also check their calling convention and function-arity before you use
them.
</code_generation>

<formatting>
1. When referring to code symbols (variables, functions, tags etc)
enclose them in markdown quotes.
  Examples: `read_file`, `getResponse(url, callback)`
  Example: `<details>...</details>`
2. If you use LaTeX notation, enclose math in \( and \), or \[ and \] delimiters.
</formatting>"
    :cache '(tool)
    :tools '("introspection"))
  :config
  (gptel-agent-update)
  (setq gptel-agent-preset nil)

  (defvar my/gptel-agent-edit-confirm-cache nil)

  (defun my/gptel-agent-edit-or-insert-confirm (path &rest _args)
    "Don't ask for confirmation if path is git-controlled.
Edit freely."
    (not
     (with-memoization (alist-get path my/gptel-agent-edit-confirm-cache
                                  nil nil #'equal)
       (and (file-readable-p path)
            ;; TODO Also check if path is part of current project
            (locate-dominating-file path ".git")
            (eql (call-process "git" nil nil nil
                               "ls-files" "--error-unmatch" path)
                 0)))))

  (setf (gptel-tool-confirm (gptel-get-tool "Edit"))
        #'my/gptel-agent-edit-or-insert-confirm
        (gptel-tool-confirm (gptel-get-tool "Insert"))
        #'my/gptel-agent-edit-or-insert-confirm))


(use-package gptel-inline
  :ensure nil
  :commands (gptel-inline)
  :general
  ("C-c g" 'gptel-inline)
  (:keymaps 'gptel-inline-map
			"C-c m" 'gptel-menu)
  (:keymaps 'gptel-inline--response-overlay-mode-map
			"j" #'gptel-inline--response-overlay-down
			"k" #'gptel-inline--response-overlay-up
			[remap evil-scroll-down] #'gptel-inline--response-overlay-pagedown
			[remap evil-scroll-up] #'gptel-inline--response-overlay-pageup))


;;; GPTEL OPENROUTER
;; gptel-openrouter.el is an Emacs package designed to retrieve and
;; process model information from OpenRouter's API. It allows Emacs
;; users to fetch detailed annotations about available models,
;; including descriptions, context lengths, prices, and more. This
;; information is formatted for compatibility with gptel, an Emacs
;; package facilitating communication with AI models.
(use-package gptel-openrouter
  :after gptel
  :straight (gptel-openrouter :type git :host github :repo "darcamo/gptel-openrouter"))


;;; LLM Tool Collection
;; A curated collection of tools to empower Emacs-based LLM agents.
(use-package llm-tool-collection
  :after gptel
  :straight (llm-tool-collection :type git :host github :repo "skissue/llm-tool-collection")
  :config
  (mapcar (apply-partially #'apply #'gptel-make-tool)
                  (llm-tool-collection-get-all)))


;;; ==================== LANGUAGE MODES ====================

;; Here is where I have to install all the different modes to support Emacs syntax highlighting

;;; EMACS FISH
;; Emacs major mode for fish shell scripts.
(use-package fish-mode
  :straight t)


;;; SVELTE MODE
;; Emacs major mode for .svelte files. It's based on mhtml-mode. It
;; requires (>= emacs-major-version 26).
(use-package svelte-ts-mode
  :straight (svelte-ts-mode :type git :host github :repo "leafOfTree/svelte-ts-mode")
  :config
    (dolist (item svelte-ts-mode-language-source-alist)
    (add-to-list 'treesit-language-source-alist item)))


;;; UTILITARY FUNCTION TO INSTALL EMACS-KICK
(defun ek/first-install ()
  "Install tree-sitter grammars and compile packages on first run..."
  (interactive)                                      ;; Allow this function to be called interactively.
  (switch-to-buffer "*Messages*")                    ;; Switch to the *Messages* buffer to display installation messages.
  (message ">>> All required packages installed.")
  (message ">>> Configuring Emacs-Kick...")
  (message ">>> Installing Python tooling...")
  (unless (file-exists-p (expand-file-name ".pixi" user-emacs-directory))
	(shell-command (concat "pixi install -m " (expand-file-name (concat user-emacs-directory "pixi.toml")))))
  (message ">>> Configuring Tree Sitter parsers...")
  (require 'treesit-auto)
  (treesit-auto-install-all)                         ;; Install all available Tree Sitter grammars.
  (message ">>> Configuring Nerd Fonts...")
  (require 'nerd-icons)
  (nerd-icons-install-fonts)                         ;; Install all available nerd-fonts
  (message ">>> Emacs-Kick installed! Press any key to close the installer and open Emacs normally. First boot will compile some extra stuff :)")
  (read-key)                                         ;; Wait for the user to press any key.
  (kill-emacs))                                      ;; Close Emacs after installation is complete.

(provide 'init)
;;; init.el ends here
