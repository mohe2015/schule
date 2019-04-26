(in-package :spickipedia.web)

(my-defroute :POST "/api/teachers" (:admin :user) (|name| |initial|) "text/html"
  (format t "data: ~a ~a ~a" user |name| |initial|)
  (let* ((teacher  (create-dao 'teacher))
         (revision (create-dao 'teacher-revision
                               :author user
                               :teacher teacher
                               :name |name|
                               :initial |initial|)))
    (format nil "~a" (object-id teacher))))
