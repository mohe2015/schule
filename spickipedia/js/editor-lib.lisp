(var __-p-s_-m-v_-r-e-g)

(i "./test.lisp")
(i "./file-upload.lisp" "sendFile")
(i "./categories.lisp")
(i "./handle-error.lisp" "handleError")

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
       (chain event (stop-propagation))
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

(defun get-url (url)
  (new (-u-r-l url (chain window location origin))))

(export (defun is-local-url (url)
         (try
          (let ((url (get-url url)))
            (return (= (chain url origin) (chain window location origin))))
          (:catch (error)
            (return F)))))

;; TODO allow to edit links
;; TODO handle full urls to local wiki page
(defun update-link (url)
  (if (is-local-url url)

      ;; local url
      (let ((parsed-url (get-url url)))
       (if (chain window (get-selection) is-collapsed)
           (chain document (exec-command "insertHTML" F (concatenate 'string "<a href=\"" (chain parsed-url pathname) "\">" url "</a>")))
           (chain document (exec-command "createLink" F (chain parsed-url pathname)))))

         ;; external url
      (if (chain window (get-selection) is-collapsed)
       (chain document (exec-command "insertHTML" F (concatenate 'string "<a target=\"_blank\" rel=\"noopener noreferrer\" href=\"" url "\">" url "</a>")))
       (progn
         (chain document (exec-command "createLink" F url))
         (let* ((selection (chain window (get-selection)))
                (link (chain selection focus-node parent-element (closest "a"))))
           (setf (chain link target) "_blank")
           (setf (chain link rel) "noopener noreferrer"))))))

(tool "createLink"
      (chain
       ($ "#link-form")
       (off "submit")
       (submit
        (lambda (event)
          (chain event (prevent-default))
          (chain event (stop-propagation))
          (chain ($ "#link-modal") (modal "hide"))
          (restore-range)
          (update-link (chain ($ "#link") (val))))))
      (chain ($ "#link-modal") (modal "show")))

(var network-data-received F)

(var articles (array))

;; fetch fresh data
(var
 network-update
 (chain (fetch "/api/articles")
    (then (lambda (response)
           (chain response (json))))
    (then (lambda (data)
           (setf network-data-received T)
           (setf articles data)))))

;; fetch cached data
(chain
 caches
 (match "/api/articles")
 (then (lambda (response)
        (if (not response)
            (throw (-error "No data"))) ;; is that right syntax?
        (chain response (json))))
 (then (lambda (data)
     ;; don't overwrite newer network data
        (if (not network-data-received)
            (setf articles data))))
 (catch (lambda ()
      ;; we didn't get cached data, the network is our last hope
         network-update))
 (catch (lambda (jq-xhr text-status error-thrown)
         F)))

(chain
 document
 (get-element-by-id "link")
 (add-event-listener
  "input"
  (lambda (event)
    (chain console (log event))
    (let* ((input (chain document (get-element-by-id "link")))
           (value (chain input value (replace "/wiki/" "")))
           (result (chain
                    articles
                    (filter
                     (lambda (article)
                       (not (= (chain article (to-lower-case) (index-of (chain value (to-lower-case)))) -1)))))))
      (chain console (log result))
      (setf (chain input next-element-sibling inner-h-t-m-l) "")
      (if (> (chain result length) 0)
       (chain input next-element-sibling class-list (add "show"))
       (chain input next-element-sibling class-list (remove "show")))
      (loop for article in result do
       (let ((element (chain document (create-element "div"))))
         (setf (chain element class-name) "dropdown-item")
         (setf (chain element inner-h-t-m-l) article) ;; TODO XSS
         (chain
          element
          (add-event-listener
           "click"
           (lambda (event)
            (setf (chain input value) (concatenate 'string "/wiki/" (chain element inner-h-t-m-l)))
            (chain input next-element-sibling class-list (remove "show")))))

         (chain input next-element-sibling (append element))))
      nil))))

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

      ;; TODO
      (chain ($ "#link") (val (chain ($ target) (attr "href"))))

      (chain
       ($ "#link-form")
       (off "submit")
       (submit
        (lambda (event)
          (chain event (prevent-default))
          (chain event (stop-propagation))
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
    (let ((target (chain event current-target)))
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
      (chain target class-list (add "w-25")))
    F)))

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
    (let ((target (chain event current-target)))
      (create-popover-for target "table data")
      (chain ($ target) (popover "show"))))))

(tool "insertFormula"
      (chain
       ($ "#update-formula")
       (off "click")
       (click
        (lambda (event)
          (chain ($ "#formula-modal") (modal "hide"))
          (chain document (get-elements-by-tag-name "article") 0 (focus))
          (let ((latex (chain window mathfield (latex))))
            (chain window mathfield (revert-to-original-content))
            (chain document (exec-command "insertHTML" F (concatenate 'string "<span class=\"formula\" contenteditable=\"false\">\\(" latex "\\)</span>")))
            (loop for element in (chain document (get-elements-by-class-name "formula")) do
             (chain -math-live (render-math-in-element element)))))))

      (chain ($ "#formula-modal") (modal "show"))
      (setf (chain window mathfield) (chain -math-live (make-math-field (chain document (get-element-by-id "formula")) (create virtual-keyboard-mode "manual")))))

(chain
 ($ "#update-formula")
 (off "click")
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

(tool "settings"
      (chain ($ "#settings-modal") (modal "show")))

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

(chain
 ($ "body")
 (on
  "click"
  "article[contenteditable=true] .formula"
  (lambda (event)
    (let ((target (chain event current-target)))
      (create-popover-for target "<a href=\"#\" class=\"editFormula\"><span class=\"fas fa-pen\"></span></a> <a href=\"#\" class=\"deleteFormula\"><span class=\"fas fa-trash\"></span></a>")

      (chain ($ target) (popover "show"))))))

(chain
 ($ "body")
 (on
  "click"
  ".deleteFormula"
  (lambda (event)
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (let ((target (get-popover-target (chain event current-target))))
      (chain ($ target) (popover "hide"))
      (chain document (get-elements-by-tag-name "article") 0 (focus))
      (chain target (remove))))))

(chain
 ($ "body")
 (on
  "click"
  ".editFormula"
  (lambda (event)
    (chain event (prevent-default))
    (chain event (stop-propagation))
    (let* ((target (get-popover-target (chain event current-target)))
           (content (chain -math-live (get-original-content target))))
      (chain ($ target) (popover "hide"))
      (chain document (get-elements-by-tag-name "article") 0 (focus))

      (setf (chain document (get-element-by-id "formula") inner-h-t-m-l) (concatenate 'string "\\( " content " \\)"))
      (setf (chain window mathfield) (chain -math-live (make-math-field (chain document (get-element-by-id "formula")) (create virtual-keyboard-mode "manual"))))
      (chain ($ "#formula-modal") (modal "show"))

      (chain
       ($ "#update-formula")
       (off "click")
       (click
        (lambda (event)
          (chain ($ "#formula-modal") (modal "hide"))
          (chain document (get-elements-by-tag-name "article") 0 (focus))
          (let ((latex (chain window mathfield (latex))))
            (chain window mathfield (revert-to-original-content))
            (setf (chain target inner-h-t-m-l) (concatenate 'string "\\( " latex " \\)"))
            (loop for element in (chain document (get-elements-by-class-name "formula")) do
             (chain -math-live (render-math-in-element element)))))))))))
