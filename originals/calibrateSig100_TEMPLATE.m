function [spherePos] = calibrateSig100(Config, Data, sphereDiameter, approxDist)

[pcLin, r] = PulseCompression(Data, Config);

Nsamp = size(pcLin,1);

% Find distance to sphere
i=find((r>approxDist-0.5) & (r<approxDist+0.5));
spherePos = zeros(Nsamp,1);

for k=1:Nsamp
   j = i(find(pcLin(k,i) == max((pcLin(k,i)))));
   spherePos(k) = r(j);
end

end
