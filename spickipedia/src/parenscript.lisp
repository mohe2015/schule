(in-package :cl-user)
(defpackage spickipedia.parenscript
  (:use :cl :parenscript :ppcre)
  (:export :file-js-gen
	   :js-files))
(in-package :spickipedia.parenscript)

(defun js-files ()
  (loop for parenscript-file in (directory #P"js/*.lisp")
	      when (not (equal (file-namestring parenscript-file) "common.lisp")) collect parenscript-file))

(defun file-js-gen (file)
  (in-package :spickipedia.parenscript)
  (get-routes)
  (format t "~a" (concatenate 'string (alexandria:read-file-into-string #P"js/common.lisp") (alexandria:read-file-into-string file)))
  (with-input-from-string (s (concatenate 'string (alexandria:read-file-into-string #P"js/common.lisp") (alexandria:read-file-into-string file)))
    (let ((content (ps-compile-stream s)))
      (in-package :common-lisp-user)
      content)))
  

(defun find-defroute (code)
  (let ((routes ()))
    (loop for list in code do
	 (if (listp list)
	     (if (eql (car list) 'defroute)
		 (push (car (cdr list)) routes)
		 (setf routes (append (find-defroute list) routes)))))
    routes))

(defun get-sexp (file)
   (with-open-file (stream file)
    (loop for line = (read stream)
       collect line
       while (peek-char nil stream nil nil t))))

;; THIS IS AN UGLY HACK
(defun get-routes ()
  (defparameter
      *ROUTES*
   (append `(progn) (mapcar
     #'(lambda (r)
	 `(if (,(make-symbol (concatenate 'string "handle-" (subseq (regex-replace-all "\/:?" r "-") 1))) (chain window location pathname))
	      (return-from update-state)))
     (find-defroute (get-sexp "js/index.lisp")))))
  (defparameter *UPDATE-STATE*
    `(defun update-state ()
       (setf (chain window last-url) (chain window location pathname))
       (if (undefined (chain window local-storage name))
	   (chain ($ "#logout") (text "Abmelden"))
	   (chain ($ "#logout") (text (concatenate 'string (chain window local-storage name) " abmelden"))))
       (if (and (not (= (chain window location pathname) "/login")) (undefined (chain window local-storage name)))
	   (progn
	     (chain window history (push-state (create last-url (chain window location href)
					  last-state (chain window history state)) nil "/login"))
	     (return-from update-state)))
       ,*ROUTES*)))
