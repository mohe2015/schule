(var __-p-s_-m-v_-r-e-g)

(i "./test.lisp")
(i "./file-upload.lisp" "sendFile")
(i "./categories.lisp")
(i "./handle-error.lisp" "handleError")
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
 (on ("submit" (one "#link-form") event)
   (chain event (prevent-default))
   (chain event (stop-propagation))
   (chain (one "#link-modal") (modal "hide"))
   (restore-range)
   (update-link (chain (one "#link") (val))))
 (chain (one "#link-modal") (modal "show")))

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
          (chain input next-element-sibling class-list (add "show"))
          (chain input next-element-sibling class-list (remove "show")))
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
                     (chain input next-element-sibling class-list
                      (remove "show")))))
                 (chain input next-element-sibling (append element))))
      nil))))

(on ("click" (one "body") event :dynamic-selector ".editLink")
  (chain event (prevent-default))
  (chain event (stop-propagation))
  (let ((target (get-popover-target (chain event target))))
    (chain (one target) (popover "hide"))
    (chain (one "#link") (val (chain (one target) (attr "href"))))
    (on ("submit" (one "#link-form") event)
      (chain event (prevent-default))
      (chain event (stop-propagation))
      (chain (one "#link-modal") (modal "hide"))
      (chain document (get-elements-by-tag-name "article") 0 (focus))
      (chain (one target) (attr "href" (chain (one "#link") (val)))))
    (chain (one "#link-modal") (modal "show"))))

(on ("click" (one "body") event :dynamic-selector ".deleteLink")
  (chain event (prevent-default))
  (chain event (stop-propagation))
  (let ((target (get-popover-target (chain event target))))
    (chain (one target) (popover "hide"))
    (chain (one target) (remove))))

(on ("click" (one "body") event :dynamic-selector "article[contenteditable=true] a")
  (let ((target (chain event current-target)))
    (create-popover-for target
     "<a href=\"#\" class=\"editLink\"><span class=\"fas fa-link\"></span></a> <a href=\"#\" class=\"deleteLink\"><span class=\"fas fa-unlink\"></span></a>")
    (chain (one target) (popover "show"))))

(tool "insertImage" (chain (one "#image-modal") (modal "show")))

(on ("click" (one "body") event :dynamic-selector "article[contenteditable=true] figure")
  (let ((target (chain event current-target)))
    (create-popover-for target
     "<a href=\"#\" class=\"floatImageLeft\"><span class=\"fas fa-align-left\"></span></a> <a href=\"#\" class=\"floatImageRight\"><span class=\"fas fa-align-right\"></span></a> <a href=\"#\" class=\"resizeImage25\">25%</a> <a href=\"#\" class=\"resizeImage50\">50%</a> <a href=\"#\" class=\"resizeImage100\">100%</a> <a href=\"#\" class=\"deleteImage\"><span class=\"fas fa-trash\"></span></a>")
    (chain (one target) (popover "show"))))

(on ("click" (one "body") event :dynamic-selector ".floatImageLeft")
  (chain event (prevent-default))
  (chain event (stop-propagation))
  (let ((target (get-popover-target (chain event current-target))))
    (chain (one target) (popover "hide"))
    (chain document (get-elements-by-tag-name "article") 0 (focus))
    (chain target class-list (remove "float-right"))
    (chain target class-list (add "float-left"))))

(on ("click" (one "body") event :dynamic-selector ".floatImageRight")
  (chain event (prevent-default))
  (chain event (stop-propagation))
  (let ((target (get-popover-target (chain event current-target))))
    (chain (one target) (popover "hide"))
    (chain document (get-elements-by-tag-name "article") 0 (focus))
    (chain target class-list (remove "float-left"))
    (chain target class-list (add "float-right"))))

(on ("click" (one "body") event :dynamic-selector ".resizeImage25")
  (chain event (prevent-default))
  (chain event (stop-propagation))
  (let ((target (get-popover-target (chain event current-target))))
    (chain (one target) (popover "hide"))
    (chain document (get-elements-by-tag-name "article") 0 (focus))
    (chain target class-list (remove "w-50"))
    (chain target class-list (remove "w-100"))
    (chain target class-list (add "w-25")))
  f)

(on ("click" (one "body") event :dynamic-selector ".resizeImage50")
  (chain event (prevent-default))
  (chain event (stop-propagation))
  (let ((target (get-popover-target (chain event current-target))))
    (chain (one target) (popover "hide"))
    (chain document (get-elements-by-tag-name "article") 0 (focus))
    (chain target class-list (remove "w-25"))
    (chain target class-list (remove "w-100"))
    (chain target class-list (add "w-50"))))

