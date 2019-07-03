(in-package :spickipedia.web)

(my-defroute :POST "/api/settings" (:admin :user) (|grade|) "text/html"
  (setf (user-grade user) (find-dao 'schedule :id (parse-integer (first |grade|))))
  (mito:save-dao user)
  "")

(my-defroute :GET "/api/settings" (:admin :user) () "text/html"
  (encode-json-to-string (user-grade user)))
