(var __-p-s_-m-v_-r-e-g)


(i "./show-tab.lisp" "showTab")
(i "./cleanup.lisp" "cleanup")
(i "./math.lisp" "renderMath")
(i "./image-viewer.lisp")
(i "./fetch.lisp" "checkStatus" "json" "handleFetchError")
(i "./utils.lisp" "all" "one" "clearChildren")

(defun update-page (data)
  (remove (all ".closable-badge"))
  (setf (inner-html (one "#categories")) "")
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
  (setf (inner-html (one "article")) (chain data content))
  (render-math)
  (show-tab "#page"))

(defroute "/wiki/:name"
 (remove-class (one ".edit-button") "disabled")
 (add-class (one "#is-outdated-article") "d-none")
 (setf (inner-text (one "#wiki-article-title")) (decode-u-r-i-component name))
 (cleanup)
 (var network-data-received f)
 (show-tab "#loading")
 (var network-update
      (chain (fetch (concatenate 'string "/api/wiki/" name))
       (then check-status)
       (then json)
       (then (lambda (data) (setf network-data-received t) (update-page data)))
       (catch
           (lambda (error)
             (if (= (chain error response status) 404)
                 (show-tab "#not-found")
                 (handle-fetch-error error))))))

 (chain
  caches
  (match (concatenate 'string "/api/wiki/" name))
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
            (handle-fetch-error error))))))
