;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2005 Tore Risch, UDBL
;;;
;;; Description: Merge two streams using sub processes
;;; =============================================================

(osql "create function merge(bag x, bag y)-> <object,object> 
       as foreign 'sockmerge';")

(defun pf (x s)
  (print x s)
  (flush s))

(defun sockmerge (fno x y rx ry)
  (let ((bx (bag-closure x))
        (by (bag-closure y))
        (ls (open-socket nil 0))
        sx sy)
    (rollout "temp.dmp")		; save state
    (system (concat "start amos2 temp.dmp -l \"(merge-stream " 
		    (socket-portno ls)
		    " 1)\""))		; start 1st server
    (setq sx (accept-socket ls))	; accept 1st connection
    (system (concat "start amos2 temp.dmp -l \"(merge-stream " 
		    (socket-portno ls)
		    " 2)\""))		; start 2nd server
    (setq sy (accept-socket ls))	; accept 2nd connection
    (pf bx sx)				; print closure of x
    (pf by sy)				; print closure of y
    (while t
      (setq rx (read sx))		; read result
      (cond ((eq rx 'eof)
             (pf 'ok sx)		; kill child
             (return t)))
      (setq ry (read sy))
      (cond ((eq ry 'eof)
	     (pf 'ok sy)		; kill child
	     (return t)))
      (osql-result x y rx ry))))
   
(defun merge-stream (portno branch)
  "This function runs on child"
  (unwind-protect
      (let* ((s (open-socket (gethostname) portno))
	     (cl (read s)))		; bag closure
	(mapfunction (eval (car cl))	; function definition
		     (cdr cl)		; function args
		     (f/l (row)
			  (pf (car row) s))) ; emit row
	(pf 'eof s)
	(read s))			; wait for parent to kill me
    (quit)))
