;; Following code taken and modified from:
;; https://emacs.stackexchange.com/questions/12881/how-do-i-set-a-different-location-for-the-dot-emacs-emacs-file-on-windows-7

;; Place this file in C:\Users\Username\AppData\Roaming and point to the appropriate files
(setenv "HOME" "C:/path/to/home/dir")

(defvar sm/notes-directory "c:/path/to/notes"
  "Root directory of PARA style notes.")

(setq user-emacs-directory (concat (getenv "HOME") "/dotfiles/.emacs.d"))
(setq user-init-file (concat (getenv "HOME") "/dotfiles/.emacs.d/init.el"))
(setq user-config-file (concat (getenv "HOME") "/dotfiles/.emacs.d/config.org"))
(setq default-directory (getenv "HOME"))

(load user-init-file)
