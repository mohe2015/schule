(defmacro defroute (route &body body)
  `(defun ,(make-symbol (concatenate 'string "handle-" (subseq (regex-replace-all "\/:?" route "-") 1))) (path)
	 (if (not (null (setf results (chain (new (-Reg-Exp ,(concatenate 'string "^" (regex-replace-all ":[^/]*" route "([^/]*)") "$"))) (exec path)))))
	     (progn
	       ,@(loop
		    for variable in (all-matches-as-strings ":[^/]*" route)
		    for i from 1
		    collect
		      `(defparameter ,(make-symbol (string-upcase (subseq variable 1))) (chain results ,i)))
	       ,@body
	       (return T)))
	 (return F)))

(defmacro get (url show-error-page &body body)
  `(chain $
	  (get ,url (lambda (data) ,@body))
	  (fail (lambda (jq-xhr text-status error-thrown)
		  (handle-error jq-xhr ,show-error-page)))))

(defmacro post (url data show-error-page &body body)
  `(chain $
	  (post ,url ,data (lambda (data) ,@body))
	  (fail (lambda (jq-xhr text-status error-thrown)
		  (handle-error jq-xhr ,show-error-page)))))
