;;; init-base.el --- Necessary UI packages for emacs -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

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
			"C-c C-e" 'embark-export
			"C-c C-c" 'embark-act)
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
			  :around #'embark-hide-which-key-indicator)
    ;; Add the option to run embark when using avy
  (defun bedrock/avy-action-embark (pt)
    (unwind-protect
        (save-excursion
          (goto-char pt)
          (embark-act))
      (select-window
       (cdr (ring-ref avy-ring 0))))
    t)

  ;; After invoking avy-goto-char-timer, hit "." to run embark at the next
  ;; candidate you select
  (with-eval-after-load 'avy
	(setf (alist-get ?. avy-dispatch-alist) 'bedrock/avy-action-embark)))


;;; EMBARK-CONSULT
;; Embark-Consult provides a bridge between Embark and Consult, ensuring
;; that Consult commands, like previews, are available when using Embark.
(use-package embark-consult
  :ensure t
  :straight t) ;; Enable preview in Embark collect mode.


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
  (:states 'insert :keymaps 'corfu-map
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


;;; CAPE
;; Cape provides Completion At Point Extensions which can be used in
;; combination with Corfu, Company or the default completion UI. The
;; completion backends used by completion-at-point are so called
;; completion-at-point-functions (Capfs).
(use-package cape
  :straight t
  :commands (cape-keyword cape-dabbrev)
  :general
  (:states 'insert
	"C-x C-l" #'cape-line
    "C-x C-f" #'cape-file
    "C-x C-k" #'cape-dict)
  :hook ((md-mode markdown-mode org-mode) .
         (lambda ()
           (setq-local completion-at-point-functions (list #'cape-dict #'cape-keyword #'cape-dabbrev)
                       completion-styles '(basic)))))


(provide 'init-base)
;;; init-base.el ends here
