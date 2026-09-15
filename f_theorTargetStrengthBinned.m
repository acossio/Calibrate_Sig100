function [TS_theor_binned] = f_theorTargetStrengthBinned(TS_theor_params, doPLOT, doFBINNED)
% function [TS_theor_binned, TS_theor_params] = f_theorTargetStrengthBinned(TS_theor_params, doPLOT)

% formerly: f_binnedTargetStrength
% 
% modified from binnedTargetStrength.m
%
% Requires LPfilter.mat to exist in this directory. 
%
% S. Nylund, 2019-
% G. Cutter, 2019-09

% clear; clc; close all;

%% OPTIONS
if(isempty(doFBINNED))
    doFBINNED = true;
end
doCALCSPHERETS = true; 
% if true, calculates TS of sphere
% if false, loads predicted f & TS from TS_24mmSphere_f68-119copy.txt
if(isempty(doPLOT))
    doPLOT=false;
end

%% PARAMETER VALUES
if(isempty(TS_theor_params))
    % defaults
    TS_theor_params.Ftminspec      =  68.4;  % kHz minimum frequency to model
    TS_theor_params.Ftmaxspec      = 113.4;  % kHz maximum frequency to model
    TS_theor_params.nF             = 500;    % number of frequencies to model
    TS_theor_params.sphereDiameter = 25.4;   % sphere diameter (mm)
    TS_theor_params.sphereType     = 'WC';   % sphere type, %'WC' or 'CU'
    TS_theor_params.HZPASS         = -0.1;   % avoids TS samples affected by filter edges
    TS_theor_params.soundVel       = 1500;   % water sound speed
    TS_theor_params.rhow           = 1033.0; % water density
end
Ftminspec      = TS_theor_params.Ftminspec;      %68.4; % kHz
Ftmaxspec      = TS_theor_params.Ftmaxspec;      %113.4; % kHz
sphereDiameter = TS_theor_params.sphereDiameter; %25.4; % sphere diameter (mm)
sphereType     = TS_theor_params.sphereType;     %'WC' or 'CU'
nF             = TS_theor_params.nF;             %500; % number of frequencies
HZPASS         = TS_theor_params.HZPASS;         % -0.1; % avoids TS samples affected by filter edges
Cw             = TS_theor_params.soundVel;  
rhow           = TS_theor_params.rhow;           %1033.0;



%% LOW-PASS FILTER DATA
% if(isempty(B))
    load LPfilter
% end

%% TS_theoretical(f)

if(doCALCSPHERETS)
    %-------------------------------------------------------------------------
    %% Calculate theoretical TS of sphere
    %-------------------------------------------------------------------------
    %Freq           = [Ftminspec : 0.1 : Ftmaxspec]*1000;  % frequency (Hz)
    %Freq           = [Ftminspec-1.0 : dF_model_kHz : Ftmaxspec+1.0]*1000;  % frequency (Hz)
    Freq_Hz         = linspace(Ftminspec,Ftmaxspec,nF)*1000;
    %Cw             = 1500.0;  % sound speed of water (m/s)
    sphere_diam_mm = sphereDiameter; %25.4; % sphere diameter (mm)
    %sphereType     = sphereType;  %'WC';  % sphere material
    doSAVE         = 0;  % save TS results or not
    
    [f_Hz, TS_theor]  = sphere_TS(Freq_Hz, Cw, sphere_diam_mm, sphereType, rhow, doSAVE);
    
    f_kHz = f_Hz/1000;
    
    Ft = f_kHz;
    TS = TS_theor;
    
    itarget= intersect(find(Ft>=Ftminspec), find(Ft<=Ftmaxspec));
    Ft=Ft(itarget);
    TS=TS(itarget);
    min(Ft)
    max(Ft)
    length(Ft)
    
    if(doPLOT)
    figure('Color',[1 1 1],'Name','TS_theor')
        plot(f_kHz,TS_theor,'.k')
        xlabel('f (kHz)');
        ylabel('TS_{theor}');
        title('TS_{theor}(f)');
    end
    
    clear f_Hz f_kHz TS_theor Freq
else
    % TS from file
    load TS_24mmSphere_f68-119copy.txt
    d=TS_24mmSphere_f68_119copy;
    % d is a 2x511 array, row 1 contains frequencies (kHz)
    % and row 2 contains theoretical TS of target sphere
    %itarget=5:(511-54);
    dfall = d(1,:); % d(1,:) has freq in kHz
    % Ftminspec = 68.4;
    % Ftmaxspec = 113.6;
    itarget= intersect(find(dfall>=Ftminspec), find(dfall<=Ftmaxspec));
    Ft=d(1,itarget);
    TS=d(2,itarget);
    
    fprintf('Ft range, from file: %.1f : %.1f.\n', min(d(1,:)), max(d(1,:)));

end

% % %% RESAMPLING xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
% % Ft  = Ft(1:FSKIP:end);
% % TS  = TS(1:FSKIP:end);
% % dFt_Hz = (Ft(2)-Ft(1))*1000; % d(Ft) in Hz
% % nF  = length(Ft);
% % %%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

fprintf('Ft(isig100): %.1f : %.1f. (%d samples)\n', min(Ft), max(Ft),length(Ft));


%%
if(~doFBINNED)  % if NOT binned
    Bscale = 1;
    TSmean=10*log10(Bscale*mean(10.^(TS/10)));
    
    %% Struct with data to return
    TS_theor_binned.F_mean_bin   = [mean(Ft)];
    TS_theor_binned.F_vec_bin        = [Ft];
    TS_theor_binned.TS_theor_mean_bin = [TSmean];
    TS_theor_binned.TS_theor_vec_bin = [TS];

    return;
