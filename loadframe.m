function [frame,Xdim,Ydim,NumFrames] = loadframe(file,framenum)
% [frame,Xdim,Ydim,NumFrames] = loadframe(file,framenum)
info = h5info(file,'/Object');
NumFrames = info.Dataspace.Size(3);
Xdim = info.Dataspace.Size(1);
Ydim = info.Dataspace.Size(2);

frame = h5read(file,'/Object',[1 1 framenum 1],[Xdim Ydim 1 1]);