(var __-p-s_-m-v_-r-e-g)

(i "../template.lisp" "getTemplate")
(i "../show-tab.lisp" "showTab")
(i "../math.lisp" "renderMath")
(i "../image-viewer.lisp")
(i "../fetch.lisp" "checkStatus" "json" "handleFetchErrorShow" "cacheThenNetwork")
(i "../utils.lisp" "all" "one" "clearChildren")
(i "../state-machine.lisp" "enterState")

(defun update-page (data)
  (when (chain data categories)
    (remove (all ".closable-badge" (one "#categories")))
    (loop for category in (chain data categories) do
     (let ((template (get-template "template-readonly-category")))
          (setf (inner-html (one ".closable-badge" template)) category)
          (append (one "#categories") template))))
  (setf (inner-html (one "article")) (chain data content))
  (show-tab "#page"))

(defroute "/wiki/:page"
    (enter-state "handleWikiPage")

  (setf (inner-text (one "#wiki-article-title")) (decode-u-r-i-component page))
  (show-tab "#loading")
  (cache-then-network (concatenate 'string "/api/wiki/" page) update-page))

(defstate handle-wiki-page-enter
    (remove-class (all ".edit-button") "disabled"))

(defstate handle-wiki-page-exit
    (add-class (all ".edit-button") "disabled"))
