(ql:quickload :dbi)
(ql:quickload "str")
(use-package :str)

(defvar *connection* (dbi:connect :postgres :database-name "spickipedia" :username "postgres"))

(defparameter *query* (dbi:prepare *connection* "SELECT to_tsquery('german', ?), to_tsquery('german', ?) @@ to_tsvector('german', 'Dies ist ein sehr toller Text über Elefanten. Sie können laufen, rennen und trompeten');"))

(defun test (query)
  (let ((query (tsquery-convert query)))
    (print query)
    (dbi:fetch-all (dbi:execute *query* query query))))

(defun handle-quoted (query)
  (concat "(" (join " <-> " (split " " query)) ")"))

(defun handle-unquoted (query)
  (concat "(" (join " & " (split " " query)) ")"))

(defun tsquery-convert (query)
  ;; if query contains an odd amount of qoutes add one at the end
  (if (oddp (count #\" query))
      (setf query (concatenate 'string query "\"")))

  ;; split at quotes
  (setf query (split #\" query))

  (print query)

  ;; handle quoted and unquoted parts separately
  (setf query
	(loop for e in query
	   for x from 1
	     
	   if (oddp x)
	   do
	     (setf e (handle-unquoted e))
	   else do
	     (setf e (handle-quoted e))
	     collect e))

  ;; handle logical not operator



  ;; join substrings
  (setf query (join " & " query))
  
  query)
