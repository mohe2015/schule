(@ window onerror)

(setf (chain window onerror) (lambda () nil))
