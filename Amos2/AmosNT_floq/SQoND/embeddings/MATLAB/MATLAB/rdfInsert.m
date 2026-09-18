function [res]=rdfInsert(Cid,arg1,arg2,arg3)
res = calllib('msl','sparqlRdfInsertFn',Cid,arg1,arg2,arg3);
end
