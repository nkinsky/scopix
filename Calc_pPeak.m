function Calc_pPeak()
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
load('ProcOut.mat','NeuronPixels','NumNeurons','FT','NumFrames');

pPeak = cell(1,NumNeurons); 
mRank = cell(1,NumNeurons);
for i = 1:NumNeurons
    pPeak{i} = zeros(size(NeuronPixels{i}));
    mRank{i} = zeros(size(NeuronPixels{i}));
end

disp('Getting frames...'); 
p = ProgressBar(NumFrames); 
for i = 1:NumFrames
    %i
    ActiveN = find(FT(:,i));
    frame = loadframe('DFF.h5',i);
    for j = 1:length(ActiveN)
        idx = ActiveN(j);
        [~,maxid] = max(frame(NeuronPixels{idx}));
        pPeak{idx}(maxid) = pPeak{idx}(maxid) + 1;
        
        [~,srtidx] = sort(frame(NeuronPixels{idx}));
        for k = 1:length(srtidx)
            mRank{idx}(srtidx(k)) = mRank{idx}(srtidx(k))+k;
        end
    end
    
    p.progress;
end
p.stop;

for i = 1:NumNeurons
    pPeak{i} = pPeak{i}./sum(FT(i,:));
    mRank{i} = mRank{i}./sum(FT(i,:))./length(NeuronPixels{i});
end

RankDiff = zeros(NumNeurons,NumFrames); 
disp('Rank scoring...'); 
p = ProgressBar(NumFrames); 
for i = 1:NumFrames
    %display(['rankscoring ',int2str(i)]);
    frame = loadframe('DFF.h5',i);
    for j = 1:NumNeurons
      [~,srtidx] = sort(frame(NeuronPixels{j}));
      tempRank = [];
       for k = 1:length(srtidx)
            tempRank(srtidx(k)) = k;
       end
       tempRank = tempRank./length(NeuronPixels{j});
       %size(mRank{j}),size(tempRank),
       RankDiff(j,i) = abs(mean(mRank{j}-tempRank'));
    end
    
    p.progress;
end
p.stop; 

save pPeak.mat pPeak mRank RankDiff;

end

