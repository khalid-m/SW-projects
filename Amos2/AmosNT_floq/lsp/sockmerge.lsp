;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c)  2005 Tore Risch, UDBL
;;; $RCSfile: sockmerge.lsp,v $
;;; $Revision: 1.3 $ $Date: 2007/09/27 14:01:19 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Stream merge operator using sockets under Windows
;;; =============================================================

(osql "create function merge(bag x, bag y)-> <object,object> 
       as foreign 'sockmerge';")

(defun pf (x s)
  (print x s)
  (flush s))

(defun sockmerge (fno x y rx ry)
  (let ((bx  x)
        (by  y)
        (ls (open-socket nil 0))
        sx sy)
    (rollout "temp.dmp")		; save state
    (system (concat "start amos2 temp.dmp -l \"(merge-stream " 
		    (socket-portno ls)
		    " 1)\""))		; start 1st server
    (system (concat "start amos2 temp.dmp -l \"(merge-stream " 
		    (socket-portno ls)
		    " 2)\""))		; start 2nd server
    (setq sx (accept-socket ls))	; accept 1st connection
    (setq sy (accept-socket ls))	; accept 2nd connection
    (pf bx sx)				; print closure of x
    (pf by sy)				; print closure of y
    (while t
      (setq rx (read sx))		; read result
      (cond ((eq rx 'eof)
             (return t)))
      (setq ry (read sy))
      (cond ((eq ry 'eof)
	     (return t)))
      (osql-result x y rx ry))))
   
(defun merge-stream (portno branch)
  "This function runs on child"
  (unwind-protect
      (let* ((s (open-socket (gethostname) portno))
	     (cl (read s)))		; bag closure
	(mapbag cl
		(f/l (row)
		     (pf (car row) s))) ; emit row
	(pf 'eof s)
	(read s))			; wait for parent to kill me
    (quit)))


;;; test cases:
(quote 
 (checkequal "Stream merge using sockets"
	     ((osql "merge(iota(1,4),iota(100,104));")
	      '((1 100) (2 101) (3 102) (4 103)))
	     ((osql "merge(iota(1,4),iota(100,2000000))	;") 
					; Stream truncation
	      '((1 100) (2 101) (3 102) (4 103)))
	     ((osql "merge(iota(1,4000000),iota(100,104));") 
					; Stream truncation
	      '((1 100) (2 101) (3 102) (4 103)))
	     )
 )
 
   