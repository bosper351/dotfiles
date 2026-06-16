;; -*- lexical-binding: t; -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Elpaca Package Manager Setup
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Elpaca installer
(defvar elpaca-installer-version 0.12)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca-activate)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-sources-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Profiler
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq use-package-compute-statistics t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Basic settings
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Use separate file for auto-generated config
(setq custom-file (locate-user-emacs-file "custom.el"))
(add-hook 'elpaca-after-init-hook (lambda () (load custom-file 'noerror)))

;; Change default mode for the *scratch* buffer from lisp-interaction-mode. This is faster to load.
(setopt initial-major-mode 'fundamental-mode)
;; (setopt inhibit-splash-screen t)

;; M-x Command history
(savehist-mode)

;; Recent files history
(setopt recentf-max-saved-items 200)
(global-set-key (kbd "C-c r") 'recentf-open)
(add-hook 'elpaca-after-init-hook (lambda () (recentf-mode 1)))

;; Start emacs server
(add-hook 'elpaca-after-init-hook 'server-start)


;; Fix archaic defaults
(setopt sentence-end-double-space nil)

;; Prefer spaces over tabs
(setq-default indent-tabs-mode nil)

;; Save the existing clipboard content into the kill ring before overwriting with C-k
(setq save-interprogram-paste-before-kill t)

;; GUI-only tweaks
(when (display-graphic-p)
  (context-menu-mode))  ;; Make right-click do something sensible

;; Terminal tweaks
(unless (display-graphic-p)
  ;; Disable the menu bar for a more streamlined look.
  (menu-bar-mode -1)
  ;; Enable mouse support in terminal mode.
  (xterm-mouse-mode 1)
  ;; Makes Emacs vertical divisor the symbol │ instead of |.
  (set-display-table-slot standard-display-table 'vertical-border (make-glyph-code ?│)))

;; Don't litter file system with *~ backup files; put them all inside
;; ~/.emacs.d/backup or wherever
(defun my--backup-file-name (fpath)
  "Return a new file path of a given file path.
If the new path's directories does not exist, create them."
  (let* ((backupRootDir (concat user-emacs-directory "emacs-backup/"))
         (filePath (replace-regexp-in-string "[A-Za-z]:" "" fpath )) ; remove Windows driver letter in path
         (backupFilePath (replace-regexp-in-string "//" "/" (concat backupRootDir filePath "~") )))
    (make-directory (file-name-directory backupFilePath) (file-name-directory backupFilePath))
    backupFilePath))
(setopt make-backup-file-name-function 'my--backup-file-name)

;; Use ripgrep for built-in greps
(setopt xref-search-program 'ripgrep)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Keybindings
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Comments
(global-set-key (kbd "C-;") 'comment-line)

;; Ignore Ctrl+wheel events. This does text scalling and is annoying with
;; scroll/trackpad inertia.
(global-set-key (kbd "<C-wheel-up>") 'ignore)
(global-set-key (kbd "<C-wheel-down>") 'ignore)

;; which-key: shows a popup of available keybindings when typing a long key
;; sequence (e.g. C-x ...)
(use-package which-key
  :hook
  (elpaca-after-init-hook . which-key-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   MacOS
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Use GNU ls from homebrew
(setq dired-use-ls-dired t
      insert-directory-program "/opt/homebrew/bin/gls"
      dired-listing-switches "-l --all --human-readable --group-directories-first --no-group"
      dired-mouse-drag-files t
      mouse-drag-and-drop-region-cross-program t)

;; Unbind right option for polish characters
(setq mac-right-option-modifier 'none)

;; Move through windows with Option-Command-<arrow keys>
(windmove-default-keybindings '(meta super))
 
;; Fix shell commands PATH
(use-package exec-path-from-shell
  :ensure t
  :config
  ;; (setq exec-path-from-shell-debug t)
  (setq exec-path-from-shell-arguments '("-l"))
  (add-to-list 'exec-path-from-shell-variables "GH_HOST")
  (add-to-list 'exec-path-from-shell-variables "CURSOR_API_KEY")
  (add-to-list 'exec-path-from-shell-variables "OPENROUTER_API_KEY")
  (exec-path-from-shell-initialize))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Theme
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package modus-themes
  :ensure t
  :init
  (modus-themes-include-derivatives-mode t)
  :custom
  (modus-vivendi-palette-overrides
   '((bg-main "#242529") ; Lighter background
     (bg-dim "#242529")  ; Unified background
     (variable fg-main)  ; No variable coloring
     (border-mode-line-active bg-mode-line-active) ; Invisible modeline border
     (border-mode-line-inactive bg-mode-line-inactive)))
  (modus-operandi-palette-overrides
   '((bg-dim bg-main)    ; Unified background
     (variable fg-main)  ; No variable coloring
     (border-mode-line-active bg-mode-line-active) ; Invisible modeline border
     (border-mode-line-inactive bg-mode-line-inactive)))
  :config
  (if (eq ns-system-appearance 'dark)
      (modus-themes-load-theme 'modus-vivendi)
    (modus-themes-load-theme 'modus-operandi)))

(add-to-list 'default-frame-alist '(font . "SFMono Nerd Font Mono")) ; Change default font

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Minibuffer/completion settings
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; For help, see: https://www.masteringemacs.org/article/understanding-minibuffer-completion

(setopt enable-recursive-minibuffers t)                ; Use the minibuffer whilst in the minibuffer
(setopt completion-cycle-threshold 1)                  ; TAB cycles candidates
(setopt completions-detailed t)                        ; Show annotations
(setopt tab-always-indent 'complete)                   ; When I hit TAB, try to complete, otherwise, indent
(setopt completion-styles '(basic initials substring)) ; Different styles to match input to candidates

(setopt completion-auto-help 'always)                  ; Open completion always; `lazy' another option
(setopt completions-max-height 20)                     ; This is arbitrary
(setopt completions-format 'one-column)
(setopt completions-group t)
(setopt completion-auto-select 'second-tab)            ; Much more eager
;(setopt completion-auto-select t)                     ; See `C-h v completion-auto-select' for more possible values

(keymap-set minibuffer-mode-map "TAB" 'minibuffer-complete) ; TAB acts more like how it does in the shell

;; For a fancier built-in completion option, try ido-mode,
;; icomplete-vertical, or fido-mode. See also the file extras/base.el

;(icomplete-vertical-mode)
;(fido-vertical-mode)
;(setopt icomplete-delay-completions-threshold 4000)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Interface enhancements/defaults
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setopt switch-to-buffer-obey-display-actions t)   ; Make switching buffers more consistent

;; Enable horizontal scrolling
(setopt mouse-wheel-tilt-scroll t)
(setopt mouse-wheel-flip-direction t)

;; Misc. UI tweaks
(blink-cursor-mode -1)                                ; Steady cursor

;; Ultra-scroll for smooth, fast scrolling
;; Disabled until emacs 31
;; (use-package ultra-scroll
;;   :ensure t
;;   :init
;;   (setq scroll-conservatively 3
;;         scroll-margin 0)
;;   :config
;;   (ultra-scroll-mode 1))

;; Display line numbers in programming mode
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(setopt display-line-numbers-width 3)           ; Set a minimum width

;; Nice line wrapping when working with text
(add-hook 'text-mode-hook 'visual-line-mode)

;; Modes to highlight the current line with
(let ((hl-line-hooks '(text-mode-hook prog-mode-hook)))
  (mapc (lambda (hook) (add-hook hook 'hl-line-mode)) hl-line-hooks))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Modeline + file tree
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Mode line information
(setopt line-number-mode t)                        ; Show current line in modeline
(setopt column-number-mode t)                      ; Show column as well

;; Dependency
(use-package nerd-icons
  :ensure t)

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config
  ;; Disable language icon
  (setq doom-modeline-major-mode-icon nil))

(use-package neotree
  :ensure t
  :bind
  ("s-b" . my/neotree-toggle-project-root)
  :config
  (defun my/neotree-toggle-project-root ()
    "Toggle neotree, changing root to project root if not already there."
    (interactive)
    (if (neo-global--window-exists-p)
        (neotree-hide)
      (if-let* ((project (project-current nil))
                (proj-root (project-root project)))
          (neotree-dir proj-root)
        (neo-global--open))))
  :custom
  (neo-theme 'nerd-icons)
  (neo-mode-line-type 'none)
  (neo-window-width 30)
  (neo-vc-integration nil)
  (neo-keymap-style 'concise)
  (neo-show-hidden-files t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Base extras
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package avy
  :ensure t
  :demand t
  :bind (("C-c j" . avy-goto-line)
         ("s-j"   . avy-goto-char-timer)))


;; Dependency (https://github.com/minad/vertico/discussions/669)
(use-package compat
  :ensure t)

;; Consult: Misc. enhanced commands
(use-package consult
  :ensure t
  :bind (
         ;; Drop-in replacements
         ("C-x b" . consult-buffer)     ; orig. switch-to-buffer
         ("M-y"   . consult-yank-pop)   ; orig. yank-pop
         ;; Searching
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)       ; Buffer search
         ("s-f"   . consult-line)       ; Common shortcut
         ("M-s L" . consult-line-multi) ; Multi-buffer search
         ("M-s o" . consult-outline)
         ;; Isearch integration
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)   ; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history) ; orig. isearch-edit-string
         ("M-s l" . consult-line)            ; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)      ; needed by consult-line to detect isearch
         )
  :config
  ;; Narrowing lets you restrict results to certain groups of candidates
  (setq consult-narrow-key "<"))

(use-package embark-consult
  :ensure t)

;; Embark: supercharged context-dependent menu
(use-package embark
  :ensure t
  :after embark-consult
  :bind (("C-." . embark-act)))        ; bind this to an easy key to hit

; Minibuffer and completion

;; Vertico: better vertical completion for minibuffer commands
(use-package vertico
  :ensure t
  :init
  ;; You'll want to make sure that e.g. fido-mode isn't enabled
  (vertico-mode))

(use-package vertico-directory
  :ensure nil
  :after vertico
  :bind (:map vertico-map
              ("M-DEL" . vertico-directory-delete-word)))

;; Marginalia: annotations for minibuffer
(use-package marginalia
  :ensure t
  :config
  (marginalia-mode))

;; Corfu: Popup completion-at-point
(use-package corfu
  :ensure t
  :init
  (global-corfu-mode)
  :bind
  (:map corfu-map
        ("SPC" . corfu-insert-separator)
        ("C-n" . corfu-next)
        ("C-p" . corfu-previous)))

;; Part of corfu
(use-package corfu-popupinfo
  :after corfu
  :ensure nil
  :hook (corfu-mode . corfu-popupinfo-mode)
  :custom
  (corfu-popupinfo-delay '(0.25 . 0.1))
  (corfu-popupinfo-hide nil)
  :config
  (corfu-popupinfo-mode))

;; Corfu icons
(use-package kind-icon
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

;; Fancy completion-at-point functions; there's too much in the cape package to
;; configure here; dive in when you're comfortable!
(use-package cape
  :ensure t
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

;; Orderless: powerful completion style
(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless)))

;; Modify search results en masse
(use-package wgrep
  :ensure t
  :config
  (setq wgrep-auto-save-buffer t))

(use-package deadgrep
  :ensure t)

;; VSCode-like multi-cursor on click
(use-package multiple-cursors
  :ensure t
  :bind
  (("C-S-c C-S-c" . mc/edit-lines)
   ("C->" . mc/mark-next-like-this)
   ("C-<" . mc/mark-previous-like-this)
   ("C-c C-<" . mc/mark-all-like-this)
   ("C-S-<mouse-1>" . mc/add-cursor-on-click)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Developer Tools
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package emacs
  :hook
  ;; Auto parenthesis matching
  ((prog-mode . electric-pair-mode)))

;; Common file types
;; Emacs ships with a lot of popular programming language modes. If it's not
;; built in, you're almost certain to find a mode for the language you're
;; looking for with a quick Internet search.

(use-package markdown-mode
  :ensure t
  :hook ((markdown-mode . visual-line-mode)))

(use-package groovy-mode
  :ensure t)

;; Tree-sitter - try to use tree-sitter for supported languages
(use-package treesit-auto
  :ensure t
  :config
  ;; Pick languages from `treesit-auto-recipe-list'. Run M-x `treesit-auto-install-all' once to install the required libs
  (setq treesit-auto-langs '(awk bash c c-sharp cpp css dockerfile gitcommit go gomod gowork html java javascript json lua make markdown perl php python ruby rust scala sql toml tsx typescript yaml))
  ;; Register tree-sitter modes in `auto-mode-alist'
  (treesit-auto-add-to-auto-mode-alist 'all))

(use-package project
  :bind
  ("s-p" . project-find-file)
  :custom
  (project-mode-line t))         ; show project name in modeline

;; Magit: best Git client to ever exist
(use-package transient
  :ensure (:fetcher github :repo "magit/transient"))

(use-package magit
  :ensure t
  :bind
  ("C-x g" . magit-status)
  ("C-c g" . magit-dispatch))

(use-package magit-gh
  :ensure t
  :after magit)

;; LSP
(use-package eglot
  ;; no :ensure t here because it's built-in

  ;; Configure hooks to automatically turn-on eglot for selected modes
  :hook
  ((python-base-mode . eglot-ensure))

  :custom
  (eglot-send-changes-idle-time 0.1)
  (eglot-extend-to-xref t)              ; activate Eglot in referenced non-project files
  (eglot-ignored-server-capabilities
   '(:inlayHintProvider))

  :config
  (fset #'jsonrpc--log-event #'ignore)  ; massive perf boost---don't log every event
  ;; Sometimes you need to tell Eglot where to find the language server
  (add-to-list 'eglot-server-programs
               '(python-base-mode . ("uvx" "--from" "rassumfrassum" "--with" "basedpyright,ruff" "rass" "basedruff"))))

;; grep-based xref
(use-package dumb-jump
  :ensure t
  :custom
  (dumb-jump-prefer-searcher 'rg)
  :config
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate))

;; GitHub helpers
(use-package git-link
  :ensure t
  :config
  (when-let ((gh-host (getenv "GH_HOST")))
    (add-to-list 'git-link-remote-alist
                 (list (regexp-quote gh-host) 'git-link-github))
    (add-to-list 'git-link-commit-remote-alist
                 (list (regexp-quote gh-host) 'git-link-commit-github))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Terminal
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package ghostel
  :ensure (:host github :repo "dakra/ghostel" :ref "main" :files (:defaults "etc"))
  :bind
  ("C-c t" . ghostel)
  ("C-x p t" . ghostel-project)
  :custom
  (ghostel-module-auto-install 'download)
  :config
  (add-to-list 'project-switch-commands '(ghostel-project "Terminal" "t")))

(use-package eat
  :ensure t
  :custom
  (eat-term-name "xterm-256color") ; https://codeberg.org/akib/emacs-eat/issues/119
  (eat-enable-yank-to-terminal t)
  (eat-kill-buffer-on-exit t)
  ; Do not inhibit modifiers+arrows
  (eat-semi-char-non-bound-keys
   '([?\C-x] [?\C-\\] [?\C-q] [?\C-g] [?\C-h] [?\e ?\C-c] [?\C-u]
     [?\e ?x] [?\e ?:] [?\e ?!] [?\e ?&])))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   LLMs
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package agent-shell
  :ensure t
  :defer t
  :config
  (setq agent-shell-cursor-acp-command '("cursor-agent" "acp"))
  (setq agent-shell-anthropic-claude-acp-command '("mise" "-C" "~" "x" "node" "npm:@agentclientprotocol/claude-agent-acp" "--" "claude-agent-acp"))
  (setq agent-shell-anthropic-claude-environment
        (agent-shell-make-environment-variables
         "CLAUDE_CODE_USE_BEDROCK" "1"
	 "AWS_REGION" "us-west-2"))
  (setq agent-shell-opencode-default-model-id "openrouter/minimax/minimax-m2.7"))

(use-package gptel
  :ensure t
  :config
  (setq gptel-backend
        (gptel-make-openai "OpenRouter"
          :host "openrouter.ai"
          :endpoint "/api/v1/chat/completions"
          :stream t
          :key (lambda () (exec-path-from-shell-copy-env "OPENROUTER_API_KEY"))
          :models '(z-ai/glm-5.1:exacto
                    qwen/qwen3.7-max
                    minimax/minimax-m2.7:exacto
                    moonshotai/kimi-k2.6:exacto
                    openai/gpt-oss-120b:exacto
                    openai/gpt-5.4-mini))))

(use-package gptel-agent
  :ensure t
  :config (gptel-agent-update))         ;Read files from agents directories
