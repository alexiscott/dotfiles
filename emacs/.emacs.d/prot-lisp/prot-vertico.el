;;; prot-vertico.el --- Custom Vertico extras -*- lexical-binding: t -*-

;; Copyright (C) 2023-2025  Protesilaos Stavrou

;; Author: Protesilaos Stavrou <info@protesilaos.com>
;; URL: https://protesilaos.com/emacs/dotemacs
;; Version: 0.1.0
;; Package-Requires: ((emacs "30.1"))

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or (at
;; your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Remember that every piece of Elisp that I write is for my own
;; educational and recreational purposes.  I am not a programmer and I
;; do not recommend that you copy any of this if you are not certain of
;; what it does.

;;; Code:

(require 'vertico)

(defvar prot-vertico-multiform-minimal
  '(unobtrusive
    (vertico-flat-format . ( :multiple  ""
                             :single    ""
                             :prompt    ""
                             :separator ""
                             :ellipsis  ""
                             :no-match  ""))
    (vertico-preselect . prompt))
  "List of configurations for minimal Vertico multiform.
The minimal view is intended to be more private or less
revealing.  This is important when, for example, a prompt shows
names of people.  Of course, such a view also provides a minimal
style for general usage.

Toggle the vertical view with the `vertico-multiform-vertical'
command or use the commands `prot-vertico-private-next' and
`prot-vertico-private-previous', which toggle the vertical view
automatically.")

(defvar prot-vertico-multiform-maximal
  '((vertico-count . 10)
    (vertico-preselect . directory)
    (vertico-resize . t))
  "List of configurations for maximal Vertico multiform.")

(defun prot-vertico--match-directory (str)
  "Match directory delimiter in STR."
  (string-suffix-p "/" str))

;; From the Vertico documentation.
(defun prot-vertico-sort-directories-first (files)
  "Sort directories before FILES."
  (setq files (vertico-sort-alpha files))
  (nconc (seq-filter #'prot-vertico--match-directory files)
         (seq-remove #'prot-vertico--match-directory files)))

(defun prot-vertico-private-next ()
  "Like `vertico-next' but toggle vertical view if needed.
This is done to accommodate `prot-vertico-multiform-minimal'."
  (interactive)
  (if vertico-unobtrusive-mode
      (progn
        (vertico-multiform-vertical)
        (vertico-next 1))
    (vertico-next 1)))

(defun prot-vertico-private-previous ()
  "Like `vertico-previous' but toggle vertical view if needed.
This is done to accommodate `prot-vertico-multiform-minimal'."
  (interactive)
  (if vertico-unobtrusive-mode
      (progn
        (vertico-multiform-vertical)
        (vertico-previous 1))
    (vertico-previous 1)))

(defun prot-vertico-private-complete ()
  "Expand contents and show remaining candidates, if needed.
This is done to accommodate `prot-vertico-multiform-minimal'."
  (interactive)
  (if (and vertico-unobtrusive-mode (> vertico--total 1))
      (progn
        (minibuffer-complete)
        (prot-vertico-private-next))
    (vertico-insert)))

(defun prot-vertico-private-exit ()
  "Exit with the candidate if `prot-vertico-multiform-minimal'.
If there are more candidates that match the given input, expand the
minibuffer to show the remaining candidates and select the first one.
Else do `vertico-exit'."
  (interactive)
  (cond
   ((and (= vertico--total 1)
         (not (eq 'file (vertico--metadata-get 'category))))
    (minibuffer-complete)
    (vertico-exit))
   ((and vertico-unobtrusive-mode
         (not minibuffer--require-match)
         (or (string-empty-p (minibuffer-contents))
             minibuffer-default
             (eq vertico-preselect 'directory)
             (eq vertico-preselect 'prompt)))
    (vertico-exit-input))
   ((and vertico-unobtrusive-mode (> vertico--total 1))
    (minibuffer-complete-and-exit)
    (prot-vertico-private-next))
   (t
    (vertico-exit))))

;; I want to keep `prot-window-define-with-popup-frame' as-is because
;; it is useful for other users as well.  But I also wish to extend it
;; to make Vertico use its buffer mode, if I am running Vertico.  So I
;; do this with an advice even though the proper way would be to
;; modify my macro directly.
(defun prot-vertico-with-buffer-mode (&rest args)
  "Apply ARGS with `vertico-buffer-mode' enabled.
Do so when `prot-emacs-completion-ui' is set to use Vertico.

Add this function as an advice around another."
  (when (eq prot-emacs-completion-ui 'vertico)
    (unwind-protect
        (progn
          (let ((vertico-multiform-categories `((t ,@prot-vertico-multiform-maximal)))
                (vertico-buffer-display-action '(display-buffer-full-frame)))
            (vertico-buffer-mode 1)
            (apply args)))
      (vertico-buffer-mode -1))))

(with-eval-after-load 'prot-window
  (dolist (command '(prot-window-popup-org-capture
                     prot-window-popup-tmr
                     prot-window-popup-prot-project-switch))
    (advice-add command :around #'prot-vertico-with-buffer-mode)))

(provide 'prot-vertico)
;;; prot-vertico.el ends here
