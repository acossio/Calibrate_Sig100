%% function f_find_spherepos
function [spherePos] = f_find_spherepos( Data, Config, echogram, range, approxDist, rangebuffer) 
% % function [spherePos] = f_find_spherepos( echogram, range, approxDist, rangebuffer) 
    range = range(1,:);
    Nsamp = size(echogram,1); % Number of samples == number of pings

    if(isempty(rangebuffer))
        rangebuffer = 0.5; % m
    end

% %     spherePos.index = zeros(Nsamp,1);
% %     spherePos.range = zeros(Nsamp,1);

    %-------------------------------------------------------------------------
    %% Find range, index, and amplitude of sphere target
    %-------------------------------------------------------------------------
    f_disp_dbstack_info()
    fprintf('Find range, index, and amplitude of sphere target.\n');  

    approxDist = approxDist;
    i=find((range>approxDist-rangebuffer) & (range<approxDist+rangebuffer));
%     if(length(i)>1)
%         i = i(1);
%     end
    spherePos.index = zeros(Nsamp,1);
    spherePos.indexWithTx = zeros(Nsamp,1); % account for Ltx = size(Data.RawEcho1_90kHzTx_DataI,2);
    spherePos.range = zeros(Nsamp,1);

%     % TO DO - MAKE THIS SAFE:
%     Ltx = size(Data.RawEcho1_90kHzTx_DataI,2); % Data.RawEcho1_90kHzTx_DataI MUST EXIST
    
    for k=1:Nsamp
        indc = i( find(echogram(k,i) == max((echogram(k,i)))) );
        %spherePos(k) = r(j);
        spherePos.index(k,1)  = indc;
        %spherePos.indexWithTx(k,1)  = indc+Ltx;
        spherePos.indexWithTx(k,1)  = -99999;
        spherePos.range(k,1)  = range(indc);
        spherePos.ampLin(k,1) = echogram(k,indc);
    end

    spherePos.indexmean  = nanmean(  spherePos.index );
    spherePos.indexmeanWithTx  = nanmean(  spherePos.indexWithTx );
    spherePos.ampLinmean = nanmean(  spherePos.ampLin );
    spherePos.rangemean  = nanmean(  spherePos.range );
    spherePos.ampLog     = 10*log10( spherePos.ampLin );
    spherePos.ampLogmean = 10*log10( spherePos.ampLinmean );

    fprintf('nanmean(spherePos.index) = %.1f (sample)\n', nanmean(spherePos.index) );
    fprintf('nanmean(spherePos.indexWithTx) = %.1f (sample)\n', nanmean(spherePos.indexWithTx) );
    fprintf('nanmean(spherePos.range) = %.2f (m)\n', nanmean(spherePos.range) );
end
