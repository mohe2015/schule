
(var __-p-s_-m-v_-r-e-g)

(i "./read-cookie.lisp" "readCookie")
(i "./utils.lisp" "all" "one" "clearChildren")
(i "/js/fetch.lisp" "checkStatus" "json" "html" "handleFetchError")

(export
 (defun send-file (file)
   (setf (disabled (one "#update-image")) t)
   (let ((data (new (-form-data))))
     (chain data (append "file" file))
     (chain data (append "_csrf_token" (read-cookie "_csrf_token")))
     (chain
       (fetch "/api/upload"
          (create
            method "POST"
            body data))
       (then check-status)
       (then html)
       (then
         (lambda (url)
           (setf (disabled (one "#update-image")) nil)
           (hide-modal (one "#modal-image"))
           (chain
             document
             (exec-command
               "insertHTML"
               f
               (concatenate
                 'string
                 "<figure class=\"figure\"><img src=\"/api/file/"
                 url
                 "\" class=\"figure-img img-fluid rounded\" alt=\"...\"><figcaption class=\"figure-caption\">A caption for the above image.</figcaption></figure>")))))
       (catch
         (lambda (error)
           (setf (disabled (one "#update-image")) nil)
           (hide-modal (one "#modal-image"))
           (alert "Fehler beim Upload!")))))))
