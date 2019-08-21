(in-package :spickipedia.web)

(defparameter *static-files* (make-hash-table :test #'equal))

(loop for file in (directory (concatenate 'string (namestring *application-root*) "/static/**/*.*")) do
     (setf (gethash file *static-files*) file))

(defroute ("/.*" :regexp t :method :get) ()
  (basic-headers)
  (let ((path (merge-pathnames (parse-namestring (subseq (request-path-info *request*) 1)) *static-directory*)))
    (if (gethash path *static-files*)
	(with-cache-vector (read-file-into-byte-vector (gethash path *static-files*))
          (setf (getf (response-headers *response*) :content-type)
                (get-safe-mime-type path))
          path)
        (test))))
