(in-package :cl-user)
(defpackage spickipedia.parenscript
  (:use :cl :parenscript :ppcre :ironclad)
  (:export :file-js-gen
	   :js-files))
(in-package :spickipedia.parenscript)

(defparameter *js-target-version* "1.8.5")

(defpsmacro defroute (route &body body)
  `(export (defun ,(make-symbol (concatenate 'string "handle-" (subseq (regex-replace-all "\/:?" route "-") 1))) (path)
	 (if (not (null (var results (chain (new (-Reg-Exp ,(concatenate 'string "^" (regex-replace-all ":[^/]*" route "([^/]*)") "$"))) (exec path)))))
	     (progn
	       ,@(loop
		    for variable in (all-matches-as-strings ":[^/]*" route)
		    for i from 1
		    collect
		      `(defparameter ,(make-symbol (string-upcase (subseq variable 1))) (chain results ,i)))
	       ,@body
	       (return T)))
	 (return F))))

(defpsmacro get (url show-error-page &body body)
  `(chain $
	  (get ,url (lambda (data) ,@body))
	  (fail (lambda (jq-xhr text-status error-thrown)
		  (handle-error jq-xhr ,show-error-page)))))

(defpsmacro post (url data show-error-page &body body)
  `(chain $
	  (post ,url ,data (lambda (data) ,@body))
	  (fail (lambda (jq-xhr text-status error-thrown)
		  (handle-error jq-xhr ,show-error-page)))))

(defpsmacro i (file &rest contents)
  `(import ,file ,@contents))

;;(defpsmacro i (file &rest contents)
;;  `(import ,(concatenate 'string file "?v=" (lisp (byte-array-to-hex-string (digest-file :sha512 (concatenate 'string "js/" file))))) ,@contents)) ;; TODO local file inclusion

(defun file-js-gen (file)
  (in-package :spickipedia.parenscript)
  (get-routes)
  (handler-bind ((simple-warning #'(lambda (e) (if (equal "Returning from unknown block ~A" (simple-condition-format-control e)) (muffle-warning)))))
    (ps-compile-file file)))

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
    (loop for line = (read stream nil)
       while line
       collect line)))

;; THIS IS AN UGLY HACK
(defparameter
    *ROUTES*
  (append `(progn) (mapcar
		    #'(lambda (r)
			`(if (,(make-symbol (concatenate 'string "handle-" (subseq (regex-replace-all "\/:?" r "-") 1))) (chain window location pathname))
			     (return-from update-state)))
		    (find-defroute (loop for file in (directory #P"js/*.lisp") collect (get-sexp file))))))

(defun get-routes ()
  (defparameter *UPDATE-STATE*
    `(export (defun update-state ()
       (setf (chain window last-url) (chain window location pathname))
       (if (undefined (chain window local-storage name))
	   (chain ($ "#logout") (text "Abmelden"))
	   (chain ($ "#logout") (text (concatenate 'string (chain window local-storage name) " abmelden"))))
       (if (and (not (= (chain window location pathname) "/login")) (undefined (chain window local-storage name)))
	   (progn
	     (chain window history
		    (push-state (create
				 last-url (chain window location href)
				 last-state (chain window history state)) nil "/login"))
	   (update-state)))
       ,*ROUTES*
       (chain ($ "#errorMessage") (text "Unbekannter Pfad!"))
       (show-tab "#error")))))
