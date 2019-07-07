
(var __-p-s_-m-v_-r-e-g)
(i "./test.lisp")
(i "./show-tab.lisp" "showTab")
(i "./cleanup.lisp" "cleanup")
(i "./handle-error.lisp" "handleError")
(i "./math.lisp" "renderMath")
(i "./image-viewer.lisp")
(i "./fetch.lisp" "checkStatus" "json")
(i "./utils.lisp" "showModal" "all" "one" "hideModal" "clearChildren")

(defun update-page (data)
  (chain (one ".closable-badge") (remove))
  (chain (one "#categories") (html ""))
  (if (chain data categories)
      (loop for category in (chain data categories)
            do (chain (one "#categories")
                (append
                 (who-ps-html
                  (:span :class "closable-badge bg-secondary"
                   category)))) (chain (one "#new-category")
                                 (before
                                  (who-ps-html
                                   (:span :class "closable-badge bg-secondary"
                                    (:span :class "closable-badge-label"
                                     category)
                                    (:button :type "button" :class
                                     "close close-tag" :aria-label "Close"
                                     (:span :aria-hidden "true"
                                      "&times;"))))))))
  (chain (one "article") (html (chain data content)))
  (render-math)
  (show-tab "#page"))
(defroute "/wiki/:name"
 (var pathname (chain window location pathname (split "/")))
 (chain (one ".edit-button") (remove-class "disabled"))
 (chain (one "#is-outdated-article") (add-class "d-none"))
 (chain (one "#wiki-article-title")
  (text (decode-u-r-i-component (chain pathname 2))))
 (cleanup) (var network-data-received f) (show-tab "#loading")
 (var network-update
      (chain (fetch (concatenate 'string "/api/wiki/" (chain pathname 2)))
       (then check-status) (then json)
       (then (lambda (data) (setf network-data-received t) (update-page data)))
       (catch
           (lambda (error)
             (if (= (chain error response status) 404)
                 (show-tab "#not-found")
                 (handle-error (chain error response) t))))))
 (chain caches (match (concatenate 'string "/api/wiki/" (chain pathname 2)))
  (then check-status) (then json)
  (then
   (lambda (data)
     (if (not network-data-received)
         (update-page data))))
  (catch (lambda () network-update))
  (catch
      (lambda (error)
        (if (= (chain error response status) 404)
            (show-tab "#not-found")
            (handle-error (chain error response) t))))))
