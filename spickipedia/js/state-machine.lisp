(var __-p-s_-m-v_-r-e-g)

(i "./template.lisp" "getTemplate")
(i "./show-tab.lisp" "showTab")
(i "./cleanup.lisp" "cleanup")
(i "./math.lisp" "renderMath")
(i "./image-viewer.lisp")
(i "./fetch.lisp" "checkStatus" "json" "handleFetchError")
(i "./utils.lisp" "all" "one" "clearChildren")
(i "./wiki.lisp" "handleWikiName" "handleWikiNameEnter")

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

(let ((edit (new (node "edit")))
      (settings (new (node "settings")))
      (handle-wiki-name (new (node "handleWikiName"))))
  (chain *STATE* (add-child handle-wiki-name))
  (chain *STATE* (add-child (new (node "history"))))
  (chain *STATE* (add-child (new (node "histories"))))
  (chain handle-wiki-name (add-child edit))
  (chain edit (add-child (new (node "publish"))))
  (chain edit (add-child settings))
  (chain settings (add-child (new (node "add-tag"))))
  (chain console (log *STATE*)))

(export
  (defun current-state-to-new-state (old-state new-state)
    (if (= (chain old-state value) new-state)
        (return (values (array) old-state)))
    (loop for state in (chain old-state (get-children)) do
      (multiple-value-bind (transitions new-state-object) (current-state-to-new-state state new-state)
        (if transitions
            (return (values (chain (array (concatenate 'string (chain state value) "Enter")) (concat transitions)) new-state-object)))))))

(export
  (defun current-state-to-new-state2 (old-state new-state)
    (multiple-value-bind (transitions new-state-object) (current-state-to-new-state old-state new-state)
      (if transitions
        (return (values transitions new-state-object))))
    (if (chain old-state (get-parent-node))
      (multiple-value-bind (transitions new-state-object) (current-state-to-new-state (chain old-state (get-parent-node)) new-state)
        (return (values (chain (array (concatenate 'string (chain old-state value) "Exit")) (concat transitions)) new-state-object))))))

(export
  (async
    (defun enter-state (state)
      (let ((module (await (funcall import (chain import meta url)))))
        (multiple-value-bind (transitions new-state-object) (current-state-to-new-state2 *STATE* state)
          (loop for transition in transitions do
            (funcall (getprop window 'states transition)))
          (setf *STATE* new-state-object))))))
          ;; state handleWikiName

(export
  (defun enter-loading ()
    (show-tab "#loading")))

(export
  (defun exit-loading ()
    (hide-tab "#loading")))

(export
  (defun exit-wiki-page ()))
    ;; abort fetch

(export
  (defun enter-settings ()))
    ;; fetch settings
    ;; show settings

(export
  (defun exit-settings ()))
    ;; abort fetch

(export
  (defun enter-settings-add-grade ()))
    ;; show-dialog

(export
  (defun exit-settings-add-grade ()))
    ;; hide dialog

(export
  (defun enter-login ()))
    ;; show login

(export
  (defun enter-logout ()))
    ;; logging out
