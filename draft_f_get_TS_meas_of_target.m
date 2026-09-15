function [TS_meas_target] = f_get_TS_meas_of_target( fEcho_binned, TS_binned, Range, spherePos, doTARGOFFSET, TARGSAMPOFFSET, NCELLBUFF)

if(isempty(doTARGOFFSET))
    doTARGOFFSET=false;
end
if(isempty(NCELLBUFF))
    NCELLBUFF = 1;
end

fprintf('\n');
% loop through binned frequencies
for( indx = 1 : length(fEcho_binned))
    sfields = fieldnames(TS_binned);       % get fields of TS struct
    myfield  = sfields{indx};           % current field 
    TS_meas_band   = TS_binned.(myfield);  % TS_meas samples for this f-band
    if(doTARGOFFSET)                    % adjust for sphere pos from 90fm pulse compressed range
        targindx =  round(spherePos.index) + TARGSAMPOFFSET;
        TS_meas_band_itarget = TS_meas_band( : , targindx-NCELLBUFF : targindx+NCELLBUFF );
    else
        targindx =  round(spherePos.index);
        TS_meas_band_itarget = TS_meas_band( : , targindx-NCELLBUFF : targindx+NCELLBUFF );
    end
    TS_meas_target.(myfield) = TS_meas_band_itarget;

    %% DEBUGGING, Figure  ===============================
    matnames = {'TS_meas_band'} ;   
    f_plot_echogram_maxamp( TS_meas_band , Range , matnames);
    hold on;
    line( [-50, 50], [mean(spherePos.index) mean(spherePos.index)],...
        'Color','c','LineWidth',0.5, 'LineStyle','--');
    hold on;
    line( [-50, 50], [mean(spherePos.index)+TARGSAMPOFFSET  mean(spherePos.index)+TARGSAMPOFFSET ],...
        'Color','m','LineWidth',0.5);
    %====================================================

    TS_meas_target_q = quantile( TS_meas_target.(myfield), [0.95, 0.99, 0.999]);
    %fprintf('\n'); fprintf('%.1f\n',TS_meas_target_q); fprintf('\n');
    
    TS_meas_target_mean(indx) = 10*log10( mean(10.^(reshape(TS_meas_target_q,[],1)/10)));
    fprintf('(%s) TS_meas_target_mean = %.2f.\n', myfield, TS_meas_target_mean(indx));
end
fprintf('\n');


