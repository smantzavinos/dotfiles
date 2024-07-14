;; Following code taken and modified from:
;; https://emacs.stackexchange.com/questions/12881/how-do-i-set-a-different-location-for-the-dot-emacs-emacs-file-on-windows-7

;; Place this file in C:\Users\Username\AppData\Roaming and point to the appropriate files
;; (setenv "HOME" "C:/path/to/home/dir")
(setenv "HOME" "/home/spiros")

;; (defvar sm/notes-directory "c:/path/to/notes"
(defvar sm/notes-directory "/home/spiros/notes"
  "Root directory of PARA style notes.")

(setq user-emacs-directory (concat (getenv "HOME") "/dotfiles/.emacs.d"))
(setq user-init-file (concat (getenv "HOME") "/dotfiles/.emacs.d/init.el"))
(setq user-config-file (concat (getenv "HOME") "/dotfiles/.emacs.d/config.org"))
(setq default-directory (getenv "HOME"))

;; Set the default font size.
;; Units are 1/10th of a point.
;; Set to 120 for font size of 12.
(setq my-default-font-size 120)

;; Set path to plantuml.jar file to render plantuml source blocks.
;; If installed with chocolatey on Windows, the following line is likely correct
;; (setq org-plantuml-jar-path "C:/ProgramData/chocolatey/lib/plantuml/tools/plantuml.jar")

(load user-init-file)
