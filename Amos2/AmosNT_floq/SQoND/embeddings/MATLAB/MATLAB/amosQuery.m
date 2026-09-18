
function [scanid]=amosQuery(cid,query)
is_str=ischar(query);
if is_str
      scanid=calllib('msl','amosExecute',cid,query);
else
    scanid = 0;
    fprintf('Input has to be query!\n');
end