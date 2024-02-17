(in-package #:hashids)

(defparameter *alphabet* "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890")
(defparameter *salt* "")
(defparameter *min-hash-length* 0)
(defconstant +sep-ratio+ 3.5)
(defconstant +guards-ratio+ 12)
(defvar *seps* "cfhistuCFHISTU")

(defun prepare ()
  (assert (>= (length *alphabet*) 16)
          nil "The Hashids alphabet must contain at least 16 unique characters.")
  (assert (not (position #\Space *alphabet*))
          nil "The Hashids alphabet can\'t contain spaces.")
  (let* ((seps-pr (remove-if-not (lambda(c) (position c *alphabet*))
                                 *seps*))
         (alphabet (remove-if (lambda (c) (position c seps-pr))
                              (remove-duplicates *alphabet*)))
         (seps (reorder seps-pr *salt*))
         (alpha-len (length alphabet))
         (seps-len (length seps))
         (guards nil))
    (when (or (zerop seps-len)
              (< +sep-ratio+ (/ alpha-len seps-len)))
      (let* ((min-seps-cnt (ceiling alpha-len +sep-ratio+))
             (diff (- min-seps-cnt seps-len)))
        (when (plusp diff)
          (setf seps (strcat seps (subseq alphabet 0 diff)))
          (setf alphabet (subseq alphabet diff))
          (setf alpha-len (length alphabet)))))
    (setf alphabet (reorder alphabet *salt*))
    (let ((guards-cnt (ceiling alpha-len +guards-ratio+)))
      (if (< alpha-len 3)
          (progn
            (setf guards (subseq seps 0 guards-cnt))
            (setf seps (subseq seps guards-cnt)))
          (progn
            (setf guards (subseq alphabet 0 guards-cnt))
            (setf seps (subseq alphabet guards-cnt)))))
    (values alphabet seps guards)))



(defun reorder (alphabet salt)
  "Shuffle alphabet by given salt"
  (let ((salt-len (length salt))
        (alphabet (copy-seq alphabet)))
    (when (plusp salt-len)
      (loop :for i :from (1- (length alphabet)) :downto 1
            :for idx := 0 :then (mod (1+ idx) salt-len)
            :for salt-code := (char-code (aref salt idx))
            :for isum := salt-code :then (+ isum salt-code)
            :for j := (mod (+ salt-code idx isum) i)
            :do (rotatef (aref alphabet j) (aref alphabet i))))
    alphabet))

(defun hash (val alphabet)
  "Hash given input value"
  (let ((alpha-len (length alphabet))
        (hash ""))
    (loop
      :for v := val :then (floor v alpha-len)
      :while (> v 0)
      :do (setf hash (strcat (string (aref alphabet (mod v alpha-len)))
                             hash)))
    hash))

(defun unhash (hash alphabet)
  "Hash given input value"
  (let ((alpha-len (length alphabet)))
    (loop :for c :across hash
          :for pos := (position c alphabet)
          :for res := 0 :then (+ pos (* res alpha-len))
          :finally (return res))))

(defun encode (&rest numbers)
  "Builds a hash from the passed `numbers`"
  (assert (every #'integerp numbers))
  (multiple-value-bind (alphabet seps guards)
      (prepare)
    (let* ((numbers-len (length numbers))
           (guards-len (length guards))
           (seps-len (length seps))
           (num-ihash (loop :for i :from 0 to (1- numbers-len)
                            :for num in numbers
                            :sum (mod num (+ i 100))))
           (lottery (aref alphabet (mod num-ihash (length alphabet))))
           (ret (string lottery)))
      (loop :for i :from 0 :to (1- (length numbers))
            :for num :in numbers
            :for alpha-salt := (subseq (strcat (string lottery) *salt* alphabet)
                                       0 (length alphabet))
            :for ab := (reorder (or ab alphabet) alpha-salt)
            :for last := (hash num alphabet)
            :do (setf ret (strcat ret last))
            :when (< (1+ i) numbers-len)
              :do (progn
                    (setf alphabet ab)
                    (setf ret (strcat ret
                                      (string (aref seps
                                                    (mod (+ i (char-code (first-char last)))
                                                         seps-len)))))))
      (when (< (length ret) *min-hash-length*)
        (let* ((guard-idx (mod (+ num-ihash (char-code (first-char ret)))
                               guards-len))
               (guard (aref guards guard-idx)))
          (setf ret (strcat (string guard) ret))
          (when (< (length ret) *min-hash-length*)
            (let* ((guard-idx (mod (+ num-ihash (char-code (aref ret 2)))
                                   guards-len))
                   (guard (aref guards guard-idx)))
              (setf ret (strcat ret (string guard)))))))
      (break alphabet)
      (let ((split-at (floor (length alphabet) 2))
            (excess 0))
        (loop :while (< (length ret) *min-hash-length*)
              :do (setf alphabet (reorder alphabet alphabet)
                        ret (strcat (subseq alphabet split-at) ret (subseq alphabet 0 split-at))
                        excess (- (length ret) *min-hash-length*))
              :when (plusp excess)
                :do (setf ret (subseq ret (floor excess 2) (+ (floor excess 2) *min-hash-length*)))))
      ret)))

