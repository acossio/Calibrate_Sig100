%% function f_get_TS_meas_of_target
function [TS_meas_target,TS_meas_target_mean] = f_get_TS_meas_of_target(...
    fEcho_binned, TS_binned, Range, spherePos, doTARGOFFSET, TARGSAMPOFFSET, NCELLBUFF)

doINDEXWITHTX = false;
%%
if(doINDEXWITHTX)
    spherePosINDEX = spherePos.indexWithTx;
    fprintf('\n[!!!]\nf_get_TS_meas_of_target: using index (including Tx samples).\n');
else
    fprintf('\n[!!!]\nf_get_TS_meas_of_target: using index (not including Tx samples).\n');
    spherePosINDEX = spherePos.index; % index from PulseCompression
end

%%
if(isempty(doTARGOFFSET))
    doTARGOFFSET=false;
end
if(isempty(NCELLBUFF))
    NCELLBUFF = 1;
end

fprintf('\n');

%%
TS_meas_target_mean = zeros(size(fEcho_binned,1));

%% loop through binned frequencies
for( indf = 1 : length(fEcho_binned))
    
    if(isstruct(TS_binned))
        sfields = fieldnames(TS_binned);       % get fields of TS struct
        myfield  = sfields{indf};           % current field
        TS_meas_fband   = TS_binned.(myfield);  % TS_meas samples for this f-band
    else
        TS_meas_fband   = TS_binned;
    end
    if(doTARGOFFSET)              % adjust for sphere pos from 90fm pulse compressed range
        for(inds = 1 : size( TS_meas_fband,1 ))
            targindx =  round( spherePosINDEX(inds) ) + TARGSAMPOFFSET;
            COLS_TARG = targindx-NCELLBUFF : targindx+NCELLBUFF;
            %TS_meas_band_itarget(inds, 1:length(COLS_TARG) ) = TS_meas_band( : , COLS_TARG );
            TS_meas_band_itarget(inds, 1:length(COLS_TARG) ) = TS_meas_fband( inds , COLS_TARG );
        end
    else
        for(inds = 1 : size( TS_meas_fband,1 ))
            targindx =  round( spherePosINDEX(inds) );
            COLS_TARG = targindx-NCELLBUFF : targindx+NCELLBUFF;
            %TS_meas_band_itarget(inds, 1:length(COLS_TARG) ) = TS_meas_band( : , COLS_TARG );
            TS_meas_band_itarget(inds, 1:length(COLS_TARG) ) = TS_meas_fband( inds , COLS_TARG );
        end
    end
    if(isstruct(TS_binned))
        TS_meas_target.(myfield) = TS_meas_band_itarget;
    else
        TS_meas_target  = TS_meas_band_itarget;
    end
    
    if(isstruct(TS_binned))
        TS_meas_target_q = quantile( TS_meas_target.(myfield), [0.95, 0.99, 0.999]);
    else
        TS_meas_target_q = quantile( TS_meas_target, [0.95, 0.99, 0.999]);
    end
    %%
    %TS_meas_target_mean(indf) = 10*log10( mean(10.^(reshape(TS_meas_target_q,[],1)/10)));
    % %TS_meas_target_meanOLD(indf) = 10*log10( mean(10.^(reshape(TS_meas_target_q,[],1)/10)));
    sigmabs_meas_target_qOLD = 10.^(reshape( TS_meas_target_q,[],1)/10);
    TS_meas_target_meanOLD(indf) = 10*log10( mean( sigmabs_meas_target_qOLD ) );
    %%
    % Sven, 2020-01-08:
    % When we calculate the return signal from the reference target sphere, 
    % the return signal typically is distributed over three cells. 
    % I think we want to total returned energy when estimate the target strength 
    % and hence I suggest to modify line 63 in f_get_TS_meas_of_target.m 
    % to this line:  TS_meas_target_mean(indf) = 10*log10(mean(sum(10.^((TS_meas_target_q')/10))));
    %The target strength should increase when we consider all parts of 
    % the return signal, so the signal from the three cells/bins should 
    % be added (correctly in linear space) before we take the average. 
    % This will change the calibration values significantly.
    % %TS_meas_target_mean(indf) = 10*log10(mean(sum(10.^((TS_meas_target_q')/10))));
    sigmabs_meas_target_q = 10.^((TS_meas_target_q')/10);
    TS_meas_target_mean(indf) = 10*log10(mean( sum( sigmabs_meas_target_q ) ) );
    
    fprintf('(findex %d) TS_meas_target_mean = %.2f.\n', indf, TS_meas_target_mean(indf));
    
    %% Figure  ==========================================
    %matnames = {'TS_meas_band'} ;
    if( isstruct(TS_binned))
        matnames = {myfield;'TS_meas_band'};
    else
        matnames = { sprintf('%d',fEcho_binned); 'TS_meas_band'};
    end
    f_plot_echogram_maxamp( TS_meas_fband , Range , matnames);
    %
    % plot with NO OFFSET
    hold on;
    plot( mean(TS_meas_fband(:,mode( spherePosINDEX ))), mean(Range(mode( spherePosINDEX ))),...
        'om','MarkerSize',10,'LineWidth',0.8);
    plot( mean(TS_meas_fband(:,mode( spherePosINDEX ))), mean(Range(mode( spherePosINDEX ))),...
        'xm','MarkerSize',10,'LineWidth',0.8);

    % plot with TARGETOFFSET
    hold on;
    plot( TS_meas_target_mean(indf) , mean(Range(mode( spherePosINDEX )+TARGSAMPOFFSET)),...
        'og','MarkerSize',10,'LineWidth',1.2);

    newfigname=[get(gcf,'Name') ' (call by f_get_TS_meas)'];
    set(gcf,'Name',newfigname);
    disp('');
    %====================================================
end
fprintf('\n');
end