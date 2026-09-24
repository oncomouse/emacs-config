;;; init.el --- oncomouse's Emacs config for (neo)vi(m)mers -*- lexical-binding: t; -*-
;; Author: oncomouse <oncomouse@gmail.com>
;; URL: https://github.com/oncomouse/emacs-config
;; Derived from Emacs-Kick by Rahul Martim Juliato.

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
;; (setq gc-cons-threshold #x40000000)

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


;; Emacs comes with a built-in package manager (`package.el'), which we use here
;; to fetch and manage packages. The `use-package' macro (also built into Emacs,
;; so it needs no bootstrapping) drives it:
;;
;;   ;; :ensure installs a package from a package archive (MELPA / ELPA).
;;   ;; :vc     installs a package straight from its source repository via
;;   ;;         `package-vc' (built into Emacs 30+), for packages that are not
;;   ;;         published to any archive we use.
;;
;; In Emacs, a package is a collection of Elisp code that extends the editor's
;; functionality, much like plugins do in Neovim. We register our archives and
;; initialise `package.el' once, up front, before any `use-package' form runs.

;; Register MELPA before initialising. GNU ELPA is already in `package-archives'
;; by default; MELPA offers a much broader range of packages and is the de-facto
;; standard for Emacs users. Add more archives here as needed.
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(setq use-package-vc-prefer-newest t)

;; `loaddefs-generate' copies `;;;###autoload'-tagged non-defun forms verbatim
;; into a package's generated autoloads file.  `typst-ts-mode' tags a
;; `define-compilation-mode' form, so evaluating that copy needs `compile.el'
;; already loaded -- otherwise `package-activate' logs
;;   Error loading autoloads: (void-function define-compilation-mode)
;; and abandons the rest of the file, silently dropping every autoload that comes
;; after it, including `typst-ts-mode' itself and its .typ entry in
;; `auto-mode-alist'.  An autoload stub for the macro satisfies the copied form
;; without paying for `compile.el' at startup.  This must stay above
;; `(package-initialize)'.
(autoload 'define-compilation-mode "compile" nil t)

;; Initialise package.el before any `use-package' form runs. On a fresh install
;; (no cached archive contents yet) refresh so that `:ensure' can find packages.
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(use-package general
  :ensure t
  :config
  (general-evil-setup)
  (general-create-definer general-nivmap :states '(normal insert visual)))

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
;;   :vc     t     ;; Install from source via package-vc (Emacs 30+).
;;   :config       ;; Configuration settings for the package.
;;   ;; Additional settings can go here.
;; )
;;
;; This approach simplifies package management, enabling us to easily control
;; both built-in (first-party) and external (third-party) packages. While Emacs
;; is a vast and powerful editor, using `use-package`—backed by `package.el` for
;; archived packages and `package-vc` for packages installed from source—helps
;; streamline our configuration for better organization and customization. As we proceed, you'll see smaller
;; `use-package` declarations for specific packages, which will help us enable
;; the desired features and improve our workflow.


                                            ;;; EMACS
                                            ;;  This is biggest one. Keep going, plugins (oops, I mean packages) will be shorter :)
(use-package emacs
  :ensure nil
  :custom                                   ;; Set custom variables to configure Emacs behavior.
  (confirm-kill-emacs 'yes-or-no-p)         ;; Ask before quitting Emacs
  (column-number-mode t)                    ;; Display the column number in the mode line.
  (auto-save-default nil)                   ;; Disable automatic saving of buffers.
  (create-lockfiles nil)                    ;; Prevent the creation of lock files when editing.
  (delete-by-moving-to-trash t)             ;; Move deleted files to the trash instead of permanently deleting them.
  (delete-selection-mode 1)                 ;; Enable replacing selected text with typed text.
  (display-line-numbers-type 'relative)     ;; Use relative line numbering in programming modes.
  (global-auto-revert-non-file-buffers t)   ;; Automatically refresh non-file buffers.
  (history-length 100)                      ;; Set the length of the command history.
  (inhibit-startup-message t)               ;; Disable the startup message when Emacs launches.
  (initial-scratch-message "")              ;; Clear the initial message in the *scratch* buffer.
  (ispell-dictionary "en_US")               ;; Set the default dictionary for spell checking.
  (make-backup-files nil)                   ;; Disable creation of backup files.
  (pixel-scroll-precision-mode t)           ;; Enable precise pixel scrolling.
  (pixel-scroll-precision-use-momentum nil) ;; Disable momentum scrolling for pixel precision.
  (ring-bell-function 'ignore)              ;; Disable the audible bell.
  (split-width-threshold 300)               ;; Prevent automatic window splitting if the window width exceeds 300 pixels.
  (switch-to-buffer-obey-display-actions t) ;; Make buffer switching respect display actions.
  (tab-always-indent 'complete)             ;; Make the TAB key complete text instead of just indenting.
  (tab-width 4)                             ;; Set the tab width to 4 spaces.
  (treesit-font-lock-level 4)               ;; Use advanced font locking for Treesit mode.
  (truncate-lines t)                        ;; Enable line truncation to avoid wrapping long lines.
  (use-dialog-box nil)                      ;; Disable dialog boxes in favor of minibuffer prompts.
  (use-short-answers t)                     ;; Use short answers in prompts for quicker responses (y instead of yes)
  (sentence-end-double-space nil)           ;; It's no longer the 1980s, Emacs
  (save-interprogram-paste-before-kill t)
  (kill-do-not-save-duplicates t)
  (ffap-machine-p-known 'reject)            ;; Don't ping url-looking things when running find-file

  ;; (warning-minimum-level :emergency)              ;; Set the minimum level of warnings to display.

  :hook                                           ;; Add hooks to enable specific features in certain modes.
  (before-save . delete-trailing-whitespace)      ;; Delete trailing spaces on save
  (after-init . undelete-frame-mode)

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
  (setq-default bidi-paragraph-direction 'left-to-right)
  (setq bidi-inhibit-bpa t)

  (menu-bar-mode -1)           ;; Disable the menu bar for a more streamlined look.

  (when (display-graphic-p)
	(mouse-shift-adjust-mode)
	(context-menu-mode))


  (when scroll-bar-mode
    (scroll-bar-mode -1))      ;; Disable the scroll bar if it is active.

  (global-display-line-numbers-mode +1) ;; Display line numbers everywhere
  (global-hl-line-mode 1)               ;; Enable highlight of the current line

  ;; Set this to `nil' if Emacs is having trouble picking up changes.
  (setopt auto-revert-avoid-polling t)
  (setopt auto-revert-interval 5)
  (setopt auto-revert-check-vc-info t)
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
  (with-eval-after-load 'modus-catppuccin
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
						:slant 'italic)))


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
  :general
  (:states '(insert normal motion)
		   "C-s" 'isearch-forward             ;; Bind C-s to forward isearch.
		   "C-S-s" 'isearch-backward))          ;; Bind C-r to backward isearch.


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
  :diminish eldoc-mode
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
  ((text-mode prog-mode) . electric-pair-mode)
  ((org-mode markdown-ts-mode) . (lambda ()
														 (add-function :before-until (local 'electric-pair-inhibit-predicate)
																	   (lambda (c) (eq c ?<)))))
  ((markdown-ts-mode) . (lambda ()
			   (add-hook 'post-self-insert-hook
						 #'markdown-electric-pair-string-delimiter 'append t)))
  ((markdown-ts-mode) . (lambda ()
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
  :hook (((prog-mode org-mode markdown-ts-mode) . completion-preview-mode)
		 (completion-preview-mode . completion-preview-echo-mode)
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
  :ensure nil
  :defer t
  :commands (ibuffer)
  :general
  ("C-x C-b" 'ibuffer)
  :init
  (sanityinc/fullframe-mode 'ibuffer-mode))


;;; PROJECT
;;;;  A project is a collection of files used for producing one or more
;; programs. Files that belong to a project are typically stored in a
;; hierarchy of directories; the top-level directory of the hierarchy
;; is known as the project root.
(use-package project
  :ensure nil
  :custom
  (when (>= emacs-major-version 30)
    (project-mode-line t))
  (project-vc-extra-root-markers '(".projectile" ".git"))
  (when (>= emacs-major-version 31)
	(project-list-exclude '("/elpa/" "/\\.eldev/" "/node_modules/"))))

;;; VISUAL LINE MODE
;; Another alternative to ordinary line continuation is to use word
;; wrap. Here, each long logical line is divided into two or more
;; screen lines, or “visual lines”, like in ordinary line
;; continuation. However, Emacs attempts to wrap the line at word
;; boundaries near the right window edge. (If the line’s direction is
;; right-to-left, it is wrapped at the left window edge instead.) This
;; makes the text easier to read, as wrapping does not occur in the
;; middle of words.
(use-package visual-line-mode
  :ensure nil
  :diminish 'visual-line-mode
  :hook
  (text-mode  . turn-on-visual-line-mode))


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
  :ensure t)


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
  :ensure t
  :bind (("M-`"   . popper-toggle)
		 ("C-`"   . popper-cycle)
		 ("C-M-`" . popper-toggle-type))
  :custom
  (popper-group-function #'popper-group-by-project)
  (popper-reference-buffers
   '("\\*\\(lsp-help\\|Backtrace\\|Warnings\\|Compile-Log\\|[Hh]elp\\|Messages\\|Bookmark List\\|Occur\\|eldoc.*\\)\\*"
	 "\\*\\(Flymake diagnostics\\|xref\\|ivy\\|Swiper\\|Completions\\|gptel-reasoning\\|vc-git\\)"
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
  :ensure t
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
			"M-o" 'other-window)
  (:keymaps 'project-prefix-map
			"t" 'ghostel-project
			"T" 'ghostel-project-buffer-list)
  :config
  (add-to-list 'project-switch-commands '(ghostel-project "Ghostel") t)
  (add-to-list 'project-switch-commands '(ghostel-project-list-buffers "Ghostel buffers") t))

(defun ghostel--close-window-on-kill ()
  "Remove window if it contains a Ghostel buffer, unless last window."
  (when (derived-mode-p 'ghostel-mode)
    ;; Only delete the window if there are other windows in this frame
    (when (> (length (window-list)) 1)
      (delete-window))))


;;; HYDRA
;; Hydras and transient menus both can provide a temporary menu of commands at
;; the bottom of the screen. Hydras can also provide a pop-up menu as alternate
;; mode of operation. Transient menus are currently more popular. Both are
;; useful for getting work done with an unfamiliar package by providing for the
;; execution of commands by clicking on hyperlinks.
(use-package hydra
  :ensure t)


;;; TREESITTER-AUTO
;; Treesit-auto simplifies the use of Tree-sitter grammars in Emacs,
;; providing automatic installation and mode association for various
;; programming languages. This enhances syntax highlighting and
;; code parsing capabilities, making it easier to work with modern
;; programming languages.
(use-package treesit-auto
  :ensure t
  :after emacs
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode t))


(require 'init-base)
(require 'init-lsp)

;; Keep source-installed (:vc) packages current: `M-x ek-vc-status' shows what is
;; actually checked out, `M-x ek-vc-upgrade-stale' fast-forwards and rebuilds,
;; and a gated idle timer does the same on `ek-vc-upgrade-interval-days'.
(require 'init-vc-maintenance)

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
  :defer t
  :hook
  (after-init . xclip-mode))     ;; Enable xclip mode after initialization.


(require 'init-evil)
(require 'init-pretty-ui)
(require 'init-org)


;;; MOVE DUP
;; This package offers convenient editing commands much like Eclipse's
;; ability to move and duplicate lines or rectangular selections.
(use-package move-dup
  :ensure t
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
  :ensure t
  :config
  (rg-enable-default-bindings))


;;; SESSION
;; When you start Emacs, package Session restores various variables
;; (e.g., input histories) from your last session. It also provides a
;; menu containing recently changed/visited files and restores the
;; places (e.g., point) of such a file when you revisit it.
(use-package session
  :ensure t
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
  :ensure t
  :diminish jinx-mode
  :hook (after-init . global-jinx-mode)
  :custom
  (jinx-languages "en_US")
  (jinx-camel-modes '(prog-mode))
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


(require 'init-gptel)


;;; YASNIPPET
;; YASnippet is a template system for Emacs. It allows you to type an
;; abbreviation and automatically expand it into function templates.
;; Bundled language templates include: C, C++, C#, Perl, Python, Ruby,
;; SQL, LaTeX, HTML, CSS and more. The snippet syntax is inspired from
;; TextMate's syntax, you can even import most TextMate templates to
;; YASnippet. Watch a demo on YouTube.
(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1))


;;; YASNIPPET SNIPPETS
;; This repository contains the official collection of snippets for yasnippet.
(use-package yasnippet-snippets
  :ensure t)


;;; YASNIPPET CAPF
;; A simple capf (Completion-At-Point Function) for completing
;; yasnippet snippets.
(use-package yasnippet-capf
  :ensure t)


;;; TEMPEL
;; Tempel is a tiny template package for Emacs, which uses the syntax
;; of the Emacs Tempo library. Tempo is an ancient temple of the
;; church of Emacs. It is over 32 years old, but still in good shape
;; since it successfully resisted change over the decades. However it
;; looks a bit dusty here and there. Therefore we present Tempel, its
;; worthy successor with inline expansion and integration with recent
;; Emacs facilities. Tempel takes advantage of the standard
;; completion-at-point-functions mechanism which is used by Emacs for
;; in-buffer completion.
(use-package tempel
  :ensure t
  :general
  ("M-*" 'tempel-insert
  "M-+" 'tempel-complete)
  (:keymaps 'tempel-map
			"C-c RET" 'tempel-done
			"C-j" 'tempel-next
			"C-k" 'tempel-previous
			"C-<down>" 'tempel-next
			"C-<up>" 'tempel-previous
			"M-<down>" 'tempel-next
			"M-<up>" 'tempel-previous))


;;; MPDEL
;; MPDel is an Emacs client for Music Player Daemon (MPD), a flexible,
;; powerful, server-side application for playing music. MPDel provides
;; an Emacs user interface to control playback (play, pause, next,
;; volume up…) and to display and control the current playlist as well
;; as your stored playlists (e.g., “my favorites”, “wake me up”, “make
;; me dance”, …).
(use-package mpdel
  :ensure t
  :diminish mpdel-mode
  :general
  (:states 'normal
		   "<leader> z" 'mpdel-core-map)
  :config
  (mpdel-mode))


;;; MPDEL EMBARK
;; This Emacs package binds together mpdel (a Music Player Daemon
;; client) with the embark library.
;;
;; When mpdel-embark is installed, you can use M-x mpdel-embark-list
;; (bound to i in MPDel keymaps) to start a completion interface for
;; all your music library. This interface shows a list of all artists
;; in the MPD database. You can add all songs from any artist by
;; selecting the artist and using embark-act. You can also browse the
;; artist’s albums by typing RET. Add a complete album to the current
;; playlist by using embark-act or go to the album’s songs by typing
;; RET. Using embark-act on a song will add it to the current playlist
;; while RET shows information about the song.
(use-package mpdel-embark
  :ensure t
  :after (embark mpdel)
  :config
  (progn
    (mpdel-embark-setup)))


;;; PAREDIT
;; Parenthetical Editing in Emacs.
(use-package paredit
  :ensure t
  :commands paredit-mode
  :hook
  (emacs-lisp-mode . paredit-mode))


;;; ==================== LANGUAGE MODES ====================

;; Here is where I have to install all the different modes to support Emacs syntax highlighting

;;; MARKDOWN-MODE
;; Markdown Mode provides support for editing Markdown files in Emacs,
;; enabling features like syntax highlighting, previews, and more.
;; It’s particularly useful for README files, as it can be set
;; to use GitHub Flavored Markdown for enhanced compatibility.
(use-package markdown-ts-mode
  :ensure nil
  :mode ("\\.md\\'" "\\.mdx\\'" "\\.markdown\\'")
  :config
  (require 'markdown-ts-mode-x))


;;; TYPST-TS-MODE
;; Tree Sitter support for Typst. Minimum Emacs version requirement: 29. Its
;; tree-sitter grammar is installed once with `M-x typst-ts-mc-install-grammar'
;; treesit-auto doesn't cover Typst.
(use-package typst-ts-mode
  :ensure nil
  :vc (typst-ts-mode :url "https://codeberg.org/meow_king/typst-ts-mode.git" :branch "main")
  :after (transient)
  :custom
  (typst-ts-watch-options "--open")
  (typst-ts-mode-grammar-location (expand-file-name "tree-sitter/libtree-sitter-typst.so" user-emacs-directory))
  (typst-ts-mode-enable-raw-blocks-highlight t))


;;; EMACS FISH
;; Emacs major mode for fish shell scripts.
(use-package fish-mode
  :ensure t)


;;; SVELTE MODE
;; Emacs major mode for .svelte files. It's based on mhtml-mode. It
;; requires (>= emacs-major-version 26).
(use-package svelte-ts-mode
  :ensure nil
  :vc (svelte-ts-mode :url "https://github.com/leafOfTree/svelte-ts-mode")
  :config
    (dolist (item svelte-ts-mode-language-source-alist)
    (add-to-list 'treesit-language-source-alist item)))


;;; UTILITARY FUNCTION TO INSTALL THIS CONFIG
(defun ek/first-install ()
  "Install tree-sitter grammars and compile packages on first run..."
  (interactive)                                      ;; Allow this function to be called interactively.
  (switch-to-buffer "*Messages*")                    ;; Switch to the *Messages* buffer to display installation messages.
  (message ">>> All required packages installed.")
  (message ">>> Configuring Emacs...")
  (message ">>> Installing Python tooling...")
  (unless (file-exists-p (expand-file-name ".pixi" user-emacs-directory))
	(shell-command (concat "pixi install -m " (expand-file-name (concat user-emacs-directory "pixi.toml")))))
  (message ">>> Configuring Tree Sitter parsers...")
  (require 'treesit-auto)
  (treesit-auto-install-all)                         ;; Install all available Tree Sitter grammars.
  (message ">>> Configuring Nerd Fonts...")
  (require 'nerd-icons)
  (nerd-icons-install-fonts)                         ;; Install all available nerd-fonts
  (message ">>> Configuring Ghostel...")
  (require 'ghostel)
  (ghostel-download-module)
  (message ">>> Configuring GPTel OpenRouter...")
  (require 'gptel-openrouter)
  (gptel-openrouter-download-model-data)
  (message ">>> Emacs config installed! Press any key to close the installer and open Emacs normally. First boot will compile some extra stuff :)")
  (read-key)                                         ;; Wait for the user to press any key.
  (kill-emacs))                                      ;; Close Emacs after installation is complete.


;; Handle unicode quotes in document by converting them to ASCII
(defun ap/convert-quotes-to-straight (&optional string)
  "Convert Unicode curly quotes to ASCII straight quotes in STRING."
  (interactive)
  (if (stringp string)
	  (replace-regexp-in-string "[\u2018\u2019]" "'"
								(replace-regexp-in-string "[\u201C\u201D]" "\"" string))
	(save-excursion
	  (if (use-region-p)
		  (replace-regexp "[\u2018\u2019]" "'" nil (region-beginning) (region-end))
		(replace-regexp "[\u2018\u2019]" "'"))
	  (if (use-region-p)
		  (replace-regexp "[\u201C\u201D]" "\"" nil (region-beginning) (region-end))
		(replace-regexp "[\u201C\u201D]" "\"")))))

(defun ap/advice-yank-before (orig-fn &optional ARG)
  "Before yank, sanitize the current kill-ring item."
  (let ((killed (car kill-ring)))
    (when (stringp killed)
      (let ((sanitized (ap/convert-quotes-to-straight killed)))
        (unless (string-equal killed sanitized)
          (setcar kill-ring sanitized))))))

(advice-add 'yank :before #'ap/advice-yank-before)
(advice-add 'yank-pop :before #'ap/advice-yank-before)

(setq gc-cons-threshold (or bedrock--initial-gc-threshold 800000))

(provide 'init)
;;; init.el ends here
