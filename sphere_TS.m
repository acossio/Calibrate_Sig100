function [freq, TS] = sphere_TS(varargin)
% SPHERE_TS             Calculate Target Strength of a standard sphere
%   [F, TS] = SPHERE_TS(F, C, D, TYPE, SAVE) returns the Target Strength
%   (TS) of a standard sphere with diameter D over the frequencies F and
%   sound speeds C.  D must be a single numeric value while F and C can be
%   either a vector or single value.  TYPE can be either WC or Cu and
%   designates the sphere parameters that will be used in the TS
%   calculation.  The optional SAVE parameter indicates if the data should
%   be saved (TRUE) or not (FALSE; default).  The user
%   will be prompted for the filename to save the comma-separated TS table.
%
%   [F, TS] = SPHERE_TS prompts the user for values of F, C, D, TYPE, and
%   SAVE to use for calculation the TS.
%
%   INPUTS
%       F = Single value or numeric array giving the frequencies in Hz
%       C = Single value or numeric array giving the soundspeeds (of water) in m/s
%       D = Single numeric value giving the sphere diameter in mm
%       TYPE = String of either 'WC' or 'Cu' indicating the sphere
%              parameters to use
%       rhow = water density kg/m^3;
%       SAVE = Boolean value (1 or 0) indicating if the data should be
%              saved to .txt file.  1 is yes, 0 is no.  The default is 0.
%
%   OUTPUTS
%       F = The frequencies used for calculating TS.
%       TS = MxN matrix of Target Strength values.  M is the number of
%            sound speeds specified, while N is the number of frequencies
%            specified.
%
%   NOTES
%       The calculations used in this program are taken from equations in
%       the paper "The Theory of Solid Spheres as Sonar Calibration
%       Targets" by D.N. MacLennan (1981).

% Created by Josiah Renfree
% September 29, 2010
% Modified by G. Cutter, 2019-09

% clear all; close all; clc;

% Check inputs
if isequal(nargin, 0)      % If no inputs given
    
    % Prompt user for everything
    prompt = {'Frequencies (Hz):', 'Sound Speeds (m/s):' ...
        'Sphere diameters (mm):', 'Sphere Type (WC or Cu):', ...
        'Save? (1=yes, 0=no):'};
	name = 'TS processing parameters';
    numlines = 1;
    defaultanswer = {'[18 38 70 120 200].*1e3', '1450:5:1550', '38.1', ...
        'WC', '0'};
    answer = inputdlg(prompt,name,numlines,defaultanswer);
    
    freq = eval(answer{1});
    cw = eval(answer{2});
    spherediam = eval(answer{3});
    type = answer{4};
    saveflag = eval(answer{5});
    
    clear answer defaultanswer numlines name prompt
    
elseif isequal(nargin, 5)  % If everything but save info given
    
    freq = varargin{1};
    cw = varargin{2};
    spherediam = varargin{3};
    type = varargin{4};
    rhow = varargin{5};
    saveflag = 1;           % Default is to save data
    
elseif isequal(nargin, 6)  % If everything but save info given
    
    freq = varargin{1};
    cw = varargin{2};
    spherediam = varargin{3};
    type = varargin{4};
    rhow = varargin{5};
    saveflag = varargin{6};           % Default is to not save data

elseif ~isequal(nargin, 5) % If 0, 3, or 4 inputs not given, display error
    
    error('Incorrect number of inputs given')   % Give error
    
end
    
% Check inputs
if ~isnumeric(freq) || ~isnumeric(cw)
    error('Frequencies and sound speeds must be numeric')
elseif ~isnumeric(spherediam) || length(spherediam) ~= 1
    error('Diameter must be a single numeric value')
elseif ~isnumeric(saveflag) || ~isequal(saveflag,0) && ~isequal(saveflag,1)
    error('Save flag must be a single boolean value (0 or 1)')
elseif ~ischar(type) || ~strcmpi(type,'WC') && ~strcmpi(type,'Cu')
    error('Sphere type must be a string and equal to either WC or Cu')
end

%% Water parameters
% % NOTE: These should be calculated from water properties
if(isempty(rhow))
    rhow = 1033.0;    % water density (kg/m^3)
end
cw   = cw;        % sound speed (m/s)  
fprintf('[sphere_TS] WARNING. WATER PROPERTIES ARE NOT COMPUTED, \\rho = %.1f, c = %.1f.\n\n',rhow,cw);


%% Sphere parameters based on type
% % def materialProperties():
% %     """
% %     Provides sound speed and density values for selected sphere materials.
% %     
% %     Returns:
% %         A dictionary with keys containing the material name, and values being 
% %         another dictionary with keys 'rho1', 'c1', and 'c2' corresponding to
% %         density, transveral sound speed, and longitudinal sound speed 
% %         respectively. Units are kg/m^3, m/s, and m/s respectively.
% %     """
% %     
% %     return {'Tungsten carbide': {'c1': 6853.0, 'c2': 4171.0, 'rho1': 14900.0},
% %             'Copper':           {'c1': 4760.0, 'c2': 2288.5, 'rho1':  8947.0}, 
% %             'Stainless steel':  {'c1': 5610.0, 'c2': 3120.0, 'rho1':  7800.0},
% %             'Alumnium':         {'c1': 6260.0, 'c2': 3080.0, 'rho1':  2700.0}}
switch lower(type)
    case 'wc'
        c1 = 6853.0;          % longitudinal sound speed (m/s)
        c2 = 4171.0;          % transverse sound speed (m/s)
        rho1 = 14900.0;       % sphere density
        % rhow = 1030.0;         % water density
    case 'cu'
        c1 = 4760;          % longitudinal sound speed (m/s)
        c2 = 2288.5;        % transverse sound speed (m/s)
        rho1 = 8945;        % sphere density
        % rhow = 1030;         % water density
