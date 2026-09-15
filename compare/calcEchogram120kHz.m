function [echogram120,fEcho,RangeBinned,pulse_length] = calcEchogram120kHz(Config, Data, WaterProp, Options)
% function [echogram120] = calcEchogram120kHz(Config, Data)

%% INIT
echogram120 = [];

try
    soundVel = WaterProp.soundVel;
catch
    soundVel = 1500;
end

if(isempty(Options))
else
end

soundVel2 = soundVel/2;

%% CALC
fAdjMonochromeAmp = 6.0206;  % Adjustment used in firmware [dB]

BD=Config.echo_blanking;

if (Config.echo_frequency1 == 120)
   nEcho=1;
else
   if isfield(Config,'echo_frequency2') && Config.echo_frequency2 == 120
      nEcho=2;
   else
      if isfield(Config,'echo_frequency3') && Config.echo_frequency3 == 120
         nEcho=3;
      else
         disp('No 120 kHz data');
         return;
      end
   end
end

% Load filter 
if Config.fwVersionDoppler >= 2212
   load CBF120kHz_Tx500us.mat
   BF120 = CBF_500us;
else
   load CBF120kHz_Tx1ms 
   BF120 = CBF_1ms;   % Firmware versions 2211_4 and older
end


L = length(BF120);
FiltDelay = round(L/2);

eval(['sampleRate = Config.echo_rawSampleRate' num2str(nEcho) ';'])
eval(['nRawSamp   = Config.echo_nRawSamp'      num2str(nEcho) ';'])
eval(['DataI = Data.RawEcho' num2str(nEcho) '_120kHz_DataI;'])
eval(['DataQ = Data.RawEcho' num2str(nEcho) '_120kHz_DataQ;'])
eval(['Range = Data.RawEcho' num2str(nEcho) '_120kHz_Range;'])
eval(['fEcho = Data.Echo' num2str(nEcho) '120_0kHz_Frequency(1);'])
eval(['pulse_length = Config.echo_transmitLength' num2str(nEcho) ';'])

if nRawSamp > 0,
   sampDist120kHz     = soundVel/(2*sampleRate);
   Nsamp = size(DataI,1);
   
   % DSP processing
   startInd120 = 1+round((BD-Range(1))/sampDist120kHz);
else 
   disp('No raw echo data');
   return;
end

% Apply complex filter in order to reduce noise since the 120 kHz data
% is sampled at 125 kHz with a higher bandwidth than the actual signal
% bandwidth
X = DataI(:,startInd120:end)' +j*DataQ(:,startInd120:end)';
DataFilt = filter(BF120, 1, X)';

sampDist120 = soundVel2/sampleRate;
samplesPerCell = Config.echo_binSize/sampDist120;
BinLength=zeros(1,Config.echo_numBins);

% Calculate the number of samples per bin
BinLength(1) = round(samplesPerCell);
for i=2:Config.echo_numBins
   BinLength(i) = round((i*Config.echo_binSize - sum(BinLength(1:i-1))*sampDist120)/sampDist120);
end

echogram120 = zeros(Nsamp, Config.echo_numBins);
RangeBinned = zeros(1, Config.echo_numBins);
for n=1:Nsamp
   k = FiltDelay; % Sample number for start of first echogram bin. Blanking has already been accounted for
                  % so start echogram after the filter delay.

   for m=1:Config.echo_numBins
      samplesInCell = k:(k+BinLength(m)-1);

      Z = DataFilt(n,samplesInCell);
      sumZZ = sum(Z.*conj(Z));
      if sumZZ == 0,
         % Get rid of log10 of zero messages
         sumZZ = 1e-16;
      end
      echogram120(n,m) = fAdjMonochromeAmp + 10*log10(sumZZ/BinLength(m)); % Average. Using 10*log10 since Z is squared
            
      RangeBinned(m) = mean(Range(startInd120 - FiltDelay + samplesInCell));
      
      k = k+BinLength(m);
   end   
end

zz=0;
