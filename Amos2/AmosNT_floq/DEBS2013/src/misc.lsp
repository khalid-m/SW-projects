(defun writecsvfile--(fno file b)
  (with-output-file
   s file
   (mapbag b (f/l (row)
                  (selectq (typename (car row))
			   (array (write-csv-line (car row) s))
			   (numarray (na-csv-print (car row) s))
			   (error "Illegal CVS row" (car row)))))
   t))

(defun logger--+ (fno file b r)  
  (with-output-file
   s file
   (mapbag b (f/l (row)
                  (selectq (typename (car row))
			   (array (write-csv-line (car row) s))
			   (numarray (na-csv-print (car row) s))
			   (error "Illegal CVS row" (car row)))
                  (osql-result file b (car row))))		  
	   
   t))

(osql "
create function baglogger(Charstring file, Bag rows) -> Bag of Object
  as foreign 'logger--+';

create function logger(Charstring file, Stream rows) -> Stream
  as streamof(baglogger(file,cast(rows as Bag)));

")

(defun log-csv-line-stdout-+ (fno v res)
  (if *mystream* 
      (write-csv-line v *mystream*)
    (print v))
  (osql-result v t))

(osql "
  create function log_csv_stdout(Vector v) -> Boolean 
  as foreign 'log-csv-line-stdout-+';
")

(set-resulttypesfn (theresolvent 'logger) 'logger-resulttypes)
(set-resulttypesfn (theresolvent 'baglogger) 'logger-resulttypes)

(defun logger-resulttypes (FNO ARGS)
  (list (arg-type (second args))))

(defun propagate-delays- (fno flg)
  (cond ((is-true flg)
         (add-sp-startform '(progn (setq _socket-systime_ t)
                                   (setq _report-csv-times_ t))))
        (t (add-sp-startform '(progn (setq _socket-systime_ nil)
				     (setq _report-csv-times_ nil))))))

(osql "
create function propagate_delays(Boolean) -> Boolean
  as foreign 'propagate-delays-';")

(osql "
create function mergstreams(stream s1, stream s2, Number pos) -> bag of vector
  as begin declare Scan c1, Scan c2;
      open c1 for s1; next(c1);
      open c2 for s2; next(c2);
      loop if (notany(this(c1)) and notany(this(c2)))then leave;
           if this(c1)[pos]<this(c2)[pos] then
	 	begin
			return this(c1);
			next(c1);
		end
           else if this(c1)[pos]>this(c2)[pos] then
		begin
			return this(c2);
			next(c2);
		end
           else begin
                      return this(c1);
                      return this(c2);
                      next(c1);
                      next(c2);
                end
      end loop;
      close c1;
      close c2;
     end;
)