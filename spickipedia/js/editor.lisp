(var __-p-s_-m-v_-r-e-g)

(i "./editor-lib.lisp")
(i "./math.lisp" "revertMath")
(i "./read-cookie.lisp" "readCookie")
(i "./state-machine.lisp" "pushState")
(i "./utils.lisp" "all" "one" "clearChildren")
(i "./fetch.lisp" "checkStatus" "json" "html" "handleFetchError")

(on ("click" (one "#publish-changes") event)
    (hide (one "#publish-changes"))
    (show (one "#publishing-changes"))
    (let ((change-summary (value (one "#change-summary")))
          (temp-dom (chain (one "article") (clone-node t)))
          (article-path (chain window location pathname (split "/") 2))
          (formdata (new (-form-data))))
      (revert-math temp-dom)
      (var categories (chain (all ".closable-badge-label" (one "#modal-settings")) (map (lambda (category) (chain category inner-text)))))
      (chain formdata (append "_csrf_token" (read-cookie "_csrf_token")))
      (chain formdata (append "summary" change-summary))
      (chain formdata (append "html" (inner-html temp-dom)))
      (loop for category in categories do
	   (chain formdata (append "categories[]" category)))
      (chain (fetch (concatenate 'string "/api/wiki/" article-path) (create method "POST" body formdata))
             (then check-status)
             (then
              (lambda (data)
		(hide-modal (one "#modal-publish-changes"))
		(push-state (concatenate 'string "/wiki/" article-path))))
             (catch
		 (lambda (error)
		   (chain (one "#publish-changes") (show-element))
		   (chain (one "#publishing-changes") (hide-element))
		   (handle-fetch-error error))))))

(export
 (defun show-editor ()
   (remove-class (one "#editor") "d-none")
   (setf (content-editable (one "article")) t)
   (if (= (inner-html (one "article")) "")
       (setf (inner-html (one "article")) "<p></p>"))
   (add-class (one ".article-editor") "fullscreen")
   (chain document (exec-command "defaultParagraphSeparator" f "p"))))

(export
 (defun hide-editor ()
   (add-class (one "#editor") "d-none")
   (setf (content-editable (one "article")) f)
   (remove-class (one ".article-editor") "fullscreen")))
