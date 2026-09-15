function [echogramstruct,fEcho,RangeBinned,SampleBinned] = calcEchogram90kHzBinned(Config, Data, WaterProp, Options)
%function [echogram90bin1,echogram90bin2,echogram90bin3,echogram90bin4,echogram90bin5] = calcEchogram90kHzBinned(Config, Data, NBINF)
%function [echogram90bin1,echogram90bin2,echogram90bin3,echogram90bin4,echogram90bin5] = calcEchogram90kHzBinned(Config, Data)
%
% S. Nylund, 201908
% G. Cutter, 201909

%% OPTIONS
% Struct Options should include values for: 
% Options.retRawData  % DEFAULT=0
% Options.NBINF  %default=5

%retRawData = 1;
%if(isempty(Options.retRawData))
if(isempty(Options))
    retRawData = 0;  % retRawData = 1;
    NBINF      = [];
else
    retRawData = Options.retRawData;
    NBINF      = Options.NBINF;
end

%% INIT
echogramstruct = []; % in case we want more than default 5 freq-bins
% echogram90bin1 = [];
% echogram90bin2 = [];
% echogram90bin3 = [];
% echogram90bin4 = [];
% echogram90bin5 = [];
try
    soundVel = WaterProp.soundVel;
catch
    soundVel = 1450;
end

BD=Config.echo_blanking;

if Config.echo_frequency1 == 90 && Config.echo_pulseComp1 == 1
    nEcho=1;
else
    if isfield(Config,'echo_frequency2') && Config.echo_frequency2 == 90 && Config.echo_pulseComp2 == 1
        nEcho=2;
    else
        if isfield(Config,'echo_frequency3') && Config.echo_frequency3 == 90 && Config.echo_pulseComp3 == 1
            nEcho=3;
        else
            disp('No 90 kHz pulse compressed data');
            return;
        end
    end
end


eval(['sampleRate = Config.echo_rawSampleRate' num2str(nEcho) ';'])
eval(['nRawSamp   = Config.echo_nRawSamp'      num2str(nEcho) ';'])
eval(['DataI = Data.RawEcho' num2str(nEcho) '_90kHz_DataI;'])
eval(['DataQ = Data.RawEcho' num2str(nEcho) '_90kHz_DataQ;'])
eval(['Range = Data.RawEcho' num2str(nEcho) '_90kHz_Range;'])
eval(['Zxmit = Data.RawEcho' num2str(nEcho) '_90kHzTx_DataI + j*Data.RawEcho' num2str(nEcho) '_90kHzTx_DataQ;']);
Zxmit0 = Zxmit;
Zxmit=[Zxmit zeros(1,100)]; % Why the extra zeros? 

%%
if nRawSamp > 0,
    sampDist90 = soundVel/(2*sampleRate);
    Nsamp = size(DataI,1);
else
    disp('No raw echo data');
    return;
end



%% DEBUGGING
fprintf('sizes\n');
fprintf('DataI   %d %d\n', size( DataI ) );
fprintf('DataQ   %d %d\n', size( DataQ ) );
fprintf('Zxmit0  %d %d\n', size( Zxmit0 ) );
fprintf('Zxmit   %d %d\n', size( Zxmit ) );
fprintf('Range   %d %d\n', size( Range ) );


%% range 
N=length(Data.RawEcho1_90kHz_SampleRate);
Z=DataI+j*DataQ;
pcLin=zeros(N,length(real(Z(1,:)))-length(Zxmit0));
%r=0:(length(pcLin(1,:))-1);
%r=0:(length(pcLin(1,:)));
r=0:(length(pcLin(1,:))-2);
r=r*(WaterProp.soundVel*0.5)/Config.echo_rawSampleRate1;



%% Calculate complex bandpass filters
load LPfilter  % Load low pass filter
ECHO_REMOVE_ENDS = 1.875;
recvBW = 0.5; % 50% bandwidth
%% Number of frequency bins
if(isempty(NBINF))
    nbinf = Config.echo_nbinf1;
else
    nbinf = NBINF;
end

