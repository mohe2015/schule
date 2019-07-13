(var __-p-s_-m-v_-r-e-g)

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
(i "./utils.lisp" "all" "one" "clearChildren")

#|

graph like

                                    loading
    page history histories      edit
                          publish settings
                                  add-tag

|#

;; this format should be easily readable - the first subelement always belongs to the parent list
(defparameter *TEST* '(loading (page) (history) (histories) (edit (publish) (settings (add-tag)))))

;; everything not in subarray belongs to current level; the next array is child of previous element
(defparameter *TEST2* '(loading (page history histories edit (publish settings (add-tag)))))

(defparameter
  *TEST3*
  (create
    :element "loading"
    :children
      (array
        (create :element "test" :test "jo"))))      
#|
{
 element: "loading",
 children:
  [
   {
    element: "page"
    children:
     [
      {
       element: "test"}]}]}
...
|#

(defparameter *STATE* 'LOADING)

(defun enter-loading ()
  (show-tab "#loading"))

(defun exit-loading ()
  (hide-tab "#loading"))

(defun enter-wiki-page (page))
  ;;(fetch wiki page))
  ;; show wiki page

(defun exit-wiki-page ())
  ;; abort fetch

(defun enter-settings ())
  ;; fetch settings
  ;; show settings

(defun exit-settings ())
  ;; abort fetch

(defun enter-settings-add-grade ())
  ;; show-dialog

(defun exit-settings-add-grade ())
  ;; hide dialog

(defun enter-login ())
  ;; show login

(defun enter-logout ())
  ;; logging out

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
         do (if (route (chain window location pathname))
                (return-from update-state)))
   (setf (inner-text (one "#errorMessage")) "Unbekannter Pfad!")
   (show-tab "#error")))
