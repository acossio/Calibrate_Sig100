
function [echogram70,fEcho,RangeBinned,pulse_length] = calcEchogram70kHz(Config, Data, WaterProp, Options)
% function [echogram70] = calcEchogram70kHz(Config, Data)

%% INIT
echogram70 = [];

try
    soundVel = WaterProp.soundVel;
catch
    soundVel = 1500;
end

if(isempty(Options))
else
end


%% CALC
fAdjMonochromeAmp = 6.0206;  % Adjustment used in firmware [dB]

try
    BD=Config.echo_blanking;  %Reference to non-existent field 'echo_blanking'.
catch
    BD=Config.EchoSounder_BlankingDistance;
end


if (Config.echo_frequency1 == 70)
   nEcho=1;
else
   if isfield(Config,'echo_frequency2') && Config.echo_frequency2 == 70
      nEcho=2;
   else
      if isfield(Config,'echo_frequency3') && Config.echo_frequency3 == 70
         nEcho=3;
      else
         disp('No 70 kHz data');
         return;
      end
   end
end

eval(['sampleRate = Config.echo_rawSampleRate' num2str(nEcho) ';'])
eval(['nRawSamp   = Config.echo_nRawSamp'      num2str(nEcho) ';'])
eval(['DataI = Data.RawEcho' num2str(nEcho) '_70kHz_DataI;'])
eval(['DataQ = Data.RawEcho' num2str(nEcho) '_70kHz_DataQ;'])
eval(['Range = Data.RawEcho' num2str(nEcho) '_70kHz_Range;'])
eval(['fEcho = Data.Echo' num2str(nEcho) '70_0kHz_Frequency(1);'])
eval(['pulse_length = Config.echo_transmitLength' num2str(nEcho) ';'])

if nRawSamp > 0,
   sampDist70kHz     = soundVel/(2*sampleRate);
   Nsamp = size(DataI,1);
   
   % DSP processing
   startInd70 = 1+round((BD-Range(1))/sampDist70kHz);
else 
   disp('No raw echo data');
   return;
end

sampDist70 = 750/sampleRate;
samplesPerCell = Config.echo_binSize/sampDist70;
BinLength=zeros(1,Config.echo_numBins);

% Calculate the number of samples per bin
BinLength(1) = round(samplesPerCell);
for i=2:Config.echo_numBins
   BinLength(i) = round((i*Config.echo_binSize - sum(BinLength(1:i-1))*sampDist70)/sampDist70);
end

echogram70 = zeros(Nsamp, Config.echo_numBins);
RangeBinned = zeros(1, Config.echo_numBins);
for n=1:Nsamp
   k = startInd70; % Sample number for start of first echogram bin. 

   for m=1:Config.echo_numBins
      samplesInCell = k:(k+BinLength(m)-1);

      Z = DataI(n,samplesInCell)+j*DataQ(n,samplesInCell);
      sumZZ = sum(Z.*conj(Z));
      if sumZZ == 0,
         % Get rid of log10 of zero messages
         sumZZ = 1e-16;
      end
      echogram70(n,m) = fAdjMonochromeAmp + 10*log10(sumZZ/BinLength(m)); % Average. Using 10*log10 since Z is squared
      
      RangeBinned(m) = mean(Range(samplesInCell));
      
      k = k+BinLength(m);
   end   
end

zz=0;
