;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010 Robert Kajic, UDBL
;;; $RCSfile: base.lsp,v $
;;; $Revision: 1.19 $ $Date: 2011/05/30 17:22:34 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: General lisp functions.
;;; =============================================================
;;; $Log: base.lsp,v $
;;; Revision 1.19  2011/05/30 17:22:34  torer
;;; revert
;;;
;;; Revision 1.17  2011/02/01 18:18:17  roka4241
;;; Removed dependency on streamfile/1 from base.lsp so that it may be used by non-scsq code.
;;;
;;; Revision 1.16  2010/10/13 02:26:38  roka4241
;;; Changed the n-theta join to call its joining funtion with n arguments instead of a vector with n elements.
;;;
;;; Revision 1.15  2010/10/08 02:35:45  roka4241
;;; *** empty log message ***
;;;
;;; Revision 1.14  2010/10/08 02:33:25  roka4241
;;; res_idx and join_res_idx now take the name of the query function for which to resolve an output field, instead of the query metadata function associated with the query.
;;;
;;; Revision 1.13  2010/09/21 13:29:29  roka4241
;;; Started using more strict argument typing, for example Stream of Vector and Stream of Window instread of the ambiguous Stream.
;;;
;;; Revision 1.12  2010/08/22 03:31:15  roka4241
;;; Added projectl, for projection over lists of arrays. Removed no longer used btree functions. Fixed some bugs in join_res_idx. Added flatten to remove nesting in nested lists.
;;;
;;; Revision 1.11  2010/08/07 03:48:24  roka4241
;;; Updated arefl and alrefl to accept amos functions in place of an index so that more advanced array referencing can be peformed.
;;;
;;; Revision 1.10  2010/07/30 18:49:54  roka4241
;;; Updated bag-tolist to return a list of elements for single element tuples, and a list of lists for multiple element tuples. Added join-res-idx that can determine how to access some field in a a set of joined finctions. Added alrefl, used to reference any number of elements in a list of arrays. Added btree-values-tolist that creates a list from the values of a binary tree.
;;;
;;; Revision 1.9  2010/07/27 01:12:56  roka4241
;;; Renamed fn-field-idx to fn-res-idx and changed it so that it now takes a reference to a function, instead of a function name. Changed arefl to return a new array, instead of a list.
;;;
;;; Revision 1.8  2010/07/22 00:40:01  roka4241
;;; Removed flist, replaced by vectors.
;;;
;;; Revision 1.7  2010/07/13 05:31:29  roka4241
;;; Changed the time window operator so that it always outputs a window when a new timestamp is encountered. Made the same changes to the tuple window. Started testing the partition window, fixing bugs and also made the same changes as were made to the time and tuple windows (windows are emitted at timestamp change). Due to the 'emission'-changes made to the window operators, regression tests will be broken for all and must be fixed.
;;;
;;; Revision 1.6  2010/07/12 05:09:13  roka4241
;;; Added listlist-flatten, arefl and btree-empty-p.
;;;
;;; Revision 1.5  2010/07/08 02:21:46  roka4241
;;; Added the function fn-field-idx which determines the index, starting with 0, at which a functions' result tuples' element name can be found.
;;;
;;; Revision 1.4  2010/07/07 03:52:10  roka4241
;;; Added additional regression tests for istream / dstream / time window and tuple window operators. Fixed bugs in time window operator. Added sublist and sublst functions for extractions of a lists' subset. Made it so that the swin-make-c wrapper swin-make no longer takes a hashmap argument and passes nil as hashmap to the underlying implementation.
;;;
;;; Revision 1.3  2010/07/01 13:19:05  roka4241
;;; Added CVS header.
;;;
;;; =============================================================

(defun reduce (fn l)
  (let
      ((first nil))
    (mapc
     (f/l (x)
          (if (null first)
              (setq first x)            
            (setq first (funcall fn first x)))) 
     l)
    first))

