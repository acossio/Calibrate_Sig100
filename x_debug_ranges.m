%% compare range arrays 
clc; 

n=8;

%
fprintf('rangePC, from PulseCompression\n');
for(indx=1:n)
    fprintf('%.3f\n',rangePC(indx))
end

%
fprintf('Range, from Data.RawEcho1_90kHz_Range (used by calcEchogram90kHzBinned)\n');
Range_calcEchogram = Data.RawEcho1_90kHz_Range;
for(indx=1:n)
    fprintf('%.3f\n',Data.RawEcho1_90kHz_Range(indx))
end

RangeGT0 = Range_calcEchogram(Range_calcEchogram>=0);

%%
length(rangePC)
length(Data.RawEcho1_90kHz_Range)
length(RangeGT0) 

min( rangePC ) 
min( Data.RawEcho1_90kHz_Range ) 
min( RangeGT0 ) 
max( rangePC ) 
max( Data.RawEcho1_90kHz_Range ) 
max( RangeGT0 ) 

%%
figure
subplot(2,1,1) 
plot( rangePC, ones(size(rangePC)), 'x')
xlim( [min(min(rangePC),min(Data.RawEcho1_90kHz_Range)) ,  max(max(rangePC),max(Data.RawEcho1_90kHz_Range)) ]);
subplot(2,1,2) 
plot( Data.RawEcho1_90kHz_Range, ones(size(Data.RawEcho1_90kHz_Range)), 'o')
xlim( [min(min(rangePC),min(Data.RawEcho1_90kHz_Range)) ,  max(max(rangePC),max(Data.RawEcho1_90kHz_Range)) ]);
