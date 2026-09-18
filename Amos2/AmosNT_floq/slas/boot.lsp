;; Common functions
(with-directory "common"
		(load  "format.lsp"))

;; Functions to bulk load log files to RDBMS
(with-directory "bulkloader"
		(load "bulk.lsp"))

;; Functions to log a stream into CSV file for bulk loading laater
(with-directory "bulkload_logger"
		(load "logger.lsp"))

;; Proxy function to query directly on raw file
(with-directory "raw"
		(load "raw_proxy.lsp")
		(load-amosql "raw_proxy.osql"))

;; prompter is slas
(setq _prompter_ "Slas")
