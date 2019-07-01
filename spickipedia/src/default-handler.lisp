(in-package :spickipedia.web)

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
        (test))))
