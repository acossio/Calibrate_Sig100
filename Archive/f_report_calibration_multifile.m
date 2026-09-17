function [] = f_report_calibration(calibration,Config,doWRITEFILE)
% calibration is a struct produced by calibrateSig100
% controlled by calibrateSig100_invoke

%%
if(isempty(doWRITEFILE))
    doWRITEFILE=false;
end


%%
    calfields = fieldnames(calibration);
    for(indx = 1 : length(calfields))
        fprintf('%d %s\n',indx, calfields{indx});
        
        % Needed for report
        fEcho = calibration.(calfields{indx}).fEcho;
        TS_theor_binned = calibration.(calfields{indx}).TS_theor_binned;
        TS_meas_target_mean = calibration.(calfields{indx}).TS_meas_target_mean;
        
        if( doWRITEFILE )
            defname = ['CAL_' Config.File_file_prefix(1:21) '_' calfields{indx} '.txt'];
            doDEFAULTOFN=true;
            [fid,outfn] = f_openfile( defname , doDEFAULTOFN);
            if(isempty(fid))
                doWRITEFILE = false;
            end
        end
        
        %-------------------------------------------------------------------------
        %% CALIBRATION
        %   Calc TS measured for each freq band, and get d(TS_meas - TS_theor).
        %   TS meas == Echogram data from calcEchogram#.
        %   Store in struct calibration to return.
        %-------------------------------------------------------------------------
        
        %-------------------------------------------------------------------------
        % % Print filename prefix, from Config, and firmware version
        %-------------------------------------------------------------------------
        %fprintf('\n\n------------------------------------------------------------\n');
        strheader = sprintf('CALIBRATION RESULTS\n');
        %fprintf('------------------------------------------------------------\n');
        strfile = sprintf('File: %s\n',Config.File_file_prefix);
        strsernum = sprintf('Serial#: %d\n',Config.serialNumberDoppler);
        strfw   = sprintf('Firmware: %d\n',Config.fwVersionDoppler);
        fprintf('%s',strheader);
        fprintf('%s',strfile);
        fprintf('%s',strsernum);
        fprintf('%s',strfw);
        if( doWRITEFILE )
            fprintf(fid, '%s', strheader);
            fprintf(fid, '%s', strfile);
            fprintf(fid, '%s',strsernum);
            fprintf(fid, '%s', strfw);
        end
        
        % TS_theoretical
        for( indx = 1 : length(fEcho))
            strtstheor = sprintf('TS_theo(f=%.2f) = %.2f\n', fEcho(indx), TS_theor_binned.TS_theor_mean_bin(indx));
            fprintf('%s',strtstheor);
            if( doWRITEFILE )
                fprintf(fid, '%s', strtstheor);
            end
        end
        fprintf('\n');
        
        % meas
        for( indx = 1 : length(fEcho))
            strtsmeas = sprintf('TS_meas(f=%.2f) = %.2f\n', fEcho(indx), TS_meas_target_mean(indx));
            fprintf('%s',strtsmeas);
            if( doWRITEFILE )
                fprintf(fid, '%s', strtsmeas);
            end
        end
        fprintf('\n');
        
        % CALGAIN  = TS_meas - TS_theor;
        for( indx = 1 : length(fEcho))
            CALGAIN(indx) = TS_theor_binned.TS_theor_mean_bin(indx) - TS_meas_target_mean(indx);
            strcalgain = sprintf('CALGAIN(f=%.2f) = %.2f\n', fEcho(indx), CALGAIN(indx));
            fprintf('%s',strcalgain);
            if( doWRITEFILE )
                fprintf(fid, '%s',strcalgain);
            end
        end
        fprintf('------------------------------------------------------------\n');
        
            if(doWRITEFILE)
                fclose(fid);
            end
    end
    
end



function [fid,outfn] = f_openfile( defname , doDEFAULTOFN)
if(doDEFAULTOFN)
    filename = defname;
    try
        % Path to save figures
        pathname = fullfile( pwd, 'Results');
        if(~isdir(pathname))
            mkdir(pathname);
        end
    catch
        pathname = pwd;
    end
else % BE ANNOYING 
    % Prompt for file
    [filename, pathname] = uiputfile('*.txt', 'Save calibration results.',...
        defname);
end

outfn = fullfile(pathname, filename);

% If user presses cancel, don't save
if isequal(filename,0) || isequal(pathname,0)
    disp('User pressed cancel')
    fid=[];
    outfn=[];
else
    % Create file
    fid = fopen( outfn , 'w');
end

end % end function
