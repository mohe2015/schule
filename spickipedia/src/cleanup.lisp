
(quicklisp-client:quickload "str")
(quicklisp-client:quickload "cl-fad")
(use-package :cl-fad)
(defun mapc-directory-tree (fn directory &key (depth-first-p t))
  (dolist (entry (list-directory directory))
    (unless depth-first-p (funcall fn entry))
    (when (directory-pathname-p entry) (mapc-directory-tree fn entry))
    (when depth-first-p (funcall fn entry))))
(defun update-file (file)
  (if (not (and (pathname-name file) (str:ends-with? ".lisp" (file-namestring file))))
    (return-from update-file))
  (let ((result
          (with-open-file (s file)
            (loop for sexp = (macrolet ((:div (&rest rest)
                                          (format t "jo:~S~%" rest)
                                          (if (equal (ignore-errors (subseq rest 0 5))
                                                     '(:style
                                                       "display: none;"
                                                       :class
                                                       "container my-tab position-absolute"
                                                       :id))
                                              ``(tab ,,(nth 5 rest)
                                                 ,',@(subseq rest 6))
                                              ``(:div ,,@rest))))
                               (read s nil))
                  while sexp
                  collect sexp))))
    (with-open-file (s file :direction :output :if-exists :supersede)
      (let ((*print-case* :downcase))
        (loop for sexp in result
              do (print sexp s))))))
;;(mapc-directory-tree 'update-file
;;                     (asdf/system:system-source-directory :spickipedia)))))))

(quicklisp-client:quickload "str")
(quicklisp-client:quickload "cl-fad")
(use-package :cl-fad)
(defun mapc-directory-tree (fn directory &key (depth-first-p t))
  (dolist (entry (list-directory directory))
    (unless depth-first-p (funcall fn entry))
    (when (directory-pathname-p entry) (mapc-directory-tree fn entry))
    (when depth-first-p (funcall fn entry))))

(defmacro convert (sexp)
  `(macrolet ((:div (&rest rest)
                    (format t "jo:~S~%" rest)
                    (if (equal (ignore-errors (subseq rest 0 5))
                               '(:style
                                 "display: none;"
                                 :class
                                 "container my-tab position-absolute"
                                 :id))
                        ``(tab ,,(nth 5 rest)
                           ,',@(subseq rest 6))
                        ``(:div ,,@rest))))
     ,sexp))

(defun update-file (file)
  (if (not (or (pathname-name file) (str:ends-with? ".lisp" (file-namestring file))))
    (progn
      (format t "invalid file: ~S~%" file)
      (return-from update-file)))
  (let ((result
          (with-open-file (s file :if-does-not-exist :error)
            (loop for sexp = (convert (read s nil))
                  while sexp
                  collect sexp))))
    (with-open-file (s file :direction :output :if-exists :supersede)
      (let ((*print-case* :downcase))
        (loop for sexp in result
              do (print sexp s))))))
;;(mapc-directory-tree 'update-file
;;                     (asdf/system:system-source-directory :spickipedia)))))))
(update-file #P"spickipedia/src/test.lisp")
