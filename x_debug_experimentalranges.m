%x_debug_experimentalranges.m

if( DEBUGEXPERIMENTAL )
    fprintf('DEBUGEXPERIMENTAL, CALLING XcalcEchogram90kHzBinned\n')
    
    [echogramiq90fm,fEcho90fm,Range90fm,SampleBinned90fm] = XcalcEchogram90kHzBinned(...
        Config, Data, WaterProp, pcegOptions, spherePos90fm);

    
    %%====================================================EXPERIMENTAL
    if(length(SampleBinned90fm) ~= Config.echo_numBins)
        doRANGEBINNING = false;
    end
    
    if(doRANGEBINNING)
        spherePos90fmNOTBINNED = spherePos90fm;
        rangebuffer = 0.8; % meters
        % [spherePos90fm] = f_find_spherepos( pcLin, range, sphereProp.approxDist, rangebuffer);
        % [spherePos90fm] = f_find_spherepos( Data, Config, pcLin, range, sphereProp.approxDist, rangebuffer);
        
        myfields = fieldnames(echogramiq90fm);
        myfield  = myfields{1};
        Echogram90findsphere = echogramiq90fm.(myfield);
        %[spherePos90fm] = f_find_spherepos( Echogram90findsphere, Range90fm, sphereProp.approxDist, rangebuffer);
        [spherePos90fm] = f_find_spherepos( Data, Config, Echogram90findsphere, Range90fm, sphereProp.approxDist, rangebuffer);
        
        %f_plotspherepos( echogram, range, spherePos )
        f_plotspherepos( Echogram90findsphere, Range90fm, spherePos90fm )
    end
    %%====================================================EXPERIMENTAL
end