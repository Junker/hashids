(defsystem hashids
  :version "0.1.0"
  :author "Dmitrii Kosenkov"
  :license "MIT"
  :depends-on ()
  :description "System to generate YouTube-like hashes from one or many numbers"
  :homepage "https://github.com/Junker/hashids"
  :source-control (:git "https://github.com/Junker/hashids.git")
  :components ((:file "package")
               (:file "hashids"))
  :in-order-to ((test-op (test-op :hashids-test))))
