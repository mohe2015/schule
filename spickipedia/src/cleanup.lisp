(ql:quickload "str")

(defun mapc-directory-tree (fn directory &key (depth-first-p t))
  (dolist (entry (cl-fad:list-directory directory))
    (unless depth-first-p
      (funcall fn entry))
    (when (cl-fad:directory-pathname-p entry)
      (mapc-directory-tree fn entry))
    (when depth-first-p
      (funcall fn entry))))

(defun update-file (file)
  (if (and (pathname-name file) (str:ends-with? ".lisp" (file-namestring file)))
    (let ((result
            (with-open-file (s file)
              (macrolet ((:div (&rest rest)
                           (if (equal (subseq rest 0 5)
                                      '(:style "display: none;" :class "container-fluid my-tab position-absolute" :id))
                             ``(tab ,,(nth 5 rest) ,',@(subseq rest 6))
                             nil)))
                (loop for sexp = (read s)
                      while sexp
                      collect sexp)))))
      (with-open-file (s file) :direction :output :if-exists :supersede
        (loop for sexp in result do
          (print sexp s))))))

(mapc-directory-tree 'update-file (asdf:system-source-directory :spickipedia))
