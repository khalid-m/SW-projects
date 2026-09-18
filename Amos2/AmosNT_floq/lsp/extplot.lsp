;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2009 Risch, Zeitler, UDBL
;;; $RCSfile: extplot.lsp,v $
;;; $Revision: 1.6 $ $Date: 2013/12/01 18:21:17 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: External plot routines for AmosII
;;; =============================================================
;;; $Log: extplot.lsp,v $
;;; Revision 1.6  2013/12/01 18:21:17  torer
;;; *** empty log message ***
;;;
;;; Revision 1.5  2013/12/01 18:15:33  torer
;;; Added mac gnuplot string
;;;
;;; Revision 1.4  2011/01/29 11:04:39  torer
;;; Base system uses (...) tuple notation, 'return' statement, and systematic indentation
;;;
;;; Revision 1.3  2009/11/03 21:06:03  zeitler
;;; Plot uses project() for projection
;;;
;;; Revision 1.2  2009/10/29 14:51:42  zeitler
;;; Linux GNU Plot
;;;
;;; Revision 1.1  2009/10/23 15:26:51  zeitler
;;; External plot functions in basic system
;;;
;;; =============================================================

;; Usage examples:
;; create function data()->vector as 
;; read_ntuples(getenv('AMOS_HOME') + '/regress/td');
;; scatter3p({0,1,2,7}, data());
;; plot({{1,1},{2,0},{3,2}});

(defun winplotstring (plot-kind params)
  (concat "echo " plot-kind " 'gnu-tmp' "
	  params " ; pause -1 'Close window' | pgnuplot.exe"))

(defun linuxplotstring (plot-kind params)
  (concat "echo \"set mouse
" plot-kind " 'gnu-tmp' " params "
pause mouse\" | gnuplot"))

(defun macplotstring (plot-kind params)
  (concat "echo \"set mouse
" plot-kind " 'gnu-tmp' " params "
pause mouse\" | gnuplot"))

(defglobal _extplotfn_
  (cond ((equal (system-environment) "Unix")
	 #'linuxplotstring)
        ((equal (system-environment) "Apple")
	 #'macplotstring)
	(t #'winplotstring)))

(defun extplot (plot-kind params)
  (system (apply _extplotfn_ (list plot-kind params))))

(defun extplot---+ (fno kind params r)
  (osql-result kind params
	       (extplot kind params)))

(osql "
create function extplotexport(Vector of Integer projs, Bag of Vector v)
                          -> Charstring
  as write_ntuples((select project(p, projs) from Vector p
                    where p in v), 'gnu-tmp');")

(osql "
create function extplotexportv(Vector of Integer projs, Vector of Vector v)
                           -> Charstring
  as write_ntuples((select project(v[i], projs) 
                    from Integer i
                    where i in iota(0, dim(v) - 1)),
                   'gnu-tmp');")

(osql "
create function extplot(Charstring kind, Charstring params)
                    -> Integer
  as foreign 'extplot---+';")

;; OSQL Plot Functions

(osql "
create function plot(Vector of Integer projs, Vector of Vector v)
                 -> Integer
   as begin
      extplotexportv(projs, v);
      return extplot('plot', 'with lines');
      end;

create function plot(Vector of Vector v) -> Integer as plot({0, 1}, v);")

(osql "
create function scatter2(Vector of Integer projs, Bag of Vector v)
                     -> Integer
  as begin
     extplotexport(projs, v);
     return extplot('plot', 'with points');
     end;

create function scatter2(Bag of Vector v) -> Integer as scatter2({0, 1}, v);")

(osql "create function scatter2l(Vector of Integer projs, Bag of Vector v)
                             -> Integer
  as begin
     extplotexport(projs, v);
     return extplot('plot', 'with labels');
     end;

create function scatter2l(Bag of Vector v) -> Integer 
  as scatter2l({0, 1, 2}, v);")

(osql "
create function scatter2p(Vector of Integer projs, Bag of Vector v)
                      -> Integer
  as begin
     extplotexport(projs, v);
     return extplot('plot', 'with points palette');
     end;

create function scatter2p(Bag of Vector v) -> Integer 
  as scatter2p({0, 1, 2}, v);")

(osql "create function scatter3(Vector of Integer projs, Bag of Vector v)
                            -> Integer
  as begin
     extplotexport(projs, v);
     return extplot('splot', 'with points');
     end;

create function scatter3(Bag of Vector v) -> Integer
  as scatter3({0, 1, 2}, v);")

(osql "create function scatter3l(Vector of Integer projs, Bag of Vector v)
                             -> Integer
  as begin
     extplotexport(projs, v);
     return extplot('splot', 'with labels');
    end;

create function scatter3l(Bag of Vector v) -> Integer
  as scatter3l({0, 1, 2, 3}, v);")

(osql "
create function scatter3p(Vector of Integer projs, Bag of Vector v)
                      -> Integer
  as begin
     extplotexport(projs, v);
     return extplot('splot', 'with points palette');
     end;
create function scatter3p(Bag of Vector v) -> Integer
  as scatter3p({0, 1, 2, 3}, v);")
