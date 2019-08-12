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

(defroute "/substitution-schedule"
  (show-tab "#loading")
  (cache-then-network
   "/api/substitutions"
   (lambda (data)
     (loop :for (k v) :of (chain data schedules) :do
	  (let ((template (get-template "template-substitution-schedule")))
	    (setf (inner-text (one ".substitution-schedule-date" template)) "1.1.2001")
	    (if (chain v substitutoins)
		(loop :for (clazz substitutions) :of (group-by (chain v substitutions) "class") :do
		     (let ((class-template (get-template "template-substitution-for-class")))
		       (setf (inner-text (one ".template-class" class-template)) "clazz")
		       (append template class-template))
		     (loop for substitution in substitutions do
			  (let ((substitution-template (get-template "template-substitution")))
			    (setf (inner-text (one "li" substitution-template)) "substitution")
			    (append class-template substitution-template)))))
	    (append (one "#substitution-schedule") template)))
     (show-tab "#substitution-schedule"))))
