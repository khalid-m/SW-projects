(with-directory "../../SQL" (load "project/init.lsp"))

(load "lsp/init.lsp")
(load "operators/init.lsp")
(load "statements/init.lsp")

(rollout "cql.dmp")
(quit)
