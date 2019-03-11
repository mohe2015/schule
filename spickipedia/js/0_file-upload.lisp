
(defun send-file (file)
  (chain ($ "#uploadProgressModal") (modal "show"))
  (let ((data (new (-form-data))))
    (chain data (append "file" file))
    (chain data (append "_csrf_token" (read-cookie "_csrf_token")))
    (setf (@ window file-upload-finished) F)
    (setf
     (@ window file-upload-xhr)
     (chain
      $
      (ajax
       (create
	data data
	type "POST"
	xhr (lambda ()
	      (let ((my-xhr (chain $ ajax-settings (xhr))))
		(if (chain my-xhr upload)
		    (chain my-xhr upload (add-event-listener "progress" progress-handling-function F)))
		my-xhr))
	url "/api/upload"
	cache F
	content-type F
	process-data F
	success (lambda (url)
		  (setf (@ window file-upload-finished) T)
		  (chain ($ "#uploadProgressModal") (modal "hide"))
		  (chain (chain document (exec-command "insertHTML" F (concatenate 'string "<figure class=\"figure\"><img src=\"/api/file/" url "\" class=\"figure-img img-fluid rounded\" alt=\"...\"><figcaption class=\"figure-caption\">A caption for the above image.</figcaption></figure>")))))
	error (lambda ()
		(if (not (@ window file-upload-finished))
		    (progn
		      (setf (@ window file-upload-finished) T)
		      (chain ($ "#uploadProgressModal") (modal "hide"))
		      (alert "Fehler beim Upload!"))))))))))

(defun progress-handling-function (e)
  (if (@ e length-computable)
      (chain ($ "#uploadProgress") (css "width" (concatenate 'string (* 100 (/ (@ e loaded) (@ e total))) "%")))))

(chain
 ($ "#uploadProgressModal")
 (on "shown.bs.modal"
     (lambda (e)
       (if (@ window file-upload-finished)
	   (chain ($ "#uploadProgressModal") (modal "hide"))))))

(chain
 ($ "#uploadProgressModal")
 (on "hide.bs.modal"
     (lambda (e)
       (if (not (@ window file-upload-finished))
	   (progn
	     (setf (@ window file-upload-finished) T)
	     (chain window file-upload-xhr (abort)))))))

(chain
 ($ "#uploadProgressModal")
 (on "hidden.bs.modal"
     (lambda (e)
       (chain ($ "#uploadProgress") (attr "width" "0%"))))) 
