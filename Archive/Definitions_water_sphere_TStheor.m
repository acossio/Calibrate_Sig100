    %% Define: Water Properties
    WaterProp.soundVel               = 1500.0; % (m/s)
    WaterProp.temp                   = 14.0;   % (C)
    WaterProp.sal                    = 34.0;   % (psu)
    WaterProp.density                = 1033.0; % kg/m^3
    
    
    %% Define: Target sphere properties
    sphereProp.sphereDiameter        = 25.4; % mm
    sphereProp.sphereType            = 'WC'; % 'WC' or 'CU' currently supported
    sphereProp.approxDist            =  4.6;  % m
    
    
    %% Define: Theoretical TS model parameters for 90 kHz FM mode 
    TS_theor_paramsFM.Ftminspec      =  68.4;  % kHz minimum frequency to model
    TS_theor_paramsFM.Ftmaxspec      = 113.4;  % kHz maximum frequency to model
    TS_theor_paramsFM.nF             = 500;    % number of frequencies to model
    TS_theor_paramsFM.sphereDiameter = sphereProp.sphereDiameter; %25.4; % sphere diameter (mm)
    TS_theor_paramsFM.sphereType     = sphereProp.sphereType; % sphere type, %'WC' or 'CU'
    TS_theor_paramsFM.HZPASS         = -0.1;   % avoids TS samples affected by filter edges
    TS_theor_paramsFM.soundVel       = WaterProp.soundVel; %1500; % water sound speed
    TS_theor_paramsFM.rhow           = WaterProp.density; % water density 1033.0
    TS_theor_paramsFM.doPLOTTSBINNED = false;

    %% Define: Theoretical TS model parameters
    TS_theor_params70.Ftminspec      =  69.5;  % kHz minimum frequency to model
    TS_theor_params70.Ftmaxspec      =  70.5;  % kHz maximum frequency to model
    TS_theor_params70.nF             = 10;    % number of frequencies to model
    TS_theor_params70.sphereDiameter = sphereProp.sphereDiameter; %25.4; % sphere diameter (mm)
    TS_theor_params70.sphereType     = sphereProp.sphereType; % sphere type, %'WC' or 'CU'
    TS_theor_params70.HZPASS         = -0.1;   % avoids TS samples affected by filter edges
    TS_theor_params70.soundVel       = WaterProp.soundVel; %1500; % water sound speed
    TS_theor_params70.rhow           = WaterProp.density; % water density 1033.0
    TS_theor_params70.doPLOTTSBINNED = false;

    %% Define: Theoretical TS model parameters
    TS_theor_params120.Ftminspec      = 119.5;  % kHz minimum frequency to model
    TS_theor_params120.Ftmaxspec      = 120.5;  % kHz maximum frequency to model
    TS_theor_params120.nF             = 10;    % number of frequencies to model
    TS_theor_params120.sphereDiameter = sphereProp.sphereDiameter; %25.4; % sphere diameter (mm)
    TS_theor_params120.sphereType     = sphereProp.sphereType; % sphere type, %'WC' or 'CU'
    TS_theor_params120.HZPASS         = -0.1;   % avoids TS samples affected by filter edges
    TS_theor_params120.soundVel       = WaterProp.soundVel; %1500; % water sound speed
    TS_theor_params120.rhow           = WaterProp.density; % water density 1033.0
    TS_theor_params120.doPLOTTSBINNED = false;

