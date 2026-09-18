function [cid]=newConnection(host, peer)
cid = calllib('msl','newConnection',host,peer);
end