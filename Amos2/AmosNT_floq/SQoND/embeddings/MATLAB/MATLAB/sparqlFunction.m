function [res] = sparqlFunction(Cid,fname,arg_list)
res = calllib('msl','sparqlFnExe',Cid,fname,arg_list);
end