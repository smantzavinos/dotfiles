;; Following code taken and modified from:
;; https://emacs.stackexchange.com/questions/12881/how-do-i-set-a-different-location-for-the-dot-emacs-emacs-file-on-windows-7

;; Place this file in C:\Users\Username\AppData\Roaming and point to the appropriate files
(setenv "HOME" "C:/path/to/home/dir")
(setenv "ORG_ROOT" "C:/path/to/notes/org")

(setq user-emacs-directory (concat (getenv "HOME") "/dotfiles/.emacs.d"))
(setq user-init-file (concat (getenv "HOME") "/dotfiles/.emacs.d/init.el"))
(setq default-directory (getenv "HOME"))

;; Directory to look for org files in to add to agenda
(setq org-agenda-files (directory-files-recursively (concat (getenv "ORG_ROOT") "/tasks") "\\.org$"))

(load user-init-file)
