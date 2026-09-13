;;; early-init.el --- Early Init -*- lexical-binding: t; -*-
;;; Commentary:
;; early-init.el is run before init.el,
;; - before package initialization, and
;; - before ui initialization

;;; Code:

;; We manage package installation ourselves in init.el (via `package-initialize'
;; and `use-package'), so disable package.el's automatic startup here.
(setq package-enable-at-startup nil)

;; Startup speed, annoyance suppression
(setq bedrock--initial-gc-threshold gc-cons-threshold)
(setq gc-cons-threshold 10000000)
(setq byte-compile-warnings '(not obsolete))
(setq warning-suppress-log-types '((comp) (bytecomp)))
(setq native-comp-async-report-warnings-errors 'silent)

;; Silence stupid startup message
(advice-add #'display-startup-echo-area-message :override #'ignore)

;; Setting *-resize-pixelwise to `t' lets frames/windows resize
;; smoothly at sub-character increments
(setq frame-resize-pixelwise t)
; (setq window-resize-pixelwise t)

(when (fboundp 'tool-bar-mode) ; When in a GUI, disable tool bar;
  (tool-bar-mode -1))          ; all these tools are in the menu-bar anyway

;; These settings apply to *all* frames.
(setq default-frame-alist '(
                            ;; You can turn off scroll bars by uncommenting these lines:
                            ;; (vertical-scroll-bars . nil)
                            ;; (horizontal-scroll-bars . nil)
                            (ns-appearance . dark)
                            (ns-transparent-titlebar . t)

                            ;; Use this to turn off the OS window decoration
                            ;; (undecorated-round . t)
                            ;; (internal-border-width . 3)
                            ))

(setq inhibit-startup-message t)                     ;; Disable the startup message when Emacs launches.
(setq initial-scratch-message "")                    ;; Clear the initial message in the *scratch* buffer.

(when (version< "31" emacs-version)
  (setq load-path-filter-function
        #'load-path-filter-cache-directory-files))

;;; * native-comp
;; - move eln files to a cache dir
;; - don't bombard the user with warnings
;; - compile packages on install, not at runtime
(unless (version-list-<
         (version-to-list emacs-version)
         '(28 0 1 0))
  (when (boundp 'native-comp-eln-load-path)
    (add-to-list 'native-comp-eln-load-path
                 (concat "~/.cache/emacs/" "eln-cache/"))
    (setq native-comp-async-report-warnings-errors 'silent
          native-comp-deferred-compilation t)))


;;; lsp-mode optimizations
(setenv "LSP_USE_PLISTS" "true")

;;; early-init.el ends here
