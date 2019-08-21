(in-package :spickipedia.web)

(my-defroute :get "/api/student-courses" (:admin :user) () "application/json"
  (if (user-grade user)
      (progn
	(describe user)
	(let* ((query (dbi.driver:prepare *connection* "SELECT student_course.* FROM student_course, course, course_revision WHERE student_course.course_id = course.id AND course_revision.course_id = course.id AND student_course.student_id = ? AND course_revision.grade_id = ?;"))
               (result (dbi.driver:execute query (object-id user) (object-id (user-grade user)))))
	  (encode-json-to-string
	   (list-to-array
            (mapcar
             #'(lambda (r)
		 `((student-id . ,(getf r :|student_id|))
		   (course-id . ,(getf r :|course_id|))))
	     (dbi.driver:fetch-all result))))))
      "[]"))

(my-defroute :post "/api/student-courses" (:admin :user) (|student-course|) "text/html"
  (let* ((query (dbi.driver:prepare *connection* "INSERT OR IGNORE INTO student_course (student_id, course_id) VALUES (?, ?);"))
         (result (dbi.driver:execute query (object-id user) |student-course|)))
    ""))

(my-defroute :delete "/api/student-courses" (:admin :user) (|student-course|) "text/html"
  (delete-by-values 'student-course :student user :course-id (parse-integer |student-course|))
  "")