end


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

F0=100*round((fFc/2)/100);
% F=-F0/2:100:F0/2;
% F=-22600:100:22600;  % Overrides previous line, make same size as TS array

%% TESTING xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
% F=-F0/2:dFt_Hz:F0/2;
%F=-22600:dFt_Hz:22600;  % Overrides previous line, make same size as TS array
F=linspace(-22600,22600,nF);  % Overrides previous line, make same size as TS array
%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

% freqz = Frequency response of digital filter
H1=freqz(coeffComplexBinnedFrequency(1,:),1,F,F0);
H2=freqz(coeffComplexBinnedFrequency(2,:),1,F,F0);
H3=freqz(coeffComplexBinnedFrequency(3,:),1,F,F0);
H4=freqz(coeffComplexBinnedFrequency(4,:),1,F,F0);
H5=freqz(coeffComplexBinnedFrequency(5,:),1,F,F0);

fFilt = F+2*F0;
fprintf('\nfFilt, F+2*F0: %.1f : %.1f.\n',min(F+2*F0),max(F+2*F0));

% TS by frequency for each band
TS1vec=10*log10(abs(H1))+TS; 
TS2vec=10*log10(abs(H2))+TS; 
TS3vec=10*log10(abs(H3))+TS; 
TS4vec=10*log10(abs(H4))+TS; 
TS5vec=10*log10(abs(H5))+TS; 

if(doPLOT)
    figure('Name','1', 'Color',[1 1 1])
    clf
    hold on
    plot(F+2*F0,10*log10(abs(H1)))
    plot(F+2*F0,10*log10(abs(H2)),'k')
    plot(F+2*F0,10*log10(abs(H3)),'m')
    plot(F+2*F0,10*log10(abs(H4)),'r')
    plot(F+2*F0,10*log10(abs(H5)))
    title({'Frequency response of digital filter';...
        '(e.g. F+2*F0, 10*log10(abs(H1)))'});

    figure('Name','Filter process', 'Color',[1 1 1])
    subplot(4,1,1)
    logabsH1=10*log10(abs(H1));
    plot(Ft,logabsH1, 'b', 'LineWidth',1.5);
    hold on;
    plot(Ft(10*log10(abs(H1))>HZPASS) , logabsH1( 10*log10(abs(H1))>HZPASS), 'og');
    % NOTE: 10*log10(abs(H1))>HZPASS is the set of samples that pass for
    % averaging TS for frequency band 1
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
    plot(Ft,TS1vec);
    plot(Ft,TS2vec,'r');
    plot(Ft,TS3vec);
    plot(Ft,TS4vec,'r');
    plot(Ft,TS5vec);
    title('TS by frequency bin')
end


%----------------------------------------------------------
%% Bscale
%----------------------------------------------------------
Bscale=1/mean(abs(H1));  % Scaling factor into efficient bandwidth


%----------------------------------------------------------
%% Mean TS by frequency bin
% % TO DO - IMPROVE THIS.
% % THIS INCLUDES TS VALUES AFFECTED BY THE FILTER EDGES.
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
% HZPASS = -0.1; % default 0.1 if using Ft(abs(H#))>HZMIN
fb1 = Ft(10*log10(abs(H1))>HZPASS);
fb2 = Ft(10*log10(abs(H2))>HZPASS);
fb3 = Ft(10*log10(abs(H3))>HZPASS);
fb4 = Ft(10*log10(abs(H4))>HZPASS);
fb5 = Ft(10*log10(abs(H5))>HZPASS);

if(doPLOT)
    figure('Name','4', 'Color',[1 1 1])
    clf
    hold on
    plot( fb1,TS1 , 'k.')
    plot( fb2,TS2 , 'k.')
    plot( fb3,TS3 , 'k.')
    plot( fb4,TS4 , 'k.')
    plot( fb5,TS5 , 'k.')
    hold on;
    tcol=[0 0.7 0];
    tyo = -0.5;
    text( mean(fb1),TS1+tyo, sprintf('%.1f, %.1f',mean(fb1),TS1) , 'Color',tcol, 'HorizontalAlignment','center')
    text( mean(fb2),TS2+tyo, sprintf('%.1f, %.1f',mean(fb2),TS2) , 'Color',tcol, 'HorizontalAlignment','center')
    text( mean(fb3),TS3+tyo, sprintf('%.1f, %.1f',mean(fb3),TS3) , 'Color',tcol, 'HorizontalAlignment','center')
    text( mean(fb4),TS4+tyo, sprintf('%.1f, %.1f',mean(fb4),TS4) , 'Color',tcol, 'HorizontalAlignment','center')
    text( mean(fb5),TS5+tyo, sprintf('%.1f, %.1f',mean(fb5),TS5) , 'Color',tcol, 'HorizontalAlignment','center')
    hold on
    plot(Ft,TS1vec);
    plot(Ft,TS2vec,'r');
    plot(Ft,TS3vec);
    plot(Ft,TS4vec,'r');
    plot(Ft,TS5vec);
    title('TS and mean(TS) by frequency bin')
end

%% Struct with data to return
TS_theor_binned.F_mean_bin   = [mean(fb1), mean(fb2), mean(fb3), mean(fb4), mean(fb5)];
TS_theor_binned.F_vec_bin        = [(fb1), (fb2), (fb3), (fb4), (fb5)];
TS_theor_binned.TS_theor_mean_bin = [TS1, TS2, TS3, TS4, TS5];
TS_theor_binned.TS_theor_vec_bin = [TS1vec, TS2vec, TS3vec, TS4vec, TS5vec];

fprintf('End binnedTS\n');
