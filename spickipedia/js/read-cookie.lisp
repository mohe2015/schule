(i "./test.lisp")

(export (defun read-cookie (name)
         (let ((name-eq (concatenate 'string name "="))
               (ca (chain document cookie (split ";"))))
           (loop for c in ca do
            (if (chain c (trim) (starts-with name-eq))
                (return (chain c (trim) (substring (chain name-eq length)))))))))
