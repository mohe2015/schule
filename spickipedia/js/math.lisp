
(var __-p-s_-m-v_-r-e-g)
(i "./test.lisp")
(export
 (defun render-math ()
   (chain ($ ".formula")
    (each (lambda () (chain -math-live (render-math-in-element this)))))
   (chain ($ "article")
    (on "summernote.init"
     (lambda () (chain ($ ".formula") (attr "contenteditable" f)))))))
(export
 (defun revert-math (dom)
   (chain dom (find ".formula")
    (each
     (lambda ()
       (setf (@ this inner-h-t-m-l)
             (concatenate 'string "\\( "
                          (chain -math-live (get-original-content this))
                          " \\)")))))))
