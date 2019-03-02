(defun render-math ()
  (chain
   ($ ".formula")
   (each
    (lambda ()
      (chain -math-live (render-math-in-element this)))))
  (chain
   ($ "article")
   (on "summernote.init"
       (lambda ()
	 (chain
	  ($ ".formula")
	  (click
	   (lambda ()
	     (alert 1))))
	 (chain ($ ".formula") (attr "contenteditable" F))))))

(defun revert-math (dom)
  (chain
   dom
   (find ".formula")
   (each
    (lambda ()
      (setf (@ this inner-h-t-m-l) (concatenate 'string "\\( " (chain -math-live (get-original-content this)) " \\)"))))))
