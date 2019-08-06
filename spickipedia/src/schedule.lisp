(in-package :spickipedia.web)

(my-defroute :post "/api/teachers" (:admin :user) (|name| |initial|) "text/html"
  (dbi:with-transaction *connection*
    (let* ((teacher (create-dao 'teacher))
           (revision (create-dao 'teacher-revision :author user :teacher teacher :name (first |name|) :initial (first |initial|))))
      (format nil "~a" (object-id teacher)))))

(my-defroute :get "/api/teachers" (:admin :user) () "application/json"
  (let* ((teachers (select-dao 'teacher))
         (teacher-revisions (mapcar #'(lambda (teacher) (first (select-dao 'teacher-revision (where (:= :teacher teacher)) (order-by (:desc :id)) (limit 1)))) teachers)))
    (encode-json-to-string (list-to-array teacher-revisions))))

(my-defroute :post "/api/courses" (:admin :user) (|subject| |type| |teacher| |is-tutorial| |topic|) "text/html"
  (dbi:with-transaction *connection*
    (let* ((course (create-dao 'course))
           (revision (create-dao 'course-revision
                       :author user
                       :course course
                       :name (first |subject|)
                       :initial (first |type|)
                       :type (first |type|)
                       :subject (first |subject|)
                       :teacher (find-dao 'teacher :id (parse-integer (first |teacher|)))
                       :is-tutorial (equal "on" (first |is-tutorial|))
                       :class (user-grade user)
                       :topic (first |topic|))))
      (format nil "~a" (object-id course)))))

(my-defroute :get "/api/courses" (:admin :user) () "application/json"
  (if (user-grade user)
      (let* ((courses (select-dao 'course))
             (course-revisions
              (mapcar
               #'(lambda (course)
                   (first
                    (select-dao 'course-revision
                     (where
                      (:and (:= :course course) (:= :grade (user-grade user))))
                     (order-by (:desc :id)) (limit 1))))
               courses)))
        (encode-json-to-string (list-to-array (remove nil course-revisions))))
      (encode-json-to-string #())))

(my-defroute :post "/api/schedules" (:admin :user) (|grade|) "text/html"
  (dbi:with-transaction *connection*
    (let* ((schedule (create-dao 'schedule :grade (first |grade|)))
           (revision (create-dao 'schedule-revision :author user :schedule schedule)))
      (format nil "~a" (object-id schedule)))))

(my-defroute :get "/api/schedules" (:admin :user) () "application/json"
  (let* ((schedules (select-dao 'schedule)))
    (encode-json-to-string (list-to-array schedules))))

(defmethod encode-json ((o teacher-revision) &optional (stream *json-output*))
  "Write the JSON representation (Object) of the postmodern DAO CLOS object
O to STREAM (or to *JSON-OUTPUT*)."
  (with-object (stream) (encode-object-member 'id (object-id o) stream)
   (encode-object-member 'name (teacher-revision-name o) stream)))

(defmethod encode-json ((o teacher) &optional (stream *json-output*))
  "Write the JSON representation (Object) of the postmodern DAO CLOS object
O to STREAM (or to *JSON-OUTPUT*)."
  (encode-json
   (first
    (select-dao 'teacher-revision (where (:= :teacher o))
     (order-by (:desc :id)) (limit 1)))
   stream))

(defmethod encode-json ((o course-revision) &optional (stream *json-output*))
  "Write the JSON representation (Object) of the postmodern DAO CLOS object
O to STREAM (or to *JSON-OUTPUT*)."
  (with-object (stream)
   (encode-object-member 'course-id (object-id (course-revision-course o))
    stream)
   (encode-object-member 'teacher (course-revision-teacher o) stream)
   (encode-object-member 'type (course-revision-type o) stream)
   (encode-object-member 'subject (course-revision-subject o) stream)
   (encode-object-member 'is-tutorial (course-revision-is-tutorial o) stream)
   (encode-object-member 'grade (course-revision-grade o) stream)
   (encode-object-member 'topic (course-revision-topic o) stream)))

(defmethod encode-json ((o course) &optional (stream *json-output*))
  "Write the JSON representation (Object) of the postmodern DAO CLOS object
O to STREAM (or to *JSON-OUTPUT*)."
  (encode-json
   (first
    (select-dao 'course-revision (where (:= :course o)) (order-by (:desc :id))
     (limit 1)))
   stream))

(defmethod encode-json ((o schedule-data) &optional (stream *json-output*))
  "Write the JSON representation (Object) of the postmodern DAO CLOS object
O to STREAM (or to *JSON-OUTPUT*)."
  (with-object (stream) (encode-object-member 'id (object-id o) stream)
   (encode-object-member 'weekday (schedule-data-weekday o) stream)
   (encode-object-member 'hour (schedule-data-hour o) stream)
   (encode-object-member 'week-modulo (schedule-data-week-modulo o) stream)
   (encode-object-member 'course (schedule-data-course o) stream)
   (encode-object-member 'room (schedule-data-room o) stream)))

(defmethod encode-json ((o student-course) &optional (stream *json-output*))
  "Write the JSON representation (Object) of the postmodern DAO CLOS object
O to STREAM (or to *JSON-OUTPUT*)."
  (with-object (stream)
   (encode-object-member 'course (student-course-course o) stream)
   (encode-object-member 'student (student-course-student o) stream)))

(my-defroute :get "/api/schedule/:grade" (:admin :user) (grade) "application/json"
  (let* ((schedule (find-dao 'schedule :grade grade)))
    (if schedule
	(let* ((revision
		(select-dao 'schedule-revision (where (:= :schedule schedule))
			    (order-by (:desc :id)) (limit 1))))
	  (encode-json-plist-to-string
	   `(:revision ,(car revision) :data
		       ,(list-to-array
			 (retrieve-dao 'schedule-data :schedule-revision (car revision))))))
	"{}")))

(my-defroute :post "/api/schedule/:grade/add" (:admin :user) (grade |weekday| |hour| |week-modulo| |course| |room|) "application/json"
  (dbi:with-transaction *connection*
    (let* ((schedule (find-dao 'schedule :grade grade))
           (last-revision (select-dao 'schedule-revision (where (:= :schedule schedule)) (order-by (:desc :id)) (limit 1)))
           (revision (create-dao 'schedule-revision :author user :schedule schedule))
           (data
            (create-dao 'schedule-data
              :schedule-revision revision
              :weekday (first |weekday|)
              :hour (first |hour|)
              :week-modulo (first |week-modulo|)
              :course (find-dao 'course :id (first |course|))
              :room (first |room|))))
      (loop for old-data in (retrieve-dao 'schedule-data :schedule-revision (car last-revision)) do
        (create-dao 'schedule-data
          :schedule-revision revision
          :weekday (schedule-data-weekday old-data)
          :hour (schedule-data-hour old-data)
          :week-modulo (schedule-data-week-modulo old-data)
          :course (schedule-data-course old-data)
          :room (schedule-data-room old-data)))
      (format nil "~a" (object-id data)))))

(my-defroute :post "/api/schedule/:grade/delete" (:admin :user) (|id|) "application/json"
  (dbi:with-transaction *connection*
    (let* ((schedule (user-grade user))
           (last-revision
            (select-dao 'schedule-revision (where (:= :schedule schedule))
             (order-by (:desc :id)) (limit 1)))
           (revision
            (create-dao 'schedule-revision :author user :schedule schedule)))
      (loop for old-data in (retrieve-dao 'schedule-data :schedule-revision
                             (car last-revision))
            do (if (not (= (object-id old-data) (parse-integer (first |id|))))
                   (create-dao 'schedule-data :schedule-revision revision
                    :weekday (schedule-data-weekday old-data) :hour
                    (schedule-data-hour old-data) :week-modulo
                    (schedule-data-week-modulo old-data) :course
                    (schedule-data-course old-data) :room
                    (schedule-data-room old-data))))
      "")))

(defmacro test ()
  `(progn
     (setf (html-mode) :html5)
     (with-html-output-to-string (jo nil :prologue t :indent t) ,(get-html))))
