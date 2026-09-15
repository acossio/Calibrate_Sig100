function [spherePos90fm,TS_theor_binned,calibration] = calibrateSig100(Config,Data,sphereProp,WaterProp,TS_theor_params)
% Calibrate Nortek Signature100 echosounder
% G. Cutter & S. Nylund, 2019


% % %% Load data for debugging in stand-alone mode
% % clear; close all; clc;
% % load('calibrateSig100wkspc.mat')


%% OPTIONS
DEBUGGING      = true;
doSHOWFIGS     = true;
doPC           = true;

DEBUGEXPERIMENTAL     = false;
doRAWSAMPLE90ECHOGRAM = true;

% OFFSETS
TARGSAMPOFFSET   = 43; 
doTARGOFFSET     = true;
% OFFSETDIST120   = -2.4; % (m) offset for sphere distance in 120
OFFSETDIST120    = 0; % no longer needed, it seems

%% GLOBALS & INITS
% water properties 
if( isempty(WaterProp) )
    WaterProp.soundVel             = 1500.0; % (m/s)
    WaterProp.temp                 = 14.0;   % (C)
    WaterProp.sal                  = 34.0;   % (psu)
    WaterProp.density              = 1033.0; % kg/m^3
end

% sphere properties
if( isempty(sphereProp) )
    sphereProp.sphereDiameter      = 25.4; % mm
    sphereProp.sphereType          = 'WC'; % 'WC' or 'CU' currently supported
    sphereProp.approxDist          = 4.6;  % m
end


if( isempty(TS_theor_params))
    fprintf('TS_theor_params is empty. Returning.\n');
    return;
end

doCALIBRATE90FM = true;
doCALIBRATE70   = true;
doCALIBRATE120  = true;
doRANGEBINNING  = true;

%
if(isfield( TS_theor_params,'TS_theor_paramsFM'))
    TS_theor_paramsFM  = TS_theor_params.TS_theor_paramsFM;
else
    doCALIBRATE90FM = false;
end
if(isfield(TS_theor_params,'TS_theor_params70'))
    TS_theor_params70  = TS_theor_params.TS_theor_params70;
else
    doCALIBRATE70 = false;
end
if(isfield(TS_theor_params,'TS_theor_params70'))
    TS_theor_params120 = TS_theor_params.TS_theor_params120;
else
    doCALIBRATE120 = false;
end

if( isempty(TS_theor_paramsFM) )
    TS_theor_paramsFM.Ftminspec      =  68.4;  % kHz minimum frequency to model
    TS_theor_paramsFM.Ftmaxspec      = 113.4;  % kHz maximum frequency to model
    TS_theor_paramsFM.nF             = 500;    % number of frequencies to model
    TS_theor_paramsFM.sphereDiameter = sphereProp.sphereDiameter; %25.4; % sphere diameter (mm)
    TS_theor_paramsFM.sphereType     = sphereProp.sphereType; % sphere type, %'WC' or 'CU'
    TS_theor_paramsFM.HZPASS         = -0.1;   % avoids TS samples affected by filter edges
    TS_theor_paramsFM.soundVel       = WaterProp.soundVel; %1500; % water sound speed
    TS_theor_paramsFM.rhow           = WaterProp.density; % water density 1033.0
    TS_theor_paramsFM.doPLOTTSBINNED = false;
end
if( isempty(TS_theor_params70))
    %% Define: Theoretical TS model parameters
    TS_theor_params70.Ftminspec      =  69.5;  % kHz minimum frequency to model
    TS_theor_params70.Ftmaxspec      =  70.5;  % kHz maximum frequency to model
    TS_theor_params70.nF             = 10;    % number of frequencies to model
    TS_theor_params70.sphereDiameter = sphereProp.sphereDiameter; %25.4; % sphere diameter (mm)
    TS_theor_params70.sphereType     = sphereProp.sphereType; % sphere type, %'WC' or 'CU'
    TS_theor_params70.HZPASS         = -0.1;   % avoids TS samples affected by filter edges
    TS_theor_params70.soundVel       = WaterProp.soundVel; %1500; % water sound speed
    TS_theor_params70.rhow           = WaterProp.density; % water density 1033.0
    TS_theor_params70.doPLOTTSBINNED = false;
end
if( isempty(TS_theor_params120))
    %% Define: Theoretical TS model parameters
    TS_theor_params120.Ftminspec      = 119.5;  % kHz minimum frequency to model
    TS_theor_params120.Ftmaxspec      = 120.5;  % kHz maximum frequency to model
    TS_theor_params120.nF             = 10;    % number of frequencies to model
    TS_theor_params120.sphereDiameter = sphereProp.sphereDiameter; %25.4; % sphere diameter (mm)
    TS_theor_params120.sphereType     = sphereProp.sphereType; % sphere type, %'WC' or 'CU'
    TS_theor_params120.HZPASS         = -0.1;   % avoids TS samples affected by filter edges
    TS_theor_params120.soundVel       = WaterProp.soundVel; %1500; % water sound speed
    TS_theor_params120.rhow           = WaterProp.density; % water density 1033.0
    TS_theor_params120.doPLOTTSBINNED = false;
end


%-------------------------------------------------------------------------
%% linear pulse-compressed amplitude and range, from raw IQ data
%-------------------------------------------------------------------------
if(doPC)
    [pcLin, rangePC] = PulseCompression(Data, Config, WaterProp);
