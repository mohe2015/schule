(var __-p-s_-m-v_-r-e-g)

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

(defparameter *STATE* (new (node "loading")))

(let ((edit (new (node "edit")))
      (settings (new (node "settings"))))
  (chain *STATE* (add-child (new (node "handleWikiName"))))
  (chain *STATE* (add-child (new (node "history"))))
  (chain *STATE* (add-child (new (node "histories"))))
  (chain *STATE* (add-child edit))
  (chain edit (add-child (new (node "publish"))))
  (chain edit (add-child settings))
  (chain settings (add-child (new (node "add-tag"))))
  (chain console (log *STATE*)))

(export
  (defun enter-state (state)
    (chain
      (funcall import (chain import meta url))
      (then
        (lambda (module)
          (chain console (log module)))))))

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
