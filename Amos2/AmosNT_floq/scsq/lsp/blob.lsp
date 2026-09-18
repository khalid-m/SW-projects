(defun make-blob (dimension elem-size)
  (let ((b (make-binary (+ 1 (* dimension elem-size)))))
    (put-integer b 0 dimension)
    b))

(defun byte-blob (fno size res)
  (osql-result size (make-blob size 1)))
(osql "create function blob(integer)->binary as foreign 'byte-blob';")

(defun byte-blobs (fno size num res)
  (dotimes (j num)
    (let ((b (make-blob size 1)))
      (osql-result size num b))))
(osql "create function byteblobs(integer,integer)->binary
as foreign 'byte-blobs';")

(defun random-int-blob (fno size num res)
  (dotimes (j num)
    (let ((b (make-blob (+ 1 size) 4)))
      (dotimes (i size)
	(put-integer b (+ 1 i) (ez-rand 2147483647)))
      (osql-result size num b)) ))
(osql "create function randintblob(integer,integer)->binary
as foreign 'random-int-blob';")

(defun intblob2vec (fno blob res)
  (let ((size (get-integer blob 0)))
    (let ((a (make-array size)))
      (dotimes (i size)
	(setf (aref a i) (get-integer blob (+ 1 i))))
      (osql-result blob a ))))
(osql "create function intblob2vec(binary)->vector of integer
as foreign 'intblob2vec';")
