
(var __-p-s_-m-v_-r-e-g) 
(i "./test.lisp") 
(i "./wiki.lisp" "handleWikiName") 
(i "./search.lisp" "handleSearchQuery" "handleSearch") 
(i "./quiz.lisp" "handleQuizIdResults" "handleQuizIdPlayIndex"
 "handleQuizIdPlay" "handleQuizIdEdit" "handleQuizCreate") 
(i "./logout.lisp" "handleLogout") 
(i "./login.lisp" "handleLogin") 
(i "./root.lisp" "handle") 
(i "./history.lisp" "handleWikiPageHistoryIdChanges" "handleWikiPageHistoryId"
 "handleWikiNameHistory") 
(i "./edit.lisp" "handleWikiNameEdit") 
(i "./create.lisp" "handleWikiNameCreate") 
(i "./articles.lisp" "handleArticles") 
(i "./show-tab.lisp" "showTab") 
(i "./categories.lisp" "handleTagsRest") 
(i "./teachers.lisp" "handleTeachersNew") 
(i "./courses/new.lisp" "handleCoursesNew") 
(i "./courses/index.lisp" "handleCourses") 
(i "./schedule/id.lisp" "handleScheduleGrade") 
(i "./schedules/new.lisp" "handleSchedulesNew") 
(i "./schedules/index.lisp" "handleSchedules") 
(i "./student-courses/index.lisp" "handleStudentCourses") 
(i "./settings/index.lisp" "handleSettings") 
(export
 (defun update-state ()
   (setf (chain window last-url) (chain window location pathname))
   (if (undefined (chain window local-storage name))
       (chain (one "#logout") (text "Abmelden"))
       (chain (one "#logout")
        (text
         (concatenate 'string (chain window local-storage name) " abmelden"))))
   (if (and (not (= (chain window location pathname) "/login"))
            (undefined (chain window local-storage name)))
       (progn
        (chain window history
         (push-state
          (create last-url (chain window location href) last-state
           (chain window history state))
          nil "/login"))
        (update-state)))
   (chain (one ".login-hide") (attr "style" ""))
   (loop for route in (chain window routes)
         do (if (route (chain window location pathname))
                (return-from update-state)))
   (chain (one "#errorMessage") (text "Unbekannter Pfad!"))
   (show-tab "#error"))) 