else
    % [cwLin, r] = ProcRawCW(Data, Config);
    fprintf('Option to do pulse compression is false. Returning.\n');
    return;
end

Nsamp = size(pcLin,1); % Number of samples == number of pings

pcLog = 10*log10(pcLin);

assignin('base', 'rangePC', rangePC); 

% % % % Debugging, length of XMIT
% % % Z0=Data.RawEcho1_90kHz_DataI+j*Data.RawEcho1_90kHz_DataQ;
% % % Xmit0=Data.RawEcho1_90kHzTx_DataI+j*Data.RawEcho1_90kHzTx_DataQ;
% % % N_XMIT = length(Xmit0);



%-------------------------------------------------------------------------
%% Range, as recorded including Tx pulse
%-------------------------------------------------------------------------
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
% eval(['sampleRate = Config.echo_rawSampleRate' num2str(nEcho) ';'])
% eval(['nRawSamp   = Config.echo_nRawSamp'      num2str(nEcho) ';'])
Range = ['Data.RawEcho' num2str(nEcho) '_90kHz_Range'];



%-------------------------------------------------------------------------
%% Find range, index, and amplitude of sphere target
%-------------------------------------------------------------------------
f_disp_dbstack_info()
fprintf('Find range, index, and amplitude of sphere target.\n');  

% % approxDist = sphereProp.approxDist;
% % i=find((range>approxDist-0.5) & (range<approxDist+0.5));
% % spherePos.index = zeros(Nsamp,1);
% % spherePos.range = zeros(Nsamp,1);
% % 
% % for k=1:Nsamp
% %     indc = i(find(pcLin(k,i) == max((pcLin(k,i)))));
% %     %spherePos(k) = r(j);
% %     spherePos.index(k,1)  = indc;
% %     spherePos.range(k,1)  = range(indc);
% %     spherePos.ampLin(k,1) = pcLin(k,indc);
% % end
% % 
% % % spherpos.amp* are only used for plots
% % spherePos.ampLinmean = nanmean(  spherePos.ampLin );
% % spherePos.ampLog     = 10*log10( spherePos.ampLin );
% % spherePos.ampLogmean = 10*log10( spherePos.ampLinmean );
% % spherePos.rangemean  = nanmean(  spherePos.range );
% % 
% % fprintf('nanmean(spherePos.index) = %.1f (sample)\n', nanmean(spherePos.index) );
% % fprintf('nanmean(spherePos.range) = %.2f (m)\n', nanmean(spherePos.range) );

%% Now, get sphere range and index by call to function f_find_spherepos
rangebuffer = 0.5; % meters
%[spherePos90fm] = f_find_spherepos( pcLin, range, sphereProp.approxDist, rangebuffer);
[spherePos90fm] = f_find_spherepos( Data, Config, pcLin, rangePC, sphereProp.approxDist, rangebuffer);



