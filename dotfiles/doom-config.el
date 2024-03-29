;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Anton Davydov"
      user-mail-address "fetsorn@gmail.com")

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
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/mm/modes/agendas/")

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

;;  multitran
(map! "C-c w" 'multitran)

;; language switch
(defun fetsorn-russian ()
  (interactive (set-input-method "russian-computer" t)))
(defun fetsorn-chinese ()
  (interactive (set-input-method "pyim" t)))
(defun fetsorn-sisheng ()
  (interactive (set-input-method "chinese-sisheng" t)))

(map! :n "C-c r" :i "C-c r" 'fetsorn-russian)
(map! :n "C-c c" :i "C-c c" 'fetsorn-chinese)
(map! :n "C-c s" :i "C-c s" 'fetsorn-sisheng)

(setq default-input-method "russian-computer")

;; Example Key binding
;(global-set-key (kbd "C-c y") 'youdao-dictionary-search-at-point)
;(global-set-key (kbd "C-c t") 'youdao-dictionary-search-at-point-tooltip)
;(global-set-key (kbd "C-c o") 'youdao-dictionary-play-voice-at-point)
;(global-set-key (kbd "C-c i") 'youdao-dictionary-search-from-input)

;; Set file path for saving search history
;(setq youdao-dictionary-search-history-file "~/.doom.d/.youdao")

;; Enable Chinese word segmentation support (支持中文分词)
;(setq youdao-dictionary-use-chinese-word-segmentation t)

(defun fetsorn-hanzi2pinyin-at-point (number)       ; Interactive version.
  "Multiply NUMBER by seven."
  (interactive "p")
  (message (pyim-hanzi2pinyin (doom-thing-at-point-or-region))))
(global-set-key (kbd "C-c u") 'fetsorn-hanzi2pinyin-at-point)



;; ledger reports
;; (custom-set-variables
;;  '(ledger-reports
;;    (quote
;;     (("budgetshort" "ledger -f %(ledger-file) bal Budget &&
;;                      ledger -f %(ledger-file) bal Budget > report.txt")
;;      ("budget"      "ledger -f %(ledger-file) --empty -S -T bal Budget")
;;      ("bal"         "ledger -f %(ledger-file) bal --empty")
;;      ("balreal"     "ledger -f %(ledger-file) bal assets --real")
;;      ("reg"         "ledger -f %(ledger-file) reg")
;;      ("payee"       "ledger -f %(ledger-file) reg @%(payee)")
;;      ("account"     "ledger -f %(ledger-file) reg %(account)")))))


;; hledger
;; To open files with .journal extension in ledger-mode
;; better formatting than hledger-mode
(add-to-list 'auto-mode-alist '("\\.journal\\'" . ledger-mode))
;; Provide the path to you journal file.
;; The default location is too opinionated.
(setq hledger-jfile "~/mm/modes/ledgers/2021.journal")
(setq ledger-master-file "~/mm/modes/ledgers/2021.journal")
;;; Auto-completion for account names
;; For company-mode users,
;; (add-to-list 'company-backends 'hledger-company)

;; (require 'flycheck-hledger)


;; org-journal
(map! :n "SPC j" 'org-journal-new-entry)
(setq org-journal-date-format "%A, %Y-%m-%d")

(when (eq system-type 'cygwin)
  (setq org-journal-dir "~/mm/modes/journals/j-nt"))
(when (eq system-type 'gnu/linux)
  (setq org-journal-dir "~/mm/modes/journals/j-gnu"))
(when (eq system-type 'darwin)
  (setq org-journal-dir "~/mm/modes/journals/j-darwin"))





;; org-agenda
(setq org-agenda-files
      (quote ("~/mm/modes/agendas/gtd.org"
              "~/mm/modes/agendas/tbn.org"
              "~/mm/yodes/9d1c52f87a4bc86b2e0c9a857cc5d744fa1d54b9a83b2d932c436f5d80ae1add-folks/anno.org"
              "~/mm/modes/agendas/org-pr.org")))
;; show agenda on startup
(add-hook 'doom-init-ui-hook (lambda () (org-agenda nil "n")) 100)





;; org-roam

(setq org-roam-directory "~/mm/modes/notes/")
(add-hook 'after-init-hook 'org-roam-mode)
(map! :leader
      :prefix "n"
      :desc "Org-Roam-Buffer" "l" #'org-roam-buffer-toggle
      :desc "Org-Roam-Find"   "/" #'org-roam-node-find
      :desc "Org-Roam-Graph"  "g" #'org-roam-graph
      :desc "Org-Roam-Insert" "i" #'org-roam-node-insert
      :desc "Org-Roam-Graph"  "c" #'org-roam-capture)



;; registers
(set-register ?c (cons 'file "~/mm/modes/configs/dotfiles/doom-config.el"))
(set-register ?p (cons 'file "~/mm/modes/configs/dotfiles/doom-packages.el"))
(set-register ?i (cons 'file "~/mm/modes/configs/dotfiles/doom-init.el"))
(set-register ?g (cons 'file "~/mm/modes/agendas/org-gtd.org"))
(set-register ?n (cons 'file "~/mm/modes/agendas/org-note.org"))
(set-register ?l (cons 'file "~/mm/modes/agendas/org-gtp.org"))
(set-register ?t (cons 'file "~/mm/modes/agendas/org-tracking.org"))
(set-register ?v (cons 'file "~/mm/modes/notes/20210630161607-graviton_contracts.org"))







;; calendar
;; show week numbers
(copy-face font-lock-constant-face 'calendar-iso-week-face)
(set-face-attribute 'calendar-iso-week-face nil
                    :height 0.7)
(setq calendar-intermonth-text
      '(propertize
        (format "%2d"
                (car
                 (calendar-iso-from-absolute
                  (calendar-absolute-from-gregorian (list month day year)))))
        'font-lock-face 'calendar-iso-week-face))
(setq calendar-week-start-day 1)





;; tweak doom
;; remove auto-fill-mode that autoinserts newlines
(add-hook 'org-mode-hook (lambda () (auto-fill-mode -1)))
;; make so long mode threshold large to account for my love of long journal lines
(setq so-long-threshold 1000)
;; UTF-8 encoding for all files
(prefer-coding-system 'utf-8)
(when (display-graphic-p)
  (setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING)))
;; override evil movement
(map! :n "C-e" :i "C-e" :v "C-e" 'end-of-line)
(map! :n "C-a" :i "C-a" :v "C-a" 'beginning-of-line)
(map! :n "C-n" :i "C-n" :v "C-n" 'next-line)
(map! :i "C-n" 'next-line)
(map! :n "C-p" :i "C-p" :v "C-p" 'previous-line)
(map! :i "C-p" 'previous-line)
(map! :n "C-f" :i "C-f" :v "C-f" 'forward-char)
(map! :n "C-b" :i "C-b" :v "C-b" 'backward-char)






(setq auto-save-default t)
(setq create-lockfiles t)
;; Legacy backup routine
(setq version-control t     ;; Use version numbers for backups.
      delete-old-versions -1 ;; Don't delete excess backup versions.
      backup-by-copying t)  ;; Copy all files, don't rename them.

(setq vc-make-backup-files t) ;; versioned backups

;; Default and per-save backups go here:
(setq backup-directory-alist '(("" . "~/.doom.d/backup/per-save")))
(setq make-backup-files t)

(defun force-backup-of-buffer ()
  ;; Make a special "per session" backup at the first save of each
  ;; emacs session.
  (when (not buffer-backed-up)
    ;; Override the default parameters for per-session backups.
    (let ((backup-directory-alist '(("" . "~/.doom.d/backup/per-session"))))
      (backup-buffer)))
  ;; Make a "per save" backup on each save.  The first save results in
  ;; both a per-session and a per-save backup, to keep the numbering
  ;; of per-save backups consistent.
  (let ((buffer-backed-up nil))
    (backup-buffer)))

;; All auto-save files  go here:
(setq auto-save-file-name-transforms '((".*" "~/.doom.d/auto-save-list/" t)))

(add-hook 'before-save-hook  'force-backup-of-buffer)

;; Save history.
(setq savehist-file "~/.doom.d/savehist")
(savehist-mode 1)
(setq history-length t)
(setq history-delete-duplicates t)
(setq savehist-save-minibuffer-history 1)
(setq savehist-additional-variables
      '(kill-ring
        search-ring
        regexp-search-ring))









;; enable activity watch
(global-activity-watch-mode)







;; custom clock table for org-gtd

(defun dfeich/org-clock-get-tr-for-ivl (buffer tstart-str tend-str &optional limit)
  "Return clocking information touching a given time interval."
  (cl-assert (and buffer (get-buffer buffer)) nil "Error: :buffer must be defined")
  (with-current-buffer buffer
    (save-excursion
      (let ((re (concat "^\\(\\*+[ \t]*.*\\)\\|^[ \t]*"
                        org-clock-string
                        "[ \t]*\\(?:\\(\\[.*?\\]\\)-+\\(\\[.*?\\]\\)\\|=>[ \t]+\\([0-9]+\\):\\([0-9]+\\)\\)"))
            (counter 0)
            (tmphd "BEFORE FIRST HEADING")
            (tstart (org-time-string-to-seconds tstart-str))
            (tend (org-time-string-to-seconds tend-str))
            (limit (or limit (point-max)))
            headings timelst
            lvl title result ts te)
        (goto-char (point-min))
        (cl-block myblock
          (while (re-search-forward re nil t)
            (cond
             ;; found a org heading
             ((match-end 1)
              (if (> (length timelst) 0)
                  (setq result (nconc result (list (list
                                                    (copy-sequence headings)
                                                    timelst)))))
              (setq tmphd (org-heading-components)
                    lvl (car tmphd)
                    title (nth 4 tmphd)
                    timelst nil)
              ;; maintain a list of the current heading hierarchy
              (cond
               ((> lvl (length headings))
                (setq headings  (nconc headings `(,title))))
               ((= lvl (length headings))
                (setf (nth (1- lvl) headings) title))
               ((< lvl (length headings))
                (setq headings (cl-subseq headings 0 lvl))
                (setf (nth (1- lvl) headings) title))))
             ;; found a clock line with 2 timestamps
             ((match-end 3)
              (setq ts (save-match-data (org-time-string-to-seconds
                                         (match-string-no-properties 2)))
                    te (save-match-data (org-time-string-to-seconds
                                         (match-string-no-properties 3))))
              ;; the clock lines progress from newest to oldest. This
              ;; enables skipping the rest if this condition is true
              (if (> tstart te)
                  (if (re-search-forward "^\\(\\*+[ \t]*.*\\)" nil t)
                      (beginning-of-line)
                    (goto-char (point-max)))
                (when (> tend ts)
                  (setq timelst (nconc timelst (list
                                                (list (match-string-no-properties 2)
                                                      (match-string-no-properties 3)))))))))
            (when (>= (point) limit)
              (cl-return-from myblock))))
        (if (> (length timelst) 0)
            (setq result (nconc result (list (list (copy-sequence headings)
                                                   timelst)))))
        result))))

(defun org-dblock-write:fetsorn/report (params)
  "Fill in a dynamic timesheet reporting block."
  (let* ((tasks (dfeich/org-clock-get-tr-for-ivl
                 (buffer-name)
                 (or (plist-get params :start) "1970-01-01")
                 (or (plist-get params :end) (org-format-time-string "%Y-%m-%d" (current-time))))))
    (insert "| Date | Top | Task | In | Out | Duration |\n")
    (insert "|------\n")
    (cl-loop
     for task in tasks
     do (let ((levels (car task))
              (ranges (-last-item task)))
          (cl-loop for range in ranges
                   do (let ((top (car levels))
                            (name (-last-item levels))
                            (tstart (car range))
                            (tend (-last-item range)))
                        (let ((duration (org-table-time-seconds-to-string
                                         (- (org-time-string-to-seconds tend)
                                            (org-time-string-to-seconds tstart))
                                         'hh:mm))
                              (date (org-format-time-string "<%Y-%m-%d %a>" (org-time-string-to-time tstart))))
                          (insert
                           "|" date
                           "|" top
                           "|" name
                           "|" tstart
                           "|" tend
                           "|" duration
                           "\n"))))))
    (insert "|------\n")
    (insert "|TOTAL||||\n")
    (insert "#+TBLFM: @>$>=vsum(@I..@>>);U")
    (search-backward "Date")
    (org-table-align)
    (org-table-recalculate)
    (org-table-goto-column 1)
    (org-table-goto-line 3)
    (org-table-sort-lines nil ?T)))





(defun insert-random-uuid ()
  (interactive)
  (shell-command "uuidgen" t))

(map! "C-c d" 'insert-random-uuid)

(defun insert-random-sha256 ()
  (interactive)
  (insert (secure-hash 'sha256 (shell-command-to-string "uuidgen"))))

(map! "C-c a" 'insert-random-sha256)

(map! "C-c ESC ESC" 'vterm-send-escape)


; insert lambda for writing lambda expressions
(defun fetsorn-insert-lambda ()
  (interactive)
  (insert-char 955 1 t))

(map! "C-c l" 'fetsorn-insert-lambda)

(setq exec-path (append exec-path '("/Users/fetsorn/.cabal/bin") '("/Users/fetsorn/.ghcup/bin")))


; should add an option to ediff for saving both conflicting changes
; https://stackoverflow.com/questions/9656311/conflict-resolution-with-emacs-ediff-how-can-i-take-the-changes-of-both-version#29757750
(defun ediff-copy-both-to-C ()
  (interactive)
  (ediff-copy-diff ediff-current-difference nil 'C nil
                   (concat
                    (ediff-get-region-contents ediff-current-difference 'A ediff-control-buffer)
                    (ediff-get-region-contents ediff-current-difference 'B ediff-control-buffer))))
(defun add-d-to-ediff-mode-map () (define-key ediff-mode-map "d" 'ediff-copy-both-to-C))
(add-hook 'ediff-keymap-setup-hook 'add-d-to-ediff-mode-map)

; bandaid for org-mode function definition is void: ad-Advice-newline-and-indent doom-emacs#3172
; https://github.com/hlissner/doom-emacs/issues/3172#issuecomment-683259265
(add-hook 'org-mode-hook (lambda () (electric-indent-local-mode -1)))

;; TODO find what breaks org-mode hideblocks in Doom

(insert-char 23478) ;;家

(defun org-roam-insert-fetsorn (&optional lowercase completions filter-fn description link-type)
  "Find an Org-roam file, and insert a relative org link to it at point.
 Return selected file if it exists.
 If LOWERCASE is non-nil, downcase the link description.
 LINK-TYPE is the type of link to be created. It defaults to \"file\".
 COMPLETIONS is a list of completions to be used instead of
 `org-roam--get-title-path-completions`.
 FILTER-FN is the name of a function to apply on the candidates
 which takes as its argument an alist of path-completions.
 If DESCRIPTION is provided, use this as the link label.  See
 `org-roam--get-title-path-completions' for details."
  (interactive "P")
  (unless org-roam-mode (org-roam-mode))
  ;; Deactivate the mark on quit since `atomic-change-group' prevents it
  (unwind-protect
      ;; Group functions together to avoid inconsistent state on quit
      (atomic-change-group
        (let* (region-text
               beg end
               (_ (when (region-active-p)
                    (setq beg (set-marker (make-marker) (region-beginning)))
                    (setq end (set-marker (make-marker) (region-end)))
                    (setq region-text (org-link-display-format (buffer-substring-no-properties beg end)))))
               (completions (--> (or completions
                                     (org-roam--get-title-path-completions))
                              (if filter-fn
                                  (funcall filter-fn it)
                                it)))
               (title-with-tags (org-roam-completion--completing-read "File: " completions
                                                                      :initial-input region-text))
               (res (cdr (assoc title-with-tags completions)))
               (title (or (plist-get res :title)
                          title-with-tags))
               (target-file-path (plist-get res :path))
               (description (or description region-text title))
               (description (if lowercase
                                (downcase description)
                              description)))
          (cond ((and target-file-path
                      (file-exists-p target-file-path))
                 (when region-text
                   (delete-region beg end)
                   (set-marker beg nil)
                   (set-marker end nil))
                 (insert (org-roam-format-link target-file-path description link-type) ", ")) ;; change
                (t
                 (let ((org-roam-capture--info `((title . ,title-with-tags)
                                                 (slug . ,(funcall org-roam-title-to-slug-function title-with-tags))))
                       (org-roam-capture--context 'title))
                   (setq org-roam-capture-additional-template-props (list :region (org-roam-shield-region beg end)
                                                                          :insert-at (point-marker)
                                                                          :link-type link-type
                                                                          :link-description description
                                                                          :finalize 'insert-link))
                   (org-roam-capture--capture))))
          res))
    (deactivate-mark)))

(use-package! org-roam
  :config
  (fset 'org-roam-insert #'org-roam-insert-fetsorn))

(setq enable-local-variables t)

;(defun fetsorn-insert-g ()
;  (interactive (insert-char 103 1 t)))
;
;(map! "C-c k" 'fetsorn-insert-g)


;; Set our nickname & real-name as constant variables
;(setq
; erc-nick "fetsorn"     ; Our IRC nick
; erc-user-full-name "fetsorn") ; Our /whois name

;; Define a function to connect to a server
;(defun erc-oftc ()
;  (lambda ()
;  (interactive)
;  (erc-tls :server "irc.oftc.net"
;           :port   "6697")))

;; mu4e
;(after! mu4e
;  (setq sendmail-program (executable-find "msmtp")
;        send-mail-function #'smtpmail-send-it
;        message-sendmail-f-is-evil t
;        message-sendmail-extra-arguments '("--read-envelope-from")
;        message-send-mail-function #'message-send-mail-with-sendmail))
;
;(set-email-account! "anton@fetsorn.website"
;  '((mu4e-sent-folder       . "/anton/Sent")
;    (mu4e-drafts-folder     . "/anton/Drafts")
;    (mu4e-trash-folder      . "/anton/Junk")
;    (mu4e-refile-folder     . "/anton/All")
;    (smtpmail-smtp-user     . "anton@fetsorn.website")
;    (mu4e-compose-signature . "---\nYours truly"))
;  t)
;(set-email-account! "git@fetsorn.website"
;  '((mu4e-sent-folder       . "/git/Sent")
;    (mu4e-drafts-folder     . "/git/Drafts")
;    (mu4e-trash-folder      . "/git/Junk")
;    (mu4e-refile-folder     . "/git/All")
;    (smtpmail-smtp-user     . "git@fetsorn.website")
;    (mu4e-compose-signature . "---\nYours truly"))
;  t)
;(set-email-account! "fetsorn@fetsorn.website"
;  '((mu4e-sent-folder       . "/fetsorn/Sent")
;    (mu4e-drafts-folder     . "/fetsorn/Drafts")
;    (mu4e-trash-folder      . "/fetsorn/Junk")
;    (mu4e-refile-folder     . "/fetsorn/All")
;    (smtpmail-smtp-user     . "fetsorn@fetsorn.website")
;    (mu4e-compose-signature . "---\nYours truly"))
;  t)
;(set-email-account! "auth@fetsorn.website"
;  '((mu4e-sent-folder       . "/auth/Sent")
;    (mu4e-drafts-folder     . "/auth/Drafts")
;    (mu4e-trash-folder      . "/auth/Junk")
;    (mu4e-refile-folder     . "/auth/All")
;    (smtpmail-smtp-user     . "auth@fetsorn.website")
;    (mu4e-compose-signature . "---\nYours truly"))
;  t)

;(defun fetsorn-insert-rightarrow ()
;  (interactive)
;  (insert "\\Rightarrow"))
;
;(map! "C-c f" 'fetsorn-insert-rightarrow)
;
;(defun fetsorn-insert-leftrightarrow ()
;  (interactive)
;  (insert "\\Leftrightarrow"))
;
;(map! "C-c e" 'fetsorn-insert-leftrightarrow)

(setq auth-sources '("~/.authinfo" macos-keychain-generic macos-keychain-internet "/Users/fetsorn/.emacs.d/.local/etc/authinfo.gpg" "~/.authinfo.gpg"))

(use-package org-jira
 :demand t
 :init
 (setq jiralib-url "https://norcivilianlabs.atlassian.net")
 (setq org-jira-working-dir "~/mm/modes/agendas/.org-jira"))

;(defun fetsorn-switch-jira ()
;  (interactive)
;  (setq jiralib-url "https://example.atlassian.net")
;  (setq jiralib-token '())
;  (setq org-jira-working-dir "/path/to/folder"))
;
;(map! "C-c a" 'fetsorn-switch-jira)

;; emacspeak
(defun fetsorn-emacspeak-load ()
  (interactive)
  (setenv "DTK_PROGRAM" "mac")
  (setq dtk-program "mac")
  (add-to-list 'load-path "~/.emacs.d/emacspeak/lisp")
  (load  "~/.emacs.d/emacspeak/lisp/emacspeak-setup.el"))

(setq rustic-rustfmt-config-alist '(("edition" . "2021")))
