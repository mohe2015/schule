(ql:quickload :cl-pdf-parser)
(in-package :pdf)

(ql:quickload :deflate)
(ql:quickload :flexi-streams)

(defparameter *JO* (car (content (content (cdr (assoc "/Contents" (dict-values (content (elt (cdr (assoc "/Kids" (dict-values (content (root-page (read-pdf-file #P"/home/moritz/Downloads/vs.pdf")))) :test #'equal)) 0))) :test #'equal))))))

(let* ((pdf (read-pdf-file #P"/home/moritz/Downloads/vs.pdf"))
       (contents (map 'list 'content (objects pdf)))
       (streams (remove-if-not (lambda (x) (typep x 'pdf::pdf-stream)) contents))
       (jo (remove-if-not (lambda (x) (equal "/FlateDecode" (cdr (assoc "/Filter" (dict-values x) :test #'equal)))) streams))
       (strings (mapcar 'content jo))
       (strings2 (mapcar 'car strings))
       (decompressed (mapcar 'decompress-string strings2)))
  decompressed)

(defun decompress-string (string)
  (flexi-streams:octets-to-string
   (let ((in (flexi-streams:make-in-memory-input-stream (flexi-streams:string-to-octets string))))
     (flexi-streams:with-output-to-sequence (out)
       (deflate:inflate-zlib-stream in out)))))


