
(var __-p-s_-m-v_-r-e-g)
(i "./test.lisp")
(i "./utils.lisp" "showModal" "all" "one" "hideModal" "clearChildren")

(export
 (defun render-math ()
   (chain (one ".formula")
    (each (lambda () (chain -math-live (render-math-in-element this)))))
   (chain (one "article")
    (on "summernote.init"
     (lambda () (chain (one ".formula") (attr "contenteditable" f)))))))
(export
 (defun revert-math (dom)
   (chain dom (find ".formula")
    (each
     (lambda ()
       (setf (@ this inner-h-t-m-l)
             (concatenate 'string "\\( "
                          (chain -math-live (get-original-content this))
                          " \\)")))))))
