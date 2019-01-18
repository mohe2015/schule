(defsystem "spickipedia-test"
  :defsystem-depends-on ("prove-asdf")
  :author "Moritz Hedtke"
  :license ""
  :depends-on ("spickipedia"
               "prove")
  :components ((:module "tests"
                :components
                ((:test-file "spickipedia"))))
  :description "Test system for spickipedia"
  :perform (test-op (op c) (symbol-call :prove-asdf :run-test-system c)))
