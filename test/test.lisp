(defpackage #:hashids-test
  (:use #:cl #:parachute #:hashids))

(in-package #:hashids-test)

(define-test encode-default-salt
  (is string= (encode 1 2 3) "o2fXhV"))

(define-test encode-single-number
  (is string= (encode 12345) "j0gW")
  (is string= (encode 1) "jR")
  (is string= (encode 22) "Lw")
  (is string= (encode 333) "Z0E")
  (is string= (encode 9999) "w0rR"))

(define-test encode-multimle-numbers
  (is string= (encode 683 94108 123 5) "vJvi7On9cXGtD")
  (is string= (encode 1 2 3) "o2fXhV")
  (is string= (encode 2 4 6) "xGhmsW")
  (is string= (encode 99 25) "3lKfD"))

(define-test encode-salt
  (let ((hashids:*salt* "Arbitrary string"))
    (is string= (encode 683 94108 123 5) "QWyf8yboH7KT2")
    (is string= (encode 1 2 3) "neHrCa")
    (is string= (encode 2 4 6) "LRCgf2")
    (is string= (encode 99 25) "JOMh1")))

(define-test encode-alphabet
  (let ((hashids:*alphabet* "!\"#%&',-/0123456789:;<=>ABCDEFGHIJKLMNOPQRSTUVWXYZ_`abcdefghijklmnopqrstuvwxyz~"))
    (is string= (encode 2839 12 32 5) "_nJUNTVU3")
    (is string= (encode 1 2 3) "7xfYh2")
    (is string= (encode 23832) "Z6R>")
    (is string= (encode 99 25) "AYyIB")))

(define-test encode-short-alphabet
  (let ((hashids:*alphabet* "ABcfhistuCFHISTU"))
    (is string= (encode 2839 12 32 5) "AABAABBBABAAAuBBAAUABBBBBCBAB")
    (is string= (encode 1 2 3) "AAhBAiAA")
    (is string= (encode 23832) "AABAAABABBBAABBB")
    (is string= (encode 99 25) "AAABBBAAHBBAAB")))


(define-test encode-min-length
  (let ((hashids:*min-hash-length* 25))
    (is string= (encode 7452 2967 21401) "pO3K69b86jzc6krI416enr2B5")
    (is string= (encode 1 2 3) "gyOwl4B97bo2fXhVaDR0Znjrq")
    (is string= (encode 6097) "Nz7x3VXyMYerRmWeOBQn6LlRG")
    (is string= (encode 99 25) "k91nqP3RBe3lKfDaLJrvy8XjV")))

(define-test encode-all-params
  (let ((hashids:*min-hash-length* 16)
        (hashids:*salt* "arbitrary salt")
        (hashids:*alphabet* "abcdefghijklmnopqrstuvwxyz"))
    (is string= (encode 7452 2967 21401) "wygqxeunkatjgkrw")
    (is string= (encode 1 2 3) "pnovxlaxuriowydb")
    (is string= (encode 60125) "jkbgxljrjxmlaonp")
    (is string= (encode 99 25) "erdjpwrgouoxlvbx")))

(define-test encode-without-standard-separator
  (let ((hashids:*alphabet* "abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890"))
    (is string= (encode 7452 2967 21401) "X50Yg6VPoAO4")
    (is string= (encode 1 2 3) "GAbDdR")
    (is string= (encode 60125) "5NMPD")
    (is string= (encode 99 25) "yGya5")))


(define-test encode-with-two-standard-separator
  (let ((hashids:*alphabet* "abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890uC"))
    (is string= (encode 7452 2967 21401) "GJNNmKYzbPBw")
    (is string= (encode 1 2 3) "DQCXa4")
    (is string= (encode 60125) "38V1D")
    (is string= (encode 99 25) "373az")))


;; ===== DECODE

(define-test decode-default-salt
  (is equal (decode "o2fXhV") '(1 2 3)))

(define-test decode-single-number
  (is equal (decode "j0gW") '(12345))
  (is equal (decode "jR") '(1))
  (is equal (decode "Lw") '(22))
  (is equal (decode "Z0E") '(333))
  (is equal (decode "w0rR") '(9999)))

(define-test decode-multiple-numbers
  (is equal (decode "vJvi7On9cXGtD") '(683 94108 123 5))
  (is equal (decode "o2fXhV") '(1 2 3))
  (is equal (decode "xGhmsW") '(2 4 6))
  (is equal (decode "3lKfD") '(99 25)))

(define-test decode-salt
  (let ((hashids:*salt* "Arbitrary string"))
    (is equal (decode "QWyf8yboH7KT2") '(683 94108 123 5))
    (is equal (decode "neHrCa") '(1 2 3))
    (is equal (decode "LRCgf2") '(2 4 6))
    (is equal (decode "JOMh1") '(99 25))))

(define-test decode-alphabet
  (let ((hashids:*alphabet* "!\"#%&',-/0123456789:;<=>ABCDEFGHIJKLMNOPQRSTUVWXYZ_`abcdefghijklmnopqrstuvwxyz~"))
    (is equal (decode "_nJUNTVU3") '(2839 12 32 5))
    (is equal (decode "7xfYh2") '(1 2 3))
    (is equal (decode "AYyIB") '(99 25))
    (is equal (decode "Z6R>") '(23832))))

(define-test decode-min-length
  (let ((hashids:*min-hash-length* 25))
    (is equal (decode "pO3K69b86jzc6krI416enr2B5") '(7452 2967 21401))
    (is equal (decode "gyOwl4B97bo2fXhVaDR0Znjrq") '(1 2 3))
    (is equal (decode "Nz7x3VXyMYerRmWeOBQn6LlRG") '(6097))
    (is equal (decode "k91nqP3RBe3lKfDaLJrvy8XjV") '(99 25))))

(define-test decode-all-params
  (let ((hashids:*min-hash-length* 16)
        (hashids:*salt* "arbitrary salt")
        (hashids:*alphabet* "abcdefghijklmnopqrstuvwxyz"))
    (is equal (decode "wygqxeunkatjgkrw") '(7452 2967 21401))
    (is equal (decode "pnovxlaxuriowydb") '(1 2 3))
    (is equal (decode "jkbgxljrjxmlaonp") '(60125))
    (is equal (decode "erdjpwrgouoxlvbx") '(99 25))))

(define-test decode-invalid-hash
  (let ((hashids:*alphabet* "abcdefghijklmnop"))
    (is equal (decode "qrstuvwxyz") nil)))

(define-test decode-without-standard-separators
  (let ((hashids:*alphabet* "abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890"))
    (is equal (decode "X50Yg6VPoAO4") '(7452 2967 21401))
    (is equal (decode "GAbDdR") '(1 2 3))
    (is equal (decode "5NMPD") '(60125))
    (is equal (decode "yGya5") '(99 25))))

(define-test decode-two-standard-separators
  (let ((hashids:*alphabet* "abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890uC"))
    (is equal (decode "GJNNmKYzbPBw") '(7452 2967 21401))
    (is equal (decode "DQCXa4") '(1 2 3))
    (is equal (decode "38V1D") '(60125))
    (is equal (decode "373az") '(99 25))))
