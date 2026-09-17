%-------------------------------------------------------------------
%% merge text files 
%-------------------------------------------------------------------
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % merge_HDA_files.m    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % get HDA file list    
    % for each file
    %  read HDA file
    %  remove 1st line (header)
    %  count n lines
    %  remove last line
    %  write to merged file
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    clear all;
    close all;
    
    codedir = pwd; 
    
    %% OPTIONS
    
    doWRITEOUTFILE  =       true
    FILEIDSTR       = ''  %'_tracks_'
    
    defaultinpath = fullfile( pwd, 'Results');
    
    cd(defaultinpath);
    
    %% PROCESS
    % PROMPT for user to select files
    [filenames, filepath] = uigetfile(...
        {'*.*';'*.grd';'*.txt';'*.dat';'*.*'},'File Selector',...
        'MultiSelect','on');
    if(~iscell(filenames))
        filenames = {filenames};
    end
    % %filein=strcat(filepath, filenames);
    % % open
    % %fid=fopen(filein,'rt');
    %
    datadir = filepath;
    %cd(datadir);
    dir(datadir);
    

    %inits
    count = 0;
    %     myfiles = [];    
    firstheaderwritten = false;
    
    % outfile
    if(doWRITEOUTFILE)
        fnoutn = sprintf('_Merged-%s.txt',regexprep(FILEIDSTR,'_',''));
        fout = fopen(fnoutn,'w');
    end
    
    % get file list
    %files = dir(filepath)
    files = filenames;
    %[mf nf] = size(files);
    mf = length(files);
    for indxf = 1:mf
        % % %skip directories
        % % if(files(indxf).isdir)
        % %     continue
        % % end
        %show filename
%         fprintf('file(%d) of (%d)\n%s\n',...
%             indxf, mf, files(indxf).name);
%         % check for HDA files, not derivatives
%         fncur = files(indxf).name;
        %
        fncur = files{indxf};
        %
        % % if( ~contains(lower(fncur),FILEIDSTR) )
            %Proc file - Begin
            fprintf('Found %s file (%s)\n',FILEIDSTR,fncur);
            count = count+1;
            fprintf('merging file # %d.\n',count);
            %myfiles(count) = indxf;
            %
            fid = fopen(fncur);
            if(~firstheaderwritten)
                firstheader = fgetl(fid); %first line
                if(doWRITEOUTFILE)
                    fprintf(fout,'%s\n',firstheader);
                end
                firstheaderwritten = true;
            end
            
            fprintf(fout,'\n\nResults from file: %s\n\n', fncur);
            
            linecount = 0; %past 1st line header
            valid = true;
            while valid
                tline = fgetl(fid);
                if ~ischar(tline)
                    disp('not char, ...eof.');
                    valid = false;
                    continue
                end                
                linecount = linecount+1; %#of lines past header
                if(isempty(tline))
                    linecount = linecount-1;
                end
            end
            %
            frewind(fid);
            fgetl(fid);
            for i = 1:linecount-1
            % % DEBUGNLINES = 100
            % % for i = 1: DEBUGNLINES 
                thisline = fgetl(fid);
                if(~isempty(thisline))
                    if(doWRITEOUTFILE)
                        fprintf(fout,'%s\n',thisline);
                    end
                end             
            end    
            fclose(fid); %keep fout open and continue to write to it
        % %end %Proc file - End
        
    end %file iteration    
    fclose all;
    
    cd(codedir);