end

a = 1e-3*spherediam/2;               % Calculate sphere radius

% Cycle through sound speeds
TS = nan(length(cw), length(freq));         % Initialize TS variable
h = waitbar(0, 'Processing...');        % Create waitbar
for i = 1:length(cw)
    
    % Calculate variables that don't change with l
    k = 2*pi*freq/cw(i);                            % Wavenumber
    q = k*a;                                    % Circumference/wavelength
    q1 = q * cw(i) / c1;                         % Relative long. c
    q2 = q * cw(i) / c2;                         % Relative trans. c
    alpha = 2 .* rho1./rhow .* (c2./cw(i)).^2;    % Used in beta and B2 calc
    beta = rho1./rhow .* (c1./cw(i)).^2 - alpha;  % used in B2 calc
    
    % Cycle through l's
    buff = zeros(1,length(q));          % Create summation variable
    flag = 0;                           % Flag for exiting while loop
    l = 0;                              % Initialize l variable
    
    % Perform summation in equation 7 until the results for every frequency
    % result in NaN.
    while flag == 0
        
        % Compute variables in equations 6a to 6h
        A1 = 2.*l.*(l+1) .* (q1 .* j1(l,q1) - j(l,q1));
        A2 = (l.^2 + l - 2) .* j(l,q2) + q2.^2 .* j2(l,q2);
        B1 = q .* (A2.*q1.*j1(l,q1) - A1.*j(l,q2));
        B2 = A2.*q1.^2 .* (beta.*j(l,q1) - alpha.*j2(l,q1)) - ...
            A1.*alpha .* (j(l,q2) - q2.*j1(l,q2));
        nu = atan(-(B2.*j1(l,q) - B1.*j(l,q)) ./ ...
            (B2.*y1(l,q) - B1.*y(l,q)));
                
        % Find frequency indices which have a nu value that is not a NaN
        idx = ~isnan(nu);
        
        % If nu for every frequency is NaN, then stop summation
        if isequal(sum(idx),0)
            flag = 1;                   % Set flag to 1 to exit while loop
        end
        
        % Perform summation from equation 7.  This will only perform the
        % summation for frequencies which continue to have nu values that
        % are real, and not a NaN.
        buff(idx) = buff(idx) + (-1).^l .* (2.*l+1) .* sin(nu(idx)) .* ...
            exp(1i.*nu(idx));
        
        l = l + 1;                      % Increment l by 1
        
        % Clear variables defined in next loop iteration
        clear idx nu P B2 B1 A2 A1
    end
    
    f_inf = -2./q .* buff;                  % Calculate Equation 7
    sigma = pi .* a.^2 .* abs(f_inf).^2;    % Calculate Equation 8
    TS(i,:) = 10*log10(sigma./(4*pi));      % Calculate TS (Equation 9)
    
    waitbar(i/length(cw), h)                 % update waitbar
    
    % Clear variables defined in next sound speed loop iteration
    clear sigma f_inf l flag buff q2 q1 q k
end
close(h)                                    % clear waitbar

% If user selected to save data
if saveflag
    
    % Prompt user for save filename
    [filename, pathname] = uiputfile('*.txt', 'Save TS as');
    
    % If user presses cancel, don't save
    if isequal(filename,0) || isequal(pathname,0)
       disp('User pressed cancel')
       
    % Else save data
    else
    
        % Create file
        fid = fopen(fullfile(pathname, filename), 'w');
        
        % Write header
        pat = repmat(',%.2f', 1, length(freq));
        fprintf(fid, strcat('%s',pat,'\n'), 'Soundspeed(m/s)', freq/1e3);
        
        % Write TS data
        temp = [cw; TS'];
        fprintf(fid, strcat('%.2f',pat,'\n'), temp);
        
        fclose(fid);
        
    end
else
    % Write header
        pat = repmat(',%.2f', 1, length(freq));
        fprintf(strcat('%s',pat,'\n'), 'Soundspeed(m/s)', freq/1e3);
        
    % Write TS data
        temp = [cw; TS'];
        fprintf(strcat('%.2f',pat,'\n'), temp);
end

fprintf('\nFunction sphere_TS completed.\n');


function answer = j(n,x)
% Spherical bessel function of the first order

answer = besselj(n+.5, x) .* sqrt(pi./(2*x));

function answer = y(n,x)
% Spherical bessel function of the second order

answer = bessely(n+.5, x) .* sqrt(pi./(2*x));

function answer = j1(n,x)
% First derivative of spherical bessel function of the first order

answer = (j(n-1,x) - j(n+1,x))./2 - j(n,x)./(2.*x);

function answer = j2(n,x)
% Second derivative of spherical bessel function of the first order

answer = (x.^2.*j(n-2,x) - 2.*x.^2.*j(n,x) + x.^2.*j(n+2,x) - ...
    2.*x.*j(n-1,x) + 2.*x.*j(n+1,x) + 3.*j(n,x)) ./ (4.*x.^2);

function answer = y1(n,x)
% First derivative of spherical bessel function of the second order

answer = (y(n-1,x) - y(n+1,x))./2 - y(n,x)./(2.*x);
