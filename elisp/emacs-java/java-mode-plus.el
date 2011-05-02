;;; java-mode-plus.el --- Java and java-mode Emacs enhancements

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

;;; Install:

;; Put this file somewhere on your load path (like in .emacs.d), and
;; require it. That's it!

;;    (require 'java-mode-plus)

;;; Commentary:

;; This package provides a hook that sets up extra features to enhance
;; java-mode a bit when using an Ant-based project. This is something
;; to do *instead* of using a large extension like JDEE, which is
;; large, complex, difficult to set up, and doesn't work very well
;; anyway.

;; I'm not a fan of giant IDEs. In a corporate setting, someone who
;; doesn't know what they're doing will usually pick a big IDE for you
;; make it difficult to use anything else. I think everyone should be
;; able to use their preferred source editing tools, whether it be
;; Emacs, Vim, or Eclipse.

;; The unix-way is to make many small, well-defined and well-focused
;; programs do all the work, so that's what I recommend below. Ant for
;; project management, AStyle for syntactic style, Checkstyle for
;; semantic style, and (not so small) Emacs as the magic wand that
;; directs all the tools. It's like The Sorcerer's Apprentice, but
;; with better results.

;; With all the tools, the only downside compared to a big Java IDE is
;; no tool has a complete understanding of the code base. Java is a
;; verbose language and it helps when you can get the computer to fill
;; in all the redundant details for you. I don't think Emacs will ever
;; be able to do this effectively. However, I think Emacs provides
;; plenty of advantages to counter that level of code awareness.

;; It is strongly recommended to use in conjunction with this package:
;;
;; * java-docs - Found alongside java-mode-plus. Provides the
;;               `insert-java-import' function for quickly adding
;;               import statements.
;;
;; * ido-mode - Packaged with Emacs for great minibuffer completion.
;;
;; * winner-mode - Maximize Emacs, split into a bunch of windows, and
;;                 hop around them quickly with this.

;; Enhancements to java-mode:

;; * `ant-compile' - Like normal `compile', but automatically search
;;     up the path looking for a build.xml.

;; * `open-java-project' - Use this on your project's root
;;     directory. Open up an entire source hierarchy at once, making
;;     it easy to switch between source files with ido-mode, and at
;;     the same time exposing lots of names for `dabbrev-expand'
;;     (M-/) to use.

;; * `create-ant-target' - Create a function that calls and with a
;;     certain target. This is used in the java-mode hook to set up
;;     bindings for common Ant targets.
;;
;;     * C-c C-j c - the default Ant target
;;     * C-c C-j C - "clean" target
;;     * C-c C-j r - "run" target
;;     * C-c C-j t - "test" target
;;     * C-c C-j y - "check" target, if you're using Checkstyle
;;     * C-c C-j f - "format" target, if you set up a Java indenter

;; * `insert-java-import' - If you have java-docs set up, you can
;;     access the quick import insertion function.
;;
;;     * C-c C-j i - quickly select an import to insert

;; Recommended usage:

;; A typical Ant-based (or also Maven) project typically consists of a
;; directory layout like so,

;;   src/    - source files
;;   test/   - JUnit test source
;;   doc/    - documentation, including generated Javadoc docs
;;   dist/   - final deliverable, created and destroyed by Ant
;;   build/  - generated/compiled files, created and destroyed by Ant

;; See my SampleJavaProject for an example of this in action,
;; http://git.nullprogram.com/?p=SampleJavaProject.git;a=summary

;; Like using the mouse, I like to avoid dropping to a shell whenever
;; I can, even if that shell is inside Emacs. If I can stay inside the
;; context of Emacs, that's really what I prefer to do. Emacs provides
;; a generic front end to various source management systems (`vc-*'),
;; but my favorite one is Git. I use Magit to interface with Git, and
;; I rarely have to visit the shell to perform maintenance. Figure out
;; what works best for you.

;; Use Emacs in daemon mode! This got *really* good in recent versions
;; of Emacs, so use it! You can either fire off an 'emacs --daemon'
;; when you first log in, and then use 'emacsclient' later, or you can
;; use "emacsclient -ca ""' any time you need to use Emacs, which will
;; create a daemon for you if needed. As you'll see below, once you're
;; set up with your project, you don't want to make Emacs do it all
;; over again when you get back from lunch.

;; You'll want to dedicate a(n Emacs) window specifically to the
;; *compilation* buffer. Any time you do a compilation, it will
;; reliably be done here, rather than hopping around to various
;; windows. I make mine a half-tall window on the top right.

;; So when you sit down to do some work at a fresh Emacs instance, the
;; first thing you will do is run `open-java-project' on your
;; project's root directory (this may not be practical on very large
;; projects). This will open all of your sources so they're very
;; accessible. Using ido-mode will make switching between the sources
;; pretty zippy.

;; To help navigate, take advantage of a TAGS file. Use `find-tag'
;; (M-.) to move around your source. You can set up an Ant "tags"
;; target like so,

;; <target name="tags" description="Generate a TAGS file for your editor.">
;;   <delete file="TAGS"/>
;;   <apply executable="etags">
;;     <arg value="-a"/>
;;     <fileset dir="src" includes="**/*.java"/>
;;     <fileset dir="test" includes="**/*.java"/>
;;   </apply>
;; </target>

;; Hack away at the code, using `dabbrev-expand' and family to help
;; save time typing. When it comes time to compile, use the C-c C-j c
;; binding. Need to run your program? Use the C-c C-j r binding, and
;; it will launch from Emacs. Use C-x ` to step through and correct
;; the errors.

;; With tabs turned off (`indent-tabs-mode'), Emacs should do a good
;; job of indentation, but a tool like Artistic Style (AStyle) can
;; tidy up a bit better. Use C-c C-j f to syntactically tidy up your
;; changes (and you'll need to `revert-buffer' to get the style fixes
;; in the buffer, so I recommend binding it to something). I recommend
;; setting up a "format" target to do this like so,

;; <target name="format" description="Run the indenter on all source files.">
;;   <apply executable="astyle">
;;     <arg value="--mode=java"/>
;;     <arg value="--suffix=none"/>
;;     <fileset dir="src" includes="**/*.java"/>
;;     <fileset dir="test" includes="**/*.java"/>
;;   </apply>
;; </target>

;; Adjust to taste.

;; AStyle checked your syntax style, so next Checkstyle can check your
;; semantic style. So if you're using Checkstyle, which I also
;; recommend, you'll use C-c C-j y to check and correct (with C-x `)
;; any issues.

;; Once you're satisfied, use your preferred Emacs SCM interface to
;; check in your code. Repeat.

;; If you want to run a particular target not bound to a short key
;; binding, use `ant-compile', which will ask you for the Ant command
;; you want to use. You can run this from any source file, and it will
;; go find your build.xml. No need to add a "-find".

;; Closing remarks:

;; As I develop and improve my Java workflow, I'm gradually building
;; up java-mode-plus to match. As long as I continue to use Java, this
;; package will slowly grow.

;;; Code:

(provide 'java-mode-plus)

(defvar open-java-project-extensions '("xml" "java" "properties")
  "File extensions to be opened when using `open-java-project'.")

(defun ant-compile ()
  "Traveling up the path, find build.xml file and run compile."
  (interactive)
  (with-temp-buffer
    (while (and (not (file-exists-p "build.xml"))
                (not (equal "/" default-directory)))
      (cd ".."))
    (call-interactively 'compile)))

(defun open-java-project-file-p (file)
  "Determine if file should be opened by `open-java-project'."
  (let ((ext (file-name-extension file)))
    (member ext open-java-project-extensions)))

;; ID: 72dc0a9e-c41c-31f8-c8f5-d9db8482de1e
(defun open-java-project (dir)
  "Open all java and xml source files and sub-directories below
the given directory."
  (interactive "DBase directory: ")
  (let* ((list (directory-files dir t "^[^.]"))
         (files (remove-if 'file-directory-p list))
         (dirs (remove-if-not 'file-directory-p list)))
    (dolist (file files)
      (if (open-java-project-file-p file)
	  (find-file-noselect file)))
    (dolist (dir dirs)
      (find-file-noselect dir)
      (open-java-project dir))))

;; Add the very handy binding from java-docs
(define-key java-mode-map (kbd "C-c C-j i") 'add-java-import)

;;; Define bindings for various Ant targets

(defmacro ant-bind (key target)
  "Define a key binding for an Ant target in java-mode."
  `(define-key java-mode-map ,key (lambda () (interactive)
				    (compile (concat "ant -emacs " ,target " -find")))))

(ant-bind (kbd "C-c C-j c") "")		; default Ant target
(ant-bind (kbd "C-c C-j C") "clean")
(ant-bind (kbd "C-c C-j r") "run")
(ant-bind (kbd "C-c C-j t") "test")
(ant-bind (kbd "C-c C-j y") "check")
(ant-bind (kbd "C-c C-j f") "format")

(defun java-mode-short-keybindings ()
  "Create (old) short bindings for java-mode."
  (interactive)
  (ant-bind (kbd "C-x c") "")
  (ant-bind (kbd "C-x C") "clean")
  (ant-bind (kbd "C-x r") "run")
  (ant-bind (kbd "C-x t") "test")
  (ant-bind (kbd "C-x y") "check")
  (ant-bind (kbd "C-x f") "format")
  (define-key java-mode-map (kbd "C-x I") 'add-java-import))

;; This is here for the sake of the "run" Ant target above, so you can
;; see your program's output live.
(setq compilation-scroll-output t)
