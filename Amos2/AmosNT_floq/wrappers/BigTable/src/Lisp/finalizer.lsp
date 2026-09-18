(defun translate-tbr (l bnd)
  "Go through conjuctive list of TBR-calls and translate them"
  (let ((res (tconc)))
    (dolist (tbr l)
      (let* ((tr (predify-tbr tbr)) 
	     (translator (get-translator tr)))  ;(help 1)
	(cond (translator 
	       (let ((translated (funcall translator tr bnd)))  ;(help 2)
                 (cond ((equal translated tr) (tconc res tbr))
                       (t (tconc res (optimize-and-or translated bnd))
			  ))))
	      (t (tconc res tbr)))
	(setq bnd (binds-variables tr bnd))))
    (car res)))

(defun get-translator (tr)
  "Get Lisp function lfn to translate TBR-call to its final format.
   For example generating query strings from FILTER calls.
   (lfn filter variable bnd) -> list of TBR-calls"
  (and (consp tr)(oid-p (car tr))
       (getobject (car tr) 'translator)))

(defun put-translator (fno lfn)
  "Put a translator on Amos function FNO"
  (/putobject fno 'translator lfn))

(defun put-translator-- (o fno lfn)
  (put-translator fno (pack 'translate- lfn))
  (osql-result fno lfn))

(osql "
create function put_translator(Function fno, Charstring tr)->Boolean
  as foreign 'put-translator--';")
                              
;;; Initialization only once:
(defglobal _translator-initialized_)

(cond ((boundp '_translator-initialized_))
      (t (advise-around 'psort 
         '(let ((l (absorb-predicates l))) (translate-tbr * bnd)))
         (setq _translator-initialized_ t)))

(quote
(defun psort (l bnd)
  "Optimize AND predicate using strategy of 'nested loop'"
  (if (atom l) l
    (selectq  *optmethod*  
	      (exhaustive (dynprogsort l bnd _DYNPROG_MAX_TIME_))
	      (randomopt  (random-opt l bnd))
	      (prog2 (printopt ">>>>>>>>>>>>>>>>>>>>>>>>>>" t
			       "TR predicate to Ranksort into TBR:"
			       "~PP" (andify l)
			       "Bound variables: " bnd t "----" t)
		  (ranksort l bnd)
		(printopt "<<<<<<<<<<<<<<<<<<<<<<<<<<" t)))))
)