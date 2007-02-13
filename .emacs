;;set the elisp to load-path
(add-to-list 'load-path "~/elisp")

;;close the error bell sound 
;;(setq visible-bell t)

;;make smoothly scroll
(setq scroll-margin 3
      scroll-conservatively 10000)

;;set the default major mode is text-mode
(setq default-major-mode 'text-mode)

;;show match parentheses with color
(show-paren-mode t)
(setq show-paren-style 'parentheses)

;;set frame title format
(setq frame-title-format "emacs@%b")

;;let emacs to open image file directly
;;(auto-image-file-mode)

;;use hippie-expand as the completion method
(global-set-key [(meta ?/)] 'hippie-expand)
(setq hippie-expand-try-functions-list
      '(try-expand-dabbrev
	try-expand-dabbrev-visible
	try-expand-dabbrev-all-buffers
	try-expand-dabbrev-from-kill
	try-complete-file-name-partially
	try-complete-file-name
	try-expand-all-abbrevs
	try-expand-list
	try-expand-line
	try-complete-lisp-symbol-partially
	try-complete-lisp-symbol))


;;use tabbar
;;comment off because this plugin eat too many memory
;;(require 'tabbar)
;;(tabbar-mode)

;;use desktop plugin
(load "desktop")
(desktop-load-default)
(desktop-read)

;;use ido to find file and switch buffers
(require 'ido)
(ido-mode t)

;;use color theme
(require 'color-theme)
(load-file "~/elisp/my-color-theme.el")
(my-color-theme)

;;(setq viper-mode t)
;;(require 'viper)


;;use session plugin
(require 'session)
(add-hook 'after-init-hook 'session-intialize)

;; use transient-mode
;;(transient-mark-mode)

;;
(require 'browse-kill-ring)
(global-set-key [(control c)(k)] 'browse-kill-ring)
(browse-kill-ring-default-keybindings)

;;config emacs to recursely load files
;; come from www.emacswiki.org/cgi-bin/wiki/LoadPath 
(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
	(let* ((my-lisp-dir "~/elisp/")
		  (default-directory my-lisp-dir))
		(setq load-path (cons my-lisp-dir load-path))
		(normal-top-level-add-subdirs-to-load-path)))

;;enable syntax highlight
(global-font-lock-mode t)

;; setting about pythom mode
(autoload 'python-mode "python-mode" "Python Mode." t)
(add-to-list 'auto-mode-alist '("\\.py\\'" . python-mode))
(add-to-list 'interpreter-mode-alist '("python" . python-mode))

 (add-hook 'python-mode-hook
		   (lambda ()
			 (set (make-variable-buffer-local 'beginning-of-defun-function)
			      'py-beginning-of-def-or-class)
			 (setq outline-regexp "def\\|class ")))

(require 'ibuffer)
(global-set-key (kbd "C-x C-b") 'ibuffer)

;; setting for cygwin path convert
;;(setenv "PATH" (concat "c:/cygwin/bin;" (getenv "PATH")))
;;(setq exec-path (cons "c:/cygwin/bin/" exec-path))
;;(require 'cygwin-mount)
;;(cygwin-mount-activate)

;; setting use cygwin bash replace dos as the default shell
(add-hook 'comint-output-filter-functions
    'shell-strip-ctrl-m nil t)
(add-hook 'comint-output-filter-functions
    'comint-watch-for-password-prompt nil t)
(setq explicit-shell-file-name "bash.exe")
;; For subprocesses invoked via the shell
;; (e.g., "shell -c command")
(setq shell-file-name explicit-shell-file-name)

(add-hook 'dired-load-hook
	  (function (lambda()
		      (load "dired-x"))))


(custom-set-variables
  ;; custom-set-variables was added by Custom -- don't edit or cut/paste it!
  ;; Your init file should contain only one such instance.
 '(global-hl-line-mode t nil (hl-line))
 '(viper-want-emacs-keys-in-insert t))
(custom-set-faces
  ;; custom-set-faces was added by Custom -- don't edit or cut/paste it!
  ;; Your init file should contain only one such instance.
 )