(defun list-sum (list)
  "Sum the elements in the list [list]."
  (reduce #'+ list))

(defun array-sum (array)
  "Sum the elements in the array [array]."
  (list-sum (arraytolist array)))

(defun curry (f &rest args)
  (f/l (&rest more-args)
       (apply f (append args more-args))))

(defun map-cartc (fn args)
  "Map over args and apply fn as n nested loops would, where n is the number of args, and the outermost loop iterates the first element in args, the second loop iterates the second element, etc."
  (let 
      ((values (make-array (length args))))
    (map-cartc-aux fn args values 0)))

(defun map-cartc-aux (fn args values depth)
  (mapc
   (f/l (value)
        (seta values depth value)
        (if  (null (cdr args))
            (funcall fn values)
          (map-cartc-aux fn (cdr args) values (1+ depth))))
   (car args)))

(defun map-cart-join (accept-test args)
  "Perform catesian join between lists in [args] and only add tuples to the result if they are accepted by the [accept-test] function. [accept-test] is given each tuple as a vector."
  (let
      ((r nil))
    (map-cartc
     (f/l (array)
          (when (funcall accept-test array)
            (setq r (cons (arraytolist array) r))))
     args)
    (nreverse r)))

(defun flatten (l)  
  "Flattens the list [l] such that all elements, regardless of nesting, in [l] are extracted and returned in the order they are encountered. I.e. '(1 (2 (3 4 5) 6) (7 8)) becomes '(1 2 3 4 5 6 7 8)."
  (mapcan 
   (f/l (el)
        (if (consp el)
            (flatten el)
          (list el))) 
   l))

(defun sublist (l x n)
  "Return subset of [l] where [x] is the starting index and [n] denotes the number of elements from [l] to pick from that index."
  (when (< x 0)
    (setq x 0))
  (let ((n-max (- (length l) x)))
    (when (or (null n) (> n n-max))
      (setq n n-max))
    (firstn n (nthcdr x l))))

(defun sublst (l x y)
  "Return subset of [l] where [x] is the starting index and [y] is the ending index of the desired sublist."
  (sublist l x (- y x)))

(defun indexof (x l fn)
  "Return the index of, starting with 0, of some element in [l] such that [fn] finds it equal to [x]."
  (let ((counter 0))
    (dolist (cur l)
      (when (funcall fn x cur)
        (return counter))
      (1++ counter))))

(defun fn-res-idx (fno fn field r)
  "Determine the position at which a tuple element called [field] can be found in the result tuple of the amos function called '__meta__'+fn. The first tuple element is found at position 0. If there is no tuple element called [field], nil is returned."
  (let* ((field-atom (mksymbol field))
         (meta-fn (theresolvent (concat "__meta__" fn)))
         (results (second (get-oc meta-fn))))
    (osql-result fn field 
                 (indexof field-atom results 
                          (f/l (needle field) 
                               (= needle (second field)))))))
(osql "create function res_idx(Charstring fn, Charstring field) -> Integer as foreign 'fn-res-idx';")


(defun join-res-idx-aux (fn-array fn-target field)
  (let ((fn-list (arraytolist fn-array))
        (i 0))
    (dolist (fn fn-list)
      (when (or (null fn-target)
                (= fn fn-target))
        (let ((fn-idx (car (getfunction-firsttuple (theresolvent 'res_idx) (list fn field)))))
          (if (not (null fn-idx))
              (return (list i fn-idx)))))
      (1++ i))))

(defun join-res-idx-notarget (fno fn-array field r)
  (osql-result fn-array field
               (join-res-idx-aux fn-array nil field)))
(osql "create function join_res_idx(Vector fnv, Charstring field) -> Object as foreign 'join-res-idx-notarget';")

(defun join-res-idx-withtarget (fno fn-array fn-target field r)
  (osql-result fn-array fn-target field 
               (join-res-idx-aux fn-array fn-target field)))
(osql "create function join_res_idx(Vector fnv, Charstring fn_target, Charstring field) -> Object as foreign 'join-res-idx-withtarget';")


(defun arefl (a l)  
  "Create vector of the elements in array [a] whose indexes are specified in list [l]. A index specifier is either an integer or an amos function which is given the array and should return some value."
  (listtoarray 
   (mapcar (f/l (i)
                (cond ((integerp i) (aref a i))
                      ((oid-p i) (getfunction-firsttuple i (list a)))))
           l)))

(defun projectl (array-list idx-list)
  "Project indexes [idx-list] in a list of arrays [array-list] using arefl."
  (mapcar (f/l (array) (arefl array idx-list)) array-list))

(defun alrefl (array-list idx-list) 
  "Create vector of the elements in the list of arrays [array-list] by referencing its values using [idx-list]. [idx-list] is a list of two-element-lists where the first element specifies the array index in [array-list] and the second elements specifies the index in the selected array. "
  (listtoarray 
   (mapcar (f/l (i)
                (cond ((consp i) 
                       (aref (nth (first i) array-list) (second i)))
                      ((oid-p i) (getfunction-firsttuple i (list (listtoarray array-list))))))
           idx-list)))
