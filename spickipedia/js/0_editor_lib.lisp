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
      (chain document (exec-command "insertHTML" F (concatenate 'string "<span class=\"formula\">\\(" latex "\\)</span>")))
      (loop for element in (chain document (get-elements-by-class-name "formula")) do
	   (chain -math-live (render-math-in-element element)))))))

;; document.getElementsByTagName("article")[0].onkeydown = function(event) {
;;    event.preventDefault()
;;};

(defun check-key-down (event)
  (let ((selection (chain window (get-selection)))
	(key (chain event key)))
    (chain console (log (chain selection anchor-node)))
    (if (or
	 (= key "ArrowLeft")
	 (= key "ArrowRight")
	 (= key "ArrowUp")
	 (= key "ArrowDown"))
	(return))
    (do ((element (chain selection anchor-node) (chain element parent-node)))
	((= element nil))
      (if (and (chain element class-list) (chain element class-list (contains "formula")))
	  (chain event (prevent-default))))
    (do ((element (chain selection focus-node) (chain element parent-node)))
	((= element nil))
      (if (and (chain element class-list) (chain element class-list (contains "formula")))
	  (chain event (prevent-default))))
    ))

(setf
(chain
 document
 (get-elements-by-tag-name "article")
 0
 onkeydown)
check-key-down)

(defun handle-selection-change (event)
  (let ((selection (chain window (get-selection))))
    (if (not (chain selection is-collapsed))
	(return-from handle-selection-change))
    (if (not (= (chain selection anchor-offset) 0))
	(return-from handle-selection-change))
    
    (do ((element (chain selection anchor-node) (chain element parent-node)))
	((or (null element) (defined (chain element next-silbling)))) ;; check if last element
      (if (and (chain element class-list) (chain element class-list (contains "ML__base"))) ;; until parent of formula content
	  (do ((formula-element element (chain formula-element parent-node)))
	      ((= formula-element nil))
	    (if (and (chain formula-element class-list (contains "formula"))) ;; find formula element
		(progn
		  ;; collapse selection to start of formula (outside of its tag)
		  (chain selection (collapse (chain formula-element parent-node) 0))
		  (chain console (log "jo"))
		  (return-from handle-selection-change))))))))

;; https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver
;; window.getSelection().collapse(document.getElementsByClassName("formula")[0], 1)
;; document.execCommand("insertText", false, "hi")

(chain document (add-event-listener "selectionchange" handle-selection-change))


(stool "undo")
(stool "redo")

;; TODO settings
;; TODO finish
