(load-extension "matWrapper" t)

;; use corresponding MATLAB type, 
;; as alternative to nma_etype_int, nma_etype_double
(defparameter nma_etype_auto -1) 

;; values for mat-set-omit-unary-dims
(defparameter nma_omit_no_unary_dims 0)
(defparameter nma_omit_trailing_unary_dims 1)
(defparameter nma_omit_all_unary_dims 2)

;; create Amos function
(defun matGetVar---+ (fno filename vname dtype res)
  (osql-result filename vname dtype 
	       (mat-get-var filename vname dtype)))

(osql"
create function matGetVar(Charstring filename, Charstring vname, integer dtype) -> Literal
 as foreign 'matGetVar---+';
")

;; create file-link reader
(defun matlab-read (filename-or-url par verbose)
  (let* ((filename (selectq (typename filename-or-url)
			   (uri (error "remote .MAT files not supported!"))			   
			   (ustr (ustr-str filename-or-url))
			   filename-or-url)) ; if string
	 (par-split (string-explode par "&"))
	 (dtype (if (cdr par-split) (read (second par-split)) nma_etype_auto)))
    (unless (first par-split)
      (error "variable name not specified!"))
    (unless (integerp dtype) 
      (error (concat "wrong desired element type: " dtype)))
    (when verbose 
      (formatl nil (now) ": Reading variable " (first par-split) " from " filename t))
    (mat-get-var filename (first par-split) dtype)))

;; register as Turtle file-link reader for type "matlab"
(push '("matlab" . matlab-read) _supported_file_formats_)


