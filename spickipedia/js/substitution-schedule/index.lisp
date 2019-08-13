(var __-p-s_-m-v_-r-e-g)

(i "/js/show-tab.lisp" "showTab")
(i "/js/cleanup.lisp" "cleanup")
(i "/js/fetch.lisp" "checkStatus" "json" "html" "handleFetchError" "cacheThenNetwork")
(i "/js/utils.lisp" "all" "one" "clearChildren")
(i "/js/template.lisp" "getTemplate")
(i "/js/read-cookie.lisp" "readCookie")
(i "/js/state-machine.lisp" "pushState")

(defun group-by (xs key)
  (chain
   xs
   (reduce
    (lambda (rv x)
      (chain (setf (getprop rv (getprop x key)) (or (getprop rv (getprop x key)) (array))) (push x))
      rv)
    (create))))

(defun substitution-to-string (substitution)
  (concatenate
   'string
   (chain substitution hour)
   "."
   (if (and (chain substitution new-room) (not (equal (chain substitution old-room) (chain substitution new-room))))
       (concatenate 'string " | " (chain substitution old-room) " -> " (chain substitution new-room))
       "")
   (if (and (chain substitution new-subject) (not (equal (chain substitution old-subject) (chain substitution new-subject))))
       (concatenate 'string " | " (chain substitution old-subject) " -> " (chain substitution new-subject))
       "")
   (if (and (chain substitution new-teacher) (not (equal (chain substitution old-teacher) (chain substitution new-teacher))))
       (concatenate 'string " | " (chain substitution old-teacher) " -> " (chain substitution new-teacher))
       "")
   (if (chain substitution notes)
       (concatenate 'string " | " (chain substitution notes))
       "")
   ))

(defroute "/substitution-schedule"
  (show-tab "#loading")
  (cache-then-network
   "/api/substitutions"
   (lambda (data)
     (loop :for (k v) :of (chain data schedules) :do
	  (let ((template (get-template "template-substitution-schedule")))
	    (setf (inner-text (one ".substitution-schedule-date" template)) (chain (new (-date (* k 1000))) (to-locale-date-string "de-DE")))
	    (if (chain v substitutions)
		(loop :for (clazz substitutions) :of (group-by (chain v substitutions) "class") :do
		     (let ((class-template (get-template "template-substitution-for-class")))
		       (setf (inner-text (one ".template-class" class-template)) clazz)
		       (loop for substitution in substitutions do
			    (let ((substitution-template (get-template "template-substitution")))
			      (setf (inner-text (one "li" substitution-template)) (substitution-to-string substitution))
			      (append (one "ul" class-template) substitution-template)))
		       (append template class-template))))
	    (append (one "#substitution-schedule-content") template)))
     (show-tab "#substitution-schedule"))))
