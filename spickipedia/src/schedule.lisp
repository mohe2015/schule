(in-package :spickipedia.web)

(my-defroute :POST "/api/teachers" (:admin :user) (|name| |initial|) "text/html"
  (let* ((teacher  (create-dao 'teacher))
         (revision (create-dao 'teacher-revision
                               :author user
                               :teacher teacher
                               :name (first |name|)
                               :initial (first |initial|))))
    (format nil "~a" (object-id teacher))))
