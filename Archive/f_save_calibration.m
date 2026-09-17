function [calibration_summary] = f_save_calibration(calibration,Config,fulloutfilename)
%-------------------------------------------------------------------------
% Saves summary of Sig100 calibration results to mat file
% 
% Requires 2 args: calibration, and Config
% Optional 3rd arg: full outfilename
%
% modified from: 
% f_report_calibration requires 3 args: 
%     calibration
%     Config (from ad2cp/mat data file)
%     doWRITETEXTFILE (bool)
%   calibration is a struct produced by calibrateSig100.m
%   calibrateSig100.m is initiated by calibrateSig100_invoke, & does: 
%    Calc TS measured for each freq band, and get d(TS_meas - TS_theor).
%    TS meas == Echogram data from calcEchogram#.
%    Store in struct calibration to return.
%   f_report_calibration is called by calibrateSig100_invoke
%    
% G. Cutter 2019-10
%-------------------------------------------------------------------------

%% OPTIONS
doWRITETEXTFILE=true;

%% INIT
calibration_summary = struct();


%% Prepare mat filename
if(isempty(fulloutfilename))
    %fncalsummary = 'calibration_summary_sig100.mat'
    % outfilename pattern: CAL_sn#SERNUM#_fw#FWVERSION#
    outpath = fullfile( pwd, 'Results');
    if(~isdir(outpath))
        mkdir(outpath);
    end
    
    %     serialNumber = Config.serialNumberDoppler;
    % strsernum = sprintf('Serial#: %d\n', serialNumber);
    % strfw   = sprintf('Firmware: %d\n', Config.fwVersionDoppler);
    % strfile = sprintf('File: %s\n', Config.File_file_prefix);
    ofnstr = sprintf('CAL_sn%d_fw%d.mat',...
        Config.serialNumberDoppler,...
        Config.fwVersionDoppler);
    
    fulloutfilename = fullfile(outpath,ofnstr);
end



%% PROCESS 

%%  Get fields of calibration data struct
calfields = fieldnames(calibration);

%%  Open file for writing summary results to text file
if( doWRITETEXTFILE )
    outfilename = ['CAL_' Config.File_file_prefix(1:21) '.txt'];
    doDEFAULTOFN=true;
    [fid,outfn] = f_openfile( outfilename , doDEFAULTOFN);
    if(isempty(fid))
        doWRITETEXTFILE = false;
    end
end



%-------------------------------------------------------------------------
%%  Print filename prefix, from Config, and firmware version
%-------------------------------------------------------------------------
%fprintf('\n\n--------------------------------------------------------\n');
strheader = sprintf('CALIBRATION RESULTS\n');
%fprintf('--------------------------------------------------------\n');
serialNumber = Config.serialNumberDoppler;
strsernum = sprintf('Serial#: %d\n', serialNumber);
strfw   = sprintf('Firmware: %d\n', Config.fwVersionDoppler);
strfile = sprintf('File: %s\n', Config.File_file_prefix);
fprintf('%s',strheader);
fprintf('%s',strsernum);
fprintf('%s',strfw);
fprintf('%s',strfile);
if( doWRITETEXTFILE )
    fprintf(fid, '%s', strheader);
    fprintf(fid, '%s', strsernum);
    fprintf(fid, '%s', strfw);
    fprintf(fid, '%s', strfile);
end

%% Add data to calibration_summary struct
snstr = sprintf('sn%d',serialNumber);
calibration_summary.(snstr).serialNumber = Config.serialNumberDoppler;
calibration_summary.(snstr).firmwareVersion = Config.fwVersionDoppler;
calibration_summary.(snstr).caldatafilename = Config.File_file_prefix;
% calibration_summary.(snstr).WaterProp = WaterProp;
% calibration_summary.(snstr).sphereProp = sphereProp;
% calibration_summary.(snstr).TS_theor_params = TS_theor_params;

%% Add data to calibration_summary struct
% calibration_summary.(snstr).caltable = caltable;
% create cell array, fill, then convert to table
calarray = {};


%% Init table index
it = 0;

