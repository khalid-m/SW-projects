%% SYSTEM INITIALIZATION
%%
amosInit()
%%
%adding new connection
c1=newConnection('','');
%%
s1=amosQuery(c1,'select i, "a"+i, i/3, {i,i+2}, {"b",i} from Integer i where i in iota(1,5);');
while ~endOfScan(s1)
    printRow(s1,5);
    nextRow(s1);
end
%%
c2 = newConnection('','peer')
%c2=calllib('AmosSample','amosNewCE','peer');
%%
s2=amosQuery(c2,'select i, "a"+i, i/3, {i,i+2}, {"b",i} from Integer i where i in iota(6,10);');

while ~endOfScan(s2)
   printRow(s2,5);
    nextRow(s2);
end

%%
finalizeSystem();

%% SPARQL INTERFACE
%initialize SSDM
sparqlInit();
%%
c1=newConnection('','');
%%
% initialize the data
A=[1,2,3;4,5,6];
B=cat(3,A,A+1,A+2,A+3);
p=makeUri('http://example.org/ns#p');

%%
%create dataset for c1
rdfInsert(c1,makeUri('http://example.org/ns#x4'),p,'simple string');
rdfInsert(c1,makeUri('http://example.org/ns#x5'),p,3);
rdfInsert(c1,makeUri('http://example.org/ns#x6'),p,B);
rdfInsert(c1,makeUri('http://example.org/ns#x7'),p,false);

%% 
% select complete dataset
s = sparqlQuery(c1,'SELECT ?s ?p ?o WHERE {?s ?p ?o}');
while endOfScan(s)~=1
    printRow(s,3);
    nextRow(s);
end
%%
c2=newConnection('','ssdmpeer');
%%
%create dataset for c2
rdfInsert(c2,makeUri('http://example.org/ns#x8'),p,true);
rdfInsert(c2,makeUri('http://example.org/ns#x9'),p,A);
rdfInsert(c2,makeUri('http://example.org/ns#x10'),p,makeTimeVal([2012 12 12 00 00 00.99]));
rdfInsert(c2,makeUri('http://example.org/ns#x1'),p,makeUniStr('dog','en'));
rdfInsert(c2,makeUri('http://example.org/ns#x2'),p,makeTypedRDF('cat','http://example.org/ns#x00'));

%%
s = sparqlQuery(c2,'SELECT ?s ?p ?o WHERE {?s ?p ?o}');
while endOfScan(s)~=1
     printRow(s,3);
    nextRow(s);
end
%%
% define a SciSPARQL function - a parametrized query
s=sparqlQuery(c2,'DEFINE FUNCTION f(?s ?p) AS SELECT ?x WHERE { ?s ?p ?x }');
%%
% call it
s = sparqlFunction(c2,'f',{makeUri('http://example.org/ns#x1'),p});
while ~endOfScan(s)
    printRow(s,1);
    nextRow(s);
end
%% calling a MATLAB function from SciSPARQL
%%
% use it inside a parametrized query
% call mtranspose function with the sam connectio, since the mtranspose
% function is defined in "", via connection c1
% ONLY WORKS ON EMBEDDED SSDM!

sparqlQuery(c1,'DEFINE FUNCTION mtranspose(?x) AS MATLAB "transpose"');
% call it directly on a value from MATLAB
array = [1,2,3,4;5,6,7,8];
s =  sparqlFunction(c1,'mtranspose', {array});
getElement(s,1)

%% use it inside a parametrized query
sparqlQuery(c1,'DEFINE FUNCTION f (?a) AS SELECT (mtranspose(?a[:,1:3]) as ?res)');
s =  sparqlFunction(c1,'f',{array});
getElement(s,1)
% NOTE: under current implementation, 'array' is converted to NMA, then back to MATLAB as an argument to 'transpose', 
% the result is converted back to NMA and back to MATLAB on return.
%
% This can be avoided by implementing 'lazy' type conversions (future work!)
%%
%Finalize SSDM system
finalizeSystem();