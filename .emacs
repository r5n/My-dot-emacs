; Time-stamp: <2012-04-19 02:57:40 (rolando)>
;;(set-scroll-bar-mode 'right)
(tool-bar-mode 0)
(scroll-bar-mode 0)
(menu-bar-mode 0)


;; TODO: Arranjar uma keybind para find-function (podera funcionar melhor que as tags)


;; Load CEDET.
;; See cedet/common/cedet.info for configuration details.
;; IMPORTANT: For Emacs >= 23.2, you must place this *before* any
;; CEDET component (including EIEIO) gets activated by another 
;; package (Gnus, auth-source, ...).
;; (load-file "~/.emacs.d/elisp/cedet/common/cedet.el")

;; Enable EDE (Project Management) features
;; (global-ede-mode 1)

;; Enable EDE for a pre-existing C++ project
;(ede-cpp-root-project "buntoids" :file "~/src/git/buntoids/source/Makefile")


;; Enabling Semantic (code-parsing, smart completion) features
;; Select one of the following:

;; * This enables the database and idle reparse engines
;(semantic-load-enable-minimum-features)

;; * This enables some tools useful for coding, such as summary mode
;;   imenu support, and the semantic navigator
;(semantic-load-enable-code-helpers)

;; * This enables even more coding tools such as intellisense mode
;;   decoration mode, and stickyfunc mode (plus regular code helpers)
;(semantic-load-enable-gaudy-code-helpers)

;; * This enables the use of Exuberent ctags if you have it installed.
;;   If you use C++ templates or boost, you should NOT enable it.
;; (semantic-load-enable-all-exuberent-ctags-support)
;;   Or, use one of these two types of support.
;;   Add support for new languges only via ctags.
;; (semantic-load-enable-primary-exuberent-ctags-support)
;;   Add support for using ctags as a backup parser.
;; (semantic-load-enable-secondary-exuberent-ctags-support)

;; Enable SRecode (Template management) minor-mode.
;; (global-srecode-minor-mode 1)




(defvar *emacs-load-start* (current-time))


;; FIXME: c-annotation-face has a bad color
(when window-system
  (load-theme 'wombat))


;; Experimentar usar a variavel default-directory ou user-emacs-directory

(defun where-am-i ()
  "If it returns t, then I am on the laptop, otherwise I am on the desktop."
  (let ((LAPTOP-HOSTNAME "rolando-laptop")
          (DESKTOP-HOSTNAME "rolando-K8NF4G-VSTA"))
    (cond ((string= system-name LAPTOP-HOSTNAME)
            'laptop)
      ((string= system-name DESKTOP-HOSTNAME)
        'desktop)
      (t
        'undefined))))

(defun running-on-laptop-p ()
  (equal (where-am-i) 'laptop))

(defun running-on-desktop-p ()
  (equal (where-am-i) 'desktop))

(defun running-on-undefined-p ()
  (equal (where-am-i) 'undefined))


(defun running-linux-p ()
  (equal system-type 'gnu/linux))

(defun running-windows-p ()
  (equal system-type 'windows-nt))

;; (defconst +dot-emacs-whereami+ (Where-Am-i)
;;   "If 'laptop, then we are on the laptop and in the linux system.
;; If 'desktop, then we are on the desktop system and in the linux system.
;; If 'undefined, then we don't know where we are.")

(require 'server)

(when (and (running-linux-p)
        (not (server-running-p)))
  (server-start))

    

;; Idea from http://nflath.com/2009/07/more-random-emacs-config/
(defun rolando-back-to-indentation-or-move-beginning-of-line ()
  "Moves to the first caracter in the line, unless it's in it, in that case
it moves the cursor to the beginning-of-line"
  (interactive)
  (let ((current-point (point)))
    (back-to-indentation)
    (if (= current-point (point))
      (move-beginning-of-line nil))))

(global-set-key (kbd "C-a") 'rolando-back-to-indentation-or-move-beginning-of-line)
(global-set-key (kbd "<home>") 'rolando-back-to-indentation-or-move-beginning-of-line)



(defun set-home-folder ()
  (cond ((and (running-on-laptop-p) (not (running-windows-p)))
          ;"/media/JCARLOS/")
         "/home/rolando/")
    ((running-windows-p)
      (substring default-directory 0 -9))
    ((running-on-desktop-p)
      "/home/rolando/")))

;(message (file-name-directory load-file-name))

(defconst +dot-emacs-home+ (concat (set-home-folder) ".emacs.d/"))
;(defconst home (file-name-directory load-file-name))

(defun file-in-exec-path-p (filename)
  "Returns t if FILENAME is in the system exec-path, otherwise returns nil"
  (if (executable-find filename)
    t
    nil))




;; E necessario muitas vezes
(with-no-warnings 
  (require 'cl))

;; Load Emacs Code Browser
;; (add-to-list 'load-path (concat +dot-emacs-home+ ".emacs.d/elisp/ecb-snap"))
;; (require 'ecb)


(setq eldoc-idle-delay 0)

(setq visible-bell t)

(add-to-list 'load-path (concat +dot-emacs-home+ "elisp"))
(add-to-list 'load-path (concat +dot-emacs-home+ "elpa"))
(add-to-list 'load-path (concat +dot-emacs-home+ "elisp/use-package"))


;; Activate packages installed using package.el
(load "package")
(package-initialize)

(require 'use-package)

(use-package usage-memo
	     :init (umemo-initialize))


;; Check to see if the pydb emacs package is installed
(when (file-directory-p "/user/share/emacs/site-lisp/pydb")
  (setq load-path (append '("/usr/share/emacs/site-lisp/pydb") load-path)))

(setq c-default-style "bsd")

(message "Stop 1 %ds" (destructuring-bind (hi lo ms &rest ignore) (current-time)
                           (- (+ hi lo) (+ (first *emacs-load-start*) (second *emacs-load-start*)))))



(setq require-final-newline t)                ; Always newline at end of file

;; Mostrar os espacos vazios no final das linhas
;; FIXME: This should only be on the programming mode
(setq show-trailing-whitespace t)

(when window-system
  (global-unset-key "\C-z"))            ; iconify-or-deiconify-frame (C-x C-z)

(setq-default ispell-program-name "aspell") ; Use aspell instead of ispell
(setq ispell-dictionary "pt_PT")             ; Set ispell dictionary

(setq frame-title-format "%b - emacs")
; Tabs expand to 4 spaces
(setq-default c-basic-offset 4
  tab-width 4
  indent-tabs-mode nil)
(setq backward-delete-char-untabify nil
  tab-width 4)
;;;

;; SVN browser
(use-package psvn
  :commands svn-status)


;; Some modes require this
(setq user-mail-address "finalyugi@sapo.pt"
  user-full-name "Rolando Pereira")
;;;

; Activar Org-Mode
(setq load-path (cons (concat +dot-emacs-home+ "elisp/org-mode/lisp") load-path))
(setq load-path (cons (concat +dot-emacs-home+ "elisp/org-mode/contrib/lisp") load-path))
;;;;;

; Mostra so a * mais a direita no org-mode
(setq org-hide-leading-stars t)
;;;

;; The following lines are always needed. Choose your own keys.
;; (Configuracoes do Org-Mode)
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)
;;;;;

;; Activar flymake-mode para o python usando o pyflakes
(when (and (load "flymake" t) (file-in-exec-path-p "pyflakes"))
  (defun flymake-pyflakes-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                        'flymake-create-temp-inplace))
            (local-file (file-relative-name
                          temp-file
                          (file-name-directory buffer-file-name))))
      (list "pyflakes" (list local-file))))

   (add-to-list 'flymake-allowed-file-name-masks
     '("\\.py\\'" flymake-pyflakes-init)))

;; FIXME: flymake-find-file-hook should be used only if there is a makefile
;(add-hook 'find-file-hook 'flymake-find-file-hook)
;;;

; Flymake settings
(defun my-flymake-show-next-error()
  (interactive)
  (flymake-goto-next-error)
  (flymake-display-err-menu-for-current-line))

(global-set-key [f8] 'my-flymake-show-next-error)
;; '(flymake-errline ((((class color)) (:underline "OrangeRed"))))
;; '(flymake-warnline ((((class color)) (:underline "yellow"))))


; Activar folding no Python
(defun my-python-mode-hook ()
  (hs-minor-mode 1)
  (eldoc-mode 1)
  '(lambda ()
     (local-set-key (kbd "RET") 'newline-and-indent)))

(add-hook 'python-mode-hook 'my-python-mode-hook)

;; C/C++/Java/C# Mode
(defun my-c-mode-common-hook ()
  (setq show-paren-style 'parenthesis)
  ;(setq c-hungry-delete-key t)
  ;(setq c-auto-newline 1)
  (highlight-fixmes-mode)
  (hs-minor-mode)
;  (lambda ()
 ;   (font-lock-add-keywords nil
  ;    '(("\\<\\(FIXME\\|TODO\\|BUG\\):" 1 font-lock-warning-face t))))
  ;(flymake-mode t)
  ;(yas/minor-mode)

  ;; Show line numbers
  (linum-mode)
  )

(message "Stop 2 %ds" (destructuring-bind (hi lo ms &rest ignore) (current-time)
                           (- (+ hi lo) (+ (first *emacs-load-start*) (second *emacs-load-start*)))))





(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

; Mudar a theme do emacs
;; (when window-system
;;   (require 'color-theme)
;;   ;(require 'color-theme-tango)
;;   (require 'zenburn)
;;   (require 'color-theme-dark-bliss)
;;   ;(require 'color-theme-sunburst)
;;   (color-theme-initialize)
;;   ;(color-theme-charcoal-black))
;;   ;(color-theme-taming-mr-arneson))
;; ;  (color-theme-goldenrod)
;;   ;(color-theme-tango))
;;   ;(color-theme-zenburn))
;;   ;(color-theme-sunburst))
;;   ;(color-theme-taylor))
;;                                         ;(color-theme-dark-bliss)
;;   (color-theme-midnight))
;;   ;(require 'color-theme-twilight)
;;   ;; (color-theme-twilight))
;; ; Other themes: midnight, white on black, charcoal black, Calm Forest, Billw,
;; ; Arjen, Clarity and Beauty, Cooper Dark, Comidia, Dark Blue 2, Dark Laptop,
;; ; Deep Blue, Hober, Late Night, Lethe, Linh Dang Dark, Taming Mr Arneson,
;; ; Subtle Hacker, TTY Dark, Taylor,  White On Black, Robin Hood
;; ;;;

; Add colors to shell
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
;;

;; zooming in and zooming out in emacs like in firefox
;; zooming; inspired by http://blog.febuiles.com/page/2/
(defun djcb-zoom (n) (interactive)
  (set-face-attribute 'default (selected-frame) :height
    (+ (face-attribute 'default :height) (* (if (> n 0) 1 -1) 10))))

(global-set-key (kbd "C-+")      '(lambda()(interactive(djcb-zoom 1))))
(global-set-key [C-kp-add]       '(lambda()(interactive(djcb-zoom 1))))
(global-set-key (kbd "C--")      '(lambda()(interactive(djcb-zoom -1))))
(global-set-key [C-kp-subtract]  '(lambda()(interactive(djcb-zoom -1))))

(global-set-key [(control tab)] 'ffap)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; time-stamps
;; when there is a "Time-stamp: <>" in the first 10 lines of the file,
;; emacs will write time-stamp information there when saving the file.
;; see the top of this file for an example...
(setq
  time-stamp-active t          ; do enable time-stamps
  time-stamp-line-limit 10     ; check first 10 buffer lines for Time-stamp: <>
  time-stamp-format "%04y-%02m-%02d %02H:%02M:%02S (%u)") ; date format
(add-hook 'write-file-hooks 'time-stamp) ; update when saving
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; turn on autofill for all text-related modes
(toggle-text-mode-auto-fill)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Elisp

(defun djcb-emacs-lisp-mode-hook ()
  (interactive)

  ;; overrides the global f7 for compilation
  (local-set-key (kbd "<f7>") 'eval-buffer)

  (set-input-method nil)       ; i don't want accented chars, funny "a etc.
  (setq lisp-indent-offset 2)  ; indent with two spaces, enough for lisp

  (font-lock-add-keywords nil
    '(("\\<\\(FIXME\\|TODO\\|XXX+\\|BUG\\):"
        1 font-lock-warning-face prepend)))

  (font-lock-add-keywords nil
    '(("\\<\\(require-maybe\\|add-hook\\|setq\\)"
        1 font-lock-keyword-face prepend)))

  (font-lock-add-keywords nil
    '(("\\<use-package" . font-lock-keyword-face)))
  ;; (font-lock-add-keywords nil
  ;;   '(("\\<use-package \\([[:word:]]*\\)" 1
  ;;       font-lock-constant-face)))

  (show-paren-mode 1)
  (setq show-paren-style 'expression)
  (eldoc-mode 1))

(add-hook 'emacs-lisp-mode-hook 'djcb-emacs-lisp-mode-hook)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




(message "Stop 3 %ds" (destructuring-bind (hi lo ms &rest ignore) (current-time)
                           (- (+ hi lo) (+ (first *emacs-load-start*) (second *emacs-load-start*)))))






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; backups  (emacs will write backups and number them)
(setq make-backup-files t ; do make backups
  backup-by-copying t ; and copy them ...
  backup-directory-alist '(("." . "~/.emacs.d/backup/")) ; ... here
  version-control t
  kept-new-versions 2
  kept-old-versions 5
  delete-old-versions t)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Activar winner
(winner-mode 1)
;;;

; Colocar o text-mode como default ao abrir um ficheiro e fazer com que o o
; texto so tenha 78 caracteres de largura
(setq-default major-mode 'text-mode)
(setq fill-column 78)
(auto-fill-mode t)
(add-hook 'text-mode-hook 'turn-on-auto-fill)
;;;

; Indicar o tamanho do ficheiro
(size-indication-mode t)
;;;

;; W3m configurations


(use-package w3m
  :load-path "elisp/emacs-w3m"
  :commands (w3m w3m-browse-url)
  :if (not (running-windows-p))
  :config (progn
            (setq browse-url-browser-function (lambda (url ignore)
                                                (w3m-browse-url url t)))

            (setq w3m-use-cookies t)

            ;; Mudar keybinding
            (define-key w3m-mode-map "q" 'w3m-previous-buffer)
            (define-key w3m-mode-map "w" 'w3m-next-buffer)
            (define-key w3m-mode-map "x" 'w3m-delete-buffer)

            ;; Gravar sessions
            ;; (cond ((= emacs-major-version 22)
            (use-package w3m-session
              :init (progn
                      (setq w3m-session-file "~/.emacs.d/w3m-session")
                      (setq w3m-session-save-always t)
                      (setq w3m-session-load-always t)
                      (setq w3m-session-autosave-period 30)
                      (setq w3m-session-duplicate-tabs 'always)
                      ;; Load last sessions
                      (setq w3m-session-load-last-sessions t)))

            ;; Utitilizar numeros para saltar para links
            ;; http://emacs.wordpress.com/2008/04/12/numbered-links-in-emacs-w3m/
            (use-package w3m-lnum)

            (defun jao-w3m-go-to-linknum ()
              "Turn on link numbers and ask for one to go to."
              (interactive)
              (let ((active w3m-link-numbering-mode))
                (when (not active) (w3m-link-numbering-mode))
                (unwind-protect
                  (w3m-move-numbered-anchor (read-number "Anchor number: "))
                  (when (not active) (w3m-link-numbering-mode)))))

            (define-key w3m-mode-map "f" 'jao-w3m-go-to-linknum)

            ;; Use "M" to open a link in the external browser

            ;; Use sessions on w3m (from Emacs Wiki)


            (define-key w3m-mode-map "S" 'w3m-session-save)
            (define-key w3m-mode-map "L" 'w3m-session-load)
            (define-key w3m-mode-map (kbd "C-j") 'w3m-search-new-session)

            ;; Download youtube video at point
            (defun w3m-yt-view ()
              "View a YouTube link with mplayer."
              (interactive)
              (let ((url (or (w3m-anchor) (w3m-image))))
                (cond ((string-match "youtube" url)
                        (string-match "[^v]*v.\\([^&]*\\)" url)
                        (let* ((vid (match-string 1 url))
                                (info (with-temp-buffer
                                        (w3m-retrieve
                                          (format "http://www.youtube.com/get_video_info?video_id=%s"
                                            vid))
                                        (buffer-string))))
                          (string-match "&token=\\([^%]*\\)" info)
                          (let ((vurl (format "http://www.youtube.com/get_video?video_id=%s&t=%s=&fmt=18"
                                        vid
                                        (match-string 1 info))))
                            (start-process "mplayer" nil "mplayer" "-quiet" "-cache" " 8192"
                              (nth 5 (w3m-attributes vurl))))))
                  (t
                    (message "Not yt URL.")))))
            ))

;; ;Activar o AUCTeX
(use-package latex
  :load-path "elpa/auctex-11.86/"
  :init (progn
          (setq TeX-save-query nil) ;;autosave before compiling
          (setq TeX-PDF-mode t)
          (setq TeX-auto-save t)
          (setq TeX-parse-self t)
          (setq-default TeX-master nil)
          (use-package latex-units)
          (use-package reftex
            :config (setq reftex-plug-into-AUCTeX t)
            :commands reftex-mode)
          (use-package preview
            :config (add-to-list 'preview-document-pt-list 8)))
  :config (progn
            (defun change-outline-keys ()
              (local-set-key (kbd "<M-up>") 'outline-move-subtree-up)
              (local-set-key (kbd "<M-down>") 'outline-move-subtree-down)
              ;; (local-set-key (kbd "C-d") 'outline-toggle-children)
              )

            (add-hook 'LaTeX-mode-hook 'change-outline-keys)
            (add-hook 'LaTeX-mode-hook 'outline-minor-mode)
            (add-hook 'LaTeX-mode-hook 'latex-math-mode)

            (add-hook 'LaTeX-mode-hook 'flyspell-mode)
            (setq outline-minor-mode-prefix "\C-c\C-o")
            (add-hook 'LaTeX-mode-hook 'reftex-mode)
            (add-hook 'LaTeX-mode-hook 'orgtbl-mode)
            (setq LaTeX-math-abbrev-prefix "'")))

;;;;;

;; spellcheck in LaTex mode
(add-hook 'TeX-mode-hook 'flyspell-mode)
(add-hook 'bibtex-mode-hook 'flyspell-mode)
;;;;;



(message "Stop 4 %ds" (destructuring-bind (hi lo ms &rest ignore) (current-time)
                        (- (+ hi lo) (+ (first *emacs-load-start*) (second *emacs-load-start*)))))




                                        ; Dias do calendario traduzidos para PT
(setq calendar-date-style 'european)
(setq calendar-week-start-day 1
  calendar-day-name-array
  ["Domingo" "Segunda" "Terça"
    "Quarta" "Quinta" "Sexta" "Sábado"]
  calendar-month-name-array
  ["Janeiro" "Fevereiro" "Março" "Abril"
    "Maio" "Junho" "Julho" "Agosto" "Setembro"
    "Outubro" "Novembro" "Dezembro"])
;;;;;

                                        ; Colocar o calendario mais bonito
(setq calendar-view-diary-initially-flag t
  calendar-mark-diary-entries-flag t
  number-of-diary-entries 7)
(add-hook 'diary-display-hook 'fancy-diary-display)
(add-hook 'today-visible-calendar-hook 'calendar-mark-today)
;;;;;


;; Fazer highline das palavras TODO e FIXME, entre outras
(use-package highlight-fixmes-mode
  :commands highlight-fixmes-mode)

;; FIXME: Add this to programming hooks
                                        ;(highlight-fixmes-mode t)
;;;

;; Show line-number and column-number in the mode line
(line-number-mode 1)
(column-number-mode 1)
;;;;;

;; Activar font-lock mode para todos os buffers
(global-font-lock-mode 1)
;;;;;

;; ============================
;; Setup syntax, background, and foreground coloring
;; ============================
(setq font-lock-maximum-decoration t)
;;;;;
;; ============================

;; ============================
;; Key mappings
;; ============================

;; use F1 key to go to a man page
(global-set-key [f1] 'man)
;; use F3 key to kill current buffer
(global-set-key [f3] 'kill-this-buffer)
;; use F5 to get help (apropos)
(global-set-key [f5] 'apropos)
;; use F6 to kill current buffer and window
(global-set-key [f6] 'kill-buffer-and-window)
;; ============================

;; ============================
;; Mouse Settings
;; ============================

;; mouse button one drags the scroll bar
(global-set-key [vertical-scroll-bar down-mouse-1] 'scroll-bar-drag)
;; ============================

;; ============================
;; DisplaY
;; ============================

;; setup font
;; This ones don't work on Windows
(if (not (running-windows-p))
  (if (>= emacs-major-version 23)
                                        ;(set-default-font "Bitstream Vera Sans Mono-12")
    (set-frame-font "Inconsolata 16")
    (set-frame-font
      "-adobe-courier-medium-r-normal-*-14-100-*-*-*-*-iso10646-1"))
  (set-frame-font "-outline-Consolas-normal-r-normal-normal-14-97-96-96-c-*-iso8859-1"))

                                        ; Mostrar linhas lado esquerdo

(add-hook 'emacs-lisp-mode-hook 'linum-mode)
(add-hook 'python-mode-hook 'linum-mode)
(add-hook 'haskell-mode-hook 'linum-mode)

(global-set-key (kbd "<f2>") 'linum-mode)
;;;




(message "Stop 5 %ds" (destructuring-bind (hi lo ms &rest ignore) (current-time)
                        (- (+ hi lo) (+ (first *emacs-load-start*) (second *emacs-load-start*)))))




;; display the current time
(setq display-time-24hr-format t)
(display-time)

;; alias y to yes and n to no
(defalias 'yes-or-no-p 'y-or-n-p)

;; highlight matches from searches
(setq isearch-highlight t
  search-highlight t)
(setq-default transient-mark-mode t)

;; Cursor should not blink
(when (fboundp 'blink-cursor-mode)
  (blink-cursor-mode -1))
;; ===========================

;; ===========================
;; Behaviour
;; ===========================

                                        ; See the commands I'm writing
(setq echo-keystrokes 0.1)

;; Pgup/dn will return exactly to the starting point.
(setq scroll-preserve-screen-position 1)

                                        ;Define mnemonic key bindings for moving to 'M-x compile' and 'M-x grep' matches
(global-set-key "\C-cn" 'next-error)
(global-set-key "\C-cp" 'previous-error)

                                        ; Don't bother entering search and replace args if the buffer is read-only
(defadvice query-replace-read-args (before barf-if-buffer-read-only activate)
  "Signal a 'buffer-read-only' error if the current buffer is read-only."
  (barf-if-buffer-read-only))

;; scroll just one line when hitting the bottom of the window
(setq scroll-step 1)
(setq scroll-conservatively 1)

;; show a menu only when running within X (save real estate when
;; in console)
                                        ;(menu-bar-mode (if window-system 1 -1))

;; resize the mini-buffer when necessary
(setq resize-minibuffer-mode t)

;; highlight during searching
(setq query-replace-highlight t)
;; ===============================

;; ===========================
;; HTML/CSS stuff
;; ===========================

;; take any buffer and turn it into an html file,
;; including syntax hightlighting
(use-package htmlize
  :commands (htmlize-buffer))

;; ===========================

;; ===========================
;; Custom Functions
;; ===========================
                                        ; resize man page to take up whole screen
(setq Man-notify 'bully)
;;

                                        ; SSH, etc.
(require 'tramp)
(setq tramp-default-method "telnet")
(setq tramp-debug-buffer t)
(setq tramp-verbose 10)
                                        ; host + user > proxy
;; (add-to-list 'tramp-default-proxies-alist
;;   '("\\." nil "/telnet:ei08150@tcpgate.fe.up.pt:"))
;; (add-to-list 'tramp-default-proxies-alist
;;   '("\\.riff\\.fe\\.up\\.pt\\'" nil nil))
                                        ; Aceder ao site da sapo
(setenv "SITE" "/ftp:rolando.do.sapo.pt@ftp.homepages.sapo.pt:~")
;;

;; Put autosave files (ie #foo#) in one place, *not*
;; scattered all over the file system!
(defvar autosave-dir
  (concat "~/.emacs.d/autosaves/" (user-login-name) "/"))

(make-directory autosave-dir t)





(message "Stop 6 %ds" (destructuring-bind (hi lo ms &rest ignore) (current-time)
                        (- (+ hi lo) (+ (first *emacs-load-start*) (second *emacs-load-start*)))))






(defun auto-save-file-name-p (filename)
  (string-match "^#.*#$" (file-name-nondirectory filename)))

(defun make-auto-save-file-name ()
  (concat autosave-dir
    (if buffer-file-name
      (concat "#" (file-name-nondirectory buffer-file-name) "#")
      (expand-file-name
        (concat "#%" (buffer-name) "#")))))

;; Put backup files (ie foo~) in one place too. (The backup-directory-alist
;; list contains regexp=>directory mappings; filenames matching a regexp are
;; backed up in the corresponding directory. Emacs will mkdir it if necessary.)
(defvar backup-dir (concat "~/.emacs.d/backups/" (user-login-name) "/"))
(setq backup-directory-alist (list (cons "." backup-dir)))

;; Auto-Completation on files
;; http://emacs-fu.blogspot.com/2009/02/switching-buffers.html
(ido-mode t)                         ; for both buffers and files
(setq
  ido-ignore-buffers                 ; ignore these guys
  '("\\` " "^\*Mess" "^\*Back" ".*Completion" "^\*Ido" "\*scratch\*" "^\*w3m" "^irc\."
     "\*slime-events\*" "\*slime-events\*" "\*gnus trace\*"
     "\*n?n?imap" "\*slime-compilation\*" "newsrc")
                                        ;  ido-work-directory-list '("~/" "~/Desktop")
  ido-case-fold  t                   ; be case-insensitive
                                        ;  ido-use-filename-at-point nil      ; don't use filename at point (annoying)
                                        ;  ido-use-url-at-point nil           ;  don't use url at point (annoying)
  ido-enable-flex-matching t         ; be flexible
                                        ;  ido-max-prospects 10               ; don't spam my minibuffer
                                        ;  ido-confirm-unique-completion t ; wait for RET, even with unique completion
  ido-create-new-buffer 'always) ; I'm always creating new buffers


                                        ; Saltar para onde se estava quando abrir um ficheiro
(use-package saveplace
  :init (setq-default save-place t))
;;;;;

                                        ; Cursor do rato nao cobre o texto
(mouse-avoidance-mode 'jump)
;;;;;

                                        ; Yasnippet
;; (add-to-list 'load-path (concat +dot-emacs-home+ "plugins/yasnippet"))
(use-package yasnippet
  :disabled t
  :init (progn
          (setq yas-snippet-dirs (list
                         (concat +dot-emacs-home+ "plugins/yasnippet/snippets")
                         (concat +dot-emacs-home+ "plugins/yasnippet/extras/imported/")))
          (yas-global-mode 1)))
;;;;;

;; Remove splash screen
(setq inhibit-splash-screen t)
;;;

;; Detaching the custom-file
;; http://www.emacsblog.org/2008/12/06/quick-tip-detaching-the-custom-file/
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)
;;;


(defun djcb-term-start-or-switch (prg &optional use-existing)
  "* run program PRG in a terminal buffer. If USE-EXISTING is non-nil
   and PRG is already running, switch to that buffer instead of starting
   a new instance."
  (interactive)
  (let ((bufname (concat "*" prg "*")))
    (when (not (and use-existing
                 (let ((buf (get-buffer bufname)))
                   (and buf (buffer-name (switch-to-buffer bufname))))))
      (ansi-term prg prg))))

(defmacro djcb-program-shortcut (name key &optional use-existing)
  "* macro to create a key binding KEY to start some terminal program PRG;
    if USE-EXISTING is true, try to switch to an existing buffer"
  `(global-set-key ,key
     '(lambda()
        (interactive)
        (djcb-term-start-or-switch ,name ,use-existing))))

;; terminal programs are under Shift + Function Key
(djcb-program-shortcut "zsh"   (kbd "<S-f1>") t)  ; the ubershell
(djcb-program-shortcut "mutt"  (kbd "<S-f2>") t)  ; mail client
(djcb-program-shortcut "slrn"  (kbd "<S-f3>") t)  ; nttp client
(djcb-program-shortcut "htop"  (kbd "<S-f4>") t)  ; my processes
(djcb-program-shortcut "mc"    (kbd "<S-f5>") t)  ; midnight commander
(djcb-program-shortcut "raggle"(kbd "<S-f6>") t)  ; rss feed reader
(djcb-program-shortcut "irssi" (kbd "<S-f7>") t)  ; irc client
(djcb-program-shortcut "tt++ " (kbd "<S-f8>") t)  ; MUD client
;;;;;;;;


(message "Stop 7 %ds" (destructuring-bind (hi lo ms &rest ignore) (current-time)
                        (- (+ hi lo) (+ (first *emacs-load-start*) (second *emacs-load-start*)))))



;; Move between windows using Meta+arrow keys
;; http://www.emacsblog.org/2008/05/01/quick-tip-easier-window-switching-in-emacs/
(windmove-default-keybindings 'meta)
;;


(message "Stop 8 %ds" (destructuring-bind (hi lo ms &rest ignore) (current-time)
                        (- (+ hi lo) (+ (first *emacs-load-start*) (second *emacs-load-start*)))))


;; Load bookmarks
;; http://www.emacsblog.org/2007/03/22/bookmark-mania/
(use-package bm
  :init (progn
          (setq bm-restore-repository-on-load t)
          ;; make bookmarks persistent as default
          (setq-default bm-buffer-persistence t)

          ;; Loading the repository from file when on start up.
          (add-hook' after-init-hook 'bm-repository-load)

          ;; Restoring bookmarks when on file find.
          (add-hook 'find-file-hooks 'bm-buffer-restore)

          ;; Saving bookmark data on killing a buffer
          (add-hook 'kill-buffer-hook 'bm-buffer-save)

          ;; Saving the repository to file when on exit.
          ;; kill-buffer-hook is not called when emacs is killed, so we
          ;; must save all bookmarks first.
          (add-hook 'kill-emacs-hook '(lambda nil
                                        (bm-buffer-save-all)
                                        (bm-repository-save)))
          (global-set-key (kbd "<C-f4>") 'bm-toggle)
          (global-set-key (kbd "<f4>")   'bm-next)
          (global-set-key (kbd "<S-f4>") 'bm-previous)
          ))

(message "Stop 9 %ds" (destructuring-bind (hi lo ms &rest ignore) (current-time)
                        (- (+ hi lo) (+ (first *emacs-load-start*) (second *emacs-load-start*)))))



;;;;;;;;;;;;;

;; Need to find some keybindings for the laptop
(require 'fold-dwim)
(if (running-on-laptop-p)
  (progn
    (global-set-key [(C J)] 'fold-dwim-hide-all)
    (global-set-key [(C K)] 'fold-dwim-toggle)
    (global-set-key [(C L)] 'fold-dwim-show-all))
  ;; On the numpad
  (global-set-key [(C kp-left)] 'fold-dwim-hide-all)   ; Key 4
  (global-set-key [(C kp-begin)] 'fold-dwim-toggle)    ; Key 5
  (global-set-key [(C kp-right)] 'fold-dwim-show-all)) ; Key 6


;; % works the same as vim
;; http://mewde.blogspot.com/2007_05_01_archive.html
(global-set-key "%" 'match-paren)
(defun match-paren (arg)
  "Go to the matching paren if on a paren; otherwise insert %."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
    ((looking-at "\\s\)") (forward-char 1) (backward-list 1))
    (t (self-insert-command (or arg 1)))))
;;;;;

;; A little game to help learn the keybindings
;; http://mewde.blogspot.com/2007_05_01_archive.html
(use-package keywiz
  :commands keywiz)
;;

;; ;; Scheme Mode
;; (defun rolando-scheme-send-whole-buffer ()
;;   "Sends the entire buffer to the inferior scheme process"
;;   (interactive)
;;   (save-excursion
;;     (set-buffer "*scheme*")
;;     (erase-buffer)
;;     (save-excursion
;;       (scheme-send-region (point-min) (point-max))
;;       (if (get-buffer-window "*scheme*")
;;         (display-buffer "*scheme*" t))
;;       (unless (get-buffer-window "*scheme*")
;;         (split-window-vertically)
;;         (windmove-do-window-select 'down)
;;         (set-window-buffer (selected-window) "*scheme*")))))

;; (defun rolando-scheme-mode-hook ()
;;   (interactive)
;;   (local-set-key (kbd "C-t") 'rolando-scheme-send-whole-buffer))

;; (add-hook 'scheme-mode-hook 'rolando-scheme-mode-hook)
;; ;;;;

;; F20 = Right Windows key
;; use "xmodmap -e 'keycode 133 = F20'" to set it
(defun rolando-switch-buffer ()
  "Alternates buffers like GNU Screen and Ratpoison"
  (interactive)
  (switch-to-buffer (other-buffer)))
(global-set-key [f20] 'rolando-switch-buffer)
;;

(defun rolando-complete-python-symbol (symbol)
  "Show the documentation for the python symbol on the cursor on a resized frame"
  (interactive)
  ;; (interactive
  ;;   (let ((symbol (with-syntax-table python-dotty-syntax-table
  ;;                   (current-word)))
  ;;          (enable-recursive-minibuffers t))
  ;;     (list (read-string (if symbol
  ;;                          (format "Describe symbol (default %s): " symbol)
  ;;                          "Describe symbol: ")
  ;;             nil nil symbol))))
  ;; Usar o fit-window-to-buffer, display-buffer
  (let ((name "*Python Documentation*"))
    (save-excursion
      ;;(python-describe-symbol symbol) ; Cria um buffer com o nome *Help*
      (get-buffer-create name)
      (set-buffer name)
      (save-excursion
        (display-buffer name)
        (select-window (next-window))
        (fit-window-to-buffer (selected-window) 10 4)))))

(message "Stop 10 %ds" (destructuring-bind (hi lo ms &rest ignore) (current-time)
                           (- (+ hi lo) (+ (first *emacs-load-start*) (second *emacs-load-start*)))))

;; Automatically close the compilation buffer after a successful compilation
;; http://www.emacswiki.org/emacs/ModeCompile
(defun compile-autoclose (buffer string)
  (cond ((and (string-match "finished" string)
           (string= (buffer-name) "*compilation*")) ; No need to hide buffer *grep* or *find*
          (bury-buffer "*compilation*")
          (winner-undo)
          (message "Build successful."))
    (t
      (message "Compilation exited abnormally: %s" string))))
(setq compilation-finish-functions 'compile-autoclose)
;;

;; Quick compile
(global-set-key [f11] 'compile)
(global-set-key [f12] 'recompile)
(global-set-key [f7] 'recompile)        ; temporary fix for the fact
                                        ; that my F12 key isn't
                                        ; working anymore

(setq compilation-scroll-output t)
(setq compilation-window-height 16)
;;

;; Typing of the Dead... erm... Emacs...
(use-package typing
  :commands typing-of-emacs)
(use-package sudoku
  :commands sudoku)
;;

;; Open Guis without hanging emacs
(defun open-gui (command)
  (interactive "sCommand: ")
  (save-window-excursion
    (let ((cmd (concat command " &"))
           (cmd-buffer (concat "*" command "*")))
      (shell-command cmd cmd-buffer))))
(global-set-key (kbd "C-M-!") 'open-gui)


;; View chm on w3m
;; Requires archmage installed
;;(require 'chm-view)
;;

;; ;; Cor hexadecimal no HTML
(use-package rainbow-mode
  :commands rainbow-mode
  :init (add-hook 'html-mode-hook 'rainbow-mode))
;;;;;




(message "Stop 11 %ds" (destructuring-bind (hi lo ms &rest ignore) (current-time)
                         (- (+ hi lo) (+ (first *emacs-load-start*) (second *emacs-load-start*)))))




;; Indent some code within an HTML file
;; http://www.emacswiki.org/emacs/HtmlMode
(defun indent-region-as (other-mode)
  "Indent selected region as some other mode.  Used in order to indent source code contained within HTML."
  (interactive "aMode to use: ")

  (save-excursion
    (let ((old-mode major-mode))
      (narrow-to-region (region-beginning) (region-end))
      (funcall other-mode)
      (indent-region (region-beginning) (region-end) nil)
      (funcall old-mode)))
  (widen))
;;;;

;; Transform accents into html code
;; http://www.emacswiki.org/emacs/html-accent.el
(use-package html-accent
  :commands (html-accent ; Accent HTML
              accent-html ; HTML codes to accent
              ))
;;

;; Stuff that shows the whitespace on a buffer
(use-package show-wspace
  :commands (toggle-show-hard-spaces-show-ws
              show-ws-toggle-show-hard-spaces
              toggle-show-trailing-whitespace-show-ws
              show-ws-toggle-show-trailing-whitespace))

;; Browse Kill Ring
;; http://www.emacswiki.org/emacs/BrowseKillRing
(use-package browse-kill-ring
  :commands browse-kill-ring)

;; Show free space on device
;; http://www.emacswiki.org/emacs/DfMode
(use-package df-mode
  :if (not (running-windows-p))
  :init (df-mode 1))

;;; This was installed by package-install.el.
;;; This provides support for the package system and
;;; interfacing with ELPA, the package archive.
;;; Move this code earlier if you want to reference
;;; packages in your .emacs.
                                        ;(when
                                        ;  (load
                                        ;    (expand-file-name "~/.emacs.d/elpa/package.el"))
                                        ;  (package-initialize))

;; Haskell configurations
(when (file-exists-p (concat +dot-emacs-home+ "elisp/haskell-mode-2.4/haskell-site-file.el"))
  (load (concat +dot-emacs-home+ "elisp/haskell-mode-2.4/haskell-site-file"))
  (add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
  (add-hook 'haskell-mode-hooj 'turn-on-haskell-indent))

(use-package org-remember
  :init (progn
          (org-remember-insinuate)

          ;; http://metajack.im/2008/12/30/gtd-capture-with-emacs-orgmode/
          (defadvice org-capture-finalize (after delete-remember-frame activate)
            "Advise remember-finalize to close the frame if it is the remember frame"
            (if (equal "*Capture*" (frame-parameter nil 'name))
              (delete-frame)))

          (defadvice org-capture-destroy (after delete-remember-frame activate)
            "Advise remember-destroy to close the frame if it is the remember frame"
            (if (equal "*Capture*" (frame-parameter nil 'name))
              (delete-frame)))

          ;; make the frame contain a single window. by default org-remember
          ;; splits the window.
          (add-hook 'org-capture-mode-hook 'delete-other-windows)  
          (add-hook 'org-capture-mode-hook (lambda ()
                                             (goto-char (point-max))))

          (defun make-capture-frame ()
            "Create a new frame and run org-remember"
            (interactive)
            (make-frame '((name . "*Capture*")
                           (width . 80)
                           (height . 10)
                           (vertical-scroll-bars . nil)
                           (menu-bar-lines . nil)
                           (tool-bar-lines . nil)))
            (select-frame-by-name "*Capture*")
            (org-capture nil "t"))


          (setq org-capture-templates
            '(("c" "Clipboard" entry
                (file+headline "~/remember.org" "Interesting")
                "* %T %^{Description}\n %x")
               ("t" "ToDo" entry
                 (file+headline "~/remember.org" "Todo")
                 "* TODO %T %^{Summary}")))))





(message "Stop 12 %ds" (destructuring-bind (hi lo ms &rest ignore) (current-time)
                         (- (+ hi lo) (+ (first *emacs-load-start*) (second *emacs-load-start*)))))


;; ;; FIXME: Usar hippie-expand
;; (defun rolando-indent-and-dabbrev ()
;;   "Try to use yas/expand to complete a snippet.
;; If it can't find a snippet, run the yas/fallback-baheviour.
;; Otherwise, run dabbrev-expand"
;;   (interactive)
;;   (indent-according-to-mode))
;; ;  (dabbrev-expand nil))
;; ;; Precisa de uns ajustes para poder usar o tab dentro de snippets
;; ;(global-set-key [(tab)] 'rolando-indent-and-dabbrev)

;; (setq yas/trigger-key (kbd "SPC"))

(defun rolando-change-comma-to-semicolon ()
  "If the character before pressing enter is a ',' change it into a ';' instead
while also doing a newline-and-indent.
If the character is not a ';' simply do a newline-and-indent"
                                        ; Find a way to see if where inside a function call
  (interactive)
  (unless (= (point) 1)
    (if (char-equal ?\, (char-before))
      (progn
        (delete-char -1)
        (insert ";"))))
  (newline-and-indent))

;; TODO: This probably only makes sense in c-mode or c++-mode
;;(define-key global-map (kbd "RET") 'rolando-change-comma-to-semicolon)

;; Experimentar o Hippie-Expand
;; http://stackoverflow.com/questions/151639/yasnippet-and-pabbrev-working-together-in-emacs
(use-package hippie-exp
  :bind ("M-SPC" . hippie-expand)
  :init (setq hippie-expand-try-functions-list
          '(try-expand-dabbrev
             try-expand-dabbrev-all-buffers
             try-expand-dabbrev-from-kill
             try-complete-file-name-partially
             try-complete-file-name
             try-complete-lisp-symbol-partially
             try-complete-lisp-symbol)))



;; Usar minibufferp para saber se estamos no minibuffer
;; http://www.emacsblog.org/2007/03/12/tab-completion-everywhere/
(defun indent-or-expand (arg)
  "Either indent according to mode, or expand the word preceding
point."
  (interactive "*P")
  (unless (minibufferp (current-buffer))
    (if (and
          (or (bobp) (= ?w (char-syntax (char-before))))
          (or (eobp) (not (= ?w (char-syntax (char-after))))))
                                        ;(dabbrev-expand arg)
      (hippie-expand arg)))
                                        ;(indent-according-to-mode)
                                        ; indent-according-to-mode doesn't work on regions
                                        ;  (indent-region (region-beginning) (region-end)))
  (indent-for-tab-command))

(defun my-tab-fix ()
  (local-set-key [(tab)] 'indent-or-expand))

;;(add-hook 'c-mode-hook          'my-tab-fix)
(add-hook 'sh-mode-hook         'my-tab-fix)
(add-hook 'emacs-lisp-mode-hook 'my-tab-fix)

;; (global-set-key [(tab)] 'indent-or-expand)


                                        ; TODO: Melhorar isto
(defun lisp-switch-keys ()
  (local-set-key (kbd "8") (lambda ()
                             (interactive)
                                        ;(insert-parentheses)
                             (insert "(")))
  (local-set-key (kbd "(") (lambda ()
                             (interactive)
                             (insert "8")))
  (local-set-key (kbd "9") (lambda ()
                             (interactive)
                                        ;(move-past-close-and-reindent)
                             (insert ")")))
  (local-set-key (kbd ")") (lambda ()
                             (interactive)
                             (insert "9"))))

(message "Stop 13 %ds" (destructuring-bind (hi lo ms &rest ignore) (current-time)
                         (- (+ hi lo) (+ (first *emacs-load-start*) (second *emacs-load-start*)))))



(add-hook 'c-mode-hook 'lisp-switch-keys)
(add-hook 'emacs-lisp-mode-hook 'lisp-switch-keys)

;; Dired reuse buffer
;; http://www.emacswiki.org/emacs/DiredReuseDirectoryBuffer
;; we want dired not not make always a new buffer if visiting a directory
;; but using only one dired buffer for all directories.
(defadvice dired-advertised-find-file (around dired-subst-directory activate)
  "Replace current buffer if file is a directory."
  (interactive)
  (let ((orig (current-buffer))
         (filename (dired-get-filename)))
    ad-do-it
    (when (and (file-directory-p filename)
            (not (eq (current-buffer) orig)))
      (kill-buffer orig))))

;; Using the methods above will still create a new buffer if you invoke ^
;; (dired-up-directory). To prevent this:
(eval-after-load "dired"
  ;; don't remove `other-window', the caller expects it to be there
  '(defun dired-up-directory (&optional other-window)
     "Run Dired on parent directory of current directory."
     (interactive "P")
     (let* ((dir (dired-current-directory))
             (orig (current-buffer))
             (up (file-name-directory (directory-file-name dir))))
       (or (dired-goto-file (directory-file-name dir))
         ;; Only try dired-goto-subdir if buffer has more than one dir.
         (and (cdr dired-subdir-alist)
           (dired-goto-subdir up))
         (progn
           (kill-buffer orig)
           (dired up)
           (dired-goto-file dir))))))

;; Get the size of all marked files in dired
;; http://www.emacswiki.org/emacs/DiredGetFileSize
(defun dired-get-size ()
  (interactive)
  (let ((files (dired-get-marked-files)))
    (with-temp-buffer
      (apply 'call-process "/usr/bin/du" nil t nil "-sch" files)
      (message "Size of all marked files: %s"
        (progn
          (re-search-backward "\\(^[0-9.,]+[A-Za-z]+\\).*total$")
          (match-string 1))))))

(require 'dired)
(define-key dired-mode-map (kbd "?") 'dired-get-size)

;; Place the directories on top of the dired buffer
;; http://www.emacswiki.org/emacs/DiredSortDirectoriesFirst
(defun mydired-sort ()
  "Sort dired listings with directories first."
  (save-excursion
    (let (buffer-read-only)
      (forward-line 2) ;; beyond dir. header
      (sort-regexp-fields t "^.*$" "[ ]*." (point) (point-max)))
    (set-buffer-modified-p nil)))

(defadvice dired-readin
  (after dired-after-updating-hook first () activate)
  "Sort dired listings with directories first before adding marks."
  (mydired-sort))

;; Dired file size should be human readable
(setq dired-listing-switches "-alh")

(message "Stop 14 %ds" (destructuring-bind (hi lo ms &rest ignore) (current-time)
                         (- (+ hi lo) (+ (first *emacs-load-start*) (second *emacs-load-start*)))))


(defun autocompile nil
  "compile itself if ~/.emacs"
  (interactive)
  (require 'bytecomp)
  (if (string= (buffer-file-name) (expand-file-name (concat default-directory ".emacs")))
    (byte-compile-file (buffer-file-name))))

(add-hook 'after-save-hook 'autocompile)




(message "My .emacs loaded in %ds" (destructuring-bind (hi lo ms) (current-time)
                                     (- (+ hi lo) (+ (first *emacs-load-start*) (second *emacs-load-start*)))))


                                        ;(require 'vimpulse)
;; Activate occur easily inside isearch
;; From: http://www.masteringemacs.org/articles/2011/07/20/searching-buffers-occur-mode/ (comments)
(define-key isearch-mode-map (kbd "C-o") 'isearch-occur)

(defun rolando-find-prev-good-buffer ()
  "Goto to the previous buffer, ignoring buffers that start and end with a *"
  (previous-buffer)
  (if (and (string-match "\\\*.*\\\*" (buffer-name))
        (not (string-match "\\\*scratch\\\*" (buffer-name))))
    (rolando-find-prev-good-buffer)))

(defun rolando-find-next-good-buffer ()
  "Goto to the next buffer, ignoring buffers that start and end with a *"
  (next-buffer)
  (if (and (string-match "\\\*.*\\\*" (buffer-name))
        (not (string-match "\\\*scratch\\\*" (buffer-name))))
    (rolando-find-next-good-buffer)))

;; Viper keys to quickly change buffers
;; (define-key viper-vi-basic-map (kbd "<right>")
;;   (lambda ()
;;     (interactive)
;;     (rolando-find-next-good-buffer)))

;; (define-key viper-vi-basic-map (kbd "<left>")
;;   (lambda ()
;;     (interactive)
;;       (rolando-find-prev-good-buffer)))

;; From http://github.com/technomancy/emacs-starter-kit/blob/master/starter-kit-misc.el
(eval-after-load 'diff-mode
  '(progn
     (set-face-foreground 'diff-added "green4")
     (set-face-foreground 'diff-removed "red3")))

;; Default to unified diffs
(setq diff-switches "-u")

;; This should be a defadvice
;; Change the color of the mode line when entering insert-mode and vi-mode
;; (defun viper-change-state (new-state)
;;   ;; Keep viper-post/pre-command-hooks fresh.
;;   ;; We remove then add viper-post/pre-command-sentinel since it is very
;;   ;; desirable that viper-pre-command-sentinel is the last hook and
;;   ;; viper-post-command-sentinel is the first hook.

;;   (when (eq new-state 'insert-state)
;;     (set-face-background 'modeline "steelblue4")
;;     (set-face-foreground 'modeline "black"))
;;   (when (eq new-state 'vi-state)
;;     (set-face-background 'modeline "gray50")
;;     (set-face-foreground 'modeline "black"))


;;   (when (featurep 'xemacs)
;;     (make-local-hook 'viper-after-change-functions)
;;     (make-local-hook 'viper-before-change-functions)
;;     (make-local-hook 'viper-post-command-hooks)
;;     (make-local-hook 'viper-pre-command-hooks))

;;   (remove-hook 'post-command-hook 'viper-post-command-sentinel)
;;   (add-hook 'post-command-hook 'viper-post-command-sentinel)
;;   (remove-hook 'pre-command-hook 'viper-pre-command-sentinel)
;;   (add-hook 'pre-command-hook 'viper-pre-command-sentinel t)
;;   ;; These hooks will be added back if switching to insert/replace mode
;;   (remove-hook 'viper-post-command-hooks
;; 	       'viper-insert-state-post-command-sentinel 'local)
;;   (remove-hook 'viper-pre-command-hooks
;; 	       'viper-insert-state-pre-command-sentinel 'local)
;;   (setq viper-intermediate-command nil)
;;   (cond ((eq new-state 'vi-state)
;; 	 (cond ((member viper-current-state '(insert-state replace-state))

;; 		;; move viper-last-posn-while-in-insert-state
;; 		;; This is a normal hook that is executed in insert/replace
;; 		;; states after each command.  In Vi/Emacs state, it does
;; 		;; nothing.  We need to execute it here to make sure that
;; 		;; the last posn was recorded when we hit ESC.
;; 		;; It may be left unrecorded if the last thing done in
;; 		;; insert/repl state was dabbrev-expansion or abbrev
;; 		;; expansion caused by hitting ESC
;; 		(viper-insert-state-post-command-sentinel)

;; 		(condition-case conds
;; 		    (progn
;; 		      (viper-save-last-insertion
;; 		       viper-insert-point
;; 		       viper-last-posn-while-in-insert-state)
;; 		      (if viper-began-as-replace
;; 			  (setq viper-began-as-replace nil)
;; 			;; repeat insert commands if numerical arg > 1
;; 			(save-excursion
;; 			  (viper-repeat-insert-command))))
;; 		  (error
;; 		   (viper-message-conditions conds)))

;; 		(if (> (length viper-last-insertion) 0)
;; 		    (viper-push-onto-ring viper-last-insertion
;; 					  'viper-insertion-ring))

;; 		(if viper-ESC-moves-cursor-back
;; 		    (or (bolp) (viper-beginning-of-field) (backward-char 1))))
;; 	       ))

;; 	;; insert or replace
;; 	((memq new-state '(insert-state replace-state))
;; 	 (if (memq viper-current-state '(emacs-state vi-state))
;; 	     (viper-move-marker-locally 'viper-insert-point (point)))
;; 	 (viper-move-marker-locally
;; 	  'viper-last-posn-while-in-insert-state (point))
;; 	 (add-hook 'viper-post-command-hooks
;; 		   'viper-insert-state-post-command-sentinel t 'local)
;; 	 (add-hook 'viper-pre-command-hooks
;; 		   'viper-insert-state-pre-command-sentinel t 'local))
;; 	) ; outermost cond

;;   ;; Nothing needs to be done to switch to emacs mode! Just set some
;;   ;; variables, which is already done in viper-change-state-to-emacs!

;;   ;; ISO accents
;;   ;; always turn off iso-accents-mode in vi-state, or else we won't be able to
;;   ;; use the keys `,',^ , as they will do accents instead of Vi actions.
;;   (cond ((eq new-state 'vi-state) (viper-set-iso-accents-mode nil));accents off
;; 	(viper-automatic-iso-accents (viper-set-iso-accents-mode t));accents on
;; 	(t (viper-set-iso-accents-mode nil)))
;;   ;; Always turn off quail mode in vi state
;;   (cond ((eq new-state 'vi-state) (viper-set-input-method nil)) ;intl input off
;; 	(viper-special-input-method (viper-set-input-method t)) ;intl input on
;; 	(t (viper-set-input-method nil)))

;;   (setq viper-current-state new-state)

;;   (viper-update-syntax-classes)
;;   (viper-normalize-minor-mode-map-alist)
;;   (viper-adjust-keys-for new-state)
;;   (viper-set-mode-vars-for new-state)
;;   (viper-refresh-mode-line)
;; )


;; (set-face-background 'modeline-inactive "black")

;; (custom-set-faces
;;   '(mode-line ((t (:box (:line-width 1 :color "orange"))))))

;; Register jumping: ‘C-x r j e’ to open DotEmacs,
;; ‘C-x r j i’ to open an ‘ideas’ file:
;; http://www.emacswiki.org/emacs-en/EmacsNiftyTricks
(set-register ?e '(file . "~/.emacs"))
(set-register ?f '(file . "~/escola/escola.org"))
(set-register ?h '(file . "~/Área de Trabalho/humor.txt"))
(set-register ?c '(file . "~/Área de Trabalho/conducao/conducao.org"))

(defun rolando-help-jump-to-source-file ()
  "Open up the file where the function/variable definition is defined."
  (interactive)
  (pop-to-buffer "*Help*")
  (goto-char (point-min))
  (when (or (re-search-forward "`.*\.el'" nil t)
          ;; If we can't find a .el file, search for "C source code"
          (re-search-forward "`C source"))
    (backward-char 2)
    (push-button))
  ;; Delete the window showing buffer *Help*
  (delete-windows-on "*Help*"))

(global-set-key (kbd "C-c j") 'rolando-help-jump-to-source-file)

;; Use this yow.lines file
(setq yow-file "~/.emacs.d/misc/yow.lines")

(global-set-key (kbd "C-c i") 'string-rectangle)

;; Not so sure about this one
                                        ;(global-set-key (kbd "C-c k") 'kill-rectangle)

;; Didn't I had a reason to remove this a while ago?
(define-key global-map (kbd "RET") 'newline-and-indent)

;; Lets try this
;; http://www.emacswiki.org/emacs-en/EmacsNiftyTricks
; Not so useful
;(global-set-key (kbd "RET") 'newline-and-indent)

;; XXX: Workaround a bug where ispell doesn't work with words that contain the
;; char ç or Ç or ô or Ô or õ or Õ
(defun ispell-get-casechars ()
  "[a-zA-ZÁÂÉÓàáâéêíóãúçÇôÔõÕ]")

(defun ispell-get-not-casechars ()
  "[^a-zA-ZÁÂÉÓàáâéêíóãúçÇôÔõÕ]")

;; Define movement keys for man mode
(use-package man
  :commands man
  :config (progn
            (define-key Man-mode-map "j" 'next-line)
            (define-key Man-mode-map "k" 'previous-line)
            (define-key Man-mode-map "K" 'Man-kill)))

;; Only show files matching the regexp on a Dired buffer
(defun dired-show-files-match-regexp (regexp)
  "Show on the dired buffer the files that match a certain regexp"
  (interactive "s files (regexp): ")
  (dired-mark-files-regexp regexp)
  (dired-toggle-marks)
  (dired-do-kill-lines))

;; r isn't the best keybinding, but it will work
(define-key dired-mode-map (kbd "r") 'dired-show-files-match-regexp)

;; Turn off yasnippet mode on the debugger
(add-hook 'gdb-mode-hook 'yas/minor-mode-off)

;; (set-face-background 'modeline-inactive "black")

;; (custom-set-faces
;;   '(mode-line ((t (:box (:line-width 1 :color "orange"))))))

(add-hook 'c-mode-common-hook
  (lambda ()
    (local-set-key  (kbd "C-c o") 'ff-find-other-file)))

(add-hook 'c-mode-common-hook
  (lambda ()
    (setq indent-tabs-mode t)))

;; Yes, you can do this same trick with the cool "It's All Text"
;; firefox add-on :-)
;(add-to-list 'auto-mode-alist '("/mutt-\\|itsalltext.*mail\\.google" .  message-mode))
(add-hook 'message-mode-hook 'turn-on-auto-fill)
(add-hook 'message-mode-hook 'flyspell-mode)
;; (add-hook 'message-mode-hook
;;   (lambda ()
;;     (define-key message-mode-map [(control c) (control c)]
;;       (lambda ()
;;         (interactive)
;;         (save-buffer)
;;         (server-edit)))))

;; My general lisp configurations
;; (add-hook 'lisp-mode-hook 'yas/minor-mode-off)
 ; Doesn't seem to function if it's inside `lisp-hook-function'
(add-hook 'lisp-mode-hook 'lisp-switch-keys)

;; If slime is on, then <f7> evals the entire buffers
(add-hook 'lisp-mode-hook (lambda ()
                            (local-set-key (kbd "<f7>")
                                   'slime-eval-buffer)))


;; Slime stuff
(use-package slime
  ;; :load-path "elisp/slime/"
  :commands (slime slime-connect)
  :config (progn
            (require 'slime-autoloads)
            (setq inferior-lisp-program "sbcl")
            (add-hook 'slime-repl-mode-hook 'lisp-switch-keys)

            (slime-setup '(slime-fancy
                            ;; slime-sbcl-exts
                            ;; slime-sprof
                            ;; slime-highlight-edits slime-hyperdoc slime-mdot-fu
                            ))
            ;; (slime-autodoc-mode)
            (setq slime-autodoc-use-multiline-p t
              slime-complete-symbol*-fancy t
              slime-complete-symbol-function 'slime-fuzzy-complete-symbol
              slime-when-complete-filename-expand t)
                                        ;slime-truncate-lines nil)
            (setq common-lisp-hyperspec-root "/usr/share/doc/hyperspec/")
            (setq common-lisp-hyperspec-symbol-table
              (concat common-lisp-hyperspec-root "Data/Map_Sym.txt"))

            ;; From: http://www.emacswiki.org/emacs-en/SlimeMode
            ;; Improve usability of slime-apropos: slime-apropos-minor-mode
            (defvar slime-apropos-anchor-regexp "^[^ ]")
            (defun slime-apropos-next-anchor ()
              (interactive)
              (let ((pt (point)))
                (forward-line 1)
                (if (re-search-forward slime-apropos-anchor-regexp nil t)
                  (goto-char (match-beginning 0))
                  (goto-char pt)
                  (error "anchor not found"))))

            (defun slime-apropos-prev-anchor ()
              (interactive)
              (let ((p (point)))
                (if (re-search-backward slime-apropos-anchor-regexp nil t)
                  (goto-char (match-beginning 0))
                  (goto-char p)
                  (error "anchor not found"))))

            (defvar slime-apropos-minor-mode-map (make-sparse-keymap))
            (define-key slime-apropos-minor-mode-map "\C-m" 'slime-describe-symbol)
            (define-key slime-apropos-minor-mode-map "l" 'slime-describe-symbol)
            (define-key slime-apropos-minor-mode-map "j" 'slime-apropos-next-anchor)
            (define-key slime-apropos-minor-mode-map "k" 'slime-apropos-prev-anchor)
            (define-minor-mode slime-apropos-minor-mode "")

            (defadvice slime-show-apropos (after slime-apropos-minor-mode activate)
              ""
              (when (get-buffer "*slime-apropos*")
                (with-current-buffer "*slime-apropos*" (slime-apropos-minor-mode 1))))

            (setq slime-net-coding-system 'utf-8-unix)))


;; Save history of minibuffer between emacs sessions
(savehist-mode 1)
;; Also save kill-ring between emacs sessions
;; From news://gnu.emacs.help
(setq savehist-additional-variables '(kill-ring
                                       ;compile-command
                                       ))

;; "a" key on a dired buffer opens the folder without opening a new buffer
;; unlike RET.
(put 'dired-find-alternate-file 'disabled nil)

;; Smex - Search M-x
(use-package smex
  :commands (smex)
  :config (smex-initialize))


(defun total-number-lines ()
  "Total number of lines on a buffer.

To add this to the mode-line, place (:EVAL (format '%s' (total-number-lines)))
somewhere on the variable mode-line-format."
  (interactive)
  (1+ (count-lines (point-min) (point-max))))

(defun rolando-call-vc ()
  "Call magit or psvn depending on the vc-backend."
  (interactive)
  (let ((backend (vc-backend (buffer-file-name))))
    (cond ((string= backend "Git")
            (load "magit")
            (magit-status (magit-get-top-dir default-directory)))
      ((string= backend "SVN")
        (svn-status default-directory)))))

(global-set-key "\C-ck" 'rolando-call-vc)

;; Seen on #emacs
;; If file size is > 100MB, don't display line number -- can use what-line function if you want anyway
(setq line-number-display-limit 100000000)

;; Zap-up-to-char (like Vi "dt" command)
(use-package misc
  :bind (("M-z" . zap-up-to-char)
          ("M-Z" . zap-to-char)))

(use-package uniquify
  :init (setq uniquify-buffer-name-style 'forward))

;; Some custom commands for eshell
(use-package eshell
  :commands eshell
  :init (progn
          (defun rolando-change-to-eshell-or-to-prev-buffer ()
            (interactive)
            (if (string= (buffer-name) "*eshell*") ; Doesn't work with multiple eshells
              (switch-to-buffer (other-buffer))
              (eshell)))

          (global-set-key (kbd "<f9>") 'rolando-change-to-eshell-or-to-prev-buffer))

  :config (progn
            (defun eshell/ff (file)
              (find-file file))

            ;; From http://www.emacswiki.org/emacs/EshellFunctions
            (defun eshell/emacs (&rest args)
              "Open a file in emacs. Some habits die hard."
              (if (null args)
                ;; If I just ran "emacs", I probably expect to be launching Emacs,
                ;; which is rather silly since I'm already in Emacs.  So just
                ;; pretend to do what I ask.
                (bury-buffer)
                ;; We have to expand the file names or else naming a directory in
                ;; an argument causes later arguments to be looked for in that
                ;; directory, not the starting directory
                (mapc #'find-file (mapcar #'expand-file-name
                                    (eshell-flatten-list (reverse args))))))

            (defun download-youtube-video (url)
              (eshell-eval-command
                (eshell-command
                  (concat "~/Área\\ de\\ Trabalho/youtube-dl.py -t " url))))


            ;; To use in eshell:
            ;; for i in http://www.quickmeme.com/meme/352khg/ http://www.quickmeme.com/meme/1yhw/ http://www.quickmeme.com/meme/xsg/ http://www.quickmeme.com/meme/Ev/  http://www.quickmeme.com/meme/16ir/ http://www.quickmeme.com/meme/vmm/  http://www.quickmeme.com/meme/uo/ http://www.quickmeme.com/meme/1q9z/ http://www.quickmeme.com/meme/1qij/ http://www.quickmeme.com/meme/35whc3/  http://www.quickmeme.com/meme/35u0ou/ { download-quickmeme $i }
            (defun download-quickmeme (url)
              (let ((id (nth 3 (split-string url "/" t))))
                (eshell-command (concat "wget http://i.qkme.me/" id ".jpg"))))))



;; Para o swi-prolog
(use-package prolog
  :commands (run-prolog mercury-mode)
  ;; :mode ("\\.pl$" . prolog-mode)
  :init (setq prolog-system 'swi)
  :config (add-hook 'prolog-hook
            '(progn
               (defun prolog-quick-help ()
                 "Show help for predicate on point"
                 (interactive)
                 (funcall prolog-help-function-i (prolog-atom-under-point)))
               (define-key prolog-mode-map (kbd "C-c ?") 'prolog-quick-help))))


;; This is sweet!  right-click, get a list of functions in the source
;; file you are editing
;; (http://emacs.wordpress.com/2007/01/24/imenu-with-a-workaround/#comment-51)
(global-set-key [mouse-3] 'imenu)


;; TODO: Work in progress, insert defun form on buffer
(defun find-help ()
  (save-excursion
    (describe-function 'eshell)
    (pop-to-buffer "*Help*")
    (goto-char (point-min))
    (when (re-search-forward "`.*\.el'" nil t)
      (backward-char 2)
      (push-button)
      (delete-windows-on "*Help*"))
    (let ((begin (point)))
      (forward-sexp 1)
      (kill-ring-save begin (point))))
  (yank))

(defun download-youtube-video (url)
  (eshell-eval-command
    (eshell-command
      (concat "~/Área\\ de\\ Trabalho/youtube-dl.py -t " url))))

;; To make ediff operate on selected-frame add next:
;; This is what you probably want if you are using a tiling window
;; manager under X, such as ratpoison.
;; From: http://www.emacswiki.org/emacs/EdiffMode
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; Para o trabalho de laig
(setq auto-mode-alist (append
                        '(("\\.sgx$" . xml-mode))
                        auto-mode-alist))

;; From: http://www.emacswiki.org/cgi-bin/wiki?goto-last-change.el
;; Seen on #emacs
;; Works like '. on vim
(use-package goto-last-change
  :bind ("C-x C-g" . goto-last-change))

(global-set-key (kbd "C-x C-b") 'ibuffer)

;; Hint from
;; http://www.reddit.com/r/emacs/comments/d7p2n/autojump_for_emacs/
;; I've just found precisely what I'm after: after hitting C-x C-f or
;; C-x d, you can press M-s, and it does precisely what I want.

;; From http://bc.tech.coop/blog/031002.html
;; CL Hyperspec in Info format in Emacs
;; (global-set-key [(control meta f1)]
;; 		'(lambda ()
;; 		   (interactive)
;; 		   (ignore-errors
;; 		     (info (concatenate 'string "(gcl) " (thing-at-point 'symbol))))))

;; Java-specific configurations
(add-to-list 'load-path (concat +dot-emacs-home+ "elisp/emacs-java"))


(add-hook 'java-mode-hook
  '(lambda ()
     (require 'java-docs)
     (require 'java-mode-plus)))

(eval-after-load "java-docs"
  '(java-docs "~/src/java-documentation/docs/api"))

;; (setq-default mode-line-position
;;   (cons '(:eval (format "[width: %s] " (window-width)))
;;     mode-line-position))

;; TODO: Ver a variavel tags-apropos-additional-actions e
;; tags-revert-without-query

(require 'gtags)
(add-hook 'java-mode-hook '(lambda () (gtags-mode 1)))

;; From: http://emacs-fu.blogspot.com/2009/01/navigating-through-source-code-using.html
(add-hook 'gtags-mode-hook 
  (lambda ()
    (local-set-key (kbd "M-.") 'gtags-find-tag)   ; find a tag, also M-.
    (local-set-key (kbd "M-,") 'gtags-find-rtag)))  ; reverse tag

;; From:
;; http://mytechrants.wordpress.com/2010/03/25/emacs-tip-of-the-day-start-using-ibuffer-asap/
(setq ibuffer-default-sorting-mode 'major-mode)

;; A couple more tips for ibuffer. After marking a couple of buffers:
;; * 'O' - ibuffer-do-occur - Do an occur on the selected buffers.
;; * 'M-s a C-s' - ibuffer-do-isearch - Do an incremental search in the marked buffers.
;; * 'Q' - ibuffer-do-query-replace - Query replace in each of the marked buffers.
;; * '=' - View the differences between this buffer and its associated file.

;; From: http://www.reddit.com/r/emacs/comments/i05v3/emacs_and_pylint/
;; Create configurations for flymake
(defmacro def-flymake-init (mode checker-file)
  "Writes a function called flymake-MODE-init which contains the usual boilerplate for a default flymake initialization."
  `(defun ,(intern (format "flymake-%s-init" mode)) () 
      (let* ((temp-file (flymake-init-create-temp-buffer-copy 
                   'flymake-create-temp-inplace)) 
       (local-file (file-relative-name 
                    temp-file 
                    (file-name-directory buffer-file-name)))) 
  (list (expand-file-name ,checker-file *kanak-flychecker-directory*) (list local-file)))))

(defmacro def-flymake-cleanup (mode extlist)
  "Writes a function called flymake-MODE-cleanup which removes files with specified extensions in current directory."
  `(defun ,(intern (format "flymake-%s-cleanup" mode)) ()
 (when flymake-temp-source-file-name
   (let* ((temp-files
           (mapcar (lambda (ext)
                     (concat 
                      (file-name-sans-extension flymake-temp-source-file-name) ext))
                   ,extlist)))
     (dolist (f temp-files)
       (when (file-exists-p f)
         (flymake-safe-delete-file f)))))
 (flymake-simple-cleanup)))

;; How to use it:
;; (def-flymake-init "python" "pychecker.sh")
;; (add-to-list 'flymake-allowed-file-name-masks '("\\.py\\'" flymake-python-init)) 
;; Note: a shell script needs to return 'true' for it to work with flymake



;; From https://github.com/al3x/emacs (although I've seen something like this before)
(defun rename-file-and-buffer (new-name)
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not filename)
        (message "Buffer '%s' is not visiting a file!" name)
      (if (get-buffer new-name)
          (message "A buffer named '%s' already exists!" new-name)
        (progn
          (rename-file name new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil))))))


(put 'narrow-to-region 'disabled nil)


;; When highlighting a text with the mouse, make that selection
;; avaiable to the C-y even if the mouse highlighted text in another
;; window
;(setq mouse-drag-copy-region t)
(setq x-select-enable-primary t)
;(setq x-select-enable-clipboard nil)

;; TODO: Meter autoload para o lorem-ipsum

;; ;; Eclim emacs
;; (add-to-list 'load-path (expand-file-name "~/src/git/emacs-eclim/"))
;; ;; only add the vendor path when you want to use the libraries provided with emacs-eclim
;; (add-to-list 'load-path (expand-file-name "~/src/git/emacs-eclim/vendor"))
;; (require 'eclim)

;; (setq eclim-auto-save t)
;; (setq eclim-executable "~/src/eclim/eclipse/eclim")
;; (global-eclim-mode)

(load "~/.emacs.d/elisp/nxhtml/autostart.el")
(add-hook 'nxhtml-mumamo-mode-hook 'mumamo-no-chunk-coloring)
(setq mumamo-chunk-coloring 'no-chunks-colored)
(setq mumamo-background-colors nil)
;; Mumamo is making emacs 23.3 and 24.0 freak out:
(when (and (equal emacs-major-version 24)
           (equal emacs-minor-version 0))
  (eval-after-load "bytecomp"
    '(add-to-list 'byte-compile-not-obsolete-vars
                  'font-lock-beginning-of-syntax-function))
  ;; tramp-compat.el clobbers this variable!
  (eval-after-load "tramp-compat"
    '(add-to-list 'byte-compile-not-obsolete-vars
                  'font-lock-beginning-of-syntax-function)))

;; Rinari configurations

(use-package rinari
  :disabled t
  :load-path "elisp/rinari/"
  :init (progn
          (use-package rinari-merb)
          ;; From: https://groups.google.com/group/emacs-on-rails/browse_thread/thread/40bd839c0fbdc781
          (add-to-list 'rinari-major-modes 'vc-dir-mode-hook)))


(setq nxhtml-global-minor-mode t
  mumamo-chunk-coloring 'submode-colored
  nxhtml-skip-welcome t
  indent-region-mode t
  rng-nxml-auto-validate-flag nil
  nxml-degraded t)
(add-to-list 'auto-mode-alist '("\\.html\\.erb$" . eruby-nxhtml-mumamo-mode))

(setenv "RUBYLIB" "/usr/local/lib/site_ruby/1.8")
(setenv "GEM_HOME" "/usr/lib/ruby/gems/1.8/")

(use-package yari
  :init (progn
          (defun ri-bind-key ()
            (local-set-key [f1] 'yari))

          (add-hook 'ruby-mode-hook 'ri-bind-key)))


;; Fontifying Code Buffers In Emacs Org Mode
;; http://irreal.org/blog/?p=671
(setq org-src-fontify-natively t)


;; To use dummy-h-mode
;; http://www.emacswiki.org/emacs-en/dummy-h-mode.el
(use-package dummy-h-mode
  :mode ("\\.h$" . dummy-h-mode)
  :config (add-hook 'dummy-h-mode-hook
            (lambda ()
              (setq dummy-h-mode-default-major-mode 'c++-mode))))

;; (slime-eval '(cl:1+ 1))

(setq tags-revert-without-query t)
(setq compilation-ask-about-save nil)

(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)

(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)


(use-package rvm
  :init (progn
          (rvm-use-default)
          (add-hook 'ruby-mode-hook #'rvm-activate-corresponding-ruby)))          


(use-package haml-mode
  :mode ("\\.haml$" . haml-mode)
  :config (add-hook 'haml-mode #'rinari-minor-mode))


;; From: http://irreal.org/blog/?p=753
(use-package dired-x
  :bind (("C-x C-j" . dired-jump) ; Jump to Dired buffer corresponding to current buffer
          ("C-x 4 C-j" . dired-jump-other-window))) ; Like dired-jump but in other window
          

;; BBDB configuration
;; (add-to-list 'load-path (concat +dot-emacs-home+ "elisp/bbdb-2.35/lisp"))
;; (add-to-list 'load-path (concat +dot-emacs-home+ "elisp/bbdb/lisp"))

;; From: http://emacs-fu.blogspot.pt/2009/08/managing-e-mail-addresses-with-bbdb.html
(setq bbdb-file "~/.emacs.d/bbdb")           ;; keep ~/ clean; set before loading
(use-package bbdb
  :init (progn
          (require 'bbdb)
          (require 'message)
          (bbdb-initialize 'gnus 'message)
          (setq 
            bbdb-offer-save 1 ;; 1 means save-without-asking
            bbdb-mail-allow-redundancy t
    
            bbdb-use-pop-up nil ;; allow popups for addresses
            bbdb-electric-p t   ;; be disposable with SPC
            bbdb-popup-target-lines  1 ;; very small
    
            bbdb-dwim-net-address-allow-redundancy t ;; always use full name
            bbdb-quiet-about-name-mismatches 2 ;; show name-mismatches 2 secs

            bbdb-always-add-address t ;; add new addresses to existing...
            ;; ...contacts automatically
            bbdb-canonicalize-redundant-nets-p t ;; x@foo.bar.cx => x@bar.cx

            bbdb-completion-type nil ;; complete on anything

            bbdb-complete-name-allow-cycling t ;; cycle through matches
            ;; this only works partially

            bbbd-message-caching-enabled t ;; be fast
            bbdb-use-alternate-names t     ;; use AKA


            bbdb-elided-display t ;; single-line addresses

            ;; auto-create addresses from mail
            bbdb/mail-auto-create-p 'bbdb-ignore-some-messages-hook   
            bbdb-ignore-some-messages-alist ;; don't ask about fake addresses
            ;; NOTE: there can be only one entry per header (such as To, From)
            ;; http://flex.ee.uec.ac.jp/texi/bbdb/bbdb_11.html

            '(( "From" . "no.?reply\\|DAEMON\\|daemon\\|facebookmail\\|twitter")))

          ;; From: http://www.mostlymaths.net/2010/12/emacs-30-day-challenge-glimpse-of-bbdb.html
          (bbdb-insinuate-message)
          (add-hook 'gnus-startup-hook 'bbdb-insinuate-gnus)
          (setq bbdb-send-mail-style 'gnus)
          (setq bbdb-complete-name-full-completion t)

          (setq bbdb-completion-display-record nil)))


(add-to-list 'auto-mode-alist '("Gemfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile$" . ruby-mode))

(use-package yaml-mode
  :mode ("\.yml$" . yaml-mode))

(use-package pivotal-tracker
  :load-path "elisp/my-version-pivotal-tracker/"
  :commands pivotal
  :config (load (concat +dot-emacs-home+ "elisp/my-version-pivotal-tracker/key.el")))
(setq history-length 1000)
(setq kill-ring-max 500)
(setq global-mark-ring-max 100)
(setq mark-ring-max 100)
(setq message-log-max 1000)
(setq regexp-search-ring-max 50)
(setq search-ring-max 50)
(use-package elisp-slime-nav
  :init (add-hook 'emacs-lisp-mode-hook '(lambda ()
                                   (elisp-slime-nav-mode t))))
;; From: http://blog.printf.net/articles/2007/10/15/productivity-a-year-on
(defun find-tag-at-point ()
  "*Find tag whose name contains TAGNAME.
  Identical to `find-tag' but does not prompt for
  tag when called interactively;  instead, uses
  tag around or before point."
  (interactive)
  (if current-prefix-arg
    (find-tag-tag "Find tag: ")
    (find-tag (find-tag-default))))

(global-set-key (kbd "M-.") 'find-tag-at-point)


(require 'edit-list)


;; From: http://nullprogram.com/blog/2009/05/28/
;; ID: 6a3f3d99-f0da-329a-c01c-bb6b868f3239
(defmacro measure-time (&rest body)
  "Measure and return the running time of the code block."
  (declare (indent defun))
  (let ((start (make-symbol "start")))
    `(let ((,start (float-time)))
       ,@body
       (- (float-time) ,start))))

;; From: http://paste.lisp.org/display/23526
(defun alistp (list)
  (if (listp list)
      (cond ((= 0 (length list))
	     t)
	    ((consp (car list))
	     (alistp (cdr list)))
	    (t nil))
      nil))

(defun make-hash-from-alist (data &rest keyword-args)
  (assert (alistp data) t "DATA is not a valid alist")
  (let ((return-value (if keyword-args
                        (apply #'make-hash-table keyword-args)
                        (make-hash-table))))
    (loop for (key . value) in data
      do (puthash key value return-value))
    return-value))

(defalias '{} 'make-hash-from-alist)

;; From: https://bitbucket.org/tarballs_are_good/qtility/src/423519bbe130/sequence.lisp
(defun subdivide (sequence chunk-size)
  "Split SEQUENCE into subsequences of size CHUNK-SIZE."
  (check-type sequence sequence)
  (check-type chunk-size (integer 1))
  
  (etypecase sequence
    ;; Since lists have O(N) access time, we iterate through manually,
    ;; collecting each chunk as we pass through it. Using SUBSEQ would
    ;; be O(N^2).
    (list (labels ((rec (sequence acc)
                     (let ((rest (nthcdr chunk-size sequence)))
                       (if (consp rest)
                           (rec rest (cons (subseq sequence 0 chunk-size) acc))
                           (nreverse (cons sequence acc))))))
            (and sequence (rec sequence nil))))
    
    ;; For other sequences like strings or arrays, we can simply chunk
    ;; by repeated SUBSEQs.
    (sequence (loop with len = (length sequence)
                    for i below len by chunk-size
                    collect (subseq sequence i (min len (+ chunk-size i)))))))


(defun take (n sequence)
  "Take the first N elements from SEQUENCE."
  (subseq sequence 0 n))

(defun drop (n sequence)
  "Drop the first N elements from SEQUENCE."
  ;; This used to be NTHCDR for lists.
  (subseq sequence n))
(defmacro sort-safe (list predicate)
  "Sort LIST without modifying it using PREDICATE"
  `(sort (copy-sequence ,list) ,predicate))

;; From: http://stackoverflow.com/questions/2199678/how-to-call-latexmk-in-emacs-and-jump-to-next-error
(add-hook 'LaTeX-mode-hook (lambda ()
  (pushnew
    '("Latexmk" "latexmk -pdf %s" TeX-run-TeX nil t
      :help "Run Latexmk on file")
    TeX-command-list
    :test #'equal)))

;; It might also be wise to add something like

;; '("%(-PDF)"
;;   (lambda ()
;;     (if (and (not TeX-Omega-mode)
;;              (or TeX-PDF-mode TeX-DVI-via-PDFTeX))
;;         "-pdf" "")))

;; to TeX-expand-list and use "latexmk %(-PDF) %s" so that it will work in both pdf and dvi mode. Personally, I find it easier to use customize especially when you are experimenting.

(defun pp-current-buffer (thing)
  (pp thing
    (get-buffer (current-buffer))))
(defun what-weekday (date)
  (interactive "sDate: ")
  (with-temp-buffer
    (insert (concat "<" date ">"))
    (org-mode)
    (backward-char 2)
    (org-ctrl-c-ctrl-c)
    (end-of-line)
    (backward-char 2)
    (message "%s" (word-at-point))))
