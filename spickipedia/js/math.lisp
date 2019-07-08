(var __-p-s_-m-v_-r-e-g)

(i "./test.lisp")
(i "./utils.lisp" "all" "one" "clearChildren")

(export
 (defun render-math ()
   (chain (all ".formula")
    (for-each (lambda () (chain -math-live (render-math-in-element this)))))
   (on ("summernote.init" (one "article") event)
     (chain (one ".formula") (attr "contenteditable" f)))))

(export
 (defun revert-math (dom)
   (chain dom (find ".formula")
    (each
     (lambda ()
       (setf (@ this inner-h-t-m-l)
             (concatenate 'string "\\( "
                          (chain -math-live (get-original-content this))
                          " \\)")))))))
