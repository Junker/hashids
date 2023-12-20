(defpackage hashids
  (:use #:cl)
  (:import-from #:uiop
                #:strcat
                #:emptyp)
  (:export #:encode
           #:decode))
