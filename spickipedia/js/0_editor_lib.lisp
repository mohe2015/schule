(defun save-range ()
  (chain document (get-elements-by-tag-name "article") 0 (focus))
  (setf (chain window saved-range)
	(chain window (get-selection) (get-range-at 0))))

(defun restore-range ()
  (chain document (get-elements-by-tag-name "article") 0 (focus))
  (chain window (get-selection) (remove-all-ranges))
  (chain window (get-selection) (add-range (chain window saved-range))))

(defmacro tool (id &body body)
  `(chain
   document
   (get-element-by-id ,id)
   (add-event-listener
    "click"
    (lambda (event)
      (chain event (prevent-default))
      (save-range)
      ,@body
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

(defun get-url (url)
  (new (-u-r-l url (chain window location origin))))

(defun is-local-url (url)
  (try
   (let ((url (get-url url)))
     (return (= (chain url origin) (chain window location origin))))
   (:catch (error)
     (return F))))

;; TODO handle full urls to local wiki page
(defun update-link (url)
  (if (is-local-url url)

      ;; local url
      (let ((parsed-url (get-url)))
	(if (chain window (get-selection) is-collapsed)
	    (chain document (exec-command "insertHTML" F (concatenate 'string "<a href=\"" (chain parsed-url pathname) "\">" url "</a>")))
	    (chain document (exec-command "createLink" F (chain parsed-url pathname)))))

      ;; external url
       (if (chain window (get-selection) is-collapsed)
	  (chain document (exec-command "insertHTML" F (concatenate 'string "<a target=\"_blank\" rel=\"noopener noreferrer\" href=\"" url "\">" url "</a>")))
	  (chain document (exec-command "createLink" F url))))) ;; TODO add target _blank

(tool "createLink"
      (chain
       ($ "#link-form")
       (off "submit")
       (submit
	(lambda (event)
	  (chain event (prevent-default))
	  (chain ($ "#link-modal") (modal "hide"))
	  (restore-range)
	  (update-link (chain ($ "#link") (val))))))
      (chain ($ "#link-modal") (modal "show")))

(chain
 ($ "#link")
 (typeahead
  (create
   class-names (create
		dataset "dropdown-menu show"
		suggestion "dropdown-item"
		wrapper "twitter-typeahead d-flex"))
  (create
   name "articles"
   source (chain window engine)
   templates
   (create
    suggestion (lambda (title)
		 (concatenate 'string "<div>" title "</div>")))
   display (lambda (title)
	     (concatenate 'string "/wiki/" title)))))


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
  ".deleteLink"
  (lambda (event)
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (let ((target (get-popover-target (chain event target))))
      (chain ($ target) (popover "hide"))
      (chain ($ target) (remove))))))

(chain
 ($ "body")
 (on
  "click"
  "article[contenteditable=true] a"
  (lambda (event)
    (let ((target (chain event target)))
      (create-popover-for target "<a href=\"#\" class=\"editLink\"><span class=\"fas fa-link\"></span></a> <a href=\"#\" class=\"deleteLink\"><span class=\"fas fa-unlink\"></span></a>")

      (chain ($ target) (popover "show"))))))

(tool "insertImage"
      (chain ($ "#image-modal") (modal "show")))

;; TODO replace chain event target with chain event current-target

(chain
 ($ "body")
 (on
  "click"
  "article[contenteditable=true] figure"
  (lambda (event)
    (let ((target (chain event current-target)))
      (create-popover-for target "<a href=\"#\" class=\"floatImageLeft\"><span class=\"fas fa-align-left\"></span></a> <a href=\"#\" class=\"floatImageRight\"><span class=\"fas fa-align-right\"></span></a> <a href=\"#\" class=\"resizeImage25\">25%</a> <a href=\"#\" class=\"resizeImage50\">50%</a> <a href=\"#\" class=\"resizeImage100\">100%</a> <a href=\"#\" class=\"deleteImage\"><span class=\"fas fa-trash\"></span></a>")

      (chain ($ target) (popover "show"))))))




(chain
 ($ "body")
 (on
  "click"
  ".floatImageLeft"
  (lambda (event)
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (let ((target (get-popover-target (chain event current-target))))
      (chain ($ target) (popover "hide"))
      (chain document (get-elements-by-tag-name "article") 0 (focus))
      (chain target class-list (remove "float-right"))
      (chain target class-list (add "float-left"))))))

(chain
 ($ "body")
 (on
  "click"
  ".floatImageRight"
  (lambda (event)
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (let ((target (get-popover-target (chain event current-target))))
      (chain ($ target) (popover "hide"))
      (chain document (get-elements-by-tag-name "article") 0 (focus))
      (chain target class-list (remove "float-left"))
      (chain target class-list (add "float-right"))))))


(chain
 ($ "body")
 (on
  "click"
  ".resizeImage25"
  (lambda (event)
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (let ((target (get-popover-target (chain event current-target))))
      (chain ($ target) (popover "hide"))
      (chain document (get-elements-by-tag-name "article") 0 (focus))
      (chain target class-list (remove "w-50"))
      (chain target class-list (remove "w-100"))
      (chain target class-list (add "w-25"))))))

(chain
 ($ "body")
 (on
  "click"
  ".resizeImage50"
  (lambda (event)
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (let ((target (get-popover-target (chain event current-target))))
      (chain ($ target) (popover "hide"))
      (chain document (get-elements-by-tag-name "article") 0 (focus))
      (chain target class-list (remove "w-25"))
      (chain target class-list (remove "w-100"))
      (chain target class-list (add "w-50"))))))

(chain
 ($ "body")
 (on
  "click"
  ".resizeImage100"
  (lambda (event)
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (let ((target (get-popover-target (chain event current-target))))
      (chain ($ target) (popover "hide"))
      (chain document (get-elements-by-tag-name "article") 0 (focus))
      (chain target class-list (remove "w-25"))
      (chain target class-list (remove "w-50"))
      (chain target class-list (add "w-100"))))))

(chain
 ($ "body")
 (on
  "click"
  ".deleteImage"
  (lambda (event)
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (let ((target (get-popover-target (chain event current-target))))
      (chain ($ target) (popover "hide"))
      (chain document (get-elements-by-tag-name "article") 0 (focus))
      (chain target (remove))))))

(chain
 ($ "#update-image")
 (click
  (lambda (event)
    (chain ($ "#image-modal") (modal "hide"))
    (chain document (get-elements-by-tag-name "article") 0 (focus))
    (if (chain ($ "#image-url") (val))
	(chain document (exec-command "insertHTML" F (concatenate 'string "<img src=\"" (chain ($ "#image-url") (val)) "\"></img>")))
	(send-file (chain document (get-element-by-id "image-file") files 0))))))

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

(chain
 ($ "body")
 (on
  "click"
  "article[contenteditable=true] td"
  (lambda (event)
    (let ((target (chain event target)))
      (create-popover-for target "table data")
      (chain ($ target) (popover "show"))))))

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

(defun remove-old-popovers (event)
  (loop for popover in ($ ".popover") do 
       (let ((target (get-popover-target popover)))
	 (if (undefined target)
	     (progn
	       (chain popover (remove))
	       (return-from remove-old-popovers)))
	 (loop for target-parent in (chain ($ (chain event target)) (parents)) do
	      (if (= target-parent target) ;; TODO target to jquery
		  (return-from remove-old-popovers)))
	 (if (= (chain event target) target)
	     (return-from remove-old-popovers))
	 (chain ($ target) (popover "hide")))))

(chain
 ($ "body")
 (click remove-old-popovers))
