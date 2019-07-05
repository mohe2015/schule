
(i "./test.lisp") 
(export
 (defun get-url-parameter (param)
   (let* ((page-url (chain window location search (substring 1)))
          (url-variables (chain page-url (split "&"))))
     (loop for parameter-name in url-variables
           do (setf parameter-name (chain parameter-name (split "="))) (if (=
                                                                            (chain
                                                                             parameter-name
                                                                             0)
                                                                            param)
                                                                           (return
                                                                            (chain
                                                                             parameter-name
                                                                             1))))))) 