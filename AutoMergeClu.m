function [c,Xdim,Ydim,PixelList,Xcent,Ycent,meanareas,meanX,meanY,NumEvents,frames,CluDist] = AutoMergeClu(RadiusMultiplier,c,Xdim,Ydim,PixelList,Xcent,Ycent,meanareas,meanX,meanY,NumEvents,frames,plotdist)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if (~exist('plotdist'))
    plotdist = 0;
end

NumClusters = length(unique(c));
CluToMerge = unique(c);
ValidClu = unique(c);


CluDist = pdist([meanX',meanY'],'euclidean');
CluDist = squareform(CluDist);
if (plotdist)
    figure;
    dists = [];
    maxovers = [];
    minovers = [];
    for j = 1:length(ValidClu)
        
        for k = 1:j-1
            if (CluDist(ValidClu(j),ValidClu(k)) < 10)
            dists = [dists,CluDist(ValidClu(j),ValidClu(k))];
            dmin = min([length(PixelList{ValidClu(j)}),length(PixelList{ValidClu(k)})]);
            dmax = max([length(PixelList{ValidClu(j)}),length(PixelList{ValidClu(k)})]);
            maxovers = [maxovers,length(intersect(PixelList{ValidClu(j)},PixelList{ValidClu(k)}))/dmax];
            minovers = [minovers,length(intersect(PixelList{ValidClu(j)},PixelList{ValidClu(k)}))/dmin];
            end
        end
    end
    hist3([maxovers',dists'],[40 40]);
    set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
   
end

% for each unique cluster index, find sufficiently close clusters and merge
for i = CluToMerge'
    if(ismember(i,ValidClu) == 0)
        continue;
    end
    BitMap = logical(zeros(Xdim,Ydim));
    BitMap(PixelList{i}) = 1;
    tempb = bwconncomp(BitMap,4);
    tempp = regionprops(tempb(1),'all');
    maxdist = RadiusMultiplier; % try it straight up
    
    nearclust = setdiff(intersect(ValidClu,find(CluDist(i,:) < maxdist)),i);
    
    currpix = PixelList{i};
    
    % merge all clusters in nearclust into i
    DidMerge = 0;
    for k = 1:length(nearclust)
        cidx = nearclust(k); % cidx is cluster number of close transient
        targpix = PixelList{cidx};
        
        comm = length(intersect(targpix,currpix));
        targrat = comm/length(targpix),
        currrat = comm/length(currpix),
        
        lowrat = min([targrat,currrat]);
        highrat = max([targrat,currrat]);
        if (highrat < 0.33333)
             display('low OVERLAP, aborting merge');
             continue;  
        end
        
        if ((targrat < 0.6) && (currrat < 0.6))
            display('LOW MUTUAL OVERLAP, aborting merge');
            continue;
        end
        
        BitMap1 = logical(zeros(Xdim,Ydim));
        BitMap2 = logical(zeros(Xdim,Ydim));
        BitMap1(PixelList{cidx}) = 1;
        BitMap2(PixelList{i}) = 1;
        
        b = bwconncomp(BitMap1.*BitMap2,4);
        if (b.NumObjects > 1)
            display('Merge would create neuron with discontiguous pixels; merge aborted');
            continue;
        end
        if (b.NumObjects == 0)
            display('somehow no common pixels in merge');
            continue;
        end
        
        %% check for overlapping frames
        if(length(intersect(frames{i},frames{cidx}) > 0))
            display('overlapping frames, this should never happen');
            keyboard;
            continue;
        end
        
        c(find(c == cidx)) = i;
        DidMerge = 1;
        display(['merging cluster # ',int2str(i),' and ',int2str(cidx)]);
        [PixelList,meanareas,meanX,meanY,NumEvents,frames] = UpdateClusterInfo(c,Xdim,Ydim,PixelList,Xcent,Ycent,i,meanareas,meanX,meanY,NumEvents,frames);
        
    end
    ValidClu = unique(c);
    
    if (DidMerge)
        [PixelList,meanareas,meanX,meanY,NumEvents,frames] = UpdateClusterInfo(c,Xdim,Ydim,PixelList,Xcent,Ycent,i,meanareas,meanX,meanY,NumEvents,frames);
        [CluDist] = UpdateCluDistances(CluDist,meanX,meanY,ValidClu,i);
    end
    
end

end

