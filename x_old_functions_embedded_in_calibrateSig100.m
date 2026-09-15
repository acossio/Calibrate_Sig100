%% FUNCTIONS
% % %% function f_find_spherepos
% % function [spherePos] = f_find_spherepos( Data, Config, echogram, range, approxDist, rangebuffer) 
% % %function [spherePos] = f_find_spherepos( echogram, range, approxDist, rangebuffer) 
% %     range = range(1,:);
% %     Nsamp = size(echogram,1); % Number of samples == number of pings
% % 
% %     if(isempty(rangebuffer))
% %         rangebuffer = 0.5; % m
% %     end
% % 
% %     spherePos.index = zeros(Nsamp,1);
% %     spherePos.range = zeros(Nsamp,1);
% % 
% %     %-------------------------------------------------------------------------
% %     %% Find range, index, and amplitude of sphere target
% %     %-------------------------------------------------------------------------
% %     f_disp_dbstack_info()
% %     fprintf('Find range, index, and amplitude of sphere target.\n');  
% % 
% %     approxDist = approxDist;
% %     i=find((range>approxDist-rangebuffer) & (range<approxDist+rangebuffer));
% %     spherePos.index = zeros(Nsamp,1);
% %     spherePos.range = zeros(Nsamp,1);
% % 
% %     for k=1:Nsamp
% %         indc = i(find(echogram(k,i) == max((echogram(k,i)))));
% %         %spherePos(k) = r(j);
% %         spherePos.index(k,1)  = indc;
% %         spherePos.range(k,1)  = range(indc);
% %         spherePos.ampLin(k,1) = echogram(k,indc);
% %     end
% % 
% %     spherePos.indexmean  = nanmean(  spherePos.index );
% %     spherePos.ampLinmean = nanmean(  spherePos.ampLin );
% %     spherePos.rangemean  = nanmean(  spherePos.range );
% %     spherePos.ampLog     = 10*log10( spherePos.ampLin );
% %     spherePos.ampLogmean = 10*log10( spherePos.ampLinmean );
% % 
% %     fprintf('nanmean(spherePos.index) = %.1f (sample)\n', nanmean(spherePos.index) );
% %     fprintf('nanmean(spherePos.range) = %.2f (m)\n', nanmean(spherePos.range) );
% % end


