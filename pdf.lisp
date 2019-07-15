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

;; read-object

(defun read-until (test &optional (stream *standard-input*))
  (unless (peek-char nil stream nil nil)
    (return-from read-until nil))
  (with-output-to-string (out)
    (loop for c = (peek-char nil stream nil nil)
       while (and c (not (funcall test c)))
       do (write-char (read-char stream) out))))

(defun whitespace-char-p (x)
  (or (char= #\space x)
      (not (graphic-char-p x))))

(defun boundary-char-p (x)
  (or (whitespace-char-p x)
      (char= #\[ x)))

(defun parse ()
  (with-input-from-string (in (get-decompressed))
    (let ((stack '()))
      (loop
	 (if (eq (peek-char nil in nil nil) #\[)
	     (let ((*pdf-input-stream* in))
	       (push (read-object in) stack)
	       (format t "read-object ~a~%" stack))	 
	     (let ((e (read-until 'boundary-char-p in)))
	       (cond ((equal e "q") (format t "push graphics~%"))
		     ((equal e "Q") (format t "pop graphics~%"))
		     ((equal e "BT") (format t "begin text~%"))
		     ((equal e "ET") (format t "end text~%"))
		     ((equal e "Tf") (format t "font and size ~a~%" stack) (setf stack '())) ;; TODO the literal name belongs to it
		     ((equal e "Tm") (format t "text matrix ~a~%" stack) (setf stack '()))
		     ((equal e "cm") (format t "CTM ~a~%" stack) (setf stack '()))
		     ((equal e "RG") (format t "stroking color ~a~%" stack) (setf stack '()))
		     ((equal e "rg") (format t "non-stroking color ~a~%" stack) (setf stack '()))
		     ((equal e "TJ") (format t "print text with positioning ~a~%" stack) (setf stack '()))
		     ((equal e "TL") (format t "set text leading ~a~%" stack) (setf stack '()))
		     ((equal e "T*") (format t "new line ~%"))
		     ((equal e "Td") (format t "new line with offset ~a~%" stack) (setf stack '()))
		     ((equal e "w") (format t "line width ~a~%" stack) (setf stack '()))
		     ((equal e "J") (format t "line cap style ~a~%" stack) (setf stack '()))
		     ((equal e "j") (format t "line join style ~a~%" stack) (setf stack '()))
		     ((equal e "m") (format t "move to ~a~%" stack) (setf stack '()))
		     ((equal e "l") (format t "straight line ~a~%" stack) (setf stack '()))
		     ((equal e "re") (format t "rectangle ~a~%" stack) (setf stack '()))
		     ((equal e "gs") (format t "graphics state operator~%"))
		     ((equal e "S") (format t "stroke the path ~%"))
		     ((eq e nil) (return))
		     ((eq (elt e 0) #\/) (format t "literal name ~a~%" e))
		     (t (push e stack) (format t "push-stack ~a~%" e)))
	       (when (whitespace-char-p (peek-char nil in nil nil))
		 (unless (read-char in nil)
		   (return)))))))))
