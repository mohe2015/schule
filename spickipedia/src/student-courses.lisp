(in-package :spickipedia.web)

(my-defroute :GET "/api/student-courses" (:admin :user) () "application/json"
  (let* ((student-courses (select-dao 'student-course (where (:= :student user)))))
    (encode-json-to-string (list-to-array student-courses))))

(my-defroute :POST "/api/student-courses" (:admin :user) (|student-course|) "text/html"
  (let* ((student-course (create-dao 'student-course :student user :course (find-dao 'course :id (first |student-course|)))))
    (format nil "~a" (object-id student-course))))
