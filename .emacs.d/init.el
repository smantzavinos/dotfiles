
(setq inhibit-startup-message t)

(tool-bar-mode -1)

;; Use visible bell
;; from: https://lupan.pl/dotemacs/
(setq visible-bell t)

;; Remap escape
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Truncate lines by default (wrap lines)
(set-default 'truncate-lines t)

(set-default-coding-systems 'utf-8)

;; Install straight.el
(defvar bootstrap-version)
(let ((bootstrap-file


       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Install use-package
(straight-use-package 'use-package)

;; Configure use-package to use straight.el by default
(use-package straight
             :custom (straight-use-package-by-default t))

;; Automatically install missing packages
(use-package el-patch
  :straight t)

;; Always install packages if they are missing
(require 'use-package-ensure)
(setq use-package-always-ensure t)

;; icon support (all the icons)
(use-package all-the-icons
  :if (display-graphic-p))

(set-face-attribute `default nil :font "Consolas NF")

;; File path utility library
(use-package f)

;; Treat all themes as safe
(setq custom-safe-themes t)

(load-theme 'tango-dark)

;; Set up modus theme
;; (use-package modus-themes)
;; (load-theme 'modus-vivendi)

(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-dracula t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  ;; (doom-themes-neotree-config)
  ;; or for treemacs users
  ;; (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  ;; (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

;; doom modeline
;; crashing on windows
;; (use-package doom-modeline
;;   :ensure t
;;   :init (doom-modeline-mode 1))

(use-package smart-mode-line
  :config
  (setq sml/no-confirm-load-theme t
        sml/theme 'respectful)
  (sml/setup))

;; which key
(use-package which-key)
(which-key-mode)

;; Better mouse scrolling
;; Note: this setting doesnt seem to be working.
;; Source: https://stackoverflow.com/questions/445873/how-can-i-make-emacs-mouse-scrolling-slower-and-smoother
(setq mouse-wheel-scroll-amount '(0.03))
(setq mouse-wheel-progressive-speed nil)
(setq ring-bell-function 'ignore)

;; Many settins from:
;; https://github.com/daviwil/dotfiles/blob/9776d65c4486f2fa08ec60a06e86ecb6d2c40085/Emacs.org#git

;; evil mode
(defun sm/evil-hook ()
  (dolist (mode '(custom-mode
                  eshell-mode
                  git-rebase-mode
                  erc-mode
                  circe-server-mode
                  circe-chat-mode
                  circe-query-mode
                  sauron-mode
                  term-mode))
  (add-to-list 'evil-emacs-state-modes mode)))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (setq evil-respect-visual-line-mode t)
  (setq evil-undo-system 'undo-tree)
  :config
  (add-hook 'evil-mode-hook 'sm/evil-hook)
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :init
  (setq evil-collection-company-use-tng nil)  ;; Is this a bug in evil-collection?
  :custom
  (evil-collection-outline-bind-tab-p nil)
  :config
  (delete 'lispy evil-collection-mode-list)
  (delete 'org-present evil-collection-mode-list)
  (evil-collection-init))

;; General
(use-package general
  :config
  (general-evil-setup t)

  (general-create-definer sm/leader-key-def
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (general-create-definer sm/ctrl-c-keys
    :prefix "C-c"))

(global-display-line-numbers-mode t)

;; tab management
(use-package hydra)

(defhydra hydra-tabs (global-map "<f3>")
  "tabs"
  ("c" tab-bar-new-tab "create")
  ("m" tab-next "next")
  ("n" tab-previous "previous")
  ("r" tab-bar-rename-tab "rename")
  ("d" tab-bar-close-tab "delete")
  ("q" nil "cancel"))

(sm/leader-key-def
  "t"   '(:ignore t :which-key "tab")
  "tc"  'hydra-tabs/tab-bar-new-tab
  "tm"  'hydra-tabs/tab-next
  "tn"  'hydra-tabs/tab-previous
  "tr"  'tab-bar-rename-tab)

(defhydra hydra-windows ()
  "windows"
  ("s" split-window-below "split")
  ("v" split-window-right "vsplit")
  ("j" evil-window-down "down")
  ("k" evil-window-up "up")
  ("l" evil-window-right "right")
  ("h" evil-window-left "left")
  ("d" evil-window-delete "delete")
  ("o" delete-other-windows "delete others")
  ("C-m" tab-next "next tab")
  ("C-n" tab-previous "previous tab")
  ("q" nil "cancel"))

(sm/leader-key-def
  "w"   'hydra-windows/body)

(defhydra hydra-zoom (global-map "<f2>")
  "zoom"
  ("g" text-scale-increase "in")
  ("l" text-scale-decrease "out"))

;; git
(use-package magit
  :bind ("C-M-;" . magit-status)
  :commands (magit-status magit-get-current-branch)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; handles ssh credentials (for magit) on windows (and maybe other platforms?)
(use-package ssh-agency)

(sm/leader-key-def
  "g"   '(:ignore t :which-key "git")
  "gs"  'magit-status
  "gd"  'magit-diff-unstaged
  "gc"  'magit-branch-or-checkout
  "gl"   '(:ignore t :which-key "log")
  "glc" 'magit-log-current
  "glf" 'magit-log-buffer-file
  "gb"  'magit-branch
  "gP"  'magit-push-current
  "gp"  'magit-pull-branch
  "gf"  'magit-fetch
  "gF"  'magit-fetch-all
  "gr"  'magit-rebase)

(sm/leader-key-def
  "b"   '(:ignore t :which-key "buffers")
  "bb"  'counsel-switch-buffer
  "bd"  'kill-buffer)

(defun sm/find-file-in-directory (dir)
  "Interactively launch counsel-find-file in the given directory."
  (interactive)
  (cd dir)
  (counsel-find-file))

(sm/leader-key-def
  "f"   '(:ignore t :which-key "files")
  "fd"  (lambda () (interactive) (find-file user-init-file))
  "fn"  (lambda () (interactive) (sm/find-file-in-directory sm/notes-directory))
  "fp"  (lambda () (interactive) (sm/find-file-in-directory (f-join sm/notes-directory "1_projects")))
  "fa"  (lambda () (interactive) (sm/find-file-in-directory (f-join sm/notes-directory "2_areas")))
  "fr"  (lambda () (interactive) (sm/find-file-in-directory (f-join sm/notes-directory "3_resources")))
  "ft"  (lambda () (interactive) (sm/find-file-in-directory (f-join sm/notes-directory "4_archive")))
  "ff"  'counsel-find-file)

(sm/leader-key-def
  "o"   '(:ignore t :which-key "org")
  "oa"  'org-agenda)

(use-package evil-commentary)
(evil-commentary-mode)

(use-package git-gutter)
(global-git-gutter-mode +1)

;; projectile
(defun sm/switch-project-action ()
  "Switch to a workspace with the project name and start `magit-status'."
  ;; TODO: Switch to EXWM workspace 1?
  (persp-switch (projectile-project-name))
  (magit-status))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :demand t
  :bind ("C-M-p" . projectile-find-file)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/Projects/Code")
    (setq projectile-project-search-path '("~/Projects/Code")))
  (setq projectile-switch-project-action #'sm/switch-project-action))

(use-package counsel-projectile
  :straight t
  :after projectile
  :config
  (counsel-projectile-mode))

(sm/leader-key-def
  "pf"  'projectile-find-file
  "ps"  'projectile-switch-project
  "pF"  'consult-ripgrep
  "pp"  'projectile-find-file
  "pc"  'projectile-compile-project
  "pd"  'projectile-dired)

(use-package undo-tree
  :init
  (global-undo-tree-mode 1))

;; ivy
(use-package counsel)


(use-package prescient)
(use-package ivy-prescient
    :straight t
    :config
    (ivy-prescient-mode 1))

;; (straight-use-package 'company-prescient)
    ;; :config
    ;; (company-prescient-mode 1))
;; (straight-use-package 'selectrum-prescient
;; 		      :config
;; 		      (selectrum-prescient-mode 1))

;; Ivy-based interface to standard commands
(global-set-key (kbd "C-s") 'swiper-isearch)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "M-y") 'counsel-yank-pop)
(global-set-key (kbd "<f1> f") 'counsel-describe-function)
(global-set-key (kbd "<f1> v") 'counsel-describe-variable)
(global-set-key (kbd "<f1> l") 'counsel-find-library)
(global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
(global-set-key (kbd "<f2> u") 'counsel-unicode-char)
(global-set-key (kbd "<f2> j") 'counsel-set-variable)
(global-set-key (kbd "C-x b") 'ivy-switch-buffer)
(global-set-key (kbd "C-c v") 'ivy-push-view)
(global-set-key (kbd "C-c V") 'ivy-pop-view)

;; Ivy-based interface to shell and system tools
(global-set-key (kbd "C-c c") 'counsel-compile)
(global-set-key (kbd "C-c g") 'counsel-git)
(global-set-key (kbd "C-c j") 'counsel-git-grep)
(global-set-key (kbd "C-c L") 'counsel-git-log)
(global-set-key (kbd "C-c k") 'counsel-rg)
(global-set-key (kbd "C-c m") 'counsel-linux-app)
(global-set-key (kbd "C-c n") 'counsel-fzf)
(global-set-key (kbd "C-x l") 'counsel-locate)
(global-set-key (kbd "C-c J") 'counsel-file-jump)
(global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
(global-set-key (kbd "C-c w") 'counsel-wmctrl)

;; Ivy-resume and other commands
(global-set-key (kbd "C-c C-r") 'ivy-resume)
(global-set-key (kbd "C-c b") 'counsel-bookmark)
(global-set-key (kbd "C-c d") 'counsel-descbinds)
(global-set-key (kbd "C-c g") 'counsel-git)
(global-set-key (kbd "C-c o") 'counsel-outline)
(global-set-key (kbd "C-c t") 'counsel-load-theme)
(global-set-key (kbd "C-c F") 'counsel-org-file)

;; from: https://lupan.pl/dotemacs/
(use-package smartparens
  :hook ((prog-mode . smartparens-mode)
         (emacs-lisp-mode . smartparens-strict-mode))
  :init
  (setq sp-base-key-bindings 'sp)
  :config
  (define-key smartparens-mode-map [M-backspace] #'backward-kill-word)
  (define-key smartparens-mode-map [M-S-backspace] #'sp-backward-unwrap-sexp)
  (require 'smartparens-config))

;; multiple cursors package
(use-package multiple-cursors
  :bind (("C-c n" . mc/mark-next-like-this)
         ("C-c p" . mc/mark-previous-like-this)))

;; Fix trailing spaces but only in modified lines
(use-package ws-butler
  :hook (prog-mode . ws-butler-mode))

;; company mode
;; from: https://lupan.pl/dotemacs/
(use-package company
  :bind (:map prog-mode-map
         ("C-i" . company-indent-or-complete-common)
         ("C-M-i" . counsel-company))
  :hook (emacs-lisp-mode . company-mode))

;; enable company mode in all buffers
(add-hook 'after-init-hook 'global-company-mode)

(use-package company-prescient
  :after company
  :config
  (company-prescient-mode))

;; lsp-mode
;; from: https://lupan.pl/dotemacs/
(use-package lsp-mode
  :hook ((c-mode c++-mode d-mode go-mode js-mode kotlin-mode python-mode typescript-mode
          vala-mode web-mode)
         . lsp)
  :init
  (setq lsp-keymap-prefix "H-l"
        lsp-rust-analyzer-proc-macro-enable t)
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :init
  (setq lsp-ui-doc-position 'at-point
        lsp-ui-doc-show-with-mouse nil)
  :bind (("C-c d" . lsp-ui-doc-show)
         ("C-c I" . lsp-ui-imenu)))

(use-package flycheck
  :defer)

;; C++ dev. lsp.
;; from: https://lupan.pl/dotemacs/
;; (use-package cc-mode
;;   :bind (:map c-mode-map
;;          ("C-i" . company-indent-or-complete-common)
;;          :map c++-mode-map
;;          ("C-i" . company-indent-or-complete-common))
;;   :init
;;   (setq-default c-basic-offset 8))

;; web mode
;; from: https://lupan.pl/dotemacs/
(use-package web-mode
  :mode "\\.\\([jt]sx\\)\\'")

;; (use-package js
;;   :bind (:map js-mode-map
;;          ([remap js-find-symbol] . xref-find-definitions))
;;   :init
;;   (setq js-indent-level 4))

(use-package typescript-mode
  :defer)

;; yas-snippet
;; from: https://lupan.pl/dotemacs/
(setq-default abbrev-mode 1)
(use-package yasnippet
  :defer 2
  :config
  (yas-global-mode 1))
(use-package yasnippet-snippets
  :defer)
(use-package ivy-yasnippet
  :bind ("C-c y" . ivy-yasnippet))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(projectile general magit which-key use-package undo-tree evil-collection counsel all-the-icons)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(use-package excorporate)

;; Treemacs setup
(use-package treemacs
  :straight t
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay        0.5
          treemacs-directory-name-transformer      #'identity
          treemacs-display-in-side-window          t
          treemacs-eldoc-display                   'simple
          treemacs-file-event-delay                5000
          treemacs-file-extension-regex            treemacs-last-period-regex-value
          treemacs-file-follow-delay               0.2
          treemacs-file-name-transformer           #'identity
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-find-workspace-method           'find-for-file-or-pick-first
          treemacs-git-command-pipe                ""
          treemacs-goto-tag-strategy               'refetch-index
          treemacs-header-scroll-indicators        '(nil . "^^^^^^")
          treemacs-hide-dot-git-directory          t
          treemacs-indentation                     2
          treemacs-indentation-string              " "
          treemacs-is-never-other-window           nil
          treemacs-max-git-entries                 5000
          treemacs-missing-project-action          'ask
          treemacs-move-forward-on-expand          nil
          treemacs-no-png-images                   nil
          treemacs-no-delete-other-windows         t
          treemacs-project-follow-cleanup          nil
          treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                        'left
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-silent-filewatch                nil
          treemacs-silent-refresh                  nil
          treemacs-sorting                         'alphabetic-asc
          treemacs-select-when-already-in-treemacs 'move-back
          treemacs-space-between-root-nodes        t
          treemacs-tag-follow-cleanup              t
          treemacs-tag-follow-delay                1.5
          treemacs-text-scale                      nil
          treemacs-user-mode-line-format           nil
          treemacs-user-header-line-format         nil
          treemacs-wide-toggle-width               70
          treemacs-width                           35
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (when treemacs-python-executable
      (treemacs-git-commit-diff-mode t))

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-evil
  :straight t
  :after (treemacs evil)
  :ensure t)

(use-package treemacs-projectile
  :straight t
  :after (treemacs projectile)
  :ensure t)

(use-package treemacs-icons-dired
  :straight t
  :hook (dired-mode . treemacs-icons-dired-enable-once)
  :ensure t)

(use-package treemacs-magit
  :straight t
  :after (treemacs magit)
  :ensure t)

(use-package treemacs-persp ;;treemacs-perspective if you use perspective.el vs. persp-mode
  :straight t
  :after (treemacs persp-mode) ;;or perspective vs. persp-mode
  :ensure t
  :config (treemacs-set-scope-type 'Perspectives))

(use-package treemacs-tab-bar ;;treemacs-tab-bar if you use tab-bar-mode
  :straight t
  :after (treemacs)
  :ensure t
  :config (treemacs-set-scope-type 'Tabs))

(use-package dap-mode
  :straight t
  :config
  (require 'dap-cpptools))

