function [res] = getElement(Sid,pos)
res = calllib('msl','sparqlGetElement',Sid,pos-1);
end