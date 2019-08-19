(var __-p-s_-m-v_-r-e-g)


(i "./file-upload.lisp" "sendFile")
(i "./categories.lisp")
(i "./fetch.lisp" "cacheThenNetwork")
(i "./utils.lisp" "all" "one" "clearChildren")

(defun save-range ()
  (chain document (get-elements-by-tag-name "article") 0 (focus))
  (setf (chain window saved-range)
        (chain window (get-selection) (get-range-at 0))))

(defun restore-range ()
  (chain document (get-elements-by-tag-name "article") 0 (focus))
  (chain window (get-selection) (remove-all-ranges))
  (chain window (get-selection) (add-range (chain window saved-range))))

(defmacro tool (id &body body)
  `(chain document (get-element-by-id ,id)
	  (add-event-listener "click"
			      (lambda (event)
				(chain event (prevent-default))
				(chain event (stop-propagation))
				(save-range)
				,@body
				f))))

(defmacro stool (id) `(tool ,id (chain document (exec-command ,id f))))

(tool "format-p" (chain document (exec-command "formatBlock" f "<p>")))
(tool "format-h2" (chain document (exec-command "formatBlock" f "<h2>")))
(tool "format-h3" (chain document (exec-command "formatBlock" f "<h3>")))
(stool "superscript")
(stool "subscript")
(stool "insertUnorderedList")
(stool "insertOrderedList")
(stool "indent")
(stool "outdent")

(defun get-url (url) (new (-u-r-l url (chain window location origin))))

(export
 (defun is-local-url (url)
   (try
    (let ((url (get-url url)))
      (return (= (chain url origin) (chain window location origin))))
    (:catch (error) (return f)))))

(defun update-link (url)
  (if (is-local-url url)
      (let ((parsed-url (get-url url)))
        (if (chain window (get-selection) is-collapsed)
            (chain document
		   (exec-command "insertHTML" f
				 (concatenate 'string "<a href=\"" (chain parsed-url pathname)
					      "\">" url "</a>")))
            (chain document
		   (exec-command "createLink" f (chain parsed-url pathname)))))
      (if (chain window (get-selection) is-collapsed)
          (chain document
		 (exec-command "insertHTML" f
			       (concatenate 'string
					    "<a target=\"_blank\" rel=\"noopener noreferrer\" href=\""
					    url "\">" url "</a>")))
          (progn
            (chain document (exec-command "createLink" f url))
            (let* ((selection (chain window (get-selection)))
                   (link
                    (chain selection focus-node parent-element (closest "a"))))
              (setf (chain link target) "_blank")
              (setf (chain link rel) "noopener noreferrer"))))))

(tool "createLink"
      (on ("submit" (one "#form-link") event)
	  (chain event (prevent-default))
	  (chain event (stop-propagation))
	  (hide-modal (one "#modal-link"))
	  (restore-range)
	  (update-link (value (one "#link"))))
      (show-modal (one "#modal-link")))

(var articles (array))

(cache-then-network "/api/articles" (lambda (data) (setf articles data)))

(chain document (get-element-by-id "link")
       (add-event-listener "input"
			   (lambda (event)
			     (chain console (log event))
			     (let* ((input (chain document (get-element-by-id "link")))
				    (value (chain input value (replace "/wiki/" "")))
				    (result
				     (chain articles
					    (filter
					     (lambda (article)
					       (not
						(=
						 (chain article (to-lower-case)
							(index-of (chain value (to-lower-case))))
						 -1)))))))
			       (chain console (log result))
			       (setf (chain input next-element-sibling inner-h-t-m-l) "")
			       (if (> (chain result length) 0)
				   (add-class (chain input next-element-sibling) "show")
				   (remove-class (chain input next-element-sibling) "show"))
			       (loop for article in result
				  do (let ((element (chain document (create-element "div"))))
				       (setf (chain element class-name) "dropdown-item")
				       (setf (chain element inner-h-t-m-l) article)
				       (chain element
					      (add-event-listener "click"
								  (lambda (event)
								    (setf (chain input value)
									  (concatenate 'string "/wiki/"
										       (chain element inner-h-t-m-l)))
								    (remove-class (chain input next-element-sibling) "show"))))
				       (chain input next-element-sibling (append element))))
			       nil))))

(on ("click" (one "body") event :dynamic-selector ".editLink")
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (let ((target (get-popover-target (chain event target))))
      (hide-popover (one target))
      (chain (one "#link") (val (chain (one target) (attr "href"))))
      (on ("submit" (one "#form-link") event)
	  (chain event (prevent-default))
	  (chain event (stop-propagation))
	  (hide-modal (one "#modal-link"))
	  (chain document (get-elements-by-tag-name "article") 0 (focus))
	  (chain (one target) (attr "href" (chain (one "#link") (val)))))
      (show-modal (one "#modal-link"))))

