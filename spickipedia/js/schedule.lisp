(in-package :spickipedia.web)

(my-defroute :POST "/api/teachers" (:admin :user) (|name| |initial|) "text/html"
  (let* ((teacher  (mito:create-dao 'teacher))
         (revision (mito:create-dao 'teacher-revision
                                    :teacher teacher
                                    :name |name|
                                    :initial |initial|)))
    (object-id teacher)))

(chain
  ($ "#create-teacher-form")
  (submit
    (lambda (event)
      (post (concatenate 'string "/api/quiz" (chain pathname 2))
        (create
         _csrf_token (read-cookie "_csrf_token")
         data (chain -J-S-O-N (stringify obj)))
        T))))
