function [] = TempSmoothMovie(infile,outfile,smoothfr);



info = h5info(infile,'/Object');
NumFrames = info.Dataspace.Size(3);
XDim = info.Dataspace.Size(1);
YDim = info.Dataspace.Size(2);

smfun = hann(smoothfr)./sum(hann(smoothfr));

h5create(outfile,'/Object',info.Dataspace.Size,'ChunkSize',[XDim YDim 1 1],'Datatype','int32');

for i = 1:smoothfr-1
    F{i} = int32(h5read(infile,'/Object',[1 1 i 1],[XDim YDim 1 1])).*100;
    h5write(outfile,'/Object',int32(F{i}),[1 1 i 1],[XDim YDim 1 1]);
end

for i = smoothfr:NumFrames
  display(['Smoothing movie frame ',int2str(i),' out of ',int2str(NumFrames)]);
  F{smoothfr} = int32(h5read(infile,'/Object',[1 1 i 1],[XDim YDim 1 1])).*100;
  Fout = zeros(size(F{1}));
  for j = 1:smoothfr
    Fout = Fout+double(F{j}).*smfun(j);
  end
  h5write(outfile,'/Object',int32(Fout),[1 1 i 1],[XDim YDim 1 1]);

  for j = 1:smoothfr-1
      F{j} = F{j+1};
  end
end

  