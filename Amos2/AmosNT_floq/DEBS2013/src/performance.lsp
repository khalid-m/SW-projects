;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) <year> <author>, UDBL
;;; $RCSfile: performance.lsp,v $
;;; $Revision: 1.17 $ $Date: 2013/05/23 14:04:54 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Unit perfomance tests
;;; =============================================================
;;; $Log: performance.lsp,v $
;;; Revision 1.17  2013/05/23 14:04:54  thatr500
;;; - removed addSeed / sampleRate
;;; - modified index.html
;;;
;;; Revision 1.16  2013/04/21 22:38:36  thatr500
;;; removed SAMPLING !!!!
;;;
;;; Revision 1.15  2013/04/18 12:42:06  torer
;;; Using B-trees instead of hash tables
;;;
;;; Revision 1.14  2013/04/18 10:07:40  torer
;;; Testing full game with sampling. Time: 52.5
;;;
;;; Revision 1.13  2013/04/17 17:12:31  chexu484
;;; full game and full game new
;;;
;;; Revision 1.12  2013/04/17 13:56:14  chexu484
;;; q3new included in performance test
;;;
;;; Revision 1.11  2013/04/17 12:53:53  torer
;;; *** empty log message ***
;;;
;;; Revision 1.10  2013/04/16 11:16:34  torer
;;; Sampling included
;;;
;;; Revision 1.9  2013/04/16 09:49:41  torer
;;; Added samplerate parameter
;;;
;;; Revision 1.8  2013/04/16 05:46:29  torer
;;; Using assignfunction
;;;
;;; Revision 1.7  2013/04/15 06:51:44  chexu484
;;; q1 and q1_old
;;;
;;; Revision 1.6  2013/04/15 05:42:02  torer
;;; Parameterized q1q()
;;;
;;; Revision 1.5  2013/04/13 15:13:13  torer
;;; Polish
;;;
;;; Revision 1.4  2013/04/13 15:05:51  torer
;;; Using head3Min.csv
;;;
;;; Revision 1.3  2013/04/13 11:39:19  torer
;;; Added performance tests for Q1, Q2, Q3, Q4
;;;
;;; Revision 1.2  2013/04/13 09:22:20  torer
;;; Added performance test of old DEBS stream wrapper
;;;
;;; Revision 1.1  2013/04/13 08:55:57  torer
;;; New version of eventstreamna() using debs_event_file_tuples()
;;;
;;; =============================================================

(osql "
set :largefile = 'data/head3Min.csv';")

(checkequal "CSV reader"
	    ((time (osql "count(csv_file_tuples(:largefile));"))
	     '((2450204)))
	    )

(checkequal "DEBS wrapper"
	    ((time (osql "count(in(eventstreamna(:largefile)));"))
	     '((2450204)))
	    )

'(checkequal "Old DEBS wrapper"
	    ((time (osql "count(in(older_eventstreamna(:largefile)));"))
	     '((2450204)))
	    )

(osql "
create function q1q_old(Charstring file) -> Number
  as count(in(q1_old(q1input(file))));")

'(checkequal "Q1 OLD"
	    ((time (osql "q1q_old(:largefile);"))
	     '((0)))
	    )

(checkequal "Q1"
	    ((time (osql "perfq1(:largefile, 100);"))
	     '((0)))
	    )


(osql "
create function perfq2(Charstring file) -> Number
  as count(select v from Numarray v 
                    where v in ballhitter_bag(inputstreamna(file)) and 
                          isballhitter(v));")
(checkequal 
 "Q2"
 ((time (osql "perfq2(:largefile);"))
  '((202))))

(osql "
create function perfq3(Charstring file) -> Number
  as count(in(q3(q3input(file))));")

(checkequal "q3"
	    ((time (osql "perfq3(:largefile);"))
	     '((0)))
	    )


(osql "
create function perfq3b(Charstring file) -> Number
  as count(in(q3new(q3input(file))));")

(checkequal "q3 new"
	    ((time (osql "perfq3b(:largefile);"))
	     '((0)))
	    )


(osql "
create function q4(Charstring file) -> Number
  as count(in(q4(streamof(
                           ballhitter_bag(inputstreamna(file))))));")
(checkequal
 "q4"
 ((time (osql "q4(:largefile);"))
  '((0)))
 )

(checkequal
 "debs complete"
  ((time (osql "count(fullgame(:largefile));"))
  '((0)))
)

(quote
(checkequal
 "debs new complete"
  ((time (osql "count(fullgamenew(:largefile));"))
  '((0)))
)

)