% % %% function f_get_TS_meas_of_target
% % function [TS_meas_target,TS_meas_target_mean] = f_get_TS_meas_of_target( fEcho_binned, TS_binned, Range, spherePos, doTARGOFFSET, TARGSAMPOFFSET, NCELLBUFF)
% %     if(isempty(doTARGOFFSET))
% %         doTARGOFFSET=false;
% %     end
% %     if(isempty(NCELLBUFF))
% %         NCELLBUFF = 1;
% %     end
% % 
% %     fprintf('\n');
% %     % loop through binned frequencies
% %     TS_meas_target_mean = zeros(size(fEcho_binned,1));
% %     % % %     for( indx = 1 : length(fEcho_binned))
% %     % % %        
% %     % % %         if(isstruct(TS_binned))
% %     % % %             sfields = fieldnames(TS_binned);       % get fields of TS struct
% %     % % %             myfield  = sfields{indx};           % current field 
% %     % % %             TS_meas_band   = TS_binned.(myfield);  % TS_meas samples for this f-band
% %     % % %         else
% %     % % %             TS_meas_band   = TS_binned;
% %     % % %         end
% %     % % %         if(doTARGOFFSET)                    % adjust for sphere pos from 90fm pulse compressed range
% %     % % %             targindx =  round(spherePos.index) + TARGSAMPOFFSET;
% %     % % %             TS_meas_band_itarget = TS_meas_band( : , targindx-NCELLBUFF : targindx+NCELLBUFF );
% %     % % %         else
% %     % % %             targindx =  round(spherePos.index);
% %     % % %             TS_meas_band_itarget = TS_meas_band( : , targindx-NCELLBUFF : targindx+NCELLBUFF );
% %     % % %         end
% %     % % %         if(isstruct(TS_binned))
% %     % % %             TS_meas_target.(myfield) = TS_meas_band_itarget;
% %     % % %         else
% %     % % %             TS_meas_target  = TS_meas_band_itarget;
% %     % % %         end
% %     % % % 
% %     % % %         if(isstruct(TS_binned))
% %     % % %             TS_meas_target_q = quantile( TS_meas_target.(myfield), [0.95, 0.99, 0.999]);
% %     % % %         else
% %     % % %             TS_meas_target_q = quantile( TS_meas_target, [0.95, 0.99, 0.999]);
% %     % % %         end
% %     % % %         TS_meas_target_mean(indx) = 10*log10( mean(10.^(reshape(TS_meas_target_q,[],1)/10)));
% %     % % %         fprintf('(findex %d) TS_meas_target_mean = %.2f.\n', indx, TS_meas_target_mean(indx));
% %     % % %         
% %     % % %         %% Figure  ==========================================      
% %     % % %         matnames = {'TS_meas_band'} ;   
% %     % % %         f_plot_echogram_maxamp( TS_meas_band , Range , matnames);
% %     % % %         hold on;
% %     % % %         plot( mean(TS_meas_band(:,mean(spherePos.index))), mean(Range(mode(spherePos.index))),...
% %     % % %             'dm','MarkerSize',10,'LineWidth',1.1);
% %     % % %         hold on;
% %     % % %         % plot with NO OFFSET
% %     % % %         hold on;
% %     % % %         plot( TS_meas_target_mean(indx) , mean(Range(mode(spherePos.index)+0)),...
% %     % % %             'xr','MarkerSize',10,'LineWidth',1.1);        
% %     % % %         % plot with TARGETOFFSET  
% %     % % %         hold on;
% %     % % %         plot( TS_meas_target_mean(indx) , mean(Range(mode(spherePos.index)+TARGSAMPOFFSET)),...
% %     % % %             'og','MarkerSize',10,'LineWidth',1.5);    
% %     % % % 
% %     % % %         newfigname=[get(gcf,'Name') ' (f_get_TS_meas)'];
% %     % % %         set(gcf,'Name',newfigname);
% %     % % %         %====================================================
% %     % % %     end
% %     for( indf = 1 : length(fEcho_binned))
% %        
% %         if(isstruct(TS_binned))
% %             sfields = fieldnames(TS_binned);       % get fields of TS struct
% %             myfield  = sfields{indf};           % current field 
% %             TS_meas_band   = TS_binned.(myfield);  % TS_meas samples for this f-band
% %         else
% %             TS_meas_band   = TS_binned;
% %         end
% %         if(doTARGOFFSET)                    % adjust for sphere pos from 90fm pulse compressed range
% %             targindx =  round(spherePos.index) + TARGSAMPOFFSET;
% %             TS_meas_band_itarget = TS_meas_band( : , targindx-NCELLBUFF : targindx+NCELLBUFF );
% %         else
% %             targindx =  round(spherePos.index);
% %             TS_meas_band_itarget = TS_meas_band( : , targindx-NCELLBUFF : targindx+NCELLBUFF );
% %         end
% %         if(isstruct(TS_binned))
% %             TS_meas_target.(myfield) = TS_meas_band_itarget;
% %         else
% %             TS_meas_target  = TS_meas_band_itarget;
% %         end
% % 
% %         if(isstruct(TS_binned))
% %             TS_meas_target_q = quantile( TS_meas_target.(myfield), [0.95, 0.99, 0.999]);
% %         else
% %             TS_meas_target_q = quantile( TS_meas_target, [0.95, 0.99, 0.999]);
% %         end
% %         TS_meas_target_mean(indf) = 10*log10( mean(10.^(reshape(TS_meas_target_q,[],1)/10)));
% %         fprintf('(findex %d) TS_meas_target_mean = %.2f.\n', indf, TS_meas_target_mean(indf));
% %         
% %         %% Figure  ==========================================      
% %         matnames = {'TS_meas_band'} ;   
% %         f_plot_echogram_maxamp( TS_meas_band , Range , matnames);
% %         %
% %         % plot with NO OFFSET
% %         hold on;
% %         plot( mean(TS_meas_band(:,mode(spherePos.index))), mean(Range(mode(spherePos.index))),...
% %             'om','MarkerSize',10,'LineWidth',0.8); 
% %         plot( mean(TS_meas_band(:,mode(spherePos.index))), mean(Range(mode(spherePos.index))),...
% %             'xm','MarkerSize',10,'LineWidth',0.8); 
% %         hold on;
% % %         plot( TS_meas_target_mean(indf) , mean(Range(mode(spherePos.index)+0)),...
% % %             'xm','MarkerSize',10,'LineWidth',0.8);
% %         %
% %         % plot with TARGETOFFSET  
% %         hold on;
% %         plot( TS_meas_target_mean(indf) , mean(Range(mode(spherePos.index)+TARGSAMPOFFSET)),...
% %             'og','MarkerSize',10,'LineWidth',1.2);    
% % 
% %         newfigname=[get(gcf,'Name') ' (f_get_TS_meas)'];
% %         set(gcf,'Name',newfigname);
% %         %====================================================
% %     end
% %     fprintf('\n');
% % end