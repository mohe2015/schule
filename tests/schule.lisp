(in-package :cl-user)
(defpackage schule-test
  (:use :cl :schule :prove))
(in-package :schule-test)

;; (prove:run :schule-test)

(plan nil)

(finalize)
