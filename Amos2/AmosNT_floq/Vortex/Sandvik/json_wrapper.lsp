;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Cheng Xu, UDBL
;;; $RCSfile: json_wrapper.lsp,v $
;;; $Revision: 1.3 $ $Date: 2012/10/30 13:15:21 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: General wrapper of JSON streams
;;; =============================================================
;;; $Log: json_wrapper.lsp,v $
;;; Revision 1.3  2012/10/30 13:15:21  torer
;;; *** empty log message ***
;;;
;;; Revision 1.2  2012/10/20 10:34:59  chexu484
;;; 1. install.cmd updated so that
;;;    "svali.exe" and "svali.dmp" are installed and copied to bin/
;;; 2. bin/readme.txt contains walk through instructions on how to run corenetserver
;;; 3. Sandvik/readme.txt: instructions how to run Sandvik demo
;;; 4. To make a demo dump, do:
;;;    svali -O "ht2012_demo_v2.osql" -o "save '../bin/demo2012.dmp';quit;"
;;;
;;; Revision 1.1  2012/08/16 13:40:47  larme597
;;; *** empty log message ***
;;;
;;; =============================================================


(foreign-lispfn 
 json_stream_wrapper0 ((Charstring exec) 
		       (Charstring host) (Integer portno)) ((Record r))
 (let* ((s (open-socket nil 0))
	(sno (socket-portno s))
	socket)
   (system (concat "start /min " exec " " host " " portno " localhost " sno))
   (setq socket (accept-socket s 1))
   (if (null socket) (error "Connection with the wrapper failed"))
   (pf 'START socket)
   (while socket
     (if (socket-closed socket) (progn (close-socket socket)
				       (setq socket nil))
       (foreign-result (json-read socket))))))

(osql "
create function json_stream_wrapper(charstring exec, charstring host, 
                                    integer portno)
                                  -> stream of record
  as streamof(json_stream_wrapper0(exec, host, portno));")

(foreign-lispfn
 newiota0 ((integer s) (integer e) (number sleep)) ((integer r))
 (dotimes (i e)
   (foreign-result (+ i s))
   (co-sleep sleep)))