(in-package :spickipedia.web)

(my-defroute :GET "/api/student-courses" (:admin :user) () "application/json"
  (let* ((student-courses (select-dao 'student-course (where (:= :student user)))))
    (encode-json-to-string (list-to-array student-courses))))

(my-defroute :POST "/api/student-courses" (:admin :user) (|student-course|) "text/html"
  (let* ((query (dbi:prepare *connection* "INSERT OR IGNORE INTO student_course (student_id, course_id) VALUES (?, ?);"))
         (result (dbi:execute query (object-id user) (first |student-course|))))
    ;;(format nil "~a" (mito.db:last-insert-id *connection* nil "")))) ;; doesn't work but doesn't matter
    ""))

(my-defroute :DELETE "/api/student-courses" (:admin :user) (|student-course|) "text/html"
  (delete-by-values 'student-course :student user :course-id (parse-integer (first |student-course|)))
  "")