(on ("click" (one "body") event :dynamic-selector ".deleteLink")
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (let ((target (get-popover-target (chain event target))))
      (hide-popover (one target))
      (chain (one target) (remove))))

(on ("click" (one "body") event :dynamic-selector "article[contenteditable=true] a")
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (let ((target (chain event current-target)))
      (show-popover (create-popover-for target
			  "<a href=\"#\" class=\"editLink\"><span class=\"fas fa-link\"></span></a> <a href=\"#\" class=\"deleteLink\"><span class=\"fas fa-unlink\"></span></a>"))))

(tool "insertImage"
      (show-modal (one "#image-modal")))

(on ("click" (one "body") event :dynamic-selector "article[contenteditable=true] figure")
    (let ((target (chain event current-target)))
      (show-popover (create-popover-for target
			  "<a href=\"#\" class=\"floatImageLeft\"><span class=\"fas fa-align-left\"></span></a> <a href=\"#\" class=\"floatImageRight\"><span class=\"fas fa-align-right\"></span></a> <a href=\"#\" class=\"resizeImage25\">25%</a> <a href=\"#\" class=\"resizeImage50\">50%</a> <a href=\"#\" class=\"resizeImage100\">100%</a> <a href=\"#\" class=\"deleteImage\"><span class=\"fas fa-trash\"></span></a>"))))

(on ("click" (one "body") event :dynamic-selector ".floatImageLeft")
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (let ((target (get-popover-target (chain event current-target))))
      (hide-popover (one target))
      (chain document (get-elements-by-tag-name "article") 0 (focus))
      (chain target class-list (remove "float-right"))
      (chain target class-list (add "float-left"))))

(on ("click" (one "body") event :dynamic-selector ".floatImageRight")
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (let ((target (get-popover-target (chain event current-target))))
      (hide-popover (one target))
      (chain document (get-elements-by-tag-name "article") 0 (focus))
      (chain target class-list (remove "float-left"))
      (chain target class-list (add "float-right"))))

(on ("click" (one "body") event :dynamic-selector ".resizeImage25")
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (let ((target (get-popover-target (chain event current-target))))
      (hide-popover (one target))
      (chain document (get-elements-by-tag-name "article") 0 (focus))
      (chain target class-list (remove "w-50"))
      (chain target class-list (remove "w-100"))
      (chain target class-list (add "w-25")))
    f)

(on ("click" (one "body") event :dynamic-selector ".resizeImage50")
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (let ((target (get-popover-target (chain event current-target))))
      (hide-popover (one target))
      (chain document (get-elements-by-tag-name "article") 0 (focus))
      (chain target class-list (remove "w-25"))
      (chain target class-list (remove "w-100"))
      (chain target class-list (add "w-50"))))

(on ("click" (one "body") event :dynamic-selector ".resizeImage100")
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (let ((target (get-popover-target (chain event current-target))))
      (hide-popover (one target))
      (chain document (get-elements-by-tag-name "article") 0 (focus))
      (chain target class-list (remove "w-25"))
      (chain target class-list (remove "w-50"))
      (chain target class-list (add "w-100"))))

(on ("click" (one "body") event :dynamic-selector ".deleteImage")
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (let ((target (get-popover-target (chain event current-target))))
      (hide-popover (one target))
      (chain document (get-elements-by-tag-name "article") 0 (focus))
      (chain target (remove))))

(on ("click" (one "#update-image") event)
    (hide-modal (one "#image-modal"))
    (chain document (get-elements-by-tag-name "article") 0 (focus))
    (if (chain (one "#image-url") (val))
	(chain document
	       (exec-command "insertHTML" f
			     (concatenate 'string "<img src=\"" (chain (one "#image-url") (val))
					  "\"></img>")))
	(send-file
	 (chain document (get-element-by-id "image-file") files 0))))

(tool "table"
      (show-modal (one "#table-modal")))

