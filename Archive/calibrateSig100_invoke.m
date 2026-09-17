% calibrateSig100_invoke
%
% Modified from load_data_plot_echogram.m
%
% Dependencies:
%     calcEchogram70kHz
%     calcEchogram120kHz
%     calcEchogram90kHzBinned
%     calibrateSig100
%     sphere_TS
%     f_theorTargetStrengthBinned
%
% S. Nylund, 2019-
% G. Cutter, 2019-09

clear; clc; close all;

format long g;

%-------------------------------------------------------------------------
%% OPTIONS
%-------------------------------------------------------------------------
doWRITEFILE              =       true;
OPTIONS.doPLOTNBFIGS120  = false;
OPTIONS.doPLOTNBFIGS70   = false;
OPTIONS.doACCUMULATESUMMARY =    true; 


%-------------------------------------------------------------------------
%% INIT
%-------------------------------------------------------------------------
DESIREDECHOFOUND = false;
calibration_accum = {};
calibration_table = table();

%-------------------------------------------------------------------------
%% CALIBRATION DATA
%    Load raw data from Sig100 converted from ad2cp to mat using MIDAS.
%    Choose/enter inpath and infilename below.
%    TO DO - make this UI selectable by user.
%-------------------------------------------------------------------------
% inpath = 'D:\NortekData\ADCPE-calib-20180904\100757_Data.247.00000'
% infn = 'Data.247.00000.ad2cp.00000.mat'

inpath = 'D:\dev\Sig100-Calibration-data\Sig100-calibration-2019\_data_mat_from_midas'

infnlist = {...
    'S100757A003_cal2208_0.ad2cp.00000.mat',
    'S100757A004_cal2212_1.ad2cp.00000.mat',
    'S100759A003_cal2208_0.ad2cp.00000.mat',
    'S100759A004_cal2212_1.ad2cp.00000.mat',
    'S100761A010_cal20190802.ad2cp.00000.mat',
    'S100761A011_cal_2212_1.ad2cp.00000.mat',
    'S100763A003_cal2208_0.ad2cp.00000.mat',
    'S100763A004_cal2212_1.ad2cp.00000.mat',
    'S100766A003_cal2208_0.ad2cp.00000.mat',
    'S100766A004_cal2212_1.ad2cp.00000.mat',
    'S100767A003_cal2208_0.ad2cp.00000.mat',
    'S100767A004_cal2212_1.ad2cp.00000.mat',
    'S101132A006_cal2208_1.ad2cp.00000.mat',
    'S101132A007_cal2212_1.ad2cp.00000.mat',
    'S101134A006_cal2208_1.ad2cp.00000.mat',
    'S101134A007_cal2212_1.ad2cp.00000.mat'
    }

% % NOTE, these files represent:
% % Calibration of 8 AMLR Nortek Sig100s using deployed firmware 2208_0 (for 6 off Cape Shirreff), and 2208_1 (for IMR-deployed two), and new firmware 2212_1.
% % Copies of data are in
% % D:\NortekData\SIG100-CALIBRATION\Sig100-calibration-2019
% % D:\dev\Sig100-Calibration-data\Sig100-calibration-2019
% % \\swc-storage3-s\AERD\Moorings\Sig100\Calibration\Sig100-calibration-2019

% change working directory
dir(inpath)


%-------------------------------------------------------------------------
%% Load data, define water and sphere, and process (calibrate)
%-------------------------------------------------------------------------
for(indf = 1 : length(infnlist))
    
    close all;
    
    infn = infnlist{indf};
    
    % 
    f_disp_dbstack_info()
    
    %---------------------------------------------------------------------
    %% Load infile
    %---------------------------------------------------------------------
    load(fullfile(inpath,infn))
    % check
    if(exist('Data','var'))
        fprintf('Data loaded\n\n');
    else
        fprintf('Data not found. Returning\n\n');
        return;
    end
    
    % % File should contain Config and Data structs
    % % TO DO - check for Config & Data.
    
        
    %---------------------------------------------------------------------
    %% Water & target sphere properties, and theoretical TS parameters
    %---------------------------------------------------------------------
    
    %% Define: Water Properties
    WaterProp.soundVel               = 1500.0; % (m/s)
    WaterProp.temp                   = 14.0;   % (C)
    WaterProp.sal                    = 34.0;   % (psu)
    WaterProp.density                = 1033.0; % kg/m^3
    
    %% Define: Target sphere properties
    sphereProp.sphereDiameter        = 25.4; % mm
    sphereProp.sphereType            = 'WC'; % 'WC' or 'CU' currently supported
    sphereProp.approxDist            =  4.6;  % m
    
    %% Define: Theoretical TS model parameters for 90 kHz FM mode 
    TS_theor_paramsFM.Ftminspec      =  68.4;  % kHz minimum frequency to model
    TS_theor_paramsFM.Ftmaxspec      = 113.4;  % kHz maximum frequency to model
    TS_theor_paramsFM.nF             = 500;    % number of frequencies to model
    TS_theor_paramsFM.sphereDiameter = sphereProp.sphereDiameter; %25.4; % sphere diameter (mm)
    TS_theor_paramsFM.sphereType     = sphereProp.sphereType; % sphere type, %'WC' or 'CU'
    TS_theor_paramsFM.HZPASS         = -0.1;   % avoids TS samples affected by filter edges
    TS_theor_paramsFM.soundVel       = WaterProp.soundVel;% 1500 m/s % water sound speed
    TS_theor_paramsFM.rhow           = WaterProp.density; % water density 1033.0
    TS_theor_paramsFM.doPLOTTSBINNED = false;

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
    
    %% Struct with combined TS theor params 
    TS_theor_params.TS_theor_paramsFM  = TS_theor_paramsFM;
    TS_theor_params.TS_theor_params70  = TS_theor_params70;
    TS_theor_params.TS_theor_params120 = TS_theor_params120;
    
    
    
    %---------------------------------------------------------------------
    %% CALIBRATION
    % % calibrateSig100 function call
    %---------------------------------------------------------------------
    f_disp_dbstack_info()
    fprintf('Calling calibrateSig100().\n');

