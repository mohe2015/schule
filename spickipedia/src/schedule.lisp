(in-package :spickipedia.web)

(my-defroute :POST "/api/teachers" (:admin :user) (|name| |initial|) "text/html"
  (let* ((teacher  (mito:create-dao 'teacher))
         (revision (mito:create-dao 'teacher-revision
                                    :author user
                                    :teacher teacher
                                    :name |name|
                                    :initial |initial|)))
    (format nil "~a" (object-id teacher))))
