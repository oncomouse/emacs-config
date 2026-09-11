;;; init-gptel.el --- GPTEL configuration -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

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
  :straight (gptel-inline :type git :host github :repo "karthink/gptel-inline")
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


(provide 'init-gptel)
;;; init-gptel.el ends here
