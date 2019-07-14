(var __-p-s_-m-v_-r-e-g)

(i "./wiki/page.lisp" "handleWikiPage")
(i "./search.lisp" "handleSearchQuery" "handleSearch")
(i "./quiz.lisp" "handleQuizIdResults" "handleQuizIdPlayIndex"
 "handleQuizIdPlay" "handleQuizIdEdit" "handleQuizCreate")
(i "./logout.lisp" "handleLogout")
(i "./login.lisp" "handleLogin")
(i "./root.lisp" "handle")
(i "./history.lisp" "handleWikiPageHistoryIdChanges" "handleWikiPageHistoryId"
 "handleWikiNameHistory")
(i "./wiki/page/edit.lisp" "handleWikiPageEdit")
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
(i "./utils.lisp" "all" "one" "clearChildren")

(export
 (defun update-state ()
   (setf (chain window last-url) (chain window location pathname))
   (if (undefined (chain window local-storage name))
       (setf (inner-text (one "#logout")) "Abmelden")
       (setf (inner-text (one "#logout")) (concatenate 'string (chain window local-storage name) " abmelden")))
   (if (and (not (= (chain window location pathname) "/login"))
            (undefined (chain window local-storage name)))
       (progn
        (chain window history
         (push-state
          (create last-url (chain window location href) last-state
           (chain window history state))
          nil "/login"))
        (update-state)))
   (setf (style (one ".login-hide")) "")
   (loop for route in (chain window routes)
         do (when (route (chain window location pathname))
              ;;(chain console (log (chain route name)))
              (return-from update-state)))
   (setf (inner-text (one "#errorMessage")) "Unbekannter Pfad!")
   (show-tab "#error")))