if(doSHOWFIGS)
    % Figures
    rowoffset = 30;
    rows2plot = floor(nanmean(spherePos90fm.index))-rowoffset : floor(nanmean(spherePos90fm.index))+rowoffset ;
    
    MSUB = 1;
    NSUB = 4;
    figure('Color',[1 1 1],'Name','(calibrateSig100)-Fig1. Sphere location.');
        subplot(MSUB,NSUB,1)
        imagesc( pcLin' );
        title('pcLin');
        subplot(MSUB,NSUB,2)
        imagesc( pcLog' );
        title('pcLog');
        
        subplot(MSUB,NSUB,3)
        plot( max(pcLin,1), [1:size(pcLog,2)], '.-k');  %max(pcLin)
        title('max(pcLin) by sample')
        set (gca,'YDir','reverse')
        ylim( [1, size(pcLog,2)] );
        
        hold on;
        plot( max(spherePos90fm.ampLin)  ,spherePos90fm.indexmean, 'dg','MarkerSize',12,'LineWidth',2);
        
        subplot(MSUB,NSUB,4)
        plot( mode(pcLog,1), rangePC, '.-k');
        title('mode(pcLog) by range')
        set (gca,'YDir','reverse')
        ylim( [0, max(rangePC)] );
        % sphere expected location
        hold on;
        plot( 10*log10(spherePos90fm.ampLinmean)    ,spherePos90fm.rangemean, 'og','MarkerSize',12,'LineWidth',2);
        text( 10*log10(spherePos90fm.ampLinmean+0.1),spherePos90fm.rangemean, 'target', 'color',[0, .8, 0]);
    
    MSUB = 3;
    NSUB = 1;
    figure('Color',[1 1 1],'Name','(calibrateSig100)-Fig2. Sphere amp.');
        subplot(MSUB,NSUB,1)
        plot( spherePos90fm.range , spherePos90fm.ampLin, '.-k');
        subplot(MSUB,NSUB,2)
        h1 = histogram(spherePos90fm.ampLin);
        h1.Normalization = 'probability';
        h1.NumBins = 15;
        subplot(MSUB,NSUB,3)
        h2 = histogram(spherePos90fm.ampLog);
        h2.Normalization = 'probability';
        h2.NumBins = 15;
end

pcLin_quantiles = quantile( reshape(pcLin,[],1), [0.01, 0.1, 0.5, 0.9, 0.95, 0.99, 0.999]);
    fprintf('pcLin quantiles\n')
    fprintf('%.4f\t',pcLin_quantiles );
    fprintf('\n');


    

%-------------------------------------------------------------------------
%% Calculate theoretical TS of sphere for the broadband frequency bins
%-------------------------------------------------------------------------
f_disp_dbstack_info()
fprintf('Calculate theoretical TS.\n');  

% call modified 'binnedTargetStrength' code
% % TS_theor_paramsFM.Ftminspec      =  68.4;  % kHz minimum frequency to model
% % TS_theor_paramsFM.Ftmaxspec      = 113.4;  % kHz maximum frequency to model
% % TS_theor_paramsFM.nF             = 500;    % number of frequencies to model
% % TS_theor_paramsFM.sphereDiameter = 25.4;   % sphere diameter (mm)
% % TS_theor_paramsFM.sphereType     = 'WC';   % sphere type, %'WC' or 'CU'
% % TS_theor_paramsFM.HZPASS         = -0.1;   % avoids TS samples affected by filter edges
% % TS_theor_paramsFM.soundVel       = 1500;   % water sound speed
% % TS_theor_paramsFM.rhow           = 1033.0; % water density
% % doPLOTTSBINNED    = false;
doFBINNED          = true;

% [TS_theor_binned, TS_theor_params] = f_theorTargetStrengthBinned(TS_theor_params, doPLOTTSBINNED);
[TS_theor_binned90fm] = f_theorTargetStrengthBinned(TS_theor_paramsFM, TS_theor_paramsFM.doPLOTTSBINNED, doFBINNED);


%-------------------------------------------------------------------------
%% Calculate theoretical TS of sphere for the narrowband 70 kHz data
%-------------------------------------------------------------------------
%% Define: Theoretical TS model parameters
TS_theor_params70.Ftminspec      =  69.5;  % kHz minimum frequency to model
TS_theor_params70.Ftmaxspec      =  70.5;  % kHz maximum frequency to model
TS_theor_params70.nF             = 10;    % number of frequencies to model
TS_theor_params70.sphereDiameter = sphereProp.sphereDiameter; %25.4; % sphere diameter (mm)
TS_theor_params70.sphereType     = sphereProp.sphereType; % sphere type, %'WC' or 'CU'
TS_theor_params70.HZPASS         = -0.1;   % avoids TS samples affected by filter edges
TS_theor_params70.soundVel       = WaterProp.soundVel; %1500; % water sound speed
TS_theor_params70.rhow           = WaterProp.density; % water density 1033.0

doFBINNED          = false;

[TS_theor_binned70] = f_theorTargetStrengthBinned(TS_theor_params70, TS_theor_params70.doPLOTTSBINNED, doFBINNED);


%-------------------------------------------------------------------------
%% Calculate theoretical TS of sphere for the narrowband 120 kHz data
%-------------------------------------------------------------------------
%% Define: Theoretical TS model parameters
TS_theor_params120.Ftminspec      = 119.5;  % kHz minimum frequency to model
TS_theor_params120.Ftmaxspec      = 120.5;  % kHz maximum frequency to model
TS_theor_params120.nF             = 10;    % number of frequencies to model
TS_theor_params120.sphereDiameter = sphereProp.sphereDiameter; %25.4; % sphere diameter (mm)
TS_theor_params120.sphereType     = sphereProp.sphereType; % sphere type, %'WC' or 'CU'
TS_theor_params120.HZPASS         = -0.1;   % avoids TS samples affected by filter edges
TS_theor_params120.soundVel       = WaterProp.soundVel; %1500; % water sound speed
TS_theor_params120.rhow           = WaterProp.density; % water density 1033.0

doFBINNED          = false;

[TS_theor_binned120] = f_theorTargetStrengthBinned(TS_theor_params120, TS_theor_params120.doPLOTTSBINNED, doFBINNED);


%% TS_theor_binned data to return
TS_theor_binned.TS_theor_binned90fm = TS_theor_binned90fm;
TS_theor_binned.TS_theor_binned70   = TS_theor_binned70;
TS_theor_binned.TS_theor_binned120  = TS_theor_binned120;




%-------------------------------------------------------------------------
%% Calculate Raw-Sample Broadband Echograms, from Raw IQ data
%  Note - this can be done outside of this function and passed as arg.
%-------------------------------------------------------------------------
if( doRAWSAMPLE90ECHOGRAM ) 
    NBINF = [] % default nbinf (number of frequency bins) is 5, defined in Config

    % Struct Options should include values for: 
    pcegOptions.retRawData = 1  % 1 for testing 
    pcegOptions.NBINF = []; % empty value here means use default (5) from Config

    % Binned 90fm echogram
    %[echogramiq90fm,fEcho90fm,Range90fm,SampleBinned90fm] = calcEchogram90kHzBinned(Config, Data, WaterProp, pcegOptions);
    [echogramiq90fm,fEcho90fm,Range90fm,Sample90fm] = calcEchogram90kHzBinned(Config, Data, WaterProp, pcegOptions);



    %% DEBUGGING - 
    % % Compare 
    %  [echogram90bin1,echogram90bin2,echogram90bin3,echogram90bin4,echogram90bin5] = calcEchogram90kHzBinned_Orig(Config, Data);

end




%-------------------------------------------------------------------------
%% Calculate Range-Binned Broadband Echograms, from Raw IQ data
%  Note - this can be done outside of this function and passed as arg.
%-------------------------------------------------------------------------
NBINF = [] % default nbinf (number of frequency bins) is 5, defined in Config

% Struct Options should include values for: 
pcegOptions.retRawData = 0  % 1 for testing 
pcegOptions.NBINF = []; % empty value here means use default (5) from Config

% Binned 90fm echogram
%[echogramiq90fm,fEcho90fm,Range90fm,SampleBinned90fm] = calcEchogram90kHzBinned(Config, Data, WaterProp, pcegOptions);
[echogramiq90fmBinned,fEcho90fm,Range90fmBinned,SampleBinned90fm] = calcEchogram90kHzBinned(Config, Data, WaterProp, pcegOptions);


% % if( DEBUGEXPERIMENTAL )
% %  % Call: x_debug_experimentalranges
% % end



%% FUTURE - create more frequency bins, 
% % Note that this option is active and allows > 5 bins 
% % by setting pcegOptions.NBINF = 9; 
% % (empty pcegOptions.NBINF means use default (5) from Config) 
% % and then calling calcEchogram90kHzBinned 
% % [echogramiq90fm,fEcho,Range90fm] = calcEchogram90kHzBinned(Config, Data, WaterProp, pcegOptions);
% % calcEchogram90kHzBinned then produces echogramiq90fm with more bins, 
% % but they still represent very wide bands.



%-------------------------------------------------------------------------
%% Calculate 70 kHz CW Echogram, from Raw IQ data
%     and get stored 70 kHz amp echogram for comparison.
%-------------------------------------------------------------------------
% [echogramiq70] = calcEchogram70kHz(Config, Data, WaterProp, []);
[echogramiq70,fEcho70,Range70,pulse_length70] = calcEchogram70kHz(Config, Data, WaterProp, []);


%-------------------------------------------------------------------------
%% Calculate 120 kHz CW Echogram, from Raw IQ data
%   and get stored 120 kHz amp echogram for comparison.
%-------------------------------------------------------------------------
[echogramiq120,fEcho120,Range120,pulse_length120] = calcEchogram120kHz(Config, Data, WaterProp, []);




%-------------------------------------------------------------------------
%% Sphere position (spherePos) data for 90fmBinned, 70, & 120 
%   call function f_find_spherepos
%-------------------------------------------------------------------------


%% TO DO - DEBUG THIS
%% 90fm Binned
rangebuffer = 1.25; % meters % def 0.4

myfields = fieldnames(echogramiq90fmBinned);
myfield  = myfields{3}; % TO DO - fix this lazy use of 3rd echogram
echogram90x = echogramiq90fmBinned.(myfield);
[spherePos90fmBinned] = f_find_spherepos( Data, Config, echogram90x, Range90fmBinned, sphereProp.approxDist, rangebuffer);

% % %% DEBUGGING 
% % if(DEBUGEXPERIMENTAL)
% %     util_debugsphereposfor90fmBinned
% % end



%% 70cwBinned 
rangebuffer = 2.0; % meters

%[spherePos70] = f_find_spherepos( echogramiq70, Range70, sphereProp.approxDist, rangebuffer);
[spherePos70] = f_find_spherepos( Data, Config, echogramiq70, Range70, sphereProp.approxDist, rangebuffer);


%% 120cwBinned
% % OFFSETDIST120 = -2.4;
% % OFFSETDIST120 = 0;
approxDist120 = sphereProp.approxDist + OFFSETDIST120;
fprintf('\n[!] Warning: approxDist120=sphereProp.approxDist + %.2f m. [!]\n',OFFSETDIST120)
%[spherePos120] = f_find_spherepos( echogramiq120, Range120, approxDist120 , rangebuffer); 
[spherePos120] = f_find_spherepos( Data, Config, echogramiq120, Range120, approxDist120 , rangebuffer); 

% sphere position figures for 70 & 120
if(DEBUGGING)
    f_plot_echograms( echogramiq70, echogramiq70 , Range70 , {'70','70'} );
    hold on; 
    plot(  spherePos70.ampLinmean, spherePos70.rangemean, 'og','MarkerSize',12,'LineWidth',2)
    newfigname=[get(gcf,'Name') ' spherepos 70kHz'];
    set(gcf,'Name',newfigname);
    
    f_plot_echograms( echogramiq120, echogramiq120 , Range120 , {'120','120'} );
    hold on; 
    plot( spherePos120.ampLinmean, spherePos120.rangemean, 'og','MarkerSize',12,'LineWidth',2)
    newfigname=[get(gcf,'Name') ' spherepos 120kHz'];
    set(gcf,'Name',newfigname);
    
    f_plot_echograms( echogram90x, echogram90x ,  Range90fmBinned , {'90fmbinned','90fmbinned'} );
    hold on; 
    plot( spherePos90fmBinned.ampLinmean, spherePos90fmBinned.rangemean, 'og','MarkerSize',12,'LineWidth',2)
    newfigname=[get(gcf,'Name') ' spherepos 120kHz'];
    set(gcf,'Name',newfigname);
end


% %-------------------------------------------------------------------------
% %% DEBUGGING - assignin all vars
% %   call function
% %-------------------------------------------------------------------------
% if( DEBUGGING ) 
%     f_assignin_allvars;
%     
%     save('calibrateSig100wkspc.mat')
%     disp('L354. Saved workspace. Returning for debugging.');
% 
%     return;
% end




%-------------------------------------------------------------------------
%% Calculate Absorption, by frequency
%   use WaterProp
%-------------------------------------------------------------------------
ABSORPTION90FM  = [];
ABSORPTION70CW  = [];
ABSORPTION120CW = [];

% freq = frequency in Hz
% Z  = depth in km (yes, kilometers)
% T  = temperature in C
% S  = salinity in ppt
% pH = pH
absorp.Z = 0.001;   % (km)
absorp.T = WaterProp.temp;  % default 13.0;  % (deg C)
absorp.S = WaterProp.sal;   % default 33.0; (psu)
absorp.pH = 8.0; % Approx.

%% Absorption 90fm
fprintf('freq (kHz)\tabsorption (dB/m)\n');
for( indx = 1 : length(fEcho90fm))
    f_Hz     = fEcho90fm(indx);  % frequency (Hz) e.g. 70000
    absorp.freq = f_Hz;
    [alpha] = absorption(absorp.freq, absorp.Z, absorp.T, absorp.S, absorp.pH);
    ABSORPTION90FM(indx) = alpha * 1e-3;
    fprintf('%.1f\t%.4f\n', f_Hz*1e-3, ABSORPTION90FM(indx) );
end

fprintf('freq (kHz)\tabsorption (dB/m)\n');
for( indx = 1 : length(fEcho70))
    f_Hz     = fEcho70(indx);  % frequency (Hz) e.g. 70000
    absorp.freq = f_Hz;
    [alpha] = absorption(absorp.freq, absorp.Z, absorp.T, absorp.S, absorp.pH);
    ABSORPTION70CW(indx) = alpha * 1e-3;
    fprintf('%.1f\t%.4f\n', f_Hz*1e-3, ABSORPTION70CW(indx) );
end

fprintf('freq (kHz)\tabsorption (dB/m)\n');
for( indx = 1 : length(fEcho120))
    f_Hz     = fEcho120(indx);  % frequency (Hz) e.g. 70000
    absorp.freq = f_Hz;
    [alpha] = absorption(absorp.freq, absorp.Z, absorp.T, absorp.S, absorp.pH);
    ABSORPTION120CW(indx) = alpha * 1e-3;
    fprintf('%.1f\t%.4f\n', f_Hz*1e-3, ABSORPTION120CW(indx) );
end





%-------------------------------------------------------------------------
%% Convert echogram amplitude to target strength, TS_meas
%-------------------------------------------------------------------------
CALGAIN90fm =[];
CALGAIN70   =[];
CALGAIN120  =[];

%% TS90fmbinned (TS measured)
echogramraw  = echogramiq90fmBinned;
fEcho        = fEcho90fm; 

% %Range        = Range90fm;
Range        = Range90fmBinned;

soundVel     = WaterProp.soundVel; 
% pulse_length = 5e-3;
pulse_length = []; 

% [TS, Sv, TStype] = f_TS_from_Sig100_amp(Config, Data, echogram, fEcho, Range, CALGAIN)
[TS90fm, Sv90fm, TStype90fm, RangeTS90fm] = f_TS_from_Sig100_amp(Config, Data,...
    pulse_length, echogramraw, fEcho, ABSORPTION90FM, Range, soundVel, CALGAIN90fm);

    % rename figure
    set(gcf,'Name','(f_TS_from_Sig100_amp)-TS90fm');    

clear echogramraw fEcho Range pulse_length;

    %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    % % %DEBUGGING call: x_for_comparison_TS90fm_from_recorded.m
    %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX



%% TS70 (TS measured)
echogramraw  = echogramiq70;
fEcho        = fEcho70;
Range        = Range70;  % Range from calcEchogram70kHz
% pulse_length = 1e-3;
pulse_length = pulse_length70; 

% % [TS70, Sv70, TStype70, RangeTS70] = f_TS_from_Sig100_amp(Config, Data,...
% ERROR %     pulse_length, echogramraw, fEcho, ABSORPTION90FM, Range, soundVel, CALGAIN70);
[TS70, Sv70, TStype70, RangeTS70] = f_TS_from_Sig100_amp(Config, Data,...
    pulse_length, echogramraw, fEcho, ABSORPTION70CW , Range, soundVel, CALGAIN70);

    % rename figure
    set(gcf,'Name','(f_TS_from_Sig100_amp)-TS70');    
    
clear echogramraw fEcho Range pulse_length;



%% TS120 (TS measured)
echogramraw  = echogramiq120;
fEcho        = fEcho120;
Range        = Range120;  % Range from calcEchogram120kHz
% pulse_length = 1e-3;
pulse_length = pulse_length120; 

% % [TS120, Sv120, TStype120, RangeTS120] = f_TS_from_Sig100_amp(Config, Data,...
% ERROR %     pulse_length, echogramraw, fEcho, ABSORPTION90FM, Range, soundVel, CALGAIN120);
[TS120, Sv120, TStype120, RangeTS120] = f_TS_from_Sig100_amp(Config, Data,...
    pulse_length, echogramraw, fEcho, ABSORPTION120CW , Range, soundVel, CALGAIN120);	

    % rename figure
    set(gcf,'Name','(f_TS_from_Sig100_amp)-TS120');  
    
clear echogramraw fEcho Range pulse_length;




close all;



%-------------------------------------------------------------------------
%% Get TS_meas at samples of sphere position
%   TS_meas_binned from echogramiq90fm, echogramiq70, & echogramiq120
%   spherePos.index
%-------------------------------------------------------------------------
%% TS_meas_targ 90fm
% % doTARGOFFSET   = true;
% % TARGSAMPOFFSET = 43; 
NCELLBUFF      = 1;

% % %% TS_meas 90fm NOT BINNED
% % [TS_meas_target90fm, TS_meas_target_mean90fm] = f_get_TS_meas_of_target( fEcho90fm, TS90fm, Range90fm, spherePos90fm, doTARGOFFSET, TARGSAMPOFFSET, NCELLBUFF);
% %     newfigname=[get(gcf,'Name') ' 90fm (NOT BINNED)'];
% %     set(gcf,'Name',newfigname);

%% TS_meas_targ 90fm Binned
TARGSAMPOFFSETBINNED = 0; 
[TS_meas_target90fm, TS_meas_target_mean90fm] = f_get_TS_meas_of_target(...
    fEcho90fm, TS90fm, Range90fmBinned, spherePos90fmBinned, doTARGOFFSET, TARGSAMPOFFSETBINNED, NCELLBUFF);
    %
    newfigname=[get(gcf,'Name') ' 90fm'];
    set(gcf,'Name',newfigname);

   
%% TS_meas_targ 70
doTARGOFFSET   = true;
TARGSAMPOFFSET = 0; 
NCELLBUFF      = 1;

[TS_meas_target70, TS_meas_target_mean70] = f_get_TS_meas_of_target(...
    fEcho70, TS70, Range70, spherePos70, doTARGOFFSET, TARGSAMPOFFSET, NCELLBUFF);
    %
    newfigname=[get(gcf,'Name') ' 70 kHz'];
    set(gcf,'Name',newfigname);

%% TS_meas_targ 120
doTARGOFFSET   = true;
TARGSAMPOFFSET = 0; 
NCELLBUFF      = 1;

[TS_meas_target120, TS_meas_target_mean120] = f_get_TS_meas_of_target(...
    fEcho120, TS120, Range120, spherePos120, doTARGOFFSET, TARGSAMPOFFSET, NCELLBUFF);
    %     hold on; 
    %     plot(  spherePos120.ampLinmean, spherePos120.rangemean, 'og','MarkerSize',12,'LineWidth',2)    
    newfigname=[get(gcf,'Name') ' 120 kHz'];
    set(gcf,'Name',newfigname);
        
clear doTARGOFFSET TARGSAMPOFFSET;





%-------------------------------------------------------------------------    
%% CALIBRATION  
%   Calc TS measured for each freq band, and get d(TS_meas - TS_theor).
%   TS meas == Echogram data from calcEchogram#.
%   Store in struct calibration to return. 
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
% % Print filename prefix, from Config, and firmware version
%-------------------------------------------------------------------------
fprintf('\n\n------------------------------------------------------------\n');
fprintf('CALIBRATION RESULTS\n');
fprintf('------------------------------------------------------------\n');
fprintf('File: %s\n',Config.File_file_prefix); 
fprintf('Firmware: %d\n',Config.fwVersionDoppler);

if(doCALIBRATE90FM)    
    fprintf('90 kHz FM\n');
    % TS_theoretical
    for( indx = 1 : length(fEcho90fm))
        fprintf('TS_theo(f=%.2f) = %.2f\n',...
            fEcho90fm(indx),...
            TS_theor_binned.TS_theor_binned90fm.TS_theor_mean_bin(indx));
    end
    fprintf('\n');
    
    % CALGAIN  = TS_meas - TS_theor;
    for( indx = 1 : length(fEcho90fm))        

        TS_theor = TS_theor_binned.TS_theor_binned90fm.TS_theor_mean_bin(indx);
        
        TS_meas  = TS_meas_target_mean90fm(indx);
        
        CALGAIN90fm(indx) = TS_theor - TS_meas;
        
        fprintf('CALGAIN(f=%.2f) = %.2f\n', fEcho90fm(indx), CALGAIN90fm(indx));        
        clear TS_theor TS_meas;
    end
end

if(doCALIBRATE70)
    fprintf('70 kHz\n');
    % TS_theoretical
    for( indx = 1 : length(fEcho70))
        fprintf('TS_theo(f=%.2f) = %.2f\n',...
            fEcho70(indx),...
            TS_theor_binned.TS_theor_binned70.TS_theor_mean_bin(indx));
    end
    fprintf('\n');
    
    % CALGAIN  = TS_meas - TS_theor;
    for( indx = 1 : length(fEcho70))

        TS_theor = TS_theor_binned.TS_theor_binned70.TS_theor_mean_bin(indx);
        
        TS_meas  = TS_meas_target_mean70(indx);
        
        CALGAIN70(indx) = TS_theor - TS_meas;
        
        clear TS_theor TS_meas;
        fprintf('CALGAIN(f=%.2f) = %.2f\n', fEcho70(indx), CALGAIN70(indx));
    end
end

%% Cal 120
if(doCALIBRATE120)
    fprintf('120 kHz\n');
    % TS_theoretical
    for( indx = 1 : length(fEcho120))
        fprintf('TS_theo(f=%.2f) = %.2f\n',...
            fEcho120(indx),...
            TS_theor_binned.TS_theor_binned120.TS_theor_mean_bin(indx));
    end
    fprintf('\n');
    
    % CALGAIN  = TS_meas - TS_theor;
    for( indx = 1 : length(fEcho120))
        
        TS_theor = TS_theor_binned.TS_theor_binned120.TS_theor_mean_bin(indx);
        
        TS_meas  = TS_meas_target_mean120(indx);
        
        CALGAIN120(indx) = TS_theor - TS_meas;
        clear TS_theor TS_meas;
        fprintf('CALGAIN(f=%.2f) = %.2f\n', fEcho120(indx), CALGAIN120(indx));
    end
end



fprintf('------------------------------------------------------------\n');


% % Recall: TS_theor_binned is a struct with fields for each mode
% % % TS_theor_binned.TS_theor_binned90fm = TS_theor_binned90fm;
% % % TS_theor_binned.TS_theor_binned70   = TS_theor_binned70;
% % % TS_theor_binned.TS_theor_binned120  = TS_theor_binned120;


%% DATA TO RETURN FROM FUNCTION
calibration.fm90.CALGAIN = CALGAIN90fm;
calibration.fm90.TS_theor_binned = TS_theor_binned.TS_theor_binned90fm;
calibration.fm90.fEcho = fEcho90fm;
calibration.fm90.TS_meas_target = TS_meas_target90fm;
calibration.fm90.TS_meas_target_mean = TS_meas_target_mean90fm;

calibration.nb70.CALGAIN = CALGAIN70;
calibration.nb70.TS_theor_binned = TS_theor_binned.TS_theor_binned70;
calibration.nb70.fEcho = fEcho70;
calibration.nb70.TS_meas_target = TS_meas_target70;
calibration.nb70.TS_meas_target_mean = TS_meas_target_mean70;

calibration.nb120.CALGAIN = CALGAIN120;
calibration.nb120.TS_theor_binned = TS_theor_binned.TS_theor_binned120;
calibration.nb120.fEcho = fEcho120;
calibration.nb120.TS_meas_target = TS_meas_target120;
calibration.nb120.TS_meas_target_mean = TS_meas_target_mean120;


%-------------------------------------------------------------------------
%% Return: spherePos,TS_theor_binned,calibration
%-------------------------------------------------------------------------

fprintf('\n\n***************************************\n');
fprintf('Function calibrateSig100 completed.\n');
fprintf('***************************************\n\n');

% end % %// end function calibrateSig100



%% FUNCTIONS
% % %% function f_find_spherepos
% % function [spherePos] = f_find_spherepos( Data, Config, echogram, range, approxDist, rangebuffer) 
% % %function [spherePos] = f_find_spherepos( echogram, range, approxDist, rangebuffer) 
% %     range = range(1,:);
% %     Nsamp = size(echogram,1); % Number of samples == number of pings
% % 
% %     if(isempty(rangebuffer))
% %         rangebuffer = 0.5; % m
% %     end
% % 
% %     spherePos.index = zeros(Nsamp,1);
% %     spherePos.range = zeros(Nsamp,1);
% % 
% %     %-------------------------------------------------------------------------
% %     %% Find range, index, and amplitude of sphere target
% %     %-------------------------------------------------------------------------
% %     f_disp_dbstack_info()
% %     fprintf('Find range, index, and amplitude of sphere target.\n');  
% % 
% %     approxDist = approxDist;
% %     i=find((range>approxDist-rangebuffer) & (range<approxDist+rangebuffer));
% %     spherePos.index = zeros(Nsamp,1);
% %     spherePos.range = zeros(Nsamp,1);
% % 
% %     for k=1:Nsamp
% %         indc = i(find(echogram(k,i) == max((echogram(k,i)))));
% %         %spherePos(k) = r(j);
% %         spherePos.index(k,1)  = indc;
% %         spherePos.range(k,1)  = range(indc);
% %         spherePos.ampLin(k,1) = echogram(k,indc);
% %     end
% % 
% %     spherePos.indexmean  = nanmean(  spherePos.index );
% %     spherePos.ampLinmean = nanmean(  spherePos.ampLin );
% %     spherePos.rangemean  = nanmean(  spherePos.range );
% %     spherePos.ampf_find_sphereposLog     = 10*log10( spherePos.ampLin );
% %     spherePos.ampLogmean = 10*log10( spherePos.ampLinmean );
% % 
% %     fprintf('nanmean(spherePos.index) = %.1f (sample)\n', nanmean(spherePos.index) );
% %     fprintf('nanmean(spherePos.range) = %.2f (m)\n', nanmean(spherePos.range) );
% % end


% % %% function f_get_TS_meas_of_target
% % function [TS_meas_target,TS_meas_target_mean] = f_get_TS_meas_of_target( fEcho_binned, TS_binned, Range, spherePos, doTARGOFFSET, TARGSAMPOFFSET, NCELLBUFF)
% %     if(isempty(doTARGOFFSET))
% %         doTARGOFFSET=false;
% %     end
% %     if(isempty(NCELLBUFF))
% %         NCELLBUFF = 1;
% %     end
% % 
% %     fprintf('\n');
% %     % loop through binned frequencies
% %     TS_meas_target_mean = zeros(size(fEcho_binned,1));
% %     % % %     for( indx = 1 : length(fEcho_binned))
% %     % % %        
% %     % % %         if(isstruct(TS_binned))
% %     % % %             sfields = fieldnames(TS_binned);       % get fields of TS struct
% %     % % %             myfield  = sfields{indx};           % current field 
% %     % % %             TS_meas_band   = TS_binned.(myfield);  % TS_meas samples for this f-band
% %     % % %         else
% %     % % %             TS_meas_band   = TS_binned;
% %     % % %         end
% %     % % %         if(doTARGOFFSET)                    % adjust for sphere pos from 90fm pulse compressed range
% %     % % %             targindx =  round(spherePos.index) + TARGSAMPOFFSET;
% %     % % %             TS_meas_band_itarget = TS_meas_band( : , targindx-NCELLBUFF : targindx+NCELLBUFF );
% %     % % %         else
% %     % % %             targindx =  round(spherePos.index);
% %     % % %             TS_meas_band_itarget = TS_meas_band( : , targindx-NCELLBUFF : targindx+NCELLBUFF );
% %     % % %         end
% %     % % %         if(isstruct(TS_binned))
% %     % % %             TS_meas_target.(myfield) = TS_meas_band_itarget;
% %     % % %         else
% %     % % %             TS_meas_target  = TS_meas_band_itarget;
% %     % % %         end
% %     % % % 
% %     % % %         if(isstruct(TS_binned))
% %     % % %             TS_meas_target_q = quantile( TS_meas_target.(myfield), [0.95, 0.99, 0.999]);
% %     % % %         else
% %     % % %             TS_meas_target_q = quantile( TS_meas_target, [0.95, 0.99, 0.999]);
% %     % % %         end
% %     % % %         TS_meas_target_mean(indx) = 10*log10( mean(10.^(reshape(TS_meas_target_q,[],1)/10)));
% %     % % %         fprintf('(findex %d) TS_meas_target_mean = %.2f.\n', indx, TS_meas_target_mean(indx));
% %     % % %         
% %     % % %         %% Figure  ==========================================      
% %     % % %         matnames = {'TS_meas_band'} ;   
% %     % % %         f_plot_echogram_maxamp( TS_meas_band , Range , matnames);
% %     % % %         hold on;
% %     % % %         plot( mean(TS_meas_band(:,mean(spherePos.index))), mean(Range(mode(spherePos.index))),...
% %     % % %             'dm','MarkerSize',10,'LineWidth',1.1);
% %     % % %         hold on;
% %     % % %         % plot with NO OFFSET
% %     % % %         hold on;
% %     % % %         plot( TS_meas_target_mean(indx) , mean(Range(mode(spherePos.index)+0)),...
% %     % % %             'xr','MarkerSize',10,'LineWidth',1.1);        
% %     % % %         % plot with TARGETOFFSET  
% %     % % %         hold on;
% %     % % %         plot( TS_meas_target_mean(indx) , mean(Range(mode(spherePos.index)+TARGSAMPOFFSET)),...
% %     % % %             'og','MarkerSize',10,'LineWidth',1.5);    
% %     % % % 
% %     % % %         newfigname=[get(gcf,'Name') ' (f_get_TS_meas)'];
% %     % % %         set(gcf,'Name',newfigname);
% %     % % %         %====================================================
% %     % % %     end
% %     for( indf = 1 : length(fEcho_binned))
% %        
% %         if(isstruct(TS_binned))
% %             sfields = fieldnames(TS_binned);       % get fields of TS struct
% %             myfield  = sfields{indf};           % current field 
% %             TS_meas_band   = TS_binned.(myfield);  % TS_meas samples for this f-band
% %         else
% %             TS_meas_band   = TS_binned;
% %         end
% %         if(doTARGOFFSET)                    % adjust for sphere pos from 90fm pulse compressed range
% %             targindx =  round(spherePos.index) + TARGSAMPOFFSET;
% %             TS_meas_band_itarget = TS_meas_band( : , targindx-NCELLBUFF : targindx+NCELLBUFF );
% %         else
% %             targindx =  round(spherePos.index);
% %             TS_meas_band_itarget = TS_meas_band( : , targindx-NCELLBUFF : targindx+NCELLBUFF );
% %         end
% %         if(isstruct(TS_binned))
% %             TS_meas_target.(myfield) = TS_meas_band_itarget;
% %         else
% %             TS_meas_target  = TS_meas_band_itarget;
% %         end
% % 
% %         if(isstruct(TS_binned))
% %             TS_meas_target_q = quantile( TS_meas_target.(myfield), [0.95, 0.99, 0.999]);
% %         else
% %             TS_meas_target_q = quantile( TS_meas_target, [0.95, 0.99, 0.999]);
% %         end
% %         TS_meas_target_mean(indf) = 10*log10( mean(10.^(reshape(TS_meas_target_q,[],1)/10)));
% %         fprintf('(findex %d) TS_meas_target_mean = %.2f.\n', indf, TS_meas_target_mean(indf));
% %         
% %         %% Figure  ==========================================      
% %         matnames = {'TS_meas_band'} ;   
% %         f_plot_echogram_maxamp( TS_meas_band , Range , matnames);
% %         %
% %         % plot with NO OFFSET
% %         hold on;
% %         plot( mean(TS_meas_band(:,mode(spherePos.index))), mean(Range(mode(spherePos.index))),...
% %             'om','MarkerSize',10,'LineWidth',0.8); 
% %         plot( mean(TS_meas_band(:,mode(spherePos.index))), mean(Range(mode(spherePos.index))),...
% %             'xm','MarkerSize',10,'LineWidth',0.8); 
% %         hold on;
% % %         plot( TS_meas_target_mean(indf) , mean(Range(mode(spherePos.index)+0)),...
% % %             'xm','MarkerSize',10,'LineWidth',0.8);
% %         %
% %         % plot with TARGETOFFSET  
% %         hold on;
% %         plot( TS_meas_target_mean(indf) , mean(Range(mode(spherePos.index)+TARGSAMPOFFSET)),...
% %             'og','MarkerSize',10,'LineWidth',1.2);    
% % 
% %         newfigname=[get(gcf,'Name') ' (f_get_TS_meas)'];
% %         set(gcf,'Name',newfigname);
% %         %====================================================
% %     end
% %     fprintf('\n');
% % end