%%
fFc = 1.0e6/11;
ECHO_FILTER_PC_LENGTH = length(B); % B is from LPfilter
coeffComplexBinnedFrequency = zeros(nbinf,ECHO_FILTER_PC_LENGTH);

L2 = size(Data.RawEcho1_90kHzTx_DataI,2);
L2filtered = round(L2/nbinf + ECHO_FILTER_PC_LENGTH);
nShiftBinfPos = floor((0:nbinf-1)*L2/nbinf);

if Config.fwVersionDoppler < 2212
    fAdjPulseCompAmp = 10.0*log10(L2) - 30.0;          % Adjustment (erroneous) used in firmware [dB]
else
    fAdjPulseCompAmp = 10.0*log10(L2filtered) - 30.0;  % Adjustment used in firmware [dB]
end

for k=0:nbinf-1
    fF0 = (ECHO_REMOVE_ENDS/nbinf)*(k-floor(nbinf/2.0));
    F0(k+1) = fF0;
    fEcho(k+1) = fFc*(1+fF0*recvBW/2.0);
    coeffComplexBinnedFrequency(k+1,:)=B.*exp(j*fF0*pi*(0:ECHO_FILTER_PC_LENGTH-1));
    
    filtXmit(k+1,:) = filter(coeffComplexBinnedFrequency(k+1,:), 1, Zxmit);
    
    nCenter = L2/2+ECHO_FILTER_PC_LENGTH/2 + L2*((floor(nbinf/2.0)-k)/nbinf);
    startIndex = max(0,round(nCenter-L2filtered/2));
    endIndex = min(size(filtXmit,2)-1,round(nCenter+L2filtered/2));
    len = 1+endIndex-startIndex;
    
    if Config.fwVersionDoppler < 2212
        % Clip/saturate filter coefficients in order to replicate firmware bug
        preFiltXmit(k+1,1:len) = complexSaturate(filtXmit(k+1,1+(startIndex:endIndex)), 1.0, -1.0);
    else
        preFiltXmit(k+1,1:len) = filtXmit(k+1,1+(startIndex:endIndex));
    end
end

fNSampPreStart = ((sampleRate * Config.echo_transmitLength1 * 1.0e-3/nbinf) + ECHO_FILTER_PC_LENGTH)/2.0;
indStartSamp = floor(0.5 + (sampleRate * BD/(soundVel/2)) - fNSampPreStart);
startInd90 = indStartSamp;
FiltDelay = len;

% Calculate the number of samples per bin
samplesPerCell = Config.echo_binSize/sampDist90;
BinLength=zeros(1,Config.echo_numBins);
BinLength(1) = round(samplesPerCell);
for i=2:Config.echo_numBins
    BinLength(i) = round((i*Config.echo_binSize - sum(BinLength(1:i-1))*sampDist90)/sampDist90);
end

echogram90raw = [];

% % Range = Range(Range>=0);
RangeBinned = zeros(1, Config.echo_numBins);
SampleBinned = RangeBinned;

