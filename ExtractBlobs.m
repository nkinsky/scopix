function [] = ExtractBlobs(file,thresh,mask,autothresh)
% [] = ExtractBlobs(file,thresh,mask,autothresh)
% Copyright 2015 by David Sullivan and Nathaniel Kinsky
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of Tenaspis.
%
%     Tenaspis is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     Tenaspis is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with Tenaspis.  If not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extract active cell "blobs" from movie in file
% todebug 0 or 1 depending if you want to go through frame-by-frame
% thresh is initial threshold (try BlobStats for thresh determination)
% mask is the binary mask of which areas to use and not to use
% use MakeBlobMask to make a mask

if ~exist('autothresh','var')
    autothresh = 0;
end

info = h5info(file,'/Object');
NumFrames = info.Dataspace.Size(3);
Xdim = info.Dataspace.Size(1);
Ydim = info.Dataspace.Size(2);

if (~exist('mask','var'))
    mask = ones(Xdim,Ydim);
end
oldmask = mask;

cc = cell(1,NumFrames); 
PeakPix = cell(1,NumFrames); 
p = ProgressBar(NumFrames); 
parfor i = 1:NumFrames
    %display(['Detecting Blobs for frame ',int2str(i)]);
    
    tempFrame = h5read(file,'/Object',[1 1 i 1],[Xdim Ydim 1 1]);
    
    if autothresh
        thresh = mean(tempFrame(:))+autothresh*std(tempFrame(:));
    end
    
    if (i <= 20)
        % Don't detect neurons on first 20 frames
        mask = zeros(Xdim,Ydim);
    else
        mask = oldmask;
    end

    [cc{i},PeakPix{i}] = SegmentFrame(tempFrame,mask,thresh);   
    
    p.progress;
end
p.stop;

save Blobs.mat cc thresh mask PeakPix;




