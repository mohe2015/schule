(var __-p-s_-m-v_-r-e-g)

(i "/js/show-tab.lisp" "showTab")
(i "/js/cleanup.lisp" "cleanup")
(i "/js/fetch.lisp" "checkStatus" "json" "html" "handleFetchError"
   "cacheThenNetwork")
(i "/js/utils.lisp" "all" "one" "clearChildren")
(i "/js/template.lisp" "getTemplate")
(i "/js/read-cookie.lisp" "readCookie")
(i "/js/state-machine.lisp" "pushState")

(defroute "/substitution-schedule"
  (show-tab "#loading")
  (cache-then-network
   "/api/substitutions"
   (lambda (data)
     (loop :for (k v) :of (chain data schedules) :do
	  (let ((template (get-template "template-substitution-schedule")))
	    (setf (inner-text (one ".substitution-schedule-date" template)) "1.1.2001")


	    
	    (let ((class-template (get-template "template-substitution-for-class")))
	      (setf (inner-text (one ".template-class" class-template)) "clazz")
	      (append template class-template))

	    (group-by:group-by-repeated
	     (chain v substitutions)
	     :keys (list #'third)
	     :tests (list #'string-equal))

	    
	    (loop for substitution in (chain v substitutions) do
		 (chain console (log substitution)))

	    (append (one "#substitution-schedule") template)
	    
	    (chain console (log k v))))
     
     (show-tab "#substitution-schedule")
     
