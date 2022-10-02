;;; emacspeak.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2022 Anton Davydov
;;
;; Author: Anton Davydov <fetsorn@gmail.com>
;; Maintainer: Anton Davydov <fetsorn@gmail.com>
;; Created: August 28, 2022
;; Modified: August 28, 2022
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex tools unix vc wp
;; Homepage: https://github.com/fetsorn/emacspeak
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:

;; not needed on mac ./dtk-speak.el:L69
;; export DTK_PROGRAM=mac

;; adds the emacspeak repo to the load-path
(add-to-list 'load-path "~/mm/codes/emacspeak")

;; load emacspeak
(load  "~/mm/codes/emacspeak/lisp/emacspeak-setup.el")

;; (provide 'emacspeak)
;;; emacspeak.el ends here
