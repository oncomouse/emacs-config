;;; early-init.el --- Early Init -*- lexical-binding: t; -*-
;;; Commentary:
;; early-init.el is run before init.el,
;; - before package initialization, and
;; - before ui initialization

;;; Code:
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
