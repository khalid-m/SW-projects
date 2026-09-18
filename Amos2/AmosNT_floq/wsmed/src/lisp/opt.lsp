(defglobal _fn_)
(defglobal _orgplan_)

(setq _fn_ 'U1->CHARSTRING.INTEGER.INTEGER)

(setq _orgplan_ (selectbody-optpred (getselectbody 
				   (getfunctionnamed _fn_))))

(setq _fn_ 'INTEGER.INTEGER.IOTA->INTEGER)

(defun splittest(from to orgplan)
  (let* ((sb (getselectbody (getfunctionnamed _fn_)))
	 (andl (argsof 'and orgplan))
	 (sp (transform-section-subplan andl from to (selectbody-argl sb)
					(selectbody-resl sb))))
    (setf (selectbody-optpred sb) sp);;Replace old TBR
    (osql "count(u1());")));; Should always be ((55))

(checkequal "Split iotatest"
  ((splittest 1 1 _orgplan_) '((55)))
  ((splittest 1 2 _orgplan_) '((55)))
  ((splittest 1 3 _orgplan_) '((55)))
  ((splittest 1 4 _orgplan_) '((55)))
  ((splittest 2 2 _orgplan_) '((55)))
  ((splittest 2 3 _orgplan_) '((55)))
  ((splittest 2 4 _orgplan_) '((55)))
  ((splittest 3 3 _orgplan_) '((55)))
  ((splittest 3 4 _orgplan_) '((55)))
  ((splittest 4 4 _orgplan_) '((55)))
)

(setf (selectbody-optpred (getselectbody (getfunctionnamed _fn_))) _orgplan_)

(setq newplan (split-plan _fn_ 2 4))

(setq subplan (nth 3 (nth 2 newplan)))

(defun printorgcode (fn stream) (pps (get-orgcode fn t) stream))

(with-output-file str "foo.lsp" (printorgcode subplan str))

(load "foo.lsp") ;; should redefine the subplan function


(selectbody-coercedoptpred (getselectbody (getfunctionnamed _fn_)))



  