;; TODO only do on edit path
;; TODO hide editor if not editing
;; TODO show editor in fullscreen
(setf (chain document (get-elements-by-tag-name "article") 0 content-editable) T)

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

(tool "createLink"
      (chain ($ "#link-modal") (modal "show")))

(chain
 ($ "#link")
 (typeahead
  (create
   class-names (create
		dataset "dropdown-menu show"
		suggestion "dropdown-item"))
  (create
   name "articles"
   source (chain window engine))))

(chain
 ($ "#update-link")
 (click
  (lambda (event)
    (chain ($ "#link-modal") (modal "hide"))
    (chain document (get-elements-by-tag-name "article") 0 (focus))
    ;; TODO replace article titles with /wiki/title
    ;; TODO this makes the links working in history etc.
    (chain document (exec-command "createLink" F (chain ($ "#link") (val)))))))

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

(defun update (event)
  (let ((target (chain event target)))
    (do ((element target (chain element parent-node)))
	((= (chain element tag-name) "ARTICLE"))
      (chain console (log element))
      (if (= (chain element tag-name) "A")
	  (progn
	    (chain console (log "GOTALINK"))
	    ;; TODO close
	    ;; $('body').popover({ html: true,  selector: "a", content: '<a href="#" id="createLink"><span class="fas fa-link"></span></a>', trigger: 'hover' });
	    ))


      )))

(chain document (get-elements-by-tag-name "article") 0 (add-event-listener "click" update))
