
(in-package :spickipedia.web) 
(my-defroute :get "/api/student-courses" (:admin :user) nil "application/json"
 (let* ((student-courses
         (select-dao 'student-course (where (:= :student user)))))
   (encode-json-to-string (list-to-array student-courses)))) 
(my-defroute :post "/api/student-courses" (:admin :user) (|student-course|)
 "text/html"
 (let* ((query
         (dbi.driver:prepare *connection*
                             "INSERT OR IGNORE INTO student_course (student_id, course_id) VALUES (?, ?);"))
        (result
         (dbi.driver:execute query (object-id user) (first |student-course|))))
   "")) 
(my-defroute :delete "/api/student-courses" (:admin :user) (|student-course|)
 "text/html"
 (delete-by-values 'student-course :student user :course-id
  (parse-integer (first |student-course|)))
 "") 