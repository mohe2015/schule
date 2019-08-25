
(var __-p-s_-m-v_-r-e-g)

(i "./read-cookie.lisp" "readCookie")
(i "./utils.lisp" "all" "one" "clearChildren")

(export
 (defun send-file (file)
   (show-modal (one "#modal-upload-progress"))
   (let ((data (new (-form-data))))
     (chain data (append "file" file))
     (chain data (append "_csrf_token" (read-cookie "_csrf_token")))
     (setf (@ window file-upload-finished) f)
     (setf (@ window file-upload-xhr)
           (chain
             (fetch "/api/upload"
                (create
                  method "POST"
                  body data
                  xhr
                    (lambda ()
                         (let ((my-xhr (chain $ ajax-settings (xhr))))
                              (if (chain my-xhr upload)
                               (chain my-xhr upload
                                    (add-event-listener "progress"
                                                 progress-handling-function f)))
                              my-xhr))))
             (then
               (lambda (url)
                    (setf (@ window file-upload-finished) t)
                    (hide-modal (one "#modal-upload-progress"))
                    (chain
                        (chain document
                            (exec-command "insertHTML" f
                                  (concatenate 'string
                                         "<figure class=\"figure\"><img src=\"/api/file/"
                                         url
                                         "\" class=\"figure-img img-fluid rounded\" alt=\"...\"><figcaption class=\"figure-caption\">A caption for the above image.</figcaption></figure>"))))))
             (catch
               (lambda (error)
                    (if (not (@ window file-upload-finished))
                     (progn
                           (setf (@ window file-upload-finished) t)
                           (hide-modal (one "#modal-upload-progress"))
                           (alert "Fehler beim Upload!"))))))))))

(defun progress-handling-function (e)
  (if (@ e length-computable)
      (chain (one "#uploadProgress")
       (css "width"
        (concatenate 'string (* 100 (/ (@ e loaded) (@ e total))) "%"))))

  (on ("shown.bs.modal" (one "#modal-upload-progress") event)
      (if (@ window file-upload-finished)
          (hide-modal (one "#modal-upload-progress"))))

  (on ("hide.bs.modal" (one "#modal-upload-progress") event)
      (if (not (@ window file-upload-finished))
          (progn
            (setf (@ window file-upload-finished) t)
            (chain window file-upload-xhr (abort)))))

  (on ("hidden.bs.modal" (one "#modal-upload-progress") event)
      (chain (one "#uploadProgress") (attr "width" "0%"))))
