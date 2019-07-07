
(var __-p-s_-m-v_-r-e-g)
(i "./test.lisp")
(i "./editor-lib.lisp")
(i "./math.lisp" "revertMath")
(i "./read-cookie.lisp" "readCookie")
(i "./push-state.lisp" "pushState")
(i "./utils.lisp" "showModal" "all" "one" "hideModal" "clearChildren")

(on "click" "#publish-changes" event
  (chain (one "#publish-changes") (hide))
  (chain (one "#publishing-changes") (show))
  (let ((change-summary (chain (one "#change-summary") (val)))
        (temp-dom (chain (one "article") (clone)))
        (article-path (chain window location pathname (split "/") 2)))
    (revert-math temp-dom)
    (var categories
         (chain (one "#settings-modal") (find ".closable-badge-label")
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
   (chain (one "#editor") (remove-class "d-none"))
   (chain (one "article") (attr "contenteditable" t))
   (if (= (chain (one "article") (html)) "")
       (chain (one "article") (html "<p></p>")))
   (chain (one ".article-editor") (add-class "fullscreen"))
   (chain document (exec-command "defaultParagraphSeparator" f "p"))))