close all    
    [spherePos,TS_theor_binned,calibration] = calibrateSig100(Config,Data,sphereProp,WaterProp,TS_theor_params);
    
    % % % % TS_theor_binned returned contains
    % % TS_theor_binned.TS_theor_binned90fm = TS_theor_binned90fm;
    % % TS_theor_binned.TS_theor_binned70   = TS_theor_binned70;
    % % TS_theor_binned.TS_theor_binned120  = TS_theor_binned120;
    
    
    %---------------------------------------------------------------------
    %% Calibration Results
    %   Call function to display results and optionally write to file
    %---------------------------------------------------------------------
    disp('calibration struct: '); disp(calibration.fm90);
    
    f_disp_dbstack_info()
    fprintf('Calling f_report_calibration() to write results.\n');
    
    % Call function to write calibration results to console and textfile (optional)
    f_report_calibration(calibration,Config,doWRITEFILE);
    
    
    % SAVE RESULTS TO MAT FILE
    outpath = fullfile( pwd, 'Results');
    if(~isdir(outpath))
        mkdir(outpath);
    end
    %ofn=fullfile(outpath,'calibration_summary_sig100.mat'); 
    %% Save calib summary to mat file, default filename ('CAL_ser#_fw#.mat')
    [calibration_summary_indiv] = f_save_calibration(calibration,Config,[]); % 

    %if(OPTIONS.doACCUMULATESUMMARY) 
    calibration_accum = [ calibration_accum ; calibration_summary_indiv.calarray];
    calibration_table = [ calibration_table ; calibration_summary_indiv.caltable];
    %end
    
end



%% Save combined calibration data table to mat file 
save( fullfile( outpath, 'Sig100_calibration_combined.mat'), 'calibration_accum');
save( fullfile( outpath, 'Sig100_calibration_table.mat'), 'calibration_table');

%% Write combined calibration data table to text file
ofncalcombined = 'Sig100_calibration_combined.txt';
doDEFAULTOFN = true;
[fidout,outfn] = f_openfile( ofncalcombined , doDEFAULTOFN);
hdr='';
fmt = calibration_summary_indiv.calheaderfmt;
for(indh = 1 : length(calibration_summary_indiv.calheader))
    hdr = sprintf('%s%s,', hdr, calibration_summary_indiv.calheader{indh});
end
hdr(length(hdr))=[];  %fprintf('HEADER:  %s\n',hdr);
fprintf(fidout,'%s\n',hdr);
rowstr = '';
for(indr = 1 : size(calibration_accum,1))
    %fprintf(fidout,'%s,',calibration_accum{indr,indc});
    rowstr = sprintf('%s%d,',  rowstr, calibration_accum{indr,1}); 
    rowstr = sprintf('%s%d,',  rowstr, calibration_accum{indr,2}); 
    rowstr = sprintf('%s%s,',  rowstr, calibration_accum{indr,3}); 
    rowstr = sprintf('%s%.2f,',rowstr, calibration_accum{indr,4}); 
    rowstr = sprintf('%s%.4f,',rowstr, calibration_accum{indr,5});
    rowstr = sprintf('%s%s',   rowstr, calibration_accum{indr,6}); 

    fprintf(fidout,'%s\n',rowstr); 
    rowstr='';
end
fclose(fidout);

fclose all;

% END
fprintf('\nFunction calibrateSig100_invoke completed.\n');



