(defun delete-root-conflicts ()
  (resetvar 
   _system-watermark_ 0
   (deleteobject (getfunctionnamed 'vector.vector.plus->vector-number))))

(with-directory "../../lsp"
		(load "init.lsp")
		(delete-root-conflicts))
