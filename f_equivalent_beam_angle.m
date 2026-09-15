function [psi, Psi] = f_equivalent_beam_angle( k, a_tdcr) 
    % Equivalent beam angle (two-way) 
    %  psi(f) = 5.78/(ka)^2
    %  Psi(f) = 10*log10( psi(f)) = 10*log10( 5.78/(ka)^2 )
    %  Where a is the transducer active radius, a = 0.0435 m (43.5 mm);
    %  Wavenumber magnitude k = 2*pi ./ lambda;
    %  Wavelength, lambda = c ./ f;
    %  f = frequency (Hz);
    if( isempty(a_tdcr) )
        a_tdcr   = 0.0435;  % approx active radius of Sig100 transducer, (m)
    end
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
