cp ../../../lsp/init.el .

chmod +x installMiner
chmod +x amosMiner

pushd ..

rm AmoxMiner.zip
zip AmosMiner/AmoxMiner AmosMiner/installMiner AmosMiner/amosMiner AmosMiner/MiningFunctions/master.osql AmosMiner/init.el

zip AmosMiner/AmoxMiner AmosMiner/MiningFunctions/knnclassifier.osql AmosMiner/data/glassdata.nt AmosMiner/data/testdata.nt AmosMiner/data/truth.nt 

zip AmosMiner/AmoxMiner AmosMiner/MiningFunctions/kmeansclustering.osql AmosMiner/MiningFunctions/dbscanclustering.osql AmosMiner/MiningFunctions/sampling.lsp AmosMiner/data/clusterdata1.nt AmosMiner/data/clusterdata2.nt 

zip AmosMiner/AmoxMiner AmosMiner/MiningFunctions/associationrulemining.osql AmosMiner/data/transactions1000.nt

popd