%x_for_comparison_TS90fm_from_recorded.m 
%% FOR COMPARISON --- TS90fm NOT FROM RAW --- 
echogramBin1  = Data.Echo173_8kHz_Amp73_8kHz;
fEcho        = fEcho90fm(1); 
RangeBin1        = Data.Echo173_8kHz_Range;
soundVel     = WaterProp.soundVel; 
% pulse_length = 5e-3;
pulse_length = []; 

% [TS, Sv, TStype] = f_TS_from_Sig100_amp(Config, Data, echogram, fEcho, Range, CALGAIN)
[TS90fmBin1, Sv90fmBin1, TStype90fmBin1, RangeTS90fmBin1] = f_TS_from_Sig100_amp(Config, Data,...
    pulse_length, echogramBin1, fEcho, ABSORPTION90FM, RangeBin1, soundVel, CALGAIN90fm);

    % rename figure
    set(gcf,'Name','(f_TS_from_Sig100_amp)-TS90fm');    

clear echogramraw fEcho Range pulse_length;

% % % % %
sfields = fieldnames(TS90fm);       % get fields of TS struct
myfield  = sfields{1};
disp('size TS90fm.(myfield)')
size(TS90fm.(myfield))
disp('size TS90fmBin1')
size(TS90fmBin1)
% figures
% % f_plot_echograms2ranges( TS90fm.(myfield), TS90fmBin1 , Range90fm, RangeBin1 , {'TS.fromBin1RawIQ','TS.Echo173 8kHz Amp73 8kHz'} );
f_plot_echograms2ranges( TS90fm.(myfield), TS90fmBin1 , [], [] , {'TS.fromBin1RawIQ','TS.Echo173 8kHz Amp73 8kHz'} );