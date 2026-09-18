;;the directory to load the master file is %AMOS_HOME%/BigIntegrator/Bigtable

(defglobal _BT-source-home_ (concat (getenv "amos_home") "/BigIntegrator/Bigtable/src"))


(print "BigIntegrator is enabled")


(with-directory _BT-source-home_
		(load "Lisp/datasource.lsp")
		(load-amosql "AmosQL/createMetaschema.amosql")
		(load-amosql "AmosQL/loadForeignFunctions.amosql")
		(load "Lisp/bt.lsp")
		(load-amosql "AmosQL/wrapperfunctions.amosql")
		(load-amosql "AmosQL/configuration.amosql")
		(load-amosql "AmosQL/hj.amosql")
		(load "Lisp/gql.lsp")
		(load-amosql "AmosQL/bt.amosql")
		)

(quote
(with-directory "src/Lisp"
		(load "datasource.lsp"))
(with-directory "src/AmosQL"
		(load-amosql "createMetaschema.amosql")
		(load-amosql "loadForeignFunctions.amosql"))
(with-directory "src/Lisp"
		(load "bt.lsp"))
(with-directory "src/AmosQL"
		(load-amosql "wrapperfunctions.amosql")
		(load-amosql "configuration.amosql"))
)