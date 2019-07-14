(var __-p-s_-m-v_-r-e-g)

(i "./template.lisp" "getTemplate")
(i "./show-tab.lisp" "showTab")
(i "./cleanup.lisp" "cleanup")
(i "./math.lisp" "renderMath")
(i "./image-viewer.lisp")
(i "./fetch.lisp" "checkStatus" "json" "handleFetchError")
(i "./utils.lisp" "all" "one" "clearChildren")
(i "./wiki/page.lisp" "handleWikiPage")

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
  (chain settings (add-child (new (node "add-tag"))))
  (chain console (log *STATE*)))

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
            (funcall (getprop window 'states transition)))
          (setf *STATE* new-state-object))))))