%%  Step through calfields (one per op-mode) 
for(indx = 1 : length(calfields))
    
    opmodeid = calfields{indx};

    % report opmode id from fieldname
    strfieldid = sprintf('\nCal struct field %d of %d\n%s\n',indx, length(calfields), calfields{indx});
    fprintf('%s',strfieldid);
    if( doWRITETEXTFILE )
        fprintf(fid, '%s', strfieldid);
    end
        
    % Needed for report
    fEcho = calibration.(calfields{indx}).fEcho;
    TS_theor_binned = calibration.(calfields{indx}).TS_theor_binned;
    TS_meas_target_mean = calibration.(calfields{indx}).TS_meas_target_mean;
    
    
    % TS_theoretical
    for( indx = 1 : length(fEcho))
        strtstheor = sprintf('TS_theo(f=%.2f) = %.2f\n', fEcho(indx), TS_theor_binned.TS_theor_mean_bin(indx));
        fprintf('%s',strtstheor);
        if( doWRITETEXTFILE )
            fprintf(fid, '%s', strtstheor);
        end
        
        %% Add data to calibration_summary struct
        %calibration_summary.(opmodeid).fEcho(indx)    = fEcho(indx);
        %calibration_summary.(opmodeid).TS_theor(indx) = TS_theor_binned.TS_theor_mean_bin(indx); 
        % % calarray{ indx, 6} = TS_theor_binned.TS_theor_mean_bin(indx);
    end
    fprintf('\n');
    
    % TS_meas
    for( indx = 1 : length(fEcho))
        strtsmeas = sprintf('TS_meas(f=%.2f) = %.2f\n', fEcho(indx), TS_meas_target_mean(indx));
        fprintf('%s',strtsmeas);
        if( doWRITETEXTFILE )
            fprintf(fid, '%s', strtsmeas);
        end
        
        %% Add data to calibration_summary struct
        %calibration_summary.(opmodeid).TS_meas(indx) = TS_meas_target_mean(indx);
        % % calarray{ indx,  7} = TS_meas_target_mean(indx);
    end
    fprintf('\n');
    
    % CALGAIN  = TS_meas - TS_theor;
    for( indx = 1 : length(fEcho))
        CALGAIN(indx) = TS_theor_binned.TS_theor_mean_bin(indx) - TS_meas_target_mean(indx);
        strcalgain = sprintf('CALGAIN(f=%.2f) = %.2f\n', fEcho(indx), CALGAIN(indx));
        fprintf('%s',strcalgain);
        if( doWRITETEXTFILE )
            fprintf(fid, '%s',strcalgain);
        end
        
        %% Add data to calibration_summary struct
        %calibration_summary.(opmodeid).CALGAIN(indx) = CALGAIN(indx);
    end
    
    %% caltable (as cell array) 
    for( indx = 1 : length(fEcho))
        it = it+1;
        calarray{ it , 1} = Config.serialNumberDoppler;
        calarray{ it , 2} = Config.fwVersionDoppler;
        calarray{ it , 3} = opmodeid;
        calarray{ it , 4} = fEcho(indx);
        calarray{ it , 5} = CALGAIN(indx);
        calarray{ it , 6} = Config.File_file_prefix;
    end
    
    fprintf('--------------------------------------------------------\n');
    
end

calibration_summary.calheader = {...
    'serialNumberDoppler',...
    'fwVersionDoppler',...
    'opmodeid',...
    'fEcho',...
    'CALGAIN',...
    'File_file_prefix'}
calibration_summary.calheaderfmt = {'%d','%d','%s','%f','%f','%s'};
calibration_summary.calarray = calarray;
% table 
caltable = cell2table(calarray, 'VariableNames',calibration_summary.calheader);
calibration_summary.caltable = caltable;


%%  Close text file
if(doWRITETEXTFILE)
    fclose(fid);
end

%-------------------------------------------------------------------------
%%  Save calibration_summary to mat file
%-------------------------------------------------------------------------
save( fulloutfilename, 'calibration_summary','Config')
fprintf('Saved calibration summary to %s.\n',fulloutfilename);

end % end function f_save_calibration



function [fid,outfn] = f_openfile( defname , doDEFAULTOFN)
if(doDEFAULTOFN)
    filename = defname;
    try
        % Path to save results
        outpath = fullfile( pwd, 'Results');
        if(~isdir(outpath))
            mkdir(outpath);
        end
    catch
        outpath = pwd;
    end
else % BE ANNOYING
    % Prompt for file
    [filename, outpath] = uiputfile('*.txt', 'Save calibration results.',...
        defname);
end

outfn = fullfile(outpath, filename);

% If user presses cancel, don't save
if isequal(filename,0) || isequal(outpath,0)
    disp('User pressed cancel')
    fid=[];
    outfn=[];
else
    % Create file
    fid = fopen( outfn , 'w');
end

end % end function f_openfile
