

%-------------------------------------------------------------------------
%% 2. Calculate 70 kHz CW Echogram, from Raw IQ data
%     and get stored 70 kHz amp echogram for comparison.
%-------------------------------------------------------------------------
[echogramiq70] = calcEchogram70kHz(Config, Data, WaterProp, []);

%----------------------------------------------------------------------
% Get 70 kHz CW Echogram, from recorded amplitude data (for comparison)
%   Must check for correct field name (differs based on conversion sw).
%----------------------------------------------------------------------
%if( isfield('Data', 'Echo370_0kHz_Amp70_0kHz') )
% % (Err) in isfield(S,'fieldname') do not quote the struct name, e.g. 'Data'
% % (Note) We operate with 70khz as Echo2. 
myechofieldname70 = 'Echo270_0kHz_Amp70_0kHz';
if( isfield(Data, myechofieldname70) ) 
    DESIREDECHOFOUND = true; 
    myfield = myechofieldname70;
else
    DESIREDECHOFOUND = false; 
    myfield = 'Echo2Bin1_70kHz_Amp70kHz';
    myechofieldname70 = myfield; 
end

if( ~ DESIREDECHOFOUND ) 
    % Print fieldnames
    names = fieldnames(Data);
    fprintf('Fieldnames from Data: \n');
    for i = 1:length(names)
        fprintf('(%3.3d) %s\n', i, names{i});
    end
end
    
if( DESIREDECHOFOUND )
    %ampecho = Data.Echo370_0kHz_Amp70_0kHz(1,:);
    ampecho70 = Data.(myfield(1,:));
else
    ampecho70 = Data.Echo2Bin1_70kHz_Amp70kHz(1,:);
end

if(OPTIONS.doPLOTNBFIGS70)
% Figures
    figure('Color',[1 1 1],'Name','Main Figure1');
    subplot(2,1,1); 
    plot( ampecho70 , 'b' );
    title('Amp70');
    subplot(2,1,2); 
    plot( echogramiq70(1,:) , 'r--');
    title('echogramiq70');

    figure('Color',[1 1 1],'Name','Main Figure2');
    plot( ampecho70(1,:),'k','LineWidth',3);
    hold on;
    plot( [ ampecho70; echogramiq70(1,:) ]');
    title('ampecho70; echogramiq70(1,:)')

    figure('Color',[1 1 1],'Name','Main Figure3');
    subplot(2,1,1);
    imagesc( ampecho70' );
    title('ampecho70');
    subplot(2,1,2);
    imagesc( echogramiq70' );
    title('echogramiq70');
end



%-------------------------------------------------------------------------
%% 3. Calculate 120 kHz CW Echogram, from Raw IQ data
%     and get stored 120 kHz amp echogram for comparison.
%-------------------------------------------------------------------------
[echogramiq120] = calcEchogram120kHz(Config, Data, WaterProp, []);

%if( isfield('Data', 'Echo370_0kHz_Amp70_0kHz') )
% % (Err) in isfield(S,'fieldname') do not quote the struct name, e.g. 'Data'
% % (Note) We operate with 70khz as Echo2. 
myechofieldname120 = 'Echo3120_0kHz_Amp120_0kHz';
DESIREDECHOFOUND = false;
if( isfield(Data, myechofieldname120) ) 
    DESIREDECHOFOUND = true; 
    myfield = myechofieldname120;
else
    DESIREDECHOFOUND = false; 
    myfield = 'Echo3Bin1_120kHz_Amp120kHz';
    myechofieldname120 = myfield; 
end

if( ~ DESIREDECHOFOUND ) 
    % Print fieldnames
    names = fieldnames(Data);
    fprintf('Fieldnames from Data: \n');
    for i = 1:length(names)
        fprintf('(%3.3d) %s\n', i, names{i});
    end
end

if( DESIREDECHOFOUND )
    %ampecho = Data.Echo3Bin1_120kHz_Amp120kHz(1,:);
    ampecho120 = Data.(myfield(1,:));
else
    ampecho120 = Data.Echo3Bin1_120kHz_Amp120kHz(1,:);
end    

if(OPTIONS.doPLOTNBFIGS120)
% Figure
    figure('Color',[1 1 1],'Name','Main Figure4');
    subplot(2,1,1);
    imagesc( ampecho120' );
    title('ampecho120');
    subplot(2,1,2);
    imagesc( echogramiq120' );
    title('echogramiq120');
end
    



%-------------------------------------------------------------------------
%% 4. Calculate Binned Broadband Echograms, from Raw IQ data
%-------------------------------------------------------------------------
% % [echogramiq90binned] = calcEchogram90kHzBinned(Config, Data, []);

NBINF = [] % default nbinf (number of frequency bins) is 5, defined in Config
% WaterProp.soundVel = 1500.0; % (m/s)
% WaterProp.temp     = 14.0;   % (C)
% WaterProp.sal      = 34.0;   % (psu)
    
% Struct Options should include values for: 
pcegOptions.retRawData = 1
pcegOptions.NBINF = []; % empty value here means use default (5) from Config

[echogramiq90fm,fEcho] = calcEchogram90kHzBinned(Config, Data, WaterProp, []);





%-------------------------------------------------------------------------
%% 5. Range data
%-------------------------------------------------------------------------
myrangefieldname = 'RawEcho1_90kHz_Range'  %'Echo270_0kHz_Range';  
DESIREDECHOFOUND = false;
if( isfield(Data, myrangefieldname) ) 
    DESIREDECHOFOUND = true; 
    myfield = myrangefieldname;
else
    DESIREDECHOFOUND = false; 
    myfield = 'Echo2Bin1_90kHz_Range';
    myrangefieldname = myfield; 
end
Range90fmAll = Data.(myrangefieldname);
Range90fm    = Range90fmAll(Range90fmAll > 0);

% Compare sizes of Range array and echogram
myfields = fieldnames(echogramiq90fm);
myfield  = myfields{1};
if( size(Range90fm,2) ~= size(echogramiq90fm.(myfield),2) )
   %% Force size of Range array to match echogram
   Range90fm = Range90fm(1: size(echogramiq90fm.(myfield),2) );   
end
    