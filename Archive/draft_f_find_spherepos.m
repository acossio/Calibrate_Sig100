function [spherePos] = f_find_spherepos( echogram, range, approxDist, rangebuffer) 

range = range(1,:);
Nsamp = size(echogram,1); % Number of samples == number of pings

if(isempty(rangebuffer))
    rangebuffer = 0.5; % m
end

spherePos.index = zeros(Nsamp,1);
spherePos.range = zeros(Nsamp,1);

%-------------------------------------------------------------------------
%% Find range, index, and amplitude of sphere target
%-------------------------------------------------------------------------
f_disp_dbstack_info()
fprintf('Find range, index, and amplitude of sphere target.\n');  

approxDist = sphereProp.approxDist;
i=find((range>approxDist-rangebuffer) & (range<approxDist+rangebuffer));
spherePos.index = zeros(Nsamp,1);
spherePos.range = zeros(Nsamp,1);

for k=1:Nsamp
    indc = i(find(pcLin(k,i) == max((pcLin(k,i)))));
    %spherePos(k) = r(j);
    spherePos.index(k,1)  = indc;
    spherePos.range(k,1)  = range(indc);
    spherePos.ampLin(k,1) = echogram(k,indc);
end

fprintf('nanmean(spherePos.index) = %.1f (sample)\n', nanmean(spherePos.index) );
fprintf('nanmean(spherePos.range) = %.2f (m)\n', nanmean(spherePos.range) );

