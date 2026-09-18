;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2013 Tore Risch, UDBL
;;; $RCSfile: dictionary.lsp,v $
;;; $Revision: 1.6 $ $Date: 2013/05/20 15:17:03 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: The collection type DICTIONARY
;;; =============================================================
;;; $Log: dictionary.lsp,v $
;;; Revision 1.6  2013/05/20 15:17:03  torer
;;; Revert to btree
;;;
;;; Revision 1.5  2013/05/20 12:57:46  torer
;;; Using hash tables for dictionaries
;;;
;;; Revision 1.4  2013/04/18 12:41:09  torer
;;; Dictionary with b-trees
;;;
;;; Revision 1.3  2013/04/17 11:02:08  chexu484
;;; added new function setd(Dictionary d, Object k, Object v) -> Dictionary
;;;
;;; Revision 1.2  2013/04/16 20:03:41  torer
;;; More examples
;;;
;;; Revision 1.1  2013/04/16 19:48:05  torer
;;; Collection datatype Dictionary
;;;
;;; =============================================================

(defglobal _dictionary_
  (createliteraltype 'dictionary (list _collection_) 'mexi))

(defun dictionary+ (fno dict)
  (osql-result (make-btree)))

(defun dictionary-set--- (fno dict k v)
  (setf (get-btree k dict) v)
  (osql-result dict k dict))

(defun dictionary-put--- (fno dict k v)
  (setf (get-btree k dict) v)
  (osql-result dict k v))

(defun dictionary-get--+ (fno dict k v)
  (let ((v (get-btree k dict)))
    (if v (osql-result dict k v))))

(defun dictionary-defaultget---+ (fno dict k default v)
  (let ((v (get-btree k dict)))
    (if v (osql-result dict k default v)
      (osql-result dict k default default))))

(defun dictionary-rem--+ (fno dict k)
  (delete-btree k dict)
  (osql-result dict k))

(defun dictionary-map-++ (fno dict k v)
  (map-btree dict '* '* (f/l (k v)(osql-result dict k v))))

(osql "
create function dictionary() -> Dictionary
  as foreign 'dictionary+';

create function setd(Dictionary d, Object k, Object v) -> Dictionary
  as foreign 'dictionary-set---';

create function put(Dictionary d, Object k, Object v) -> Boolean
  as foreign 'dictionary-put---';

create function rem(Dictionary d, Object k) -> Boolean
  as foreign 'dictionary-rem--+';

create function get_withdefault(Dictionary d, Object k, Object default) ->  Object v
  as foreign 'dictionary-defaultget---+';

create function vref(Dictionary d, Object k) ->  Object v
  as multidirectional ('bbf' foreign 'dictionary-get--+')
                      ('bff' foreign 'dictionary-map-++');
")

"Examples:

set :d = dictionary();

put(:d, 1, 2);

put(:d, 2, 3);

rem(:d, 1);

put(:d,{1,2,3},4);

:d[1];

:d[2];

:d[{1,2,3}];

select :d[o] from Object o;

select k,v from Object k, Object v where :d[k] = v;

select k from Object k where :d[k]=4;

typesof(:d);

"