set pythonpath=../../embeddings/python
call ssdm -l "(load \"../lsp/sparql-translator-logger.lsp\")" -l "(sparql-logger-start \"regress-log.html\" :mode :lispfn)" regress.lsp -l "(sparql-logger-stop)" -l "(quit)"
call ssdm -l "(load \"../lsp/sparql-translator-logger.lsp\")" -l "(sparql-logger-start \"regress_view-log.html\" :mode :lispfn)" regress_view.lsp -l "(sparql-logger-stop)" -l "(quit)"
call ssdm -l "(load \"../lsp/sparql-translator-logger.lsp\")" -l "(sparql-logger-start \"regress_optional-log.html\" :mode :lispfn)" regress_optional.lsp -l "(sparql-logger-stop)" -l "(quit)"

