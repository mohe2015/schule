(in-package :schule.config)

(setf (config-env-var) "APP_ENV")

(defparameter *application-root*
  (asdf/system:system-source-directory :schule))

(defparameter *static-directory*
  (merge-pathnames #P"static/" *application-root*))

(defparameter *template-directory*
  (merge-pathnames #P"templates/" *application-root*))

(defparameter *javascript-directory*
  (merge-pathnames #P"js/" *application-root*))

(defvar *database-path*
  (asdf/system:system-relative-pathname :schule #P"spickipedia.db"))

(defconfig :common
    `(:databases ((:maindb :sqlite3 :database-name ,*database-path*))))

(defconfig |development| 'nil)

(defconfig |production| 'nil)

(defconfig |test| 'nil)

(defun config (&optional key) (envy:config "SPICKIPEDIA.CONFIG" key))

(defun appenv () (uiop/os:getenv (config-env-var "SPICKIPEDIA.CONFIG")))

(defun developmentp () (string= (appenv) "development"))

(defun productionp () (string= (appenv) "production"))
