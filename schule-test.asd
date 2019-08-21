(defsystem "schule-test"
  :defsystem-depends-on ("prove-asdf")
  :author "Moritz Hedtke"
  :license ""
  :depends-on ("schule"
               "prove")
  :components ((:module "tests"
                :components
                ((:test-file "schule"))))
  :description "Test system for schule"
  :perform (test-op (op c) (symbol-call :prove-asdf :run-test-system c)))
