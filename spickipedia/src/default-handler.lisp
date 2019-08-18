(in-package :spickipedia.web)

(defroute ("/.*" :regexp t :method :get) ()
  (basic-headers)
  (let ((path (merge-pathnames-as-file *static-directory* (parse-namestring (subseq (request-path-info *request*) 1)))))
    (if (and (file-exists-p path) (not (directory-exists-p path)))
        (with-cache-vector (read-file-into-byte-vector path)
          (setf (getf (response-headers *response*) :content-type)
                (get-safe-mime-type path))
          path)
        (test))))

;; (merge-pathnames #P"../subpath/" #P"/basepath/")

;; https://stackoverflow.com/a/44684290/5074433
(defun abspath (path-string)
  (uiop:unix-namestring
   (uiop:merge-pathnames*
    (uiop:parse-unix-namestring path-string))))
; (abspath "/basepath/../fakesubpath/")

(defun subpath-p (base-path sub-path)
  (let ((absolute-sub-directory (uiop:pathname-directory-pathname (abspath sub-path))))
    (loop while (not (equal #P"/" absolute-sub-directory)) do
	 (if (equal base-path absolute-sub-directory)
	     (return-from subpath-p t))
	 (setf absolute-sub-directory (uiop:pathname-parent-directory-pathname absolute-sub-directory)))
  nil))

(assert (subpath-p #P"/test/" #P"/test/subpath/"))
(assert (not (subpath-p #P"/test/" #P"/test/../fakesubpath/")))
