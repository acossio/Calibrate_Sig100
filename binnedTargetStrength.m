% binnedTargetStrength.m
%
% S. Nylund, 2019-
% G. Cutter, 2019-09

clear; close all; clc;


%%
load LPfilter
load TS_24mmSphere_f68-119copy.txt
d=TS_24mmSphere_f68_119copy; 
% d is a 2x511 array, row 1 contains frequencies (kHz)
% and row 2 contains theoretical TS of target sphere 


%% FILTER
ECHO_REMOVE_ENDS = 1.875;
recvBW = 0.5; % 50% bandwidth
nbinf = 5;

fFc = 1.0e6/11;
ECHO_FILTER_PC_LENGTH = length(B);
coeffComplexBinnedFrequency = zeros(nbinf,ECHO_FILTER_PC_LENGTH);
   
for k=0:nbinf-1
   fF0 = (ECHO_REMOVE_ENDS/nbinf)*(k-floor(nbinf/2.0));
   F0(k+1) = fF0;
   fEcho(k+1) = fFc*(1+fF0*recvBW/2.0);
      
   coeffComplexBinnedFrequency(k+1,:)=B.*exp(j*fF0*pi*(0:ECHO_FILTER_PC_LENGTH-1));
end

figure('Name','1', 'Color',[1 1 1])
clf
F0=100*round((fFc/2)/100);
F=-F0/2:100:F0/2;
F=-22600:100:22600;  % Overrides previous line, make same size as TS array 
% freqz = Frequency response of digital filter
H1=freqz(coeffComplexBinnedFrequency(1,:),1,F,F0);
H2=freqz(coeffComplexBinnedFrequency(2,:),1,F,F0);
H3=freqz(coeffComplexBinnedFrequency(3,:),1,F,F0);
H4=freqz(coeffComplexBinnedFrequency(4,:),1,F,F0);
H5=freqz(coeffComplexBinnedFrequency(5,:),1,F,F0);

hold on
plot(F+2*F0,10*log10(abs(H1)))
plot(F+2*F0,10*log10(abs(H2)),'k')
plot(F+2*F0,10*log10(abs(H3)),'m')
plot(F+2*F0,10*log10(abs(H4)),'r')
plot(F+2*F0,10*log10(abs(H5)))
title({'Frequency response of digital filter';...
    '(e.g. F+2*F0, 10*log10(abs(H1)))'});

itarget=5:(511-54);
Ft=d(1,itarget);
TS=d(2,itarget);

figure('Name','Filter process', 'Color',[1 1 1])
subplot(4,1,1) 
logabsH1=10*log10(abs(H1));
    plot(Ft,logabsH1, 'b', 'LineWidth',1.5);
    title('Frequency response (10*log10(abs(H1)))');
subplot(4,1,2)
    plot(Ft,TS, 'm', 'LineWidth',1.5);
    title('TS_{theor}')
subplot(4,1,3)
TS1vec=10*log10(abs(H1))+TS; 
    plot(Ft,TS1vec, 'k', 'LineWidth',2);
    title('10*log10(abs(H1)) + TS_{theor}')
subplot(4,1,4)
    plot(Ft,logabsH1, 'b', 'LineWidth',1.5); hold on;
    plot(Ft,TS, 'm', 'LineWidth',1.5); hold on;
    plot(Ft,TS1vec, 'k', 'LineWidth',2);


figure('Name','3', 'Color',[1 1 1])
clf
hold on
TS1vec=10*log10(abs(H1))+TS; plot(Ft,TS1vec);
TS2vec=10*log10(abs(H2))+TS; plot(Ft,TS2vec,'r');
TS3vec=10*log10(abs(H3))+TS; plot(Ft,TS3vec);
TS4vec=10*log10(abs(H4))+TS; plot(Ft,TS4vec,'r');
TS5vec=10*log10(abs(H5))+TS; plot(Ft,TS5vec);
title('TS by frequency bin')


Bscale=1/mean(abs(H1));  % Scaling factor into efficient bandwidth

%----------------------------------------------------------
%% Mean TS by frequency bin
%----------------------------------------------------------
TS1=10*log10(Bscale*mean(10.^(TS1vec/10)));
TS2=10*log10(Bscale*mean(10.^(TS2vec/10)));
TS3=10*log10(Bscale*mean(10.^(TS3vec/10)));
TS4=10*log10(Bscale*mean(10.^(TS4vec/10)));
TS5=10*log10(Bscale*mean(10.^(TS5vec/10)));
disp(['Mean target strength frequency bin 1: ' num2str(TS1,'%.2f')])
disp(['Mean target strength frequency bin 2: ' num2str(TS2,'%.2f')])
disp(['Mean target strength frequency bin 3: ' num2str(TS3,'%.2f')])
disp(['Mean target strength frequency bin 4: ' num2str(TS4,'%.2f')])
disp(['Mean target strength frequency bin 5: ' num2str(TS5,'%.2f')])


%----------------------------------------------------------
% (gc) Frequency bands
fb1 = Ft(abs(H1)>0.1);
fb2 = Ft(abs(H2)>0.1);
fb3 = Ft(abs(H3)>0.1);
fb4 = Ft(abs(H4)>0.1);
fb5 = Ft(abs(H5)>0.1);

figure('Name','4', 'Color',[1 1 1])
clf
hold on
plot( fb1,TS1 , 'k.')
plot( fb2,TS2 , 'k.')
plot( fb3,TS3 , 'k.')
plot( fb4,TS4 , 'k.')
plot( fb5,TS5 , 'k.')
hold on
TS1vec=10*log10(abs(H1))+TS; plot(Ft,TS1vec);
TS2vec=10*log10(abs(H2))+TS; plot(Ft,TS2vec,'r');
TS3vec=10*log10(abs(H3))+TS; plot(Ft,TS3vec);
TS4vec=10*log10(abs(H4))+TS; plot(Ft,TS4vec,'r');
TS5vec=10*log10(abs(H5))+TS; plot(Ft,TS5vec);

title('TS and mean(TS) by frequency bin')
