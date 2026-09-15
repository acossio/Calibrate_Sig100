% 
clear; clc; close all;

%% OPTIONS
DESIREDECHOFOUND = false;

%% load data
% %load Data.179.00001.ad2cp.00000.mat
inpath = 'D:\NortekData\ADCPE-calib-20180904\100757_Data.247.00000'
infn = 'Data.247.00000.ad2cp.00000.mat'
dir(inpath)

% load
load(fullfile(inpath,infn))
% check
if(exist('Data','var'))
    fprintf('Data loaded\n\n');
else
    fprintf('Data not found. Returning\n\n');
    return;
end

%%
[echogramiq] = calcEchogram70kHz(Config, Data);

if( isfield('Data', 'Echo370_0kHz_Amp70_0kHz') ) 
    DESIREDECHOFOUND = true; 
else
    DESIREDECHOFOUND = false; 
    myfield = 'Echo2Bin1_70kHz_Amp70kHz';
end

if( ~ DESIREDECHOFOUND ) 
    names = fieldnames(Data);
    for i = 1:length(names)
        fprintf('Field %s\n', names{i});
    end
end
    
if( DESIREDECHOFOUND )
    ampecho = Data.Echo370_0kHz_Amp70_0kHz(1,:);
else
    ampecho = Data.Echo2Bin1_70kHz_Amp70kHz(1,:);
end


%% plot
% %plot([Data.Echo370_0kHz_Amp70_0kHz(1,:); echogram(1,:)]');

figure('Color',[1 1 1])
subplot(2,1,1) 
plot( ampecho , 'b' );
title('Amp70')
subplot(2,1,2) 
plot( echogramiq(1,:) , 'r--');
title('echogramiq')

figure('Color',[1 1 1])
plot( [ ampecho; echogramiq(1,:) ]');

