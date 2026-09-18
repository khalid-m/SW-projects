;;; using QUEUE data structure
;;; To find out about QUEUE implementation do (apropos 'queue)

(defstruct scan bag queue size)
(defglobal _scan-buffer-size_ 2) ;; just to test buffer overflow

(defun open-scan (b)
  (coroutine 'run-scan (list (make-scan :size _scan-buffer-size_ :bag b
					:queue (make-queue)))))

(defun run-scan (sc)
  (let ((size (scan-size sc))
        (q (scan-queue sc)))
    (mapbag (scan-bag sc)
	    (f/l (row)
                 (insert-queue q row)
		 (cond ((>= (queue-length q) size);; buffer full
			(co-yield sc)))))))

(defun scan-next (p)
  (let ((q (scan-queue (car (co-args p)))))
    (cond ((not (empty-queue? q)) (remove-queue q))
          ((co-terminated p) 'eof)
	  ((co-busyp p) '*busy*)
	  ((eq '*busy* (co-resume p)) '*busy*)
	  (t (scan-next p)))))

(defun merge-join (fno b1 b2 r)
  (let* ((s1 (open-scan b1))  (s2 (open-scan b2))
	 (nx1 (scan-next s1)) (nx2 (scan-next s2)))
    (loop (cond ((or (eq nx1 'eof)(eq nx2 'eof))
		 ;; Leak if not explicitly killed (bug)
		 (co-kill s1)(co-kill s2) 
		 (return nil))
                ((eq nx1 '*busy*)(co-sleep 0.001)(setq nx1 (scan-next s1)))
                ((eq nx2 '*busy*)(co-sleep 0.001)(setq nx2 (scan-next s2)))
		((< (car nx1) (car nx2)) (setq nx1 (scan-next s1)))
		((> (car nx1) (car nx2)) (setq nx2 (scan-next s2)))
		(t (osql-result b1 b2 (car nx1))
                   (setq nx1 (scan-next s1))
                   (setq nx2 (scan-next s2)))))))

(osql "
create function mj(Bag b1, Bag b2)->Bag of Object
  as foreign 'merge-join';")

;;;;;;;  Testing

(foreign-lispfn sliota ((number sl)(integer from)(integer to))((integer))
		(let ((r from))
		  (while (<= r to)
		    (foreign-result r)
		    (co-sleep sl)
		    (1++ r))))
(checkequal 
 "Testing scans with merge-join"
 ((osql "mj(sliota(1,1,3),sliota(1,1,1000));")
  '((1)(2) (3)));; takes 4 seconds
)
  