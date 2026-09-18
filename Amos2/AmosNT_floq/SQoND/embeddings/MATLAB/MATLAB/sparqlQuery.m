function [scanid]=sparqlQuery(cid,query)
    scanid = calllib('msl','sparqlExecute',cid,query);
end