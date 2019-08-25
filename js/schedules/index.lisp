
(var __-p-s_-m-v_-r-e-g)
(i "../show-tab.lisp" "showTab")
(i "../read-cookie.lisp" "readCookie")
(i "../fetch.lisp" "checkStatus" "json" "html" "handleFetchError")
(i "../template.lisp" "getTemplate")
(i "../utils.lisp" "all" "one" "clearChildren")

(defroute "/schedules" (show-tab "#list-schedules")
  (chain (fetch "/api/schedules") (then check-status) (then json)
   (then
    (lambda (data)
      (if (null data)
       (setf data ([])))
      (let ((courses-list (chain document (get-element-by-id "schedules-list"))))
        (setf (chain courses-list inner-h-t-m-l) "")
        (loop for page in data
         do (let ((template (get-template "schedules-list-html")))
                 (chain console (log (chain page name)))
                 (setf (chain template
                        (query-selector ".schedules-list-grade") inner-text)
                       (chain page grade))
                 (setf (chain template
                        (query-selector ".schedules-list-grade") href)
                       (concatenate 'string "/schedule/"
                        (chain page grade) "/edit"))
                 (chain document (get-element-by-id "schedules-list")
                  (append template)))))))
   (catch handle-fetch-error)))
