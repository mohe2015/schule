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
     (show-tab "#substitution-schedule")
     (let ((template (get-template "template-substitution-schedule")))
       (append (one "#substitution-schedule") template)
       (loop :for (k v) :of (chain data schedules) :do
	    (loop for substitution in (chain v substitutions) do
		 (chain console (log substitution)))
	    
	    (chain console (log k v)))))))
