
(var __-p-s_-m-v_-r-e-g)

(i "./utils.lisp" "all" "one" "clearChildren")

(export
 (defun show-tab (id)
   ;; temp1.filter(function (tab) { return tab.id != "edit-quiz" })
   (chain (all ".my-tab")
          (filter
           (lambda (tab)
             (not (= (chain tab id) id))))
          (hide-element))
   (show-element (one id))))
