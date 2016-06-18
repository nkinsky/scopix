function [] = MakeROIcorrtraces(NeuronPixels,Xdim,Ydim,NumFrames,ROIavg)

% Initialize progress bar
p=ProgressBar(NumFrames);
disp('Calculating traces for each neuron');


parfor i = 1:NumFrames
    
    % Read in each frame
    tempFrame = h5read('SLPDF.h5','/Object',[1 1 i 1],[Xdim Ydim 1 1]);
    tempFrame = tempFrame(:);
    CorrTrace(:,i) = tracecorr(tempFrame,ROIavg,NeuronPixels);
    % Sum up the number of pixels active in each frame for each neuron

    p.progress; % Update progress bar
end
p.stop;
save CorrTrace.mat CorrTrace;