(on ("click" (one "body") event :dynamic-selector ".resizeImage100")
  (chain event (prevent-default))
  (chain event (stop-propagation))
  (let ((target (get-popover-target (chain event current-target))))
    (chain (one target) (popover "hide"))
    (chain document (get-elements-by-tag-name "article") 0 (focus))
    (chain target class-list (remove "w-25"))
    (chain target class-list (remove "w-50"))
    (chain target class-list (add "w-100"))))

(on ("click" (one "body") event :dynamic-selector ".deleteImage")
  (chain event (prevent-default))
  (chain event (stop-propagation))
  (let ((target (get-popover-target (chain event current-target))))
    (chain (one target) (popover "hide"))
    (chain document (get-elements-by-tag-name "article") 0 (focus))
    (chain target (remove))))

(on ("click" (one "#update-image") event)
  (chain (one "#image-modal") (modal "hide"))
  (chain document (get-elements-by-tag-name "article") 0 (focus))
  (if (chain (one "#image-url") (val))
      (chain document
       (exec-command "insertHTML" f
        (concatenate 'string "<img src=\"" (chain (one "#image-url") (val))
                     "\"></img>")))
      (send-file
       (chain document (get-element-by-id "image-file") files 0))))

(tool "table" (chain (one "#table-modal") (modal "show")))

(on ("click" (one "#update-table") event)
  (chain (one "#table-modal") (modal "hide"))
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
    (create-popover-for target "table data")
    (chain (one target) (popover "show"))))

(tool "insertFormula"
 (on ("click" (one "#update-formula") event)
   (chain (one "#formula-modal") (modal "hide"))
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
 (chain (one "#formula-modal") (modal "show"))
 (setf (chain window mathfield)
       (chain -math-live
        (make-math-field (chain document (get-element-by-id "formula"))
         (create virtual-keyboard-mode "manual")))))

(on ("click" (one "#update-formula") event)
  (chain (one "#formula-modal") (modal "hide"))
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

(tool "settings" (chain (one "#settings-modal") (modal "show")))

(tool "finish"
  (on ("shown.bs.modal" (one "#publish-changes-modal") event)
    (chain (one "#change-summary") (trigger "focus")))
  (chain (one "#publish-changes-modal") (modal "show")))

(defun random-int ()
  (chain -math (floor (* (chain -math (random)) 10000000000000000))))

(defun create-popover-for (element content)
  (if (not (chain element id))
      (setf (chain element id)
            (concatenate 'string "popover-target-" (random-int))))
  (chain (one element)
   (popover
    (create html t template
     (concatenate 'string "<div data-target=\"#" (chain element id)
                  "\" class=\"popover\" role=\"tooltip\"><div class=\"arrow\"></div><h3 class=\"popover-header\"></h3><div class=\"popover-body\"></div></div>")
     content content trigger "manual"))))

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
             (chain (one target) (popover "hide")))))

(chain (one "body") (click remove-old-popovers))

(on ("click" (one "body") event :dynamic-selector "article[contenteditable=true] .formula")
  (let ((target (chain event current-target)))
    (create-popover-for target
     "<a href=\"#\" class=\"editFormula\"><span class=\"fas fa-pen\"></span></a> <a href=\"#\" class=\"deleteFormula\"><span class=\"fas fa-trash\"></span></a>")
    (chain (one target) (popover "show"))))

(on ("click" (one "body") event :dynamic-selector ".deleteFormula")
  (chain event (prevent-default))
  (chain event (stop-propagation))
  (let ((target (get-popover-target (chain event current-target))))
    (chain (one target) (popover "hide"))
    (chain document (get-elements-by-tag-name "article") 0 (focus))
    (chain target (remove))))

(on ("click" (one "body") event :dynamic-selector ".editFormula")
  (chain event (prevent-default))
  (chain event (stop-propagation))
  (let* ((target (get-popover-target (chain event current-target)))
         (content (chain -math-live (get-original-content target))))
    (chain (one target) (popover "hide"))
    (chain document (get-elements-by-tag-name "article") 0 (focus))
    (setf (chain document (get-element-by-id "formula") inner-h-t-m-l)
          (concatenate 'string "\\( " content " \\)"))
    (setf (chain window mathfield)
          (chain -math-live
           (make-math-field (chain document (get-element-by-id "formula"))
            (create virtual-keyboard-mode "manual"))))
    (chain (one "#formula-modal") (modal "show"))
    (chain (one "#update-formula") (off "click")
     (click
      (lambda (event)
        (chain (one "#formula-modal") (modal "hide"))
        (chain document (get-elements-by-tag-name "article") 0 (focus))
        (let ((latex (chain window mathfield (latex))))
          (chain window mathfield (revert-to-original-content))
          (setf (chain target inner-h-t-m-l)
                (concatenate 'string "\\( " latex " \\)"))
          (loop for element in (chain document
                                (get-elements-by-class-name "formula"))
                do (chain -math-live
                    (render-math-in-element element)))))))))
