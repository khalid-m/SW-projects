function [res] = amosGetElement(Sid, pos)
      res = calllib('msl','amosGetElement',Sid,pos-1);
end