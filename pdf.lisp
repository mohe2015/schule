(ql:quickload :cl-pdf-parser)
(ql:quickload :deflate)
(ql:quickload :flexi-streams)

(use-package :pdf)
(use-package :deflate)
(use-package :flexi-streams)

(defun decompress-string (string)
  (octets-to-string
   (let ((in (make-in-memory-input-stream (string-to-octets string))))
     (with-output-to-sequence (out)
       (inflate-zlib-stream in out)))))

(defun get-decompressed ()
  (let* ((pdf (read-pdf-file #P"/home/moritz/Downloads/vs.pdf"))
	 (contents (map 'list 'content (objects pdf)))
	 (streams (remove-if-not (lambda (x) (typep x 'pdf-stream)) contents))
	 (jo (remove-if-not (lambda (x) (equal "/FlateDecode" (cdr (assoc "/Filter" (dict-values x) :test #'equal)))) streams))
	 (strings (mapcar 'content jo))
	 (strings2 (mapcar 'car strings))
	 (decompressed (mapcar 'decompress-string strings2)))
    (car decompressed)))

;; http://wwwimages.adobe.com/content/dam/acom/en/devnet/pdf/PDF32000_2008.pdf#page=259&zoom=auto,-16,826

;; http://wwwimages.adobe.com/content/dam/acom/en/devnet/pdf/PDF32000_2008.pdf#page=135&zoom=120,-178,448

(defun read-until (test &optional (stream *standard-input*))
  (with-output-to-string (out)
    (loop for c = (peek-char nil stream nil nil)
       while (and c (not (funcall test c)))
       do (write-char (read-char stream) out))))

(defun spacep (char)
  (char= #\space char))

(with-input-from-string (in (get-decompressed))
  (let ((e (read-until 'spacep in)))
    (cond ((equal e "q") (print "push graphics"))
	  ((equal e "Q") (print "pop graphics"))
	  (t (print "unknown")))))
