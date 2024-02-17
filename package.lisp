(defpackage hashids
  (:use #:cl)
  (:import-from #:uiop
                #:strcat
                #:emptyp
                #:first-char)
  (:export #:encode
           #:decode
           #:*alphabet*
           #:*salt*
           #:*min-hash-length*))
