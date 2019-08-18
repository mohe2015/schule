(in-package :spickipedia.web)

(defroute ("/.*" :regexp t :method :get) ()
  (basic-headers)
  (let ((path (merge-pathnames-as-file *static-directory* (parse-namestring (subseq (request-path-info *request*) 1)))))
    (if (and (subpath-p *static-directory* path) (file-exists-p path) (not (directory-exists-p path)))
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
    (loop while (and (not (equal #P"/" absolute-sub-directory)) (ignore-errors (namestring absolute-sub-directory))) do
;;	 (break)
	 (if (equal base-path absolute-sub-directory)
	     (return-from subpath-p t))
	 (setf absolute-sub-directory (uiop:pathname-parent-directory-pathname absolute-sub-directory)))
  nil))

(assert (subpath-p #P"/test/" #P"/test/subpath/"))
(assert (not (subpath-p #P"/test/" #P"/test/../fakesubpath/")))
(assert (not (subpath-p #P"/test/" #P"/wrongpath/subpath/")))
(assert (not (subpath-p #P"/test/" #P"/")))
(assert (not (subpath-p #P"/test/" #P"/test")))
;(assert (subpath-p #P"/test/" #P"/t/../test/"))
(assert (subpath-p #P"/test/" #P"/test/"))
(assert (subpath-p #P"/test/" #P"/test/subfile"))
;(assert (subpath-p #P"/test/" #P"/test/subfile/../../test/"))
