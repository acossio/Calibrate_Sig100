function [TS, Sv, TStype, R] = f_TS_from_Sig100_amp(Config, Data,...
    pulse_length, echogramraw, fEcho, ABSORPTION, Range, soundVel, CALGAIN)

% Data is used for ranges
% TS is gotten from echogram data, by freq bin if from FM data.

%% 
doPULSEBINADJUST = true;

%% INIT
TS = echogramraw;
Sv = echogramraw;

if(isstruct(echogramraw))
    if(isempty(pulse_length) || length(fieldnames(echogramraw))>1 )  %|| isstruct(echogram)
        try
            pulse_length = Config.echo_transmitLength1 * 1e-3;
        catch
            if(fEcho==70000)                
                %pulse_length = 1e-3;  
                pulse_length = 1e-3 * echo_transmitLength2;
            end
            if(fEcho==120000)
                %pulse_length = 1e-3;  
                pulse_length = 1e-3 * echo_transmitLength3;
            end
            if(isarray(fEcho))
                pulse_length = 5e-3;  % NOT 1e-6  % pulse length (s)
            end
        end
    end
else
    if(isempty(pulse_length))
        pulse_length = 1e-3;          % !!!! UNSAFE !!!!
    end
end

if(isempty(CALGAIN))
    CALGAIN = 0.0;
    TStype = 'UNCALIBRATED';
end

%% PARAMS
try
    c = soundVel;
catch
    c = 1450;  %1500.0;         % soundspeed (m/s)
end

for( indx = 1 : length(fEcho))
    
    f_Hz     = fEcho(indx);  % frequency (Hz) e.g. 70000
    lambda   = c ./ f_Hz;         % Wavelength (m)
    k        = 2*pi ./ lambda; % Wavenumber magnitude
    a_tdcr   = 0.0435;  % radius of Sig100 transducer, (m)
    
    %% TO DO - CALCULATE ABSORPTION, OR PROVIDE ABS(F)     
    %alpha = 23.731e-3; % absorption (dB/m), from Anselie&McColm1998
    alpha = ABSORPTION(indx); % absorption (dB/m)
    
    if(isstruct(echogramraw))
        myfields = fieldnames(echogramraw);
        myfield  = myfields{indx};
    else
        myfield = [];
    end
    
    %% Equivalent beam angle
    %     %  psi(f) = 5.78/(ka)^2
    %     %  Psi(f) = 10*log10( psi(f)) = 10*log10( 5.78/(ka)^2 )
    %     %  Where a is the transducer radius, a = 0.0435 m (43.5 mm);
    %     %  Wavenumber magnitude k = 2*pi ./ lambda;
    %     %  Wavelength, lambda = c ./ f;
    %     %  f = frequency (Hz);
    %
    %     % % NO -- Psi      = 5.78 / ((k*a_tdcr)^2); NO
    %     psi      = 5.78 / ((k*a_tdcr)^2);
    %     Psi      = 10*log10( 5.78 / ((k*a_tdcr)^2));
    
    [psi, Psi] = f_equivalent_beam_angle( k, a_tdcr);
    
    fprintf('Equivalent beam angle\n');
    fprintf('psi = %.4f\n',psi);
    fprintf('Psi = %.4f\n',Psi);
    
    try
        PL = Config.echo_transmitPower1; % ? Can Power2, 3 be different?
    catch
        PL       = 0.0;  % Config.rawConfiguration: XMIT1=1.000,PL1=0.0
        fprintf('PL = 0.');
    end
    
    % %tau      = 1e-3;  % NOT 1e-6          % pulse length (s)
    tau = pulse_length;

    %% ADJUST TAU (PULSE_LENGTH) FOR FREQUENCY BAND BINNING
    if( doPULSEBINADJUST )
        if(ismatrix(fEcho))
            fprintf('fEcho ismatrix\n');
            tau = pulse_length / length(fEcho);
        end
    end
    
    if(isempty(myfield))
        Pr = echogramraw;
    else
        Pr = echogramraw.(myfield);  % Data.Echo2Bin1_70kHz_Amp70kHz
    end
    R        = repmat(Range, [size(Pr,1),1]);  % (m)

    
    %% Check sizes
    fprintf('sizes of R and Pr\n');
    fprintf('R:  %d\n',size(R));
    fprintf('Pr:  %d\n',size(Pr));
    
    R(R<=0)=0.01; % if R values are negative, causes TS to be complex
    
    % Generalized
    TS_chan   = Pr + 40*log10( R ) + (2*alpha* R) + PL + CALGAIN;
    
    %%ORIGINAL
    % Sv_chan   = Pr + 20*log10( R ) + (2*alpha* R) + PL - 10*log10(c * tau / 2) - Psi + CALGAIN;
    % % EXPERIMENTAL Sv
    % %Sv computation, following Cochrane et al. (2003) and Perrot et al. (2014)     
    % %NO % Sv_chan       = (TS_chan) - 10*log10(psi * c * tau / 2) + CALGAIN;   
    % % % Sv_chan       = (TS_chan) - 20*log10( R ) - 10*log10(psi * c * tau / 2) + CALGAIN; 

    Sv_chan   = Pr + 20*log10( R ) + (2*alpha* R) + PL - 10*log10(c * tau / 2) - Psi + CALGAIN;   



    %%
    R        = repmat(Range, [size(Pr,1),1]);  % (m)
    
    %% Figure
    matnames = {'Pr','TS'} ;
    f_plot_echograms( Pr, TS_chan , R , matnames);
    newfigname=[ 'Pr, TS ' sprintf('f = %.0f',f_Hz) ];
    set(gcf,'Name',newfigname);
    
    matnames = {'Pr','Sv'} ;
    f_plot_echograms( Pr, Sv_chan , R , matnames);
    newfigname=[ 'Pr, Sv ' sprintf('f = %.0f',f_Hz) ];
    set(gcf,'Name',newfigname);
    
    
    % 
    if(isstruct(echogramraw))
        TS = rmfield(TS,myfield);
        myfieldts = [myfield 'TS'];        
        TS.(myfieldts) = TS_chan;
        % % TS.Range       = R;
        
        Sv = rmfield(Sv,myfield);
        myfieldsv = [myfield 'Sv'];
        Sv.(myfieldsv) = Sv_chan;
        % % Sv.Range       = R;
    else
        TS = TS_chan;
        Sv = Sv_chan;
    end
