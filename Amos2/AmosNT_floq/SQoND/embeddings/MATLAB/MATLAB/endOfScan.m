function [res]=endOfScan(sid)
    res=calllib('msl','scan_end',sid);
end
