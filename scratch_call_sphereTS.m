%-------------------------------------------------------------------------
%% Calculate theoretical TS of sphere
%-------------------------------------------------------------------------
Freq           = [65.0 : 0.1 : 130.0]*1000;  % frequency (Hz)
Cw             = 1500.0;  % sound speed (m/s)
sphere_diam_mm = sphereDiameter %25.4; % sphere diameter (mm)
sphereType     = 'WC';  % sphere material
doSAVE         = 0;  % save TS results or not
[f, TS_theor]  = sphere_TS(Freq, Cw, sphere_diam_mm, sphereType, doSAVE);
f_kHz = f/1000;

figure('Color',[1 1 1],'Name','calibrateSig100 Figure5')
    plot(f_kHz,TS_theor,'.k')
    xlabel('f (kHz)');
    ylabel('TS_{theor}');
    title('TS_{theor}(f)');