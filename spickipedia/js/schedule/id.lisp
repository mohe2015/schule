(var __-p-s_-m-v_-r-e-g)

(i "/js/show-tab.lisp" "showTab")
(i "/js/cleanup.lisp" "cleanup")
(i "/js/fetch.lisp" "checkStatus" "json" "html" "handleFetchError"
   "cacheThenNetwork")
(i "/js/utils.lisp" "all" "one" "clearChildren")
(i "/js/template.lisp" "getTemplate")
(i "/js/read-cookie.lisp" "readCookie")
(i "/js/state-machine.lisp" "pushState")

(on ("click" (one "#schedule-edit-button") event)
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (let ((grade (chain window location pathname (split "/") 2)))
      (push-state (concatenate 'string "/schedule/" grade "/edit"))))

(on ("click" (one "#schedule-show-button") event)
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (let ((grade (chain window location pathname (split "/") 2)))
      (push-state (concatenate 'string "/schedule/" grade))))

(defun load-courses ()
  (cache-then-network "/api/courses"
		      (lambda (data)
			(let ((course-select (one ".course-select"))) ;; TODO implement for multiple
			  (clear-children course-select)
			  (loop for course in data
			     do (let ((option (chain document (create-element "option")))
				      (text
				       (concatenate 'string (chain course subject) " "
						    (chain course type) " "
						    (chain course teacher name))))
				  (setf (chain option value) (chain course course-id))
				  (setf (chain option inner-text) text)
				  (chain course-select (append-child option))))))))

(defparameter *WEEK-MODULO* (array "" " (ungerade)" " (gerade)"))

(defroute "/schedule/:grade"
    (show-tab "#loading")
  (hide (one "#schedule-show-button"))
  (show (one "#schedule-edit-button"))
  (hide (all ".add-course"))
  (cache-then-network (concatenate 'string "/api/schedule/" grade)
		      (lambda (data)
			(remove (all ".schedule-data"))
			(loop for element in (chain data data) do
			     (let* ((cell1 (getprop (one "#schedule-table") 'children (chain element weekday)))
				    (cell2 (chain cell1 (query-selector "tbody")))
				    (cell (getprop cell2 'children (- (chain element hour) 1) 'children 1))
				    (template (get-template "schedule-data-static-cell-template")))
			       (setf (inner-text (one ".data" template))
				     (concatenate 'string (chain element course subject) " " (chain element course type) " " (chain element course teacher name) " " (chain element room) " " (getprop *WEEK-MODULO* (chain element week-modulo))))
			       (chain cell (prepend template))))
			(show-tab "#schedule"))))

(defroute "/schedule/:grade/edit"
    (show-tab "#loading")
  (show (one "#schedule-show-button"))
  (hide (one "#schedule-edit-button"))
  (show (all ".add-course"))
  (load-courses)
  (cache-then-network (concatenate 'string "/api/schedule/" grade "/all")
		      (lambda (data)
			(remove (all ".schedule-data"))
			(loop for element in (chain data data) do
			     (let* ((cell1 (getprop (one "#schedule-table") 'children (chain element weekday)))
				    (cell2 (chain cell1 (query-selector "tbody")))
				    (cell (getprop cell2 'children (- (chain element hour) 1) 'children 1))
				    (template (get-template "schedule-data-cell-template")))
			       (setf (inner-text (one ".data" template))
				     (concatenate 'string (chain element course subject) " " (chain element course type) " " (chain element course teacher name) " " (chain element room) " " (getprop *WEEK-MODULO* (chain element week-modulo))))
			       (chain
				(one ".button-delete-schedule-data" template)
				(set-attribute "data-id" (chain element id)))
			       (chain cell (prepend template))))
			(show-tab "#schedule"))))

(on ("submit" (one "#form-schedule-data") event)
    (chain event (prevent-default))
    (let* ((day (chain (one "#schedule-data-weekday") value))
           (hour (chain (one "#schedule-data-hour") value))
           (cell1 (getprop (one "#schedule-table") 'children day))
           (cell2 (chain cell1 (query-selector "tbody")))
           (cell (getprop cell2 'children (- hour 1) 'children 1))
           (template (get-template "schedule-data-cell-template"))
           (course (chain (one ".course-select" (one "#form-schedule-data")) selected-options 0 inner-text))
           (room (chain (one "#room") value))
           (form-element (chain document (query-selector "#form-schedule-data")))
           (form-data (new (-form-data form-element)))
           (grade (chain location pathname (split "/") 2)))
      (chain form-data (append "_csrf_token" (read-cookie "_csrf_token")))
      (chain
       (fetch (concatenate 'string "/api/schedule/" grade "/add")
	      (create method "POST" body form-data))
       (then check-status) (then json)
       (then
	(lambda (data)
          (setf (chain template (query-selector ".data") inner-text)
		(concatenate 'string course " " room (getprop *WEEK-MODULO* (value (one "#week-modulo")))))
          (chain cell (prepend template))
          (hide-modal (one "#modal-schedule-data"))))
       (catch handle-fetch-error))))

(on ("click" (all ".schedule-tab-link") event)
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (chain window history (replace-state null null (href (chain event target))))
    f)

(when (chain document location hash)
  (chain (new (bootstrap.-Tab (one (concatenate 'string "a[href=\"" (chain document location hash) "\"]")))) (show)))

(on ("click" (one "body") event :dynamic-selector ".add-course")
    (chain console (log event))
    (let* ((y (chain event target (closest "tr") row-index))
           (x-element (chain event target (closest "div")))
           (x (chain -array (from (chain x-element parent-node children)) (index-of x-element))))
      (setf (chain (one "#schedule-data-weekday") value) x)
      (setf (chain (one "#schedule-data-hour") value) y)
      (show-modal (one "#modal-schedule-data"))))

(on ("click" (one "body") event :dynamic-selector ".button-delete-schedule-data")
    (chain console (log event))
    (let* ((id (chain event target (closest ".button-delete-schedule-data") (get-attribute "data-id")))
           (form-data (new (-form-data)))
           (grade (chain location pathname (split "/") 2)))
      (chain form-data (append "id" id))
      (chain form-data (append "_csrf_token" (read-cookie "_csrf_token")))
      (if (confirm "Möchtest du den Eintrag wirklich löschen? Mit dem Veröffentlichen garantierst du, dass du nicht die Rechte anderer verletzt und bist damit einverstanden, unter der Creative Commons Namensnennung - Nicht-kommerziell - Weitergabe unter gleichen Bedingungen 4.0 International Lizenz zu veröffentlichen.")
          (chain
           (fetch (concatenate 'string "/api/schedule/" grade "/delete")
		  (create method "POST" body form-data))
           (then check-status)
           (then
            (lambda (data)
              (chain event target (closest ".schedule-data") (remove))))
           (catch handle-fetch-error)))))
