
;; Install use-package
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

;; Always install packages if they are missing
(require 'use-package-ensure)
(setq use-package-always-ensure t)

;; Remap escape
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(setq inhibit-startup-message t)

;; Use visible bell
;; from: https://lupan.pl/dotemacs/
(setq visible-bell t)

;; icon support (all the icons)
(use-package all-the-icons
  :if (display-graphic-p))

(set-face-attribute `default nil :font "Consolas NF")

(load-theme 'tango-dark)

;; Set up modus theme
(use-package modus-themes)
(load-theme 'modus-vivendi)

(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-ayu-mirage t)

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

;; (defhydra hydra-tabs (global-map "<f3>")
;;   "tabs"
;;   ("c" tab-bar-new-tab "create")
;;   ("m" tab-next "next")
;;   ("n" tab-previous) "previous"))

;; (sm/leader-key-def
;;   "t"   '(:ignore t :which-key "tab")
;;   "tc"  'hydra-tabs/tab-bar-new-tab
;;   "tm"  'tab-next
;;   "tn"  'tab-previous)

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
  :disabled
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

(use-package undo-tree
  :init
  (global-undo-tree-mode 1))

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

;; ivy
(use-package counsel)

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
(use-package cc-mode
  :bind (:map c-mode-map
         ("C-i" . company-indent-or-complete-common)
         :map c++-mode-map
         ("C-i" . company-indent-or-complete-common))
  :init
  (setq-default c-basic-offset 8))

;; web mode
;; from: https://lupan.pl/dotemacs/
(use-package web-mode
  :mode "\\.\\([jt]sx\\)\\'")

(use-package js
  :bind (:map js-mode-map
         ([remap js-find-symbol] . xref-find-definitions))
  :init
  (setq js-indent-level 4))

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
