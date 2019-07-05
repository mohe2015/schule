
(var __-p-s_-m-v_-r-e-g) 
(i "../show-tab.lisp" "showTab") 
(i "../read-cookie.lisp" "readCookie") 
(i "../handle-error.lisp" "handleError") 
(i "../fetch.lisp" "checkStatus" "json" "html" "handleFetchError") 
(i "../template.lisp" "getTemplate") 
(defroute "/courses" (show-tab "#list-courses")
          (chain (fetch "/api/courses") (then check-status) (then json)
           (then
            (lambda (data)
              (if (null data)
                  (setf data ([])))
              (let ((courses-list
                     (chain document (get-element-by-id "courses-list"))))
                (setf (chain courses-list inner-h-t-m-l) "")
                (loop for page in data
                      do (let ((template (get-template "courses-list-html")))
                           (setf (chain template
                                  (query-selector ".courses-list-subject")
                                  inner-text)
                                   (chain page subject))
                           (chain document (get-element-by-id "courses-list")
                            (append template)))))))
           (catch handle-fetch-error))) 