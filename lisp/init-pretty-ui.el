;;; init-pretty-ui.el --- Themes, colors, fancy lines -*- lexical-binding: t; -*-
;;; Commentary:

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


;;; RAINBOW DELIMITERS
;; The `rainbow-delimiters' package provides colorful parentheses, brackets, and braces
;; to enhance readability in programming modes. Each level of nested delimiter is assigned
;; a different color, making it easier to match pairs visually.
(use-package rainbow-delimiters
  :defer t
  :ensure t
  :hook
  (prog-mode . rainbow-delimiters-mode))


;;; NERD ICONS
;; The `nerd-icons' package provides a set of icons for use in Emacs. These icons can
;; enhance the visual appearance of various modes and packages, making it easier to
;; distinguish between different file types and functionalities.
(use-package nerd-icons
  :if ek-use-nerd-fonts                   ;; Load the package only if the user has configured to use nerd fonts.
  :ensure t                               ;; Ensure the package is installed.
  :defer t)                               ;; Load the package only when needed to improve startup time.


;;; NERD ICONS DIRED
;; The `nerd-icons-dired' package integrates nerd icons into the Dired mode,
;; providing visual icons for files and directories. This enhances the Dired
;; interface by making it easier to identify file types at a glance.
(use-package nerd-icons-dired
  :if ek-use-nerd-fonts                   ;; Load the package only if the user has configured to use nerd fonts.
  :ensure t                               ;; Ensure the package is installed.
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
  :after (:all nerd-icons)
  :config
  (tab-line-nerd-icons-global-mode))


;;; NERD ICONS IBUFFER
;; Display nerd icons in ibuffer.
(use-package nerd-icons-ibuffer
  :if ek-use-nerd-fonts
  :ensure t
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))


;;; NERD ICONS CORFU
;; Nerd-icons-corfu.el is a library for adding icons to completions in
;; Corfu. It uses nerd-icons.el under the hood and, as such, works on
;; both GUI and terminal. Below is a screenshot of the GUI version.
(use-package nerd-icons-corfu
  :if ek-use-nerd-fonts
  :ensure t
  :after (:all corfu)
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))


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
  :ensure t
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
          (t . (bold 1.0)))))

;;; MODUS CATPPUCCIN
;; Themes for Emacs based on the Catppuccin palette, built on
;; modus-themes.
(use-package modus-catppuccin
  :ensure nil
  :vc (modus-catppuccin :url "https://gitlab.com/magus/modus-catppuccin.git" :branch "main")
  :config
  (modus-themes-load-theme 'catppuccin-latte))


;;; STANDARD THEMES
;; The standard-themes are a collection of light and dark themes for
;; GNU Emacs. The standard-light and standard-dark emulate the
;; out-of-the-box looks of Emacs (which technically do NOT constitute
;; a theme) while bringing to them thematic consistency,
;; customizability, and extensibility. Other themes are stylistic
;; variations of those.
(use-package standard-themes
  :ensure t)


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
  :ensure t
  :diminish highlight-indent-guides-mode
  :custom
  (highlight-indent-guides-method 'character)
  :hook (prog-mode . highlight-indent-guides-mode))


;;; HL TODO
;; Highlight TODO and similar keywords in comments and strings
(use-package hl-todo
  :defer t
  :ensure t
  :after modus-themes
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
  :ensure t)
(use-package rainbow-mode
  :defer nil
  :ensure nil
  :vc (rainbow-mode :url "https://github.com/amosbird/rainbow-mode")
  :diminish rainbow-mode
  :custom
  (rainbow-x-colors nil)
  :hook
  (prog-mode . rainbow-mode))


(provide 'init-pretty-ui)
;;; init-pretty-ui.el ends here