end

end % end function f_TS...


%% Called functions
function [psi, Psi] = f_equivalent_beam_angle( k, a_tdcr)
    % Equivalent beam angle (two-way) 
    %  psi(f) = 5.78/(ka)^2
    %  Psi(f) = 10*log10( psi(f)) = 10*log10( 5.78/(ka)^2 )
    %  Where a is the transducer active radius, a = 0.0435 m (43.5 mm);
    %  Wavenumber magnitude k = 2*pi ./ lambda;
    %  Wavelength, lambda = c ./ f;
    %  f = frequency (Hz);
    a_tdcr   = 0.0435;  % approx active radius of Sig100 transducer, (m)
    % %Psi      = 5.78 / ((k*a_tdcr)^2);
    psi      = 5.78 / ((k*a_tdcr)^2);
    Psi      = 10*log10( 5.78 / ((k*a_tdcr)^2));
    
    fprintf('psi = %.5f (sr), Psi = %.2f (dB)\n',psi,Psi);
    
    
    %% alternative 
    % % Lurton, X. An introduction to underwater acoustics. 
    % % Table 5.1 
    % % Equivalent solid angle, for a disc transducer 
    % % ? = (4/pi)*(lambda/D)^2
    lambda = 2*pi/k; 
    D = 2*a_tdcr;
    psi_Lurton = (1.84/pi)*((lambda/D)^2);
    Psi_Lurton = 10*log10(psi_Lurton);
    fprintf( 'psi (%.4f) - psi_Lurton (%.4f) = %f\n',psi,psi_Lurton, psi-psi_Lurton);
    fprintf( 'Psi (%.4f) - Psi_Lurton (%.4f) = %f\n',Psi,Psi_Lurton, Psi-Psi_Lurton);
    disp('');
end


% %     %% figure ------------------------------------------------------
% %     figure('Color', [1 1 1], 'Position',figsize)
% %         NSUBR = 3;  NSUBC = 1; subn = 0;
% %         %
% %         subn = subn+1;
% %         subplot(NSUBR,NSUBC,subn)
% %         plot( R , mean(Pr), 'bx-');
% %         grid on;
% %         titstr1 = sprintf('%s 70 kHz, narrowband',fntit);
% %         titstr2 = 'mean Pr';
% %         titstr  = {titstr1;titstr2};
% %         title(titstr)
% %         xlabel('Range (m)')
% %         ylabel('Amp assummed to be Pr (dB)')
% %         %
% %         subn = subn+1;
% %         subplot(NSUBR,NSUBC,subn)
% %         gl = 0.5;
% %         plot( R , mean(TSuncomp), 'o-', 'Color',[gl gl gl]);
% %         grid on;
% %         hold on;
% %         plot( R , mean(TS), 'k.-');
% %         title('mean TS')
% %         legend('TS_{uncomp}','TS')
% %         hold on;
% %         plot( R_targ_070 , TS_targ, 'k*');
% %         hold on;
% %         xlabel('Range (m)')
% %         ylabel('TS (dB)')
% %         texRoff = 0.8;
% %         text( (R_targ_070 + texRoff) , (double(TS_targ)+0.2), sprintf('calgain %.1f',CALGAIN),...
% %             'Color','b', 'FontWeight','bold');
% %         %
% %         subn = subn+1;
% %         subplot(NSUBR,NSUBC,subn)
% %         plot( R , mean(Sv), 'x-', 'Color',[.2 .9 .3]);
% %         grid on;
% %         xlabel('Range (m)')
% %         ylabel('Sv (dB)')
% %
