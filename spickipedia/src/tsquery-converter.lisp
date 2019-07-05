
(in-package :spickipedia.tsquery-converter) 
(defun handle-quoted (query) (concat "(" (join " <-> " (split " " query)) ")")) 
(defun handle-unquoted (query) (concat "(" (join " & " (split " " query)) ")")) 
(defun tsquery-convert-part (query add-wildcard)
  (setf query (split #\" query))
  (if add-wildcard
      (setf (car (last query)) (concat (car (last query)) ":*")))
  (setf query
          (loop for e in query
                for x from 1
                if (oddp x)
                do (setf e (handle-unquoted e)) else
                do (setf e (handle-quoted e))
                collect e))
  (setf query (remove "()" query :test #'string=))
  (setf query (join " & " query))
  query) 
(defun tsquery-convert (query)
  (if (oddp (count #\" query))
      (setf query (concatenate 'string query "\"")))
  (setf query (split "OR" query))
  (setf query
          (loop for e in query
                collect (tsquery-convert-part (trim e) (= 1 (length query)))))
  (setf query (join " | " query))
  query) 