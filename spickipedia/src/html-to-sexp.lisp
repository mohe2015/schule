(ql:quickload :plump)
(ql:quickload :cl-markup)
(use-package :plump)
(use-package :cl-markup)

(defparameter *FILE* (alexandria:read-file-into-string "templates/index.html"))
(defparameter *DOM* (parse *FILE*))

(html5
  (:html
   (:head
    (:title "hi"))))

(defun string->name (string)
  (if (loop for char across string
         always (or (not (both-case-p char))
                    (lower-case-p char)))
      (intern (string-upcase string) "KEYWORD")
      string))

(defgeneric to-sexp (node)
  (:documentation "Serialize the given node into a SEXP form.")
  (:method ((node comment))
    (list :!COMMENT (text node)))
  (:method ((node doctype))
    (list :!DOCTYPE (doctype node)))
  (:method ((node root))
    (cons :!ROOT
          (loop for child across (children node)
             collect (to-sexp child))))
  (:method ((node text-node))
    (text node))
  (:method ((node element))
    (append
     (list
      (if (< 0 (hash-table-count (attributes node)))
          (cons (string->name (tag-name node))
                (loop for key being the hash-keys of (attributes node)
                   for val being the hash-values of (attributes node)
                   nconc (list (string->name key) val)))
          (string->name (tag-name node))))
     (when (< 0 (length (children node)))
       (loop for child across (children node)
	  collect (to-sexp child))))))