for i=1:nbinf
    
    %% Creates an echogram array for each frequency bin
    eid = sprintf('%2.2d',i); % echogram bin identifier
    eval(['echogram90bin' eid ' = [];']); %init empty echogram
    eval(['echogram90raw' eid ' = [];']); %init empty echogram
    echogrambinname = ['echogram90bin' eid];
    
    % Apply complex filter which performs filtering and convolution
    %X = DataI(: , nShiftBinfPos(i)+(startInd90:(end-nShiftBinfPos(end))) )' +j*DataQ(:,nShiftBinfPos(i)+(startInd90:(end-nShiftBinfPos(end))))';
    INDX2 = nShiftBinfPos(i)+(startInd90:(size(DataI,2)-nShiftBinfPos(size(nShiftBinfPos,2))));
    X = DataI(: , INDX2 )' +j*DataQ(:,nShiftBinfPos(i)+(startInd90:(end-nShiftBinfPos(end))))';
    DataFilt = filter(preFiltXmit(i,:), 1, X)';
    
    %% Range init
    % NO. MOVE THIS -- % RangeBinned = Range( :, INDX2); 
    %no RangeBinned = Range( :, INDX2);
    %no RangeBinned = r;
    %RangeBinned = Range;
    %RangeBinned = Range( :, INDX2);  % or (Range>=0); %?
    %Range = Range( :, INDX2);  % or (Range>=0); %?
    Range = Range(Range>=0);
    SampleBinned = 1:length(Range);
        
    if retRawData,
        echogram90bin = zeros(Nsamp, Config.echo_numBins);
        echogram90raw = [echogram90raw; 10*log10(DataFilt.*conj(DataFilt))]';
        
        %% Range for raw echogram
        % %     %no RangeBinned = Range( :, INDX2);
        % %     %no RangeBinned = r;
        % %     %RangeBinned = Range;
        % %     RangeBinned = Range(Range>=0);
        % %     SampleBinned = 1:length(Range);
        RangeBinned = Range;
        if( length(RangeBinned) > size(DataFilt,2) )
            RangeBinned = RangeBinned( 1 : size(DataFilt,2) );
        end
    end
    
    if retRawData,
        echogram90raw = echogram90raw';
        %eval(['echogram90bin' num2str(i) ' = echogram90raw;']);
        eval(['echogram90bin' eid ' = echogram90raw;']);
        echogram90raw = [];        
    else
        for n=1:Nsamp
            k = FiltDelay; % Sample number for start of first echogram bin. Blanking has already been accounted for.
            
            for m=1:Config.echo_numBins
                samplesInCell = k:(k+BinLength(m)-1);
                
                Z = DataFilt(n,samplesInCell);
                sumZZ = sum(Z.*conj(Z));
                if sumZZ == 0,
                    % Get rid of log10 of zero messages
                    sumZZ = 1e-16;
                end
                echogram90bin(n,m) = fAdjPulseCompAmp + 10*log10(sumZZ/BinLength(m)); % Average. Using 10*log10 since Z is squared
                
                
                %% Range for binned echogram
                % %RangeBinned(m) = mean(Range(samplesInCell));
                % %SampleBinned(m) = mean(samplesInCell);
                if Config.fwVersionDoppler < 2212
                    %no RangeBinned(m) = mean(Range(samplesInCell + L2));
                    %RangeBinned(m) = Config.echo_binSize + mean(Range(startInd90 + samplesInCell + FiltDelay));
                    %RangeBinned(m) = mean(Range(startInd90 + samplesInCell + FiltDelay));
                    RangeBinned(m) = mean(Range( samplesInCell ));
                    SampleBinned(m) = mean(samplesInCell) + L2;
                else
                    %no RangeBinned(m) = mean(Range(samplesInCell + L2filtered));
                    %RangeBinned(m) = Config.echo_binSize + mean(Range(startInd90 + samplesInCell + FiltDelay));
                    %RangeBinned(m) = mean(Range(startInd90 + samplesInCell + FiltDelay));
                    RangeBinned(m) = mean(Range( samplesInCell ));
                    SampleBinned(m) = mean(samplesInCell) + L2filtered;
                end
                fprintf('samplesInCell (%d : %d), Range %.2f\n',samplesInCell(1),samplesInCell(end),RangeBinned(m));
                
                k = k+BinLength(m);
            end
        end
        eval(['echogram90bin' eid ' = echogram90bin;']); 
        
    end
    
    echogramstruct.(echogrambinname) = eval(['echogram90bin' eid]);
     
    %% DEBUGGING
    [m_echo n_echo] = size( echogramstruct.(echogrambinname) );
    fprintf('\nsizes, end of loop.\n');
    fprintf('DataI     %d %d\n', size( DataI ) );
    fprintf('echog     %d %d\n', m_echo, n_echo );
    fprintf('Range     %d %d\n', size( Range ) );
    fprintf('r         %d %d\n', size( r ));
    fprintf('r-n_echo  %d\n', size( r ,2 ) - n_echo );
    fprintf('R-n_echo  %d\n', size( r ) - n_echo );

end



fprintf('fBinnedEcho  %.1f\n',fEcho)

fprintf('\nFunction calcEchogram90kHzBinned completed.\n');
