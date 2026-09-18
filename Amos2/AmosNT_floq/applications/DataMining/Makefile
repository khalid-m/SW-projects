all:
	cd src && amos2 -O a1knntest.osql -o "quit;"
	amos2 -O src/dbscan.osql -O src/test_dbscan.osql -o "quit;"
	cd AmosMiner && amos2 -o "loadsystem('MiningFunctions','master.osql'); save 'amosMiner.dmp'; quit;"
	cd AmosMiner && amos2 amosMiner.dmp MiningFunctions/regress.lsp -o "quit;"
