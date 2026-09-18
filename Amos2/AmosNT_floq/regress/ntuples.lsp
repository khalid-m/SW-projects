;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2009 Erik Zeitler, UDBL
;;; $RCSfile: ntuples.lsp,v $
;;; $Revision: 1.2 $ $Date: 2009/10/07 14:55:11 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: ntuples reader and writer
;;; =============================================================
;;; $Log: ntuples.lsp,v $
;;; Revision 1.2  2009/10/07 14:55:11  zeitler
;;; read and write numeric and textual ntuples
;;;
;;; Revision 1.1  2009/10/07 14:11:30  zeitler
;;; ntuples on (vectors of) numbers
;;;
;;;
;;; =============================================================

(osql "create function nt()->vector of number;
add nt() = {0.015198,138.1,3.58,1.32,71.72,0.12,8.67,0.69,0,1};
add nt() = {0.015185,131,3.97,1.19,72.44,0.6,8.43,0,0,2};
add nt() = {0.015174,122,3.25,1.16,73.55,0.62,8.9,0,0.24,2};

create function tt()->vector of charstring;
add tt() = 
{'http://www2002.stoke.gov.uk/council/libraries/database/searchen.htm'};
add tt() = 
{'http://www.x-mob.org/PSA.htm','http://www.psa-peugeot-citroen.com/'};
add tt() = 
{'http://www.wheatstone.net/seven/favorite.htm',
'http://www.geocities.com/paulossainz/links/home.htm',
'http://www.caterham.co.uk/',
'ourworld.compuserve.com/homepages/easysurf/car.htm'};")

(checkequal "write_ntuples on numbers"
	    ((osql "write_ntuples({iota(1,5)}, 'singlevalue.nt');")
	     '(("singlevalue.nt")))
	    ((osql "write_ntuples(nt(), 'vectors.nt');")
	     '(("vectors.nt"))))

(checkequal "read_ntuples on numbers"
	    ((osql "read_ntuples('singlevalue.nt');")
	     '((#(1)) (#(2)) (#(3)) (#(4)) (#(5))))
	    ((osql "read_ntuples('vectors.nt');")
	     (osql "nt();")))

(checkequal "read_ and write_ntuples on textstrings"
	    ((osql "write_ntuples(tt(), 'text.nt');")
	     '(("text.nt")))
	    ((osql "read_ntuples('text.nt');")
	     (osql "tt();")))

(osql "rollback;")
