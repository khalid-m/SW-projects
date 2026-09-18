;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2005 Ruslan Fomkin, UDBL
;;; $RCSfile: wrapper3.lsp,v $
;;; $Revision: 1.6 $ $Date: 2012/05/15 18:50:03 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;              
;;; =============================================================
;;; $Log: wrapper3.lsp,v $
;;; Revision 1.6  2012/05/15 18:50:03  torer
;;; Bug fix
;;;
;;; Revision 1.5  2008/08/20 09:14:10  ruslan
;;; root wrapper returns stream, which is alias of bag
;;;
;;; Revision 1.4  2008/03/10 15:57:10  ruslan
;;; type containers defined. this removes some type check, but not all of them, while they still can be removed somehow
;;;
;;; Revision 1.3  2008/02/28 13:11:31  ruslan
;;; using sobject
;;;
;;; Revision 1.2  2008/01/09 15:16:03  ruslan
;;; root scan into structs is type container to remove additional check
;;;
;;; Revision 1.1  2006/04/13 07:01:05  ruslan
;;; missing file is added
;;;
;;; ===========================================================================

(foreign-lispfn substchars
        ((charstring from)(charstring to)(charstring string))
        ((charstring))
        (foreign-result
         (apply 'concat
            (subpair (explode from)(explode to)
                 (explode string)))))

(set-type-container 'root_scan_project_addslots)
(set-type-container 'VECTOR.VECTOR.VECTOR.PLUS->VECTOR)
(set-type-container 'VECTOR.VECTOR.PLUS->VECTOR)
(set-type-container 'BAG.TUPLES->VECTOR)
(set-type-container 'BAG-VECTOR.SUM->VECTOR-NUMBER)
(set-type-container 'OBJECT.VECTOR.NOT_IN->BOOLEAN)
