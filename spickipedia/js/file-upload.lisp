
(var __-p-s_-m-v_-r-e-g)

(i "./read-cookie.lisp" "readCookie")
(i "./utils.lisp" "all" "one" "clearChildren")

(export
 (defun send-file (file)
   (show-modal (one "#uploadProgressModal"))
   (let ((data (new (-form-data))))
     (chain data (append "file" file))
     (chain data (append "_csrf_token" (read-cookie "_csrf_token")))
     (setf (@ window file-upload-finished) f)
     (setf (@ window file-upload-xhr)
           (chain $
		  (ajax
		   (create data data type "POST" xhr
			   (lambda ()
			     (let ((my-xhr (chain $ ajax-settings (xhr))))
			       (if (chain my-xhr upload)
				   (chain my-xhr upload
					  (add-event-listener "progress"
							      progress-handling-function f)))
			       my-xhr))
			   url "/api/upload" cache f content-type f process-data f success
			   (lambda (url)
			     (setf (@ window file-upload-finished) t)
			     (hide-modal (one "#uploadProgressModal"))
			     (chain
			      (chain document
				     (exec-command "insertHTML" f
						   (concatenate 'string
								"<figure class=\"figure\"><img src=\"/api/file/"
								url
								"\" class=\"figure-img img-fluid rounded\" alt=\"...\"><figcaption class=\"figure-caption\">A caption for the above image.</figcaption></figure>")))))
			   error
			   (lambda ()
			     (if (not (@ window file-upload-finished))
				 (progn
				   (setf (@ window file-upload-finished) t)
				   (hide-modal (one "#uploadProgressModal"))
				   (alert "Fehler beim Upload!")))))))))))

(defun progress-handling-function (e)
  (if (@ e length-computable)
      (chain (one "#uploadProgress")
	     (css "width"
		  (concatenate 'string (* 100 (/ (@ e loaded) (@ e total))) "%"))))

  (on ("shown.bs.modal" (one "#uploadProgressModal") event)
      (if (@ window file-upload-finished)
          (hide-modal (one "#uploadProgressModal"))))

  (on ("hide.bs.modal" (one "#uploadProgressModal") event)
      (if (not (@ window file-upload-finished))
          (progn
            (setf (@ window file-upload-finished) t)
            (chain window file-upload-xhr (abort)))))

  (on ("hidden.bs.modal" (one "#uploadProgressModal") event)
      (chain (one "#uploadProgress") (attr "width" "0%"))))
