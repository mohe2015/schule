(in-package :spickipedia.config)

(setf (config-env-var) "APP_ENV")

(defparameter *application-root*   (asdf:system-source-directory :spickipedia))
(defparameter *static-directory*   (merge-pathnames #P"static/" *application-root*))
(defparameter *template-directory* (merge-pathnames #P"templates/" *application-root*))
(defvar *database-path* (asdf:system-relative-pathname :spickipedia #P"spickipedia.db"))

(defconfig :common
  `(:databases ((:maindb :sqlite3 :database-name ,*database-path*))))

(defconfig |development|
  '())

(defconfig |production|
  '())

(defconfig |test|
  '())

(defun config (&optional key)
  (envy:config #.(package-name *package*) key))

(defun appenv ()
  (uiop:getenv (config-env-var #.(package-name *package*))))

(defun developmentp ()
  (string= (appenv) "development"))

(defun productionp ()
  (string= (appenv) "production"))
