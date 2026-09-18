;;current directory is Bigintegrator/SparQL

(print "BigIntegrator is enabled")

(with-directory "src/Lisp"
		(load "sparql.lsp")
		(load "plugin.lsp"))

(with-directory "src/AmosQL"
		(load-amosql "configuration.amosql"))
