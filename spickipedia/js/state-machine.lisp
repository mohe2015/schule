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
  (defun current-state-to-new-state (old-state new-state)
    (if (= (chain old-state value) new-state)
        (return (array)))
    (loop for state in (chain old-state (get-children)) do
      (if (current-state-to-new-state state new-state)
          (return (chain (array (concatenate 'string (chain state value) "Enter")) (concat (current-state-to-new-state state new-state))))))))

(export
  (async
    (defun enter-state (state)
      (let ((module (await (funcall import (chain import meta url)))))
        (loop for transition in (current-state-to-new-state *STATE* state) do
          (funcall (getprop window 'states transition)))))))
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
