function [] = f_disp_dbstack_info()

%% f_disp_dbstack_info
% % display DBSTACK INFO ~ 
% % Reports file and line number during CODE EXECUTION

% % Example syntax to call this function to get DBSTACK INFO & show line number 
% % f_disp_dbstack_info()


VERBOSE = false;

dbstk = dbstack;
if( length(dbstk) > 1) 
    INDX1 = 2;
else
    INDX1 = 1;
end

if(VERBOSE)
    fprintf('\ndbstack info: code-file and line number.\n');
end
for indx = INDX1 : length(dbstk) 
        fprintf('\nEXEC-LINE %d \tof EXEC-CODE <{ %s }>\n', dbstk(indx).line, dbstk(indx).file);
end
fprintf('\n');
