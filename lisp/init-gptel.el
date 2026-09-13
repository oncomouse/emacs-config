;;; init-gptel.el --- GPTEL configuration -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;;; GPTEL
;; gptel is a simple Large Language Model chat client for Emacs, with
;; support for multiple models and backends. It works in the spirit of
;; Emacs, available at any time and uniformly in any buffer.
(use-package gptel
  :ensure t
  :general
  (:states '(normal)
		   "<leader> e g" 'gptel)
  :defer t
  :commands (gptel-send gptel)
  :custom
  (gptel-default-mode 'markdown-ts-mode)
  (gptel-include-reasoning "*gptel-reasoning*")
  :config
  (gptel-make-openai "cubtram"
	:stream t
	:protocol "http"
	:host "cubtram:8080"
	:models '(cubtram Ling-3.0-tiny Qwen3.5-4B LFM2.5-2.6B))
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
  :ensure nil
  :vc (gptel-preset-collection :url "https://github.com/karthink/gptel-preset-collection")
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
  :ensure t
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
  :ensure t
  :commands (gptel-inline)
  :general
  ("C-c g" 'gptel-inline)
  (:keymaps 'gptel-inline-map
			"C-c m" 'gptel-menu)
  (:keymaps 'gptel-inline--response-overlay-mode-map
			"j" #'gptel-inline--response-overlay-down
			"k" #'gptel-inline--response-overlay-up
			[remap evil-scroll-down] #'gptel-inline--response-overlay-pagedown
			[remap evil-scroll-up] #'gptel-inline--response-overlay-pageup)
  :config
  ;; Upstream bug workaround (gptel-inline ~20260831):
  ;; `gptel-inline--response-overlay-append-chunk' inserts each streamed chunk
  ;; into the *gptel-inline-response* source buffer WITHOUT binding
  ;; `inhibit-read-only'. Once a response involves tool calls that buffer is
  ;; read-only -- the sibling `gptel-inline--response-overlay-reset' guards its
  ;; erase with `inhibit-read-only' for exactly this reason -- so every chunk's
  ;; bare `insert' throws, once per chunk:
  ;;   Error running timer `gptel-inline--update-response-overlay':
  ;;     (buffer-read-only #<buffer *gptel-inline-response*>)
  ;; Bind `inhibit-read-only' around it. Harmless no-op when the buffer is
  ;; writable; drop this once upstream adds the same guard.
  (when (fboundp 'gptel-inline--response-overlay-append-chunk)
    (advice-add 'gptel-inline--response-overlay-append-chunk
                :around
                (lambda (fn ov chunk)
                  (let ((inhibit-read-only t))
                    (funcall fn ov chunk))))))


;;; GPTEL OPENROUTER
;; gptel-openrouter.el is an Emacs package designed to retrieve and
;; process model information from OpenRouter's API. It allows Emacs
;; users to fetch detailed annotations about available models,
;; including descriptions, context lengths, prices, and more. This
;; information is formatted for compatibility with gptel, an Emacs
;; package facilitating communication with AI models.
(use-package gptel-openrouter
  :after gptel
  :ensure nil
  :vc (gptel-openrouter :url "https://github.com/darcamo/gptel-openrouter"))


;;; LLM Tool Collection
;; A curated collection of tools to empower Emacs-based LLM agents.
(use-package llm-tool-collection
  :after gptel
  :ensure nil
  :vc (llm-tool-collection :url "https://github.com/skissue/llm-tool-collection")
  :config
  (mapcar (apply-partially #'apply #'gptel-make-tool)
                  (llm-tool-collection-get-all)))


;; ----------------------------------------------------------------------------------
;; gptel-tools: Emacs Introspection (Derived from emacs-mcp.el source)
;; https://github.com/mpontus/emacs-mcp
;;
;; Sourced from: https://github.com/NapoleonWils0n/debian-dotfiles/blob/master/debian-dotfiles.org
;; ----------------------------------------------------------------------------------
(with-eval-after-load 'gptel
  ;; ----------------------------------------------------------------------------------
  ;; Emacs: get_docstring
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda (function-name)
               (let* ((symbol (intern-soft function-name))
                      (docstring (and symbol (documentation symbol))))
				 (or docstring
					 (error "No docstring found for function: %s" function-name))))
   :name "get_docstring"
   :description "Get the docstring for an Emacs Lisp function.
 Provides the raw documentation string for any Emacs Lisp function.
 FUNCTION-NAME should be the name of the function as a string.
 Returns the full docstring or an error if the function doesn't exist."
   :args (list '(:name "function-name" :type string :description "The name of the function as a string."))
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: describe_elisp_variable
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda (variable-name)
               (save-window-excursion
				 (describe-variable (intern variable-name))
				 (with-current-buffer "*Help*"
                   (let ((docstring (buffer-string)))
					 (kill-buffer)
					 docstring))))
   :name "describe_elisp_variable"
   :description "Describe an Emacs Lisp variable in detail.
 Provides comprehensive information about a variable including:
 - Current value
 - Documentation string
 - Whether it is customizable
 - Where it was defined
 VARIABLE-NAME should be the name of the variable as a string."
   :args (list '(:name "variable-name" :type string :description "The name of the variable as a string."))
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: describe_key_binding
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda (key-sequence)
               (save-window-excursion
				 (let ((key (kbd key-sequence)))
                   (describe-key key)
                   (with-current-buffer "*Help*"
					 (let ((result (buffer-string)))
                       (kill-buffer)
                       result)))))
   :name "describe_key_binding"
   :description "Display documentation of the function invoked by KEY-SEQUENCE.
 Provides information about what command a key sequence runs and its documentation.
 KEY-SEQUENCE should be in Emacs key notation as a string (e.g. \"C-x C-f\").
 Returns details about the key binding and the function it calls."
   :args (list '(:name "key-sequence" :type string :description "Key sequence in Emacs notation (e.g. \"C-x C-f\")."))
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: describe_current_mode
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda ()
               (save-window-excursion
				 (describe-mode)
				 (with-current-buffer "*Help*"
                   (let ((result (buffer-string)))
					 (kill-buffer)
					 result))))
   :name "describe_current_mode"
   :description "Display documentation of current major mode and minor modes.
 Provides comprehensive information about:
 - The current major mode and its purpose
 - All enabled minor modes
 - Key bindings specific to these modes
 This helps understand the current editing environment and available commands."
   :args nil
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: describe_elisp_function
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda (function-name)
               (save-window-excursion
				 (describe-function (intern function-name))
				 (with-current-buffer "*Help*"
                   (let ((result (buffer-string)))
					 (kill-buffer)
					 result))))
   :name "describe_elisp_function"
   :description "Display the full documentation of FUNCTION.
 Provides detailed information about an Emacs Lisp function including:
 - Its argument list
 - Full documentation string
 - Where it was defined
 - Key bindings that call this function
 FUNCTION-NAME should be the name of the function as a string."
   :args (list '(:name "function-name" :type string :description "The name of the function as a string."))
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: describe_display_face
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda (face-name)
               (save-window-excursion
				 (describe-face (intern face-name))
				 (with-current-buffer "*Help*"
                   (let ((result (buffer-string)))
					 (kill-buffer)
					 result))))
   :name "describe_display_face"
   :description "Display the properties of face FACE.
 Provides detailed information about a display face including:
 - Its appearance attributes (color, weight, slant, etc.)
 - Where it was defined
 - How it's currently displayed
 FACE-NAME should be the name of the face as a string.
 This is useful for understanding text styling in Emacs."
   :args (list '(:name "face-name" :type string :description "The name of the face as a string (e.g., 'default')."))
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: describe_installed_package
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda (package-name)
               (save-window-excursion
				 (require 'package)
				 (describe-package (intern package-name))
				 (with-current-buffer "*Help*"
                   (let ((result (buffer-string)))
					 (kill-buffer)
					 result))))
   :name "describe_installed_package"
   :description "Display the full documentation of PACKAGE.
 Provides comprehensive information about an installed package including:
 - Version information
 - Summary and description
 - Dependencies
 - Features provided
 PACKAGE-NAME should be the name of the package as a string.
 This helps understand what functionality a package provides."
   :args (list '(:name "package-name" :type string :description "The name of the package as a string."))
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: list_all_bindings
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda ()
               (save-window-excursion
				 (describe-bindings)
				 (with-current-buffer "*Help*"
                   (let ((result (buffer-string)))
					 (kill-buffer)
					 result))))
   :name "list_all_bindings"
   :description "Display a buffer showing a list of all defined keys, and their definitions.
 Provides a comprehensive list of all currently active key bindings organized by prefix.
 This gives a complete overview of available commands and their key shortcuts.
 Useful for understanding what commands are available in the current context."
   :args nil
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: describe_custom_theme
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda (theme-name)
               (save-window-excursion
				 (require 'custom)
				 (describe-theme (intern theme-name))
				 (with-current-buffer "*Help*"
                   (let ((result (buffer-string)))
					 (kill-buffer)
					 result))))
   :name "describe_custom_theme"
   :description "Display a description of the Custom theme THEME.
 Provides information about a specific Emacs theme including:
 - Its settings and customizations
 - Faces it defines or modifies
 - Where it was defined
 THEME-NAME should be the name of the theme as a string.
 This helps understand how a theme affects Emacs appearance."
   :args (list '(:name "theme-name" :type string :description "The name of the theme as a string."))
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: describe_current_syntax
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda ()
               (save-window-excursion
				 (describe-syntax)
				 (with-current-buffer "*Help*"
                   (let ((result (buffer-string)))
					 (kill-buffer)
					 result))))
   :name "describe_current_syntax"
   :description "Describe the syntax specifications in the current syntax table.
 Provides detailed information about how Emacs interprets different characters
 in the current buffer's major mode. This includes:
 - Which characters are considered word constituents
 - Which characters are considered punctuation
 - How comment and string delimiters are defined
 This is useful for understanding how Emacs parses text in different modes."
   :args nil
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: apropos_command
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda (pattern)
               (require 'apropos)
               (save-window-excursion
				 (apropos-command pattern)
				 (with-current-buffer "*Apropos*"
                   (let ((result (buffer-string)))
					 (kill-buffer)
					 result))))
   :name "apropos_command"
   :description "Search for commands matching PATTERN.
 Finds and returns information about all Emacs commands whose names match PATTERN.
 PATTERN can be a regular expression or a simple string.
 Results include command names, key bindings, and brief descriptions.
 This is useful for discovering commands related to a specific topic or feature."
   :args (list '(:name "pattern" :type string :description "A string or regular expression to match command names."))
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: apropos_variable
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda (pattern)
               (require 'apropos)
               (save-window-excursion
				 (apropos-variable pattern)
				 (with-current-buffer "*Apropos*"
                   (let ((result (buffer-string)))
					 (kill-buffer)
					 result))))
   :name "apropos_variable"
   :description "Search for variables matching PATTERN.
 Finds and returns information about all Emacs variables whose names match PATTERN.
 PATTERN can be a regular expression or a simple string.
 Results include variable names, current values, and brief descriptions.
 This is useful for discovering configuration options related to a specific feature."
   :args (list '(:name "pattern" :type string :description "A string or regular expression to match variable names."))
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: apropos_value
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda (pattern)
               (require 'apropos)
               (save-window-excursion
				 (apropos-value pattern)
				 (with-current-buffer "*Apropos*"
                   (let ((result (buffer-string)))
					 (kill-buffer)
					 result))))
   :name "apropos_value"
   :description "Search for variables with values matching PATTERN.
 Finds and returns information about Emacs variables whose values match PATTERN.
 PATTERN can be a regular expression or a simple string.
 Results include variable names, matching values, and brief descriptions.
 This is useful for finding variables set to specific values or containing certain data."
   :args (list '(:name "pattern" :type string :description "A string or regular expression to match variable values."))
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: apropos_documentation
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda (pattern)
               (require 'apropos)
               (save-window-excursion
				 (apropos-documentation pattern)
				 (with-current-buffer "*Apropos*"
                   (let ((result (buffer-string)))
					 (kill-buffer)
					 result))))
   :name "apropos_documentation"
   :description "Search for symbols with documentation matching PATTERN.
 Finds and returns information about Emacs symbols whose documentation contains PATTERN.
 PATTERN can be a regular expression or a simple string.
 Results include symbol names and the matching portions of their documentation.
 This is useful for finding features described with specific terms in their documentation."
   :args (list '(:name "pattern" :type string :description "A string or regular expression to search within documentation strings."))
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: apropos_all_symbols
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda (pattern)
               (require 'apropos)
               (save-window-excursion
				 (apropos pattern)
				 (with-current-buffer "*Apropos*"
                   (let ((result (buffer-string)))
					 (kill-buffer)
					 result))))
   :name "apropos_all_symbols"
   :description "Search for symbols whose names match PATTERN.
 Finds and returns information about all Emacs symbols whose names match PATTERN.
 PATTERN can be a regular expression or a simple string.
 Results include functions, variables, faces, and other symbols.
 This is the most general search tool and useful for broad exploration of Emacs features."
   :args (list '(:name "pattern" :type string :description "A string or regular expression to match symbol names."))
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: info_get_node
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda (node-name)
               (require 'info)
               (save-window-excursion
				 (info node-name)
				 (with-current-buffer "*info*"
                   (let ((result (buffer-string)))
					 (kill-buffer)
					 result))))
   :name "info_get_node"
   :description "Display the contents of an Info node.
 Provides the full text content of a specific Info documentation node.
 NODE-NAME should be the name of the node as a string (e.g. \"(emacs)Basic\").
 Returns the text content of the specified Info node."
   :args (list '(:name "node-name" :type string :description "The Info node name as a string."))
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: info_documentation_search
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda (topic)
               (require 'info)
               (save-window-excursion
				 (info)
				 (Info-search topic)
				 (let ((result (format "Search results for '%s':\n\n" topic))
                       (node-name (format "%s" Info-current-node))
                       (file-name (format "%s" Info-current-file)))
                   (setq result (concat result
										(format "Found in node: %s in file: %s\n\n"
												node-name file-name)))
                   ;; Get context around the match
                   (let ((start (max (point-min) (- (point) 200)))
						 (end (min (point-max) (+ (point) 500))))
					 (setq result (concat result
                                          (buffer-substring-no-properties start end))))
                   (kill-buffer)
                   result)))
   :name "info_documentation_search"
   :description "Search for TOPIC in the Info documentation.
 Performs a search across Info documentation for the specified topic.
 TOPIC should be a string to search for.
 Returns a list of matching nodes and context around the matches."
   :args (list '(:name "topic" :type string :description "The topic string to search for."))
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: info_index_lookup
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda (index-item)
               (require 'info)
               (save-window-excursion
				 (info)
				 (Info-index index-item)
				 (with-current-buffer "*info*"
                   (let ((result (format "Index results for '%s':\n\n" index-item))
						 (node-name (format "%s" Info-current-node))
						 (file-name (format "%s" Info-current-file)))
					 (setq result (concat result
                                          (format "Found in node: %s in file: %s\n\n"
                                                  node-name file-name)))
					 ;; Get the content of the node
					 (setq result (concat result (buffer-substring-no-properties (point-min) (point-max))))
					 (kill-buffer)
					 result))))
   :name "info_index_lookup"
   :description "Look up INDEX-ITEM in the indices of the Info documentation.
 Finds entries in Info documentation indices that match the specified item.
 INDEX-ITEM should be a string to look up in the indices.
 Returns information about matching index entries and their locations."
   :args (list '(:name "index-item" :type string :description "The item string to look up in the indices."))
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: info_get_toc
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda (manual)
               (require 'info)
               (save-window-excursion
				 (info (concat "(" manual ")"))
				 (Info-directory)
				 (with-current-buffer "*info*"
                   (let ((result (format "Table of Contents for '%s':\n\n" manual)))
					 (setq result (concat result (buffer-substring-no-properties (point-min) (point-max))))
					 (kill-buffer)
					 result))))
   :name "info_get_toc"
   :description "Display the table of contents for a specific Info MANUAL.
 Provides the structure and organization of an Info manual.
 MANUAL should be the name of the manual as a string (e.g. \"emacs\").
 Returns the table of contents of the specified manual."
   :args (list '(:name "manual" :type string :description "The name of the Info manual as a string."))
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: info_list_manuals
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda ()
               (require 'info)
               (save-window-excursion
				 (info)
				 (Info-directory)
				 (with-current-buffer "*info*"
                   (let ((result "Available Info Manuals:\n\n"))
					 (setq result (concat result (buffer-substring-no-properties (point-min) (point-max))))
					 (kill-buffer)
					 result))))
   :name "info_list_manuals"
   :description "List all available Info manuals.
 Provides a comprehensive list of all Info documentation manuals available in the system.
 This helps discover what documentation is available for reference."
   :args nil
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: get_emacs_version
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda ()
               (concat "Emacs Version:\n\n" (emacs-version)))
   :name "get_emacs_version"
   :description "Get detailed information about the current Emacs version.
 Provides version number, build details, and system configuration information.
 This helps understand the capabilities and limitations of the current Emacs instance."
   :args nil
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: list_loaded_features
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda ()
               (let ((result "Loaded Features:\n\n"))
				 (dolist (feature features)
                   (setq result (concat result (format "- %s\n" feature))))
				 result))
   :name "list_loaded_features"
   :description "List all features (libraries) that have been loaded in Emacs.
 Provides a comprehensive list of all Emacs Lisp libraries currently loaded.
 This helps understand what functionality is available in the current session."
   :args nil
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: list_installed_packages
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda ()
               (require 'package)
               (package-initialize)
               (let ((result "Installed Packages:\n\n"))
				 (dolist (pkg package-alist)
                   (let* ((name (car pkg))
                          (desc (cadr pkg))
                          (version (package-desc-version desc))
                          (status (if (package-installed-p name) "Installed" "Not Installed")))
					 (setq result (concat result (format "- %s (%s): %s\n"
														 name version status)))))
				 result))
   :name "list_installed_packages"
   :description "List all installed packages with their status and version.
 Provides a comprehensive overview of the user's package ecosystem."
   :args nil
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: list_available_modes
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda ()
               (let ((result "Available Major Modes:\n\n")
					 (modes '()))
				 (mapatoms (lambda (sym)
							 (when (and (functionp sym)
										(string-match "-mode$" (symbol-name sym))
										(not (string-match "-minor-mode$" (symbol-name sym))))
                               (push (symbol-name sym) modes))))
				 (setq modes (sort modes 'string<))
				 (dolist (mode modes)
                   (setq result (concat result (format "- %s\n" mode))))
				 result))
   :name "list_available_modes"
   :description "List all available major modes in this Emacs instance.
 Provides a comprehensive list of all major modes that can be used.
 This helps understand what file types and editing modes are supported."
   :args nil
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: list_custom_variables
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda ()
               (require 'cus-edit)
               (let ((result "Customized Variables:\n\n"))
				 (dolist (theme custom-enabled-themes)
                   (setq result (concat result (format "Theme: %s\n" theme))))
				 (setq result (concat result "\nVariables:\n"))
				 (mapatoms
                  (lambda (symbol)
					(when (and (boundp symbol)
                               (get symbol 'saved-value))
                      (setq result (concat result (format "- %s: %S\n"
                                                          symbol (symbol-value symbol)))))))
				 result))
   :name "list_custom_variables"
   :description "List all customized variables in the current Emacs session.
 Shows variables that have been customized away from their default values.
 This helps understand how the user has personalized their Emacs."
   :args nil
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: describe_matching_hooks
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda (hook-pattern)
               (let ((result (format "Hooks matching \"%s\":\n\n" hook-pattern))
					 (hooks '()))
				 (mapatoms
                  (lambda (symbol)
					(when (and (boundp symbol)
                               (string-match "-hook$" (symbol-name symbol))
                               (string-match hook-pattern (symbol-name symbol)))
                      (push symbol hooks))))
				 (setq hooks (sort hooks (lambda (a b) (string< (symbol-name a) (symbol-name b)))))
				 (dolist (hook hooks)
                   (setq result (concat result (format "- %s:\n" hook)))
                   (let ((value (symbol-value hook)))
					 (if (not value)
						 (setq result (concat result "  (empty)\n"))
                       (dolist (func value)
						 (setq result (concat result (format "  - %s\n" func)))))))
				 result))
   :name "describe_matching_hooks"
   :description "List and show the functions attached to hooks matching HOOK-PATTERN."
   :args (list '(:name "hook-pattern" :type string :description "A string or regex to match hook names (e.g., 'prog-mode')."))
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: list_available_fonts
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda ()
               (let ((result "Available Fonts:\n\n")
					 (fonts (font-family-list)))
				 (setq fonts (sort fonts 'string<))
				 (dolist (font fonts)
                   (setq result (concat result (format "- %s\n" font))))
				 result))
   :name "list_available_fonts"
   :description "List all available fonts in the current Emacs session.
 Shows what fonts can be used for display customization.
 This helps understand display capabilities and options."
   :args nil
   :category "emacs")

  ;; ----------------------------------------------------------------------------------
  ;; Emacs: find_key_conflicts
  ;; ----------------------------------------------------------------------------------
  (gptel-make-tool
   :function (lambda (prefix)
               (require 'help-fns)
               (let ((result (format "Key bindings starting with %s:\n\n" prefix))
					 (key (kbd prefix))
					 (map (current-global-map))
					 bindings)
				 ;; This code block has a minor issue in the original file,
				 ;; as it attempts to call lookup-key on a keymap which is not a vector.
				 ;; The intention is to list all keys *under* the prefix, but since
				 ;; the exact logic is hard to reproduce reliably outside the package,
				 ;; we simplify it to list all bindings that START with the prefix.
				 (map-keymap
                  (lambda (k v)
					(when (and v (string-prefix-p prefix (key-description (vector k))))
                      (let ((key-desc (key-description (vector k))))
						(push (cons key-desc v) bindings))))
                  map)
				 (setq bindings (sort bindings (lambda (a b) (string< (car a) (car b)))))
				 (dolist (binding bindings)
                   (setq result (concat result (format "- %s: %s\n"
                                                       (car binding)
                                                       (cdr binding)))))
				 result))
   :name "find_key_conflicts"
   :description "Find conflicting key bindings starting with PREFIX.
 Identifies key sequences that might shadow or conflict with each other.
 PREFIX should be a key prefix in string form (e.g. \"C-c\").
 This helps diagnose keybinding issues and conflicts."
   :args (list '(:name "prefix" :type string :description "The key prefix string to check (e.g. \"C-c\")."))
   :category "emacs")

  ;;; GPTel Web Search with SearXNG
  ;; Sourced from: https://github.com/skang0601/desktop-scripts/blob/main/modules/packages/apps.d/emacs/doom/config.el#L241
  (gptel-make-tool
   :name "web_search"
   :function (lambda (query)
			   "Return titles, URLs and snippets searxng has for QUERY."
			   (condition-case err
				   (with-current-buffer
					   (url-retrieve-synchronously
						(format "%s?q=%s&format=json" searxng-url (url-hexify-string query))
						t t 15)
					 (unwind-protect
						 (progn
						   (goto-char (point-min))
						   (if (not (re-search-forward "^$" nil t))
							   "searxng returned no parseable response"
							 (let ((results (alist-get 'results (json-parse-buffer :object-type 'alist))))
							   (if (zerop (length results))
								   (format "No results for %s" query)
								 (+gptel--truncate
								  (mapconcat
								   (lambda (r)
									 (format "%s\n%s\n%s"
											 (alist-get 'title r "")
											 (alist-get 'url r "")
											 (alist-get 'content r "")))
								   (seq-take (append results nil) 8)
								   "\n\n"))))))
					   (kill-buffer)))
				 (error (format "searxng is not answering on %s: %s"
								searxng-url (error-message-string err)))))
   :description "Search the web for QUERY and return the top results with URLs and
snippets. Use for anything current, or any fact that needs a source."
   :args '((:name "query" :type string :description "The search query."))
   :category "research"))


;;; GPTEL MAGIT
;; Uses the fantastic gptel to extend the equally fantastic magit with
;; some LLM-powered functionality.
;;
;; Functionality is provided for:
;;
;; + Generating commit messages
;; + Explaining diffs
(use-package gptel-magit
  :ensure t
  :hook (magit-mode . gptel-magit-install))


(provide 'init-gptel)
;;; init-gptel.el ends here
