(var __-p-s_-m-v_-r-e-g)

(i "./contact/index.lisp" "handleContact")
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
(i "./categories.lisp" "handleTagsRest")
(i "./courses/index.lisp" "handleCourses")
(i "./schedule/id.lisp" "handleScheduleGradeEdit" "handleScheduleGrade")
(i "./schedules/new.lisp" "handleSchedulesNew")
(i "./schedules/index.lisp" "handleSchedules")
(i "./student-courses/index.lisp" "handleStudentCourses")
(i "./settings/index.lisp" "handleSettings")
(i "./math.lisp" "renderMath")
(i "./image-viewer.lisp")
(i "./substitution-schedule/index.lisp" "handleSubstitutionSchedule")

(i "./state-machine.lisp" "updateState" "replaceState" "pushState")
(i "./editor-lib.lisp" "isLocalUrl")
(i "./utils.lisp" "all" "one" "clearChildren")

(setf (chain window onerror)
      (lambda (message source lineno colno error)
        (alert
         (concatenate 'string
                      "Es ist ein Fehler aufgetreten! Melde ihn bitte dem Entwickler! "
                      message " source: " source " lineno: " lineno
                      " colno: " colno " error: " error))))

(on ("click" (one "body") event :dynamic-selector "a")
    (if (chain event target is-Content-Editable)
       (progn
	 (chain event (prevent-default))
	 (chain event (stop-propagation)))
       (let ((url (href (chain event target))))
	 (if (and url (is-local-url url))
             (progn
	       (chain event (prevent-default))
	       (push-state url)
	       f)
             t))))

(setf (chain window onpopstate)
      (lambda (event)
        (if (chain window last-url)
            (let ((pathname (chain window last-url (split "/"))))
              (if (and (= (chain pathname length) 4)
                       (= (chain pathname 1) "wiki")
                       (or (= (chain pathname 3) "create")
                           (= (chain pathname 3) "edit")))
                  (progn
                    (if (confirm
                         "Möchtest du die Änderung wirklich verwerfen?")
			(update-state))
                    (return)))))
        (update-state)))

(setf (chain window onbeforeunload)
      (lambda ()
        (let ((pathname (chain window location pathname (split "/"))))
          (if (and (= (chain pathname length) 4)
                   (= (chain pathname 1) "wiki")
                   (or (= (chain pathname 3) "create")
                       (= (chain pathname 3) "edit")))
              t))))

(setf (chain window onload) (lambda () (update-state)))
