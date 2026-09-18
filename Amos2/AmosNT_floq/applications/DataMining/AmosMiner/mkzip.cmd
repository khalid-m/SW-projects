@echo off
REM Deleting the old zip file
mkdir .XEmacs
copy /Y ..\..\..\lsp\init.el .XEmacs

pushd ..
del AmosMiner.zip
REM Adding common files
zip AmosMiner\AmosMiner AmosMiner\installMiner.cmd AmosMiner\amosMiner.cmd AmosMiner\MiningFunctions\master.osql AmosMiner\.XEmacs\init.el

REM Adding files for assignment 1
zip AmosMiner\AmosMiner AmosMiner\MiningFunctions\knnclassifier.osql AmosMiner\data\glassdata.nt AmosMiner\data\testdata.nt AmosMiner\data\truth.nt 

REM Adding files for assignment 2
zip AmosMiner\AmosMiner AmosMiner\MiningFunctions\kmeansclustering.osql AmosMiner\MiningFunctions\dbscanclustering.osql AmosMiner\MiningFunctions\sampling.lsp AmosMiner\data\clusterdata1.nt AmosMiner\data\clusterdata2.nt 

REM Adding files for assignment 3
zip AmosMiner\AmosMiner AmosMiner\MiningFunctions\associationrulemining.osql AmosMiner\data\transactions1000.nt

popd
