
(var __-p-s_-m-v_-r-e-g)
(i "./test.lisp")
(i "./editor-lib.lisp")
(i "./math.lisp" "revertMath")
(i "./read-cookie.lisp" "readCookie")
(i "./push-state.lisp" "pushState")
(i "./utils.lisp" "all" "one" "clearChildren")

(on ("click" (one "#publish-changes") event)
  (hide (one "#publish-changes"))
  (show (one "#publishing-changes"))
  (let ((change-summary (value (one "#change-summary")))
        (temp-dom (chain (one "article") (clone-node t)))
        (article-path (chain window location pathname (split "/") 2)))
    (revert-math temp-dom)
    (var categories
         (chain (one "#modal-settings") (query-selector ".closable-badge-label")
          (map (lambda () (chain this inner-text))) (get)))
    (chain $
     (post (concatenate 'string "/api/wiki/" article-path)
      (create summary change-summary html (chain temp-dom (html)) categories
       categories _csrf_token (read-cookie "_csrf_token"))
      (lambda (data)
        (push-state (concatenate 'string "/wiki/" article-path))))
     (fail
      (lambda (jq-xhr text-status error-thrown)
        (chain (one "#publish-changes") (show))
        (chain (one "#publishing-changes") (hide))
        (handle-error jq-xhr f))))))

(export
 (defun show-editor ()
   (remove-class (one "#editor") "d-none")
   (setf (content-editable (one "article")) t)
   (if (= (inner-html (one "article")) "")
       (setf (inner-html (one "article")) "<p></p>"))
   (add-class (one ".article-editor") "fullscreen")
   (chain document (exec-command "defaultParagraphSeparator" f "p"))))
