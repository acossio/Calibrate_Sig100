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