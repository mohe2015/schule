(in-package :spickipedia.web)

(my-defroute :POST "/api/teachers" (:admin :user) (|name| |initial|) "text/html"
  (let* ((teacher  (mito:create-dao 'teacher))
         (revision (mito:create-dao 'teacher-revision
                                    :teacher teacher
                                    :name |name|
                                    :initial |initial|)))
    (object-id teacher)))
