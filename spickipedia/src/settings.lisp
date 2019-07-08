
(in-package :spickipedia.web)
(my-defroute :post "/api/settings" (:admin :user) (|grade|) "text/html"
 (setf (user-grade user)
       (find-dao 'schedule :id (parse-integer (first |grade|))))
 (save-dao user) "")
(my-defroute :get "/api/settings" (:admin :user) nil "text/html"
 (encode-json-to-string (user-grade user))) 
