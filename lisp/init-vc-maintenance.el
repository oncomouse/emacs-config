;;; init-vc-maintenance.el --- keep :vc packages attached, current, and honest  -*- lexical-binding: t; -*-

;;; Commentary:

;; `use-package's :vc keyword installs a package exactly once and never touches
;; it again: `use-package-vc-install' is wrapped in
;;
;;     (unless (package-installed-p name) ...)
;;
;; `use-package-vc-prefer-newest' only decides which revision a *fresh* install
;; resolves to -- it is not an upgrade policy.  With nothing else pulling, a :vc
;; package silently freezes.  Worse, if it was ever resolved as `:last-release'
;; it is pinned to the last commit that touched its `Version:' header, and for
;; casually-versioned upstreams that commit can be an empty scaffold.  That is
;; exactly how `llm-tool-collection' (pinned at its "package scaffolding"
;; commit) and `modus-catppuccin' both ended up loading a package that defined
;; nothing.
;;
;; The pin also leaves the checkout on a *detached* HEAD, where `git pull' fails
;; outright with "You are not currently on a branch", so later upgrades become
;; interactive guesswork instead of a fast-forward.
;;
;; This file is the missing piece:
;;
;;   M-x ek-vc-status         -- what each :vc package is actually checked out at
;;   M-x ek-vc-upgrade-stale -- fast-forward + rebuild everything behind
;;
;; and, when `ek-vc-auto-upgrade' is non-nil, runs the upgrade on an idle timer
;; at most once every `ek-vc-upgrade-interval-days' days.
;;
;; Safety contract:
;;   * fast-forward only (`git merge --ff-only'): never merges, resets, or stashes
;;   * skips any checkout carrying tracked modifications
;;   * skips any package with no upstream branch
;;   * never blocks startup: work happens on an idle timer, and failures are
;;     reported rather than signaled
;;
;; The spec in your init file is not evidence of what you are running.
;; `ek-vc-status' is.

;;; Code:

(require 'cl-lib)
(require 'package)

(defgroup ek-vc nil
  "Maintenance of packages installed via `use-package's :vc keyword."
  :group 'ek)

(defcustom ek-vc-auto-upgrade t
  "When non-nil, upgrade stale :vc packages on an idle timer.
Set to nil to make `ek-vc-upgrade-stale' strictly manual."
  :type 'boolean
  :group 'ek-vc)

(defcustom ek-vc-upgrade-interval-days 7
  "Minimum number of days between automatic :vc upgrade attempts."
  :type 'number
  :group 'ek-vc)

(defcustom ek-vc-upgrade-idle-seconds 45
  "Idle time to wait before the automatic upgrade runs.
Keeps the network and any byte-compiling off the startup path."
  :type 'number
  :group 'ek-vc)

(defvar ek-vc-stamp-file
  (locate-user-emacs-file ".vc-upgrade.stamp")
  "Records the time of the last automatic :vc upgrade attempt.")

(defun ek-vc--git (dir &rest args)
  "Run git with ARGS in DIR.
Return a cons cell (EXIT-CODE . OUTPUT).  `default-directory' is bound to DIR --
without that, every git call would run against whichever repo the caller happens
to be sitting in."
  (let ((default-directory (file-name-as-directory (expand-file-name dir)))
        (buf (generate-new-buffer " *ek-vc-git*")))
    (unwind-protect
        (cons (apply #'process-file "git" nil buf nil args)
              (with-current-buffer buf (buffer-string)))
      (kill-buffer buf))))

(defun ek-vc--git* (dir &rest args)
  "Run git with ARGS in DIR, returning trimmed output.
Returns nil when the command exits non-zero."
  (let ((result (apply #'ek-vc--git dir args)))
    (and (zerop (car result))
         (string-trim (cdr result)))))

(defun ek-vc--tracked-dirty-p (dir)
  "Return non-nil if DIR has uncommitted changes to tracked files.
Untracked files -- package autoloads, .elc, pkg descriptions -- are ignored."
  (let ((status (ek-vc--git* dir "status" "--porcelain")))
    (and status
         (seq-some (lambda (line) (not (string-prefix-p "??" line)))
                  (split-string status "\n" t)))))

(defun ek-vc-installed-packages ()
  "Return the descriptors of every installed VC (source) package.\nNote `seq-mapcat', not `mapcan': `mapcan' splices destructively and would\ncorrelate the cdrs of `package-alist'."
  (seq-filter #'package-vc-p (seq-mapcat #'cdr package-alist)))

(defun ek-vc--count (dir range)
  "Count commits over RANGE (e.g. \"HEAD..@{upstream}\") in DIR."
  (string-to-number (or (ek-vc--git* dir "rev-list" "--count" range) "0")))

(defun ek-vc--branch (dir)
  "Return the current branch of DIR, or \"DETACHED-<sha>\" when detached."
  (or (ek-vc--git* dir "symbolic-ref" "-q" "--short" "HEAD")
      (concat "DETACHED@" (or (ek-vc--git* dir "rev-parse" "--short" "HEAD") "?"))))

;;;###autoload
(defun ek-vc-status ()
  "Report what each installed :vc package is actually checked out at.
Shows branch, HEAD, how far behind/ahead of upstream it is, whether the
checkout carries local modifications, and the commit subject."
  (interactive)
  (let ((rows
         (mapcar
          (lambda (desc)
            (let ((dir (package-desc-dir desc)))
              (list (symbol-name (package-desc-name desc))
                    (ek-vc--branch dir)
                    (or (ek-vc--git* dir "rev-parse" "--short" "HEAD") "?")
                    (number-to-string (ek-vc--count dir "HEAD..@{upstream}"))
                    (number-to-string (ek-vc--count dir "@{upstream}..HEAD"))
                    (if (ek-vc--tracked-dirty-p dir) "dirty" "clean")
                    (or (ek-vc--git* dir "log" "-1" "--format=%ad  %s" "--date=short")
                        ""))))
          (ek-vc-installed-packages))))
    (with-output-to-temp-buffer "*VC Package Status*"
      (princ (format "%-26s %-14s %-8s %6s %6s %-6s %s\n"
                    "PACKAGE" "BRANCH" "HEAD" "BEHIND" "AHEAD" "TREE" "COMMIT")
             standard-output)
      (princ (make-string 100 ?-) standard-output)
      (princ "\n" standard-output)
      (dolist (row (sort rows (lambda (a b) (string< (car a) (car b)))))
        (princ (format "%-26s %-14s %-8s %6s %6s %-6s %s\n"
                       (nth 0 row) (nth 1 row) (nth 2 row)
                       (nth 3 row) (nth 4 row) (nth 5 row) (nth 6 row))
               standard-output)))))

(defun ek-vc-upgrade-package (desc)
  "Fast-forward DESC from its upstream, then rebuild it.
Rebuilding re-scrapes autoloads, byte-compiles, and rebuilds docs and
dependencies -- without it a package moves but the installed state does not.
Return (NAME ACTION DETAIL)."
  (let ((name (package-desc-name desc))
        (dir (package-desc-dir desc)))
    (cond
     ((not (ek-vc--git* dir "rev-parse" "--verify" "-q" "@{upstream}"))
      (list name 'skipped "no upstream branch configured"))
     ((ek-vc--tracked-dirty-p dir)
      (list name 'skipped "checkout has tracked modifications"))
     (t
      (let ((fetch (ek-vc--git dir "fetch" "--quiet" "origin")))
        (unless (zerop (car fetch))
          (cl-return-from ek-vc-upgrade-package
            (list name 'failed
                  (format "fetch failed: %s" (string-trim (cdr fetch))))))
        (let ((behind (ek-vc--count dir "HEAD..@{upstream}")))
          (if (zerop behind)
              (list name 'up-to-date nil)
            (let ((merge (ek-vc--git dir "merge" "--ff-only" "@{upstream}")))
              (unless (zerop (car merge))
                (cl-return-from ek-vc-upgrade-package
                  (list name 'refused
                        (format "not fast-forwardable: %s"
                                (string-trim (cdr merge))))))
              (condition-case err
                  (progn
                    (package-vc-rebuild desc)
                    (list name 'updated
                          (format "%d commit(s) -> %s"
                                  behind
                                  (or (ek-vc--git* dir "rev-parse" "--short" "HEAD") "?"))))
                (error
                 (list name 'updated
                       (format "%d commit(s), but rebuild failed: %s"
                               behind (error-message-string err)))))))))))))

;;;###autoload
(defun ek-vc-upgrade-stale ()
  "Fast-forward and rebuild every installed :vc package that is behind upstream.
Reports per package: updated, up-to-date, skipped, refused, or failed."
  (interactive)
  (let* ((results (mapcar #'ek-vc-upgrade-package (ek-vc-installed-packages)))
         (needed (seq-remove (lambda (r) (eq (nth 1 r) 'up-to-date)) results))
         (updated (seq-remove (lambda (r) (not (eq (nth 1 r) 'updated))) results)))
    (with-output-to-temp-buffer "*VC Upgrade Report*"
      (princ (format "VC package upgrade -- %s\n\n"
                     (format-time-string "%Y-%m-%d %H:%M %z"))
             standard-output)
      (dolist (result (sort results (lambda (a b) (string< (car a) (car b)))))
        (princ (format "%-26s %-11s %s\n"
                       (car result) (nth 1 result) (or (nth 2 result) ""))
               standard-output)))
    (message "VC upgrade: %d package(s) updated, %d needed attention"
             (length updated) (length needed))))

(defun ek-vc--due-p ()
  "Return non-nil if the automatic upgrade interval has elapsed."
  (let ((stamp (nth 5 (file-attributes ek-vc-stamp-file))))
    (or (null stamp)
        (>= (- (time-to-seconds (current-time)) (time-to-seconds stamp))
            (* 86400.0 ek-vc-upgrade-interval-days)))))

;;;###autoload
(defun ek-vc-auto-upgrade-maybe ()
  "Upgrade stale :vc packages, but only once per `ek-vc-upgrade-interval-days'.
The stamp is written before the work so an unreachable network cannot turn
every startup into a fresh retry storm."
  (interactive)
  (when (ek-vc--due-p)
    (write-region (format-time-string "%Y-%m-%dT%H:%M:%S")
                  nil ek-vc-stamp-file nil 'silent)
    (condition-case err
        (let ((results (ek-vc-upgrade-stale)))
          (message "VC maintenance: %s"
                   (if-let* ((changes
                             (seq-remove
                              (lambda (r) (eq (nth 1 r) 'up-to-date))
                              results)))
                       (mapconcat (lambda (r) (format "%s: %s" (car r) (nth 1 r)))
                                  changes ", ")
                     "all :vc packages already current")))
      (error
       (message "VC maintenance failed: %s" (error-message-string err))))))

(when (and ek-vc-auto-upgrade (not noninteractive))
  (run-with-idle-timer ek-vc-upgrade-idle-seconds nil #'ek-vc-auto-upgrade-maybe))

(provide 'init-vc-maintenance)
;;; init-vc-maintenance.el ends here
