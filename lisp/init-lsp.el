;;; init-lsp.el --- LSP configuration -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

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


(provide 'init-lsp)
;;; init-lsp.el ends here
