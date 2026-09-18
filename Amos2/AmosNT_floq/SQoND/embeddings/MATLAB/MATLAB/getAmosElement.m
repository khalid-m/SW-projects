function [res] = getAmosElement(Sid, pos)
      res = calllib('msl','amos_getElement',Sid,pos);
end