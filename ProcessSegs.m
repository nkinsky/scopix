function [] = ProcessSegs(NumSegments, SegChain, cc, NumFrames, Xdim, Ydim, todebug)
% [] = ProcessSegs(NumSegments, SegChain, SegList, cc, NumFrames, Xdim, Ydim)
%   Detailed explanation goes here
close all;

if (exist('InitClu.mat','file') == 0)
    InitializeClusters(NumSegments, SegChain, cc, NumFrames, Xdim, Ydim);
end

if (nargin < 8)
    todebug = 0;
end


load InitClu.mat; %c Xdim Ydim PixelList Xcent Ycent frames meanareas meanX meanY NumEvents
NumIterations = 0;
NumCT = length(c);
oldNumCT = NumCT;

MinPixelDist = 0.01:0.25:3.5
figure;
set(gcf,'Position',[680          55        1120         923]);
curr = 1;
M = [];

for i = 1:length(MinPixelDist)
    Cchanged = 1;
    oldNumCT = NumCT;
    while (Cchanged == 1)
        [c,Xdim,Ydim,PixelList,Xcent,Ycent,meanareas,meanX,meanY,NumEvents,frames] = AutoMergeClu(MinPixelDist(i),c,Xdim,Ydim,PixelList,Xcent,Ycent,meanareas,meanX,meanY,NumEvents,frames);
        NumIterations = NumIterations+1;
        NumClu(NumIterations) = length(unique(c));
        %PlotNeuronOutlines(PixelList,Xdim,Ydim,unique(c)');
        %M(curr) = getframe;
        curr = curr+1;
        if (NumClu(NumIterations) == oldNumCT)
            break;
        else
            oldNumCT = NumClu(NumIterations);
        end
    end
end

% OK now unpack these things

CurrClu = 0;
CluToPlot = unique(c);
for i = CluToPlot'
    CurrClu = CurrClu + 1;
    NeuronImage{CurrClu} = logical(zeros(Xdim,Ydim));
    NeuronImage{CurrClu}(PixelList{i}) = 1;
    NeuronPixels{CurrClu} = PixelList{i};
    caltrain{CurrClu} = zeros(1,NumFrames);
    caltrain{CurrClu}(frames{CurrClu}) = 1;
end

for i = 1:length(caltrain)
    FT(i,:) = caltrain{i};
end

save ProcOut.mat NeuronImage NeuronPixels c meanX meanY Xdim Ydim FT caltrain NumFrames M NumClu MinPixelDist -v7.3;

end

