(in-package :spickipedia.web)

(my-defroute :post "/api/teachers" (:admin :user) (|name| |initial|) "text/html"
  (dbi:with-transaction *connection*
    (let* ((teacher (create-dao 'teacher))
           (revision (create-dao 'teacher-revision :author user :teacher teacher :name |name| :initial |initial|)))
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
                       :name |subject|
                       :initial |type|
                       :type |type|
                       :subject |subject|
                       :teacher (find-dao 'teacher :id (parse-integer |teacher|))
                       :is-tutorial (equal "on" |is-tutorial|)
                       :class (user-grade user)
                       :topic |topic|)))
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
    (let* ((schedule (create-dao 'schedule :grade |grade|))
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

(my-defroute :get "/api/schedule/:grade/all" (:admin :user) (grade) "application/json"
  (let* ((schedule (find-dao 'schedule :grade grade)))
    (if schedule
	(let* ((revision
		(select-dao 'schedule-revision (where (:= :schedule schedule))
			    (order-by (:desc :id)) (limit 1)))
	       (result (select-dao 'schedule-data
			 (inner-join :schedule_revision_data :on (:= :schedule_revision_data.schedule_data_id :schedule_data.id))
			 (where (:= :schedule_revision_data.schedule_revision_id (object-id (car revision)))))))
	  (encode-json-plist-to-string
	   `(:revision ,(car revision) :data
		       ,(list-to-array result))))
	"{}")))

(my-defroute :get "/api/schedule/:grade" (:admin :user) (grade) "application/json"
  (let* ((schedule (find-dao 'schedule :grade grade)))
    (if schedule
	(let* ((revision
		(select-dao 'schedule-revision (where (:= :schedule schedule))
			    (order-by (:desc :id)) (limit 1)))
	       (result (select-dao 'schedule-data
			 (inner-join :student_course :on (:= :schedule_data.course_id :student_course.course_id))
			 (inner-join :schedule_revision_data :on (:= :schedule_revision_data.schedule_data_id :schedule_data.id))
			 (where (:and (:= :schedule_revision_data.schedule_revision_id (object-id (car revision))) (:= :student_course.student_id (object-id user)))))))
	  (encode-json-plist-to-string
	   `(:revision ,(car revision) :data
		       ,(list-to-array result))))
	"{}")))

(my-defroute :post "/api/schedule/:grade/add" (:admin :user) (grade |weekday| |hour| |week-modulo| |course| |room|) "application/json"
  (dbi:with-transaction *connection*
    (let* ((schedule (find-dao 'schedule :grade grade))
           (last-revision (first (select-dao 'schedule-revision (where (:= :schedule schedule)) (order-by (:desc :id)) (limit 1))))
           (revision (create-dao 'schedule-revision :author user :schedule schedule))
           (data (create-dao 'schedule-data
			     :schedule-revision revision
			     :weekday |weekday|
			     :hour |hour|
			     :week-modulo |week-modulo|
			     :course (find-dao 'course :id |course|)
			     :room |room|))
	   (revision-data (create-dao 'schedule-revision-data
				      :schedule-revision revision
				      :schedule-data data))
	   (result (retrieve-by-sql (insert-into 'schedule_revision_data (:schedule_revision_id :schedule_data_id)
						 (select ((:raw (object-id revision)) :schedule_data_id)
						   (from :schedule_revision_data)
						   (where (:= :schedule_revision_id (object-id last-revision))))))))
      (format nil "~a" (object-id data)))))

(my-defroute :post "/api/schedule/:grade/delete" (:admin :user) (|id|) "application/json"
  (dbi:with-transaction *connection*
    (let* ((schedule (user-grade user))
           (last-revision (car (select-dao 'schedule-revision (where (:= :schedule schedule)) (order-by (:desc :id)) (limit 1))))
           (revision (create-dao 'schedule-revision :author user :schedule schedule)))
      (mito:retrieve-by-sql (insert-into 'schedule_revision_data (:schedule_revision_id :schedule_data_id)
					 (select ((:raw (object-id revision)) :schedule_data_id)
					   (from :schedule_revision_data)
					   (where (:and (:= :schedule_revision_id (object-id last-revision)) (:not (:= (parse-integer |id|) :schedule_data_id))))))))))

(defmacro test ()
  `(progn
     (setf (html-mode) :html5)
     (with-html-output-to-string (jo nil :prologue t :indent t) ,(get-html))))
