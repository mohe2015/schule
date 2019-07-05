
(in-package :spickipedia.web) 
(defroute ("/.*" :regexp t :method :get) nil (basic-headers)
          (let ((path
                 (merge-pathnames-as-file *static-directory*
                                          (parse-namestring
                                           (subseq
                                            (request-path-info *request*) 1)))))
            (if (and (file-exists-p path) (not (directory-exists-p path)))
                (with-cache-vector (read-file-into-byte-vector path)
                  (setf (getf (response-headers *response*) :content-type)
                          (get-safe-mime-type path))
                  path)
                (test)))) 