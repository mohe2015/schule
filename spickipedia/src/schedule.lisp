(in-package :spickipedia.web)

(my-defroute :POST "/api/teachers" (:admin :user) (|name| |initial|) "text/html"
  (let* ((teacher  (create-dao 'teacher))
         (revision (create-dao 'teacher-revision
                               :author user
                               :teacher teacher
                               :name (first |name|)
                               :initial (first |initial|))))
    (format nil "~a" (object-id teacher))))

(my-defroute :GET "/api/teachers" (:admin :user) () "application/json"
  (let* ((teachers (select-dao 'teacher))
         (teacher-revisions
           (mapcar
             #'(lambda (teacher)
                 (first (select-dao 'teacher-revision (where (:= :teacher teacher)) (order-by (:desc :id)) (limit 1))))
             teachers)))
    (encode-json-to-string teacher-revisions)))

(my-defroute :POST "/api/courses" (:admin :user) (|subject| |type| |teacher| |is-tutorial| |class| |topic|) "text/html"
  (let* ((course  (create-dao 'course))
         (revision (create-dao 'course-revision
                               :author user
                               :course course
                               :name (first |subject|)
                               :initial (first |type|)
			       :type (first |type|)
			       :subject (first |subject|)
                               :teacher (find-dao 'teacher :id (parse-integer (first |teacher|)))
                               :is-tutorial (equal "on" (first |is-tutorial|))
                               :class (first |class|)
                               :topic (first |topic|))))
    (format nil "~a" (object-id course))))

;; TODO convert this to my-defroute because otherwise we cant use the features of it like  (basic-headers)
;; TODO moved here only temporarily so it only gets in action after all other handlers
;; TODO automatically reload src/index.lisp
(defroute ("/.*" :regexp t :method :GET) ()
  (basic-headers)
  (let ((path (merge-pathnames-as-file *static-directory* (parse-namestring (subseq (lack.request:request-path-info ningle:*request*) 1)))))
    (if (and (cl-fad:file-exists-p path) (not (cl-fad:directory-exists-p path)))
        (with-cache-vector (read-file-into-byte-vector path)
          (setf (getf (response-headers *response*) :content-type) (get-safe-mime-type path))
          path)
        (eval `(sexp-to-html ,(concatenate 'string (namestring *application-root*) "src/index.lisp"))))))
