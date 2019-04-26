(ql:quickload :plump)
(ql:quickload :cl-markup)
(ql:quickload :alexandria)
(use-package :plump)
(use-package :cl-markup)

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
     (list (string->name (tag-name node)))
     (loop for key being the hash-keys of (attributes node)
        for val being the hash-values of (attributes node)
        nconc (list (string->name key) val))
     (loop for child across (children node)
      collect (to-sexp child)))))


(defparameter *FILE* (alexandria:read-file-into-string "templates/index.html"))
(defparameter *DOM* (parse *FILE*))
(defparameter *SEXP* (to-sexp *DOM*))
(defparameter *SEXP* (nth 2 *SEXP*))

(let ((*markup-language* :html5))
  (markup* *SEXP*))

(html5
  (:html
   (:head
    (:title "hi"))))
