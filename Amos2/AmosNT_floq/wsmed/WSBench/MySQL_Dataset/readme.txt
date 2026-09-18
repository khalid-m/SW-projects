Using the Berlin benchmark dataset generator (bsbmtools), user can create datasets of different sizes. 

Here is an example command creates a (My-)SQL dump with the scale factor 1000:
 
    java -cp bin;lib\ssj.jar benchmark.generator.Generator -fc -pc 1000 -s sql

(Make sure that using this command under the route %AMOS_HOME%wsmed\WSBench\MySQL_Dataset\bsbmtools)

Option	Description of the command:
-s <output format> For the dataset there are several output formats supported. See upper table for details. Default: nt
-pc <number of products>  Scale factor: The dataset is scaled via the number of products. For example: 91 products make about 50K triples. Default: 100
-fc  The data generator by default adds one rdf:type statement for the most specific type of a product to the dataset. However, this only works for SUTs that support RDFs reasoning and can inference the remaining relations. If the SUT doesn't support RDFS reasoning, the option -fc can be used to include the statements for the more general classes also. Default: disabled
-dir The output directory for all the data the Test Driver uses for its runs. Default: "td_data" 
-fn The file name for the generated dataset (suffix is added according to the output format). Default: "dataset"

The generated sql files will be in the folder "dataset" that can be loaded by Mysql.


