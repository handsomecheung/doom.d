;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "hc"
      user-mail-address "handsomecheung@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(if (not (display-graphic-p))
      (load-theme 'doom-dark+ t)
  (load-theme 'doom-one t))

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


(setq browse-url-browser-function 'eww-browse-url)

(map! :leader
      :desc "Search web for text between BEG/END"
      "s w" #'eww-search-words
      (:prefix ("e" . "evaluate/EWW")
       :desc "Eww web browser" "w" #'eww
       :desc "Eww reload page" "R" #'eww-reload))


(defun org-babel-execute:shell-remote (body params)
  "Execute a block of Nim code with org-babel."
  (message "executing shell-remote source code block")
  (let ((script (org-babel-temp-file "n" (format ".shell-remote.%s.sh" (format-time-string "%Y%m%d-%H%M%S"))))
        (target (or (cdr (assq :target params)) "")))
    (with-temp-file script
      (insert body))
    (org-babel-eval
     (format "shell-remote.sh --script '%s' --target '%s'"
             (org-babel-process-file-name script) target)
     "")))

(defun org-babel-execute:shell-xargs (body params)
  "Execute a block of Nim code with org-babel."
  (message "executing shell-remote source code block")
  (let ((script (org-babel-temp-file "n" (format ".shell-xargs.%s.sh" (format-time-string "%Y%m%d-%H%M%S"))))
        (prefix (or (cdr (assq :prefix params)) "")))
    (with-temp-file script
      (insert body))
    (org-babel-eval
     (format "shell-xargs.sh --script '%s' --prefix '%s'"
             (org-babel-process-file-name script) prefix)
     "")))

(map! :leader
      (:prefix ("d" . "dired")
       :desc "Open dired" "d" #'dired
       :desc "Dired jump to current" "j" #'dired-jump)
      )

(defun my-repo-root-name ()
  (file-name-sans-extension (file-name-nondirectory (directory-file-name (shell-command-to-string "git config --get remote.origin.url")))))

(defun ripple/create-merge-request ()
  "create ripple merge request from issue title."
  (interactive)
  (let* ((repo-name (my-repo-root-name))
         (issue-title (read-string "Issue title: "))
         (output (shell-command-to-string
                  (format "ripple-gitlab.sh '%s' \"%s\"" repo-name issue-title)))
         (response (json-read-from-string output))
         (source-branch (cdr (assoc 'source_branch response))))
    (message (format "branch: %s" source-branch))))
