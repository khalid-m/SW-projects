alisp.dmp: ../lsp/*.lsp 
	alisp -i ../lsp/lispdef.lsp -l "(rollout _alisp-dmp_)(quit)"
amos2.dmp: alisp.dmp
	amos2 -i -o "save 'amos2.dmp'; quit;"
