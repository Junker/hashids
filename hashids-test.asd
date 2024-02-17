(defsystem hashids-test
  :version "0.0.0"
  :author "Dmitrii Kosenkov"
  :license "MIT"
  :description "Tests for Hashids"
  :homepage "https://github.com/Junker/hashids"
  :serial T
  :components ((:file "test/test"))
  :depends-on (:hashids
               :parachute)
  :perform (test-op (op c) (uiop:symbol-call :parachute :test :hashids-test)))