(on ("click" (one "#update-table") event)
    (hide-modal (one "#table-modal"))
    (chain document (get-elements-by-tag-name "article") 0 (focus))
    (let* ((columns (parse-int (chain (one "#table-columns") (val))))
           (rows (parse-int (chain (one "#table-rows") (val))))
           (row-html (chain "<td></td>" (repeat columns)))
           (inner-table-html
            (chain (concatenate 'string "<tr>" row-html "</tr>")
		   (repeat rows)))
           (table-html
            (concatenate 'string
			 "<div class=\"table-responsive\"><table class=\"table table-bordered\">"
			 inner-table-html "</table></div>")))
      (chain document (exec-command "insertHTML" f table-html))))

(on ("click" (one "body") event :dynamic-selector "article[contenteditable=true] td")
    (let ((target (chain event current-target)))
      (show-popover (create-popover-for target "table data"))))

(tool "insertFormula"
      (on ("click" (one "#update-formula") event)
	  (hide-modal (one "#formula-modal"))
	  (chain document (get-elements-by-tag-name "article") 0 (focus))
	  (let ((latex (chain window mathfield (latex))))
	    (chain window mathfield (revert-to-original-content))
	    (chain document
		   (exec-command "insertHTML" f
				 (concatenate 'string
					      "<span class=\"formula\" contenteditable=\"false\">\\("
					      latex "\\)</span>")))
	    (loop for element in (chain document
					(get-elements-by-class-name "formula"))
               do (chain -math-live (render-math-in-element element)))))
      (show-modal (one "#formula-modal"))
      (setf (chain window mathfield)
	    (chain -math-live
		   (make-math-field (chain document (get-element-by-id "formula"))
				    (create virtual-keyboard-mode "manual")))))

(on ("click" (one "#update-formula") event)
    (hide-modal (one "#formula-modal"))
    (chain document (get-elements-by-tag-name "article") 0 (focus))
    (let ((latex (chain window mathfield (latex))))
      (chain window mathfield (revert-to-original-content))
      (chain document
	     (exec-command "insertHTML" f
			   (concatenate 'string
					"<span class=\"formula\" contenteditable=\"false\">\\("
					latex "\\)</span>")))
      (loop for element in (chain document
				  (get-elements-by-class-name "formula"))
         do (chain -math-live (render-math-in-element element)))))

(stool "undo")

(stool "redo")

(tool "settings"
      (show-modal (one "#modal-settings")))

(tool "finish"
      (on ("shown.bs.modal" (one "#modal-publish-changes") event)
	  (focus (one "#change-summary")))
      (show-modal (one "#modal-publish-changes")))

(defun random-int ()
  (chain -math (floor (* (chain -math (random)) 10000000000000000))))

(defun create-popover-for (element content)
  (if (not (chain element id))
      (setf (chain element id)
            (concatenate 'string "popover-target-" (random-int))))
  (new (bootstrap.-Popover
	element
	(create html t
		template (concatenate 'string "<div data-target=\"#" (chain element id) "\" class=\"popover\" role=\"tooltip\"><div class=\"arrow\"></div><h3 class=\"popover-header\"></h3><div class=\"popover-body\"></div></div>")
		content content
		trigger "manual"))))

(defun get-popover-target (element)
  (chain (one (chain (one element) (closest ".popover") (data "target"))) 0))

(defun remove-old-popovers (event)
  (loop for popover in (one ".popover")
     do (let ((target (get-popover-target popover)))
          (if (undefined target)
              (progn
                (chain popover (remove))
                (return-from remove-old-popovers)))
          (loop for target-parent in (chain (one (chain event target))
                                            (parents))
             do (if (= target-parent target)
                    (return-from remove-old-popovers)))
          (if (= (chain event target) target)
              (return-from remove-old-popovers))
          (show-popover (one target)))))

(chain (one "body") (click remove-old-popovers))

(on ("click" (one "body") event :dynamic-selector "article[contenteditable=true] .formula")
    (let ((target (chain event current-target)))
      (show-popover
       (create-popover-for
	target
	"<a href=\"#\" class=\"editFormula\"><span class=\"fas fa-pen\"></span></a> <a href=\"#\" class=\"deleteFormula\"><span class=\"fas fa-trash\"></span></a>"))))

(on ("click" (one "body") event :dynamic-selector ".deleteFormula")
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (let ((target (get-popover-target (chain event current-target))))
      (hide-popover (one target))
      (chain document (get-elements-by-tag-name "article") 0 (focus))
      (chain target (remove))))

(on ("click" (one "body") event :dynamic-selector ".editFormula")
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (let* ((target (get-popover-target (chain event current-target)))
           (content (chain -math-live (get-original-content target))))
      (hide-popover (one target))
      (chain document (get-elements-by-tag-name "article") 0 (focus))
      (setf (chain document (get-element-by-id "formula") inner-h-t-m-l)
            (concatenate 'string "\\( " content " \\)"))
      (setf (chain window mathfield)
            (chain -math-live
		   (make-math-field (chain document (get-element-by-id "formula"))
				    (create virtual-keyboard-mode "manual"))))
      (show-modal (one "#formula-modal"))
      (chain (one "#update-formula") (off "click")
	     (click
	      (lambda (event)
		(hide-modal (one "#formula-modal"))
		(chain document (get-elements-by-tag-name "article") 0 (focus))
		(let ((latex (chain window mathfield (latex))))
		  (chain window mathfield (revert-to-original-content))
		  (setf (chain target inner-h-t-m-l)
			(concatenate 'string "\\( " latex " \\)"))
		  (loop for element in (chain document
					      (get-elements-by-class-name "formula"))
                     do (chain -math-live
			       (render-math-in-element element)))))))))
