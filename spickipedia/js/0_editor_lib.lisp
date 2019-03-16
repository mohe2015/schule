(defmacro tool (id &body body)
  `(chain
   document
   (get-element-by-id ,id)
   (add-event-listener
    "click"
    (lambda (event)
      (chain event (prevent-default))
      ,@body
      (chain document (get-elements-by-tag-name "article") 0 (focus))
      F))))

(defmacro stool (id)
  `(tool ,id
	 (chain document (exec-command ,id F))))

(tool "format-p"
    (chain document (exec-command "formatBlock" F "<p>")))

(tool "format-h2"
      (chain document (exec-command "formatBlock" F "<h2>")))

(tool "format-h3"
      (chain document (exec-command "formatBlock" F "<h3>")))

(stool "superscript")
(stool "subscript")
(stool "insertUnorderedList")
(stool "insertOrderedList")
(stool "indent")
(stool "outdent")

(setf
 (chain window engine)
 (new (-bloodhound
       (create
	prefetch "/api/articles"
	query-tokenizer (chain -bloodhound tokenizers whitespace)
	datum-tokenizer (chain -bloodhound tokenizers whitespace)))))

(defun is-valid-url (url)
  (try
   (progn
     (new (-u-r-l url))
     (return T))
   (:catch (error)
     (return F))))

(defun update-link (url)
  ;;window.getSelection().isCollapsed
  (if (is-valid-url url)
      (if (chain window (get-selection) is-collapsed)
	  (chain document (exec-command "insertHTML" F (concatenate 'string "<a target=\"_blank\" rel=\"noopener noreferrer\" href=\"" url "\">" url "</a>")))
	  nil) ;; TODO existing selected text
      (if (chain window (get-selection) is-collapsed)
	  (chain document (exec-command "insertHTML" F (concatenate 'string "<a href=\"/wiki/" url "\">" url "</a>")))
	  (chain document (exec-command "createLink" F (concatenate 'string "/wiki/" url))))))

(tool "createLink"
      (chain
       ($ "#link-form")
       (off "submit")
       (submit
	(lambda (event)
	  (chain event (prevent-default))
	  (chain ($ "#link-modal") (modal "hide"))
	  (chain document (get-elements-by-tag-name "article") 0 (focus))
	  (update-link (chain ($ "#link") (val))))))
      (chain ($ "#link-modal") (modal "show")))

(chain
 ($ "#link")
 (typeahead
  (create
   class-names (create
		dataset "dropdown-menu show"
		suggestion "dropdown-item"
		wrapper "twitter-typeahead d-flex"
		))
  (create
   name "articles"
   source (chain window engine))))


(chain
 ($ "body")
 (on
  "click"
  ".editLink"
  (lambda (event)
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (let ((target (get-popover-target (chain event target))))
      (chain ($ target) (popover "hide"))
      (chain ($ "#link") (val (chain ($ target) (attr "href"))))

      (chain
       ($ "#link-form")
       (off "submit")
       (submit
	(lambda (event)
	  (chain event (prevent-default))
	  (chain ($ "#link-modal") (modal "hide"))
	  (chain document (get-elements-by-tag-name "article") 0 (focus))
	  (chain ($ target) (attr "href" (chain ($ "#link") (val)))))))
      (chain ($ "#link-modal") (modal "show"))))))

(chain
 ($ "body")
 (on
  "click"
  "article a"
  (lambda (event)
    (let ((target (chain event target)))
      (create-popover-for target "<a href=\"#\" class=\"editLink\"><span class=\"fas fa-link\"></span></a>")
	
      (chain ($ target) (popover "show"))))))

(tool "insertImage"
      (chain ($ "#image-modal") (modal "show")))

(chain
 ($ "#update-image")
 (click
  (lambda (event)
    (chain ($ "#image-modal") (modal "hide"))
    (chain document (get-elements-by-tag-name "article") 0 (focus))
    ;; TODO make url working
    (send-file (chain document (get-element-by-id "image-file") files 0)))))

(tool "table"
      (chain ($ "#table-modal") (modal "show")))

(chain
 ($ "#update-table")
 (click
  (lambda (event)
    (chain ($ "#table-modal") (modal "hide"))
    (chain document (get-elements-by-tag-name "article") 0 (focus))
    (let* ((columns (parse-int (chain ($ "#table-columns") (val))))
	   (rows (parse-int (chain ($ "#table-rows") (val))))
	   (row-html (chain "<td></td>" (repeat columns)))
	   (inner-table-html (chain (concatenate 'string "<tr>" row-html "</tr>") (repeat rows)))
	   (table-html (concatenate 'string "<div class=\"table-responsive\"><table class=\"table table-bordered\">" inner-table-html "</table></div>")))
      (chain document (exec-command "insertHTML" F table-html))))))

(tool "insertFormula"
      (chain ($ "#formula-modal") (modal "show"))
      (setf (chain window mathfield) (chain -math-live (make-math-field (chain document (get-element-by-id "formula")) (create virtual-keyboard-mode "manual")))))

(chain
 ($ "#update-formula")
 (click
  (lambda (event)
    (chain ($ "#formula-modal") (modal "hide"))
    (chain document (get-elements-by-tag-name "article") 0 (focus))
    (let ((latex (chain window mathfield (latex))))
      (chain window mathfield (revert-to-original-content))
      (chain document (exec-command "insertHTML" F (concatenate 'string "<span class=\"formula\" contenteditable=\"false\">\\(" latex "\\)</span>")))
      (loop for element in (chain document (get-elements-by-class-name "formula")) do
	   (chain -math-live (render-math-in-element element)))))))

(stool "undo")
(stool "redo")

;; TODO settings
;; TODO finish

(tool "finish"
      (chain
       ($ "#publish-changes-modal")
       (on "shown.bs.modal"
	   (lambda ()
	     (chain ($ "#change-summary") (trigger "focus")))))
      (chain ($ "#publish-changes-modal") (modal "show")))

(defun random-int ()
  (chain -math (floor (* (chain -math (random)) 10000000000000000))))

(defun create-popover-for (element content)
  (if (not (chain element id))
      (setf (chain element id) (concatenate 'string "popover-target-" (random-int))))
  (chain
   ($ element)
   (popover
    (create
     html T
     template (concatenate 'string "<div data-target=\"#" (chain element id) "\" class=\"popover\" role=\"tooltip\"><div class=\"arrow\"></div><h3 class=\"popover-header\"></h3><div class=\"popover-body\"></div></div>")
     content content
     trigger "manual"))))

(defun get-popover-target (element)
  (chain ($ (chain ($ element) (closest ".popover") (data "target"))) 0))

(chain
 ($ "body")
 (click
  (lambda (event)
    (loop for popover in ($ ".popover") do 
	 (let ((target (get-popover-target popover)))
	   (if (not (= (chain event target) target))
	       (chain ($ target) (popover "hide"))))))))
