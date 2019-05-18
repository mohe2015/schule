(var __-p-s_-m-v_-r-e-g)

(i "../test.lisp")
(i "../show-tab.lisp" "showTab")
(i "../cleanup.lisp" "cleanup")
(i "../handle-error.lisp" "handleError")
(i "../fetch.lisp" "checkStatus" "json" "html" "handleFetchError")
(i "../utils.lisp" "showModal" "internalOnclicks" "all" "one" "hideModal")
(i "../template.lisp" "getTemplate")

(defroute "/schedule/:id"
  (show-tab "#schedule")

  (chain
    (fetch (concatenate 'string "/api/schedule/" id))
    (then check-status)
    (then json)
    (then
      (lambda (data)
        nil))
    (catch handle-fetch-error)))

(onclicks ".add-course"
  (let ((x (chain event target (closest "td") cell-index))
        (y (chain event target (closest "tr") row-index)))
    (setf (chain (one "#schedule-data-weekday") value) x)
    (setf (chain (one "#schedule-data-hour") value) y)
    (show-modal (one "#schedule-data-modal"))))

(onsubmit "#schedule-data-form"
  (chain event (prevent-default))
  (let* ((x (chain (one "#schedule-data-weekday") value))
         (y (chain (one "#schedule-data-hour") value))
         (cell (getprop (one "#schedule-table") 'rows y 'cells x))
         (template (get-template "schedule-data-cell-template")))
    (chain cell (prepend template))
    (hide-modal (one "#schedule-data-modal"))))

(var networkDataReceived F)

(startSpinner)

;; fetch fresh data
(var
  networkUpdate
  (chain
    (fetch "/data.json")
    (then
      (lambda (response)
        (chain response (json))))
    (then (lambda (data))
      (setf networkDataReceived T)
      (updatePage data))))

;; fetch cached data)
(chain
  caches
  (match "/data.json")
  (then (lambda (response))
    (if (not response) (throw (new (-Error "No data"))))
    (chain response json))
  (then (lambda (data))
    ;; don't overwrite newer network data
    (if (not networkDataReceived)
      (updatePage data)))
  (catch (lambda())
    ;; we didn't get cached data, the network is our last hope:
    networkUpdate)
  (catch (showErrorMessage))
  (then (stopSpinner)))
