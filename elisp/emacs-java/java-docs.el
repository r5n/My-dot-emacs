;;; java-docs.el --- Java documentation Emacs integration

;; Copyright (C) 2010 Christopher Wellons <mosquitopsu@gmail.com>

;; This file is NOT part of GNU Emacs.

;; Permission to use, copy, modify, and distribute this software for
;; any purpose with or without fee is hereby granted, provided that
;; the above copyright notice and this permission notice appear in all
;; copies.

;; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
;; WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
;; WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
;; AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
;; CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
;; OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
;; NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
;; CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

;;; Commentary:

;; This package provides a quick way to look up any Javadoc
;; documentation from Emacs, using your browser to display the
;; information. Since the mechanism is already there, it also provides
;; the completing function `insert-java-import' for quickly adding an
;; import to a source file.

;; To install, just drop somewhere on your `load-path' and put this in
;; your .emacs,

;; (require 'java-docs)

;; Give `java-docs' your root Java documentation directories. It will
;; scan and index those directories, exposing them to
;; `java-docs-lookup'. You can provide multiple directories at once,
;; for example,

;;   (java-docs "/usr/share/doc/openjdk-6-jdk/api" "~/src/project/doc")

;; For your convenience, lookups can then be done with C-h j.

;; When viewing docs, a browser is fired off with `browse-url'. You
;; may have to set your `browse-url-browser-function' to make this
;; work properly. For example,

;;   (setq browse-url-browser-function 'browse-url-firefox)

;; I strongly recommend using ido-mode in conjunction with
;; java-docs. It becomes really easy to type in what you're looking
;; for. To set this up properly, make sure ido-mode is enabled before
;; loading java-docs.

;; If you're using a recent enough version of emacs, the indexes will
;; be cached in the directory specified in `java-docs-cache-dir', for
;; the purpose of faster loading. If the documentation is updated,
;; just delete the cache directory and it will be recreated.

;;; Code:

(provide 'java-docs)

(require 'cl)
(require 'ido)

(global-set-key "\C-hj" 'java-docs-lookup)

(defvar java-docs-enable-cache (featurep 'hashtable-print-readable)
  "Enable caching for faster loads.")

(defvar java-docs-compress-cache (executable-find "gzip")
  "Compress the cache using gzip.")

(defvar java-docs-cache-dir "~/.java-docs"
  "Location to store index information.")

(defvar java-docs-index (make-hash-table :test 'equal)
  "Index of documentation for quick lookups.")

(defvar java-docs-class-list nil
  "List of classes in the index.")

(defvar java-docs-full-class-list nil
  "Fully qualified names of classes in the index.")

(defvar java-docs-completing-function
  (if ido-mode 'ido-completing-read 'completing-read)
  "Function used when performing a minibuffer read.")

(defvar java-docs-full-class t
  "Use the fully qualified class name when indexing.")

(defvar java-docs-current-root nil
  "Current root being indexed. Used to determine full class name.")

(defvar java-docs-cache-version "-v2"
  "Cache version, so we don't load the wrong cache.")

(defun java-docs (&rest dirs)
  "Set the Javadoc search path to DIRS and index them."
  (dolist (java-docs-current-root dirs)
    (java-docs-add java-docs-current-root))
  (setq java-docs-class-list
	(sort* java-docs-class-list '< :key 'length))
  (setq java-docs-full-class-list
	(sort* java-docs-full-class-list '< :key 'length)))

(defun java-docs-clear ()
  "Clear all in-memory java-docs information."
  (setq java-docs-class-list nil)
  (setq java-docs-full-class-list nil)
  (setq java-docs-index (make-hash-table :test 'equal)))

(defun java-docs-add (dir)
  "Add directory to directory list and either index or fetch the cache."
  (let ((cache-name (concat (md5 dir) java-docs-cache-version
			    (if java-docs-compress-cache ".gz" "")))
	(hash (make-hash-table :test 'equal)))
    (if (and java-docs-enable-cache
	     (file-exists-p (concat java-docs-cache-dir "/" cache-name)))
	(java-docs-load-cache cache-name)
      (java-docs-index dir hash)
      (java-docs-save-cache cache-name hash)
      (java-docs-add-hash hash))))

(defun java-docs-load-cache (cache-name)
  "Load a cache from disk."
  (let ((file (concat java-docs-cache-dir "/" cache-name)))
    (with-current-buffer (find-file-noselect file)
      (goto-char (point-min))
      (java-docs-add-hash (read (current-buffer)))
      (setq java-docs-full-class-list
	    (append java-docs-full-class-list (read (current-buffer))))
      (kill-buffer))))

(defun java-docs-save-cache (cache-name hash)
  "Save a cache to the disk."
  (when java-docs-enable-cache
    (if (not (file-exists-p java-docs-cache-dir))
	(make-directory java-docs-cache-dir))
    (with-temp-buffer
      (insert (prin1-to-string hash))
      (insert (prin1-to-string java-docs-full-class-list))
      (write-file (concat java-docs-cache-dir "/" cache-name)))))

(defun java-docs-add-hash (hash)
  "Combine HASH into the main index hash."
  (maphash (lambda (key val)
	     (puthash key val java-docs-index)
	     (setq java-docs-class-list (cons key java-docs-class-list)))
	   hash))

(defun java-docs-update-list ()
  "Update the completion list to match the index."
  (setq java-docs-class-list nil)
  (maphash (lambda (key val)
	     (setq java-docs-class-list (cons key java-docs-class-list)))
	   java-docs-index))

(defun java-docs-index (dir hash)
  "Index the documentation in DIR into HASH."
  (let* ((list (directory-files dir t "^[^.]"))
	 (files (remove-if 'file-directory-p list))
	 (dirs (remove-if-not 'file-directory-p list)))
    (dolist (file files)
      (java-docs-add-file file hash))
    (dolist (dir dirs)
      (if (not (string-equal "class-use" (file-name-nondirectory dir)))
	  (java-docs-index dir hash)))))

(defun java-docs-add-file (fullfile hash)
  "Add a file to the index if it looks like a class."
  (let* ((file (file-name-nondirectory fullfile))
	 (ext (file-name-extension fullfile))
	 (class (file-name-sans-extension file))
	 (rel (substring fullfile (1+ (length java-docs-current-root))))
	 (fullclass (substitute ?. ?/ (file-name-sans-extension rel)))
	 (case-fold-search nil))
    (when (and (string-equal ext "html")
	       (string-match "^[A-Z].+" class))
      (if java-docs-full-class
	  (puthash fullclass fullfile hash)
        (puthash class fullfile hash))
      (setq java-docs-full-class-list
	    (cons fullclass java-docs-full-class-list)))))

(defun java-docs-lookup (name)
  "Lookup based on class name."
  (interactive (list (funcall java-docs-completing-function
			      "Class: " java-docs-class-list)))
  (let ((file (gethash name java-docs-index)))
    (if file
	(browse-url file))))

;; Insert import functions

(defvar java-docs-import-regexp "^import "
  "Regular expression for finding import statements.")

(defvar java-docs-package-regexp "^package "
  "Regular expression for finding package statements.")

(defun insert-java-import (name)
  "Insert an import statement with the selected class at point."
  (interactive (list (funcall java-docs-completing-function
			      "Class: " java-docs-full-class-list)))
  (insert "import " name ";\n"))

(defun java-in-package ()
  "Return t if this source has a package statement."
  (save-excursion
    (goto-char (point-min))
    (and (search-forward-regexp java-docs-package-regexp nil t) t)))

(defun java-has-import ()
  "Return t if this source has at least one import statement."
  (save-excursion
    (goto-char (point-min))
    (and (search-forward-regexp java-docs-import-regexp nil t) t)))

(defun java-goto-first-import ()
  "Move cursor to the first import statement."
  (goto-char (point-min))
  (search-forward-regexp java-docs-import-regexp)
  (move-beginning-of-line nil))

(defun java-goto-last-import ()
  "Move cursor to the first import statement."
  (goto-char (point-max))
  (search-backward-regexp java-docs-import-regexp)
  (move-end-of-line nil)
  (forward-char))

(defun add-java-import ()
  "Insert an import statement at import section at the top of the file."
  (interactive)
  (save-excursion
    (if (java-has-import)
	(progn
	  (java-goto-first-import)
	  (call-interactively 'insert-java-import))
      (progn
	(goto-char (point-min))
	(if (java-in-package)
	    (search-forward-regexp java-docs-package-regexp))
	(move-end-of-line nil)
	(forward-char)
	(insert "\n")
	(call-interactively 'insert-java-import)))))

;; TODO: This needs a lot of work still. It should be putting the most
;; generic imports first, down to most specific. Once it's working
;; properly it should be called in `add-java-import.'
(defun sort-imports ()
  "Sort the imports in the import section in proper order."
  (interactive)
  (when (java-has-import)
    (save-excursion
      (save-restriction
	(let ((beg (progn
		     (java-goto-first-import)
		     (point)))
	      (end (progn
		     (java-goto-last-import)
		     (point)))
	      (inhibit-field-text-motion t))
	  (narrow-to-region beg end)
	  (goto-char (point-min))
	  (sort-subr nil 'forward-line 'end-of-line
		     nil nil 'java-docs-sort))))))

(defun java-docs-sort (a b)
  "Sort two import statements."
  (let* ((stra (buffer-substring (car a) (cdr a)))
	 (strb (buffer-substring (car b) (cdr b)))
	 (lena (java-docs-package-length stra))
	 (lenb (java-docs-package-length strb)))
    (if (= lena lenb)
	(string< stra strb)
      (< lena lenb))))

(defun java-docs-package-length (import)
  "Return length package part of import statement."
  (- (string-match ".[^.]+$" import) (string-match " [^ ]" import) 1))
