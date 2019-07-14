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
(i "./template.lisp" "getTemplate")
(i "./cleanup.lisp" "cleanup")
(i "./math.lisp" "renderMath")
(i "./image-viewer.lisp")
(i "./fetch.lisp" "checkStatus" "json" "handleFetchError")

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

(export
 (defun push-state (url data)
   (debug "PUSH-STATE" url)
   (chain window history (push-state data nil url))
   (update-state)))

(export
 (defun replace-state (url data)
   (debug "REPLACE-STATE" url)
   (chain window history (replace-state data nil url))
   (update-state)))

(defun node (value)
  (setf (chain this value) value)
  (setf (chain this children) (array))
  (setf (chain this parent) nil)

  (setf (chain this set-parent-node)
        (lambda (node)
          (setf (chain this parent) node)))

  (setf (chain this get-parent-node)
        (lambda ()
          (chain this parent)))

  (setf (chain this add-child)
        (lambda (node)
          (chain node (set-parent-node this))
          (setf (@ this 'children (chain this children length)) node)))

  (setf (chain this get-children)
        (lambda ()
          (chain this children)))

  (setf (chain this remove-children)
        (lambda ()
          (setf (chain this children) (array))))
  this)

(export
  (defparameter *STATE* (new (node "loading"))))

(let ((handle-wiki-page-edit (new (node "handleWikiPageEdit")))
      (settings (new (node "settings")))
      (handle-wiki-page (new (node "handleWikiPage"))))
  (chain *STATE* (add-child handle-wiki-page))
  (chain *STATE* (add-child (new (node "history"))))
  (chain *STATE* (add-child (new (node "histories"))))
  (chain handle-wiki-page (add-child handle-wiki-page-edit))
  (chain handle-wiki-page-edit (add-child (new (node "publish"))))
  (chain handle-wiki-page-edit (add-child settings))
  (chain settings (add-child (new (node "add-tag")))))

(defun current-state-to-new-state-internal (old-state new-state)
  (if (= (chain old-state value) new-state)
      (return (values (array) old-state)))
  (loop for state in (chain old-state (get-children)) do
    (multiple-value-bind (transitions new-state-object) (current-state-to-new-state-internal state new-state)
      (if transitions
          (return (values (chain (array (concatenate 'string (chain state value) "Enter")) (concat transitions)) new-state-object))))))

(export
  (defun current-state-to-new-state (old-state new-state)
    (multiple-value-bind (transitions new-state-object) (current-state-to-new-state-internal old-state new-state)
      (if transitions
        (return (values transitions new-state-object))))
    (if (chain old-state (get-parent-node))
      (multiple-value-bind (transitions new-state-object) (current-state-to-new-state-internal (chain old-state (get-parent-node)) new-state)
        (return (values (chain (array (concatenate 'string (chain old-state value) "Exit")) (concat transitions)) new-state-object))))))

(export
  (async
    (defun enter-state (state)
      (let ((module (await (funcall import (chain import meta url)))))
        (multiple-value-bind (transitions new-state-object) (current-state-to-new-state *STATE* state)
          (loop for transition in transitions do
            (debug "TRANSITION " transition)
            (funcall (getprop window 'states transition)))
          (debug "STATE " new-state-object)
          (setf *STATE* new-state-object))))))
