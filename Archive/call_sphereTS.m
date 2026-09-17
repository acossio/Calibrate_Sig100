%---------------------------------------------
% call_sphereTS.m
%---------------------------------------------
% [f, TS] = sphere_TS(varargin)
%   [F, TS] = SPHERE_TS(F, C, D, TYPE, SAVE) returns the Target Strength
%   (TS) of a standard sphere with diameter D over the frequencies F and
%   sound speeds C.  D must be a single numeric value while F and C can be
%   either a vector or single value.  TYPE can be either WC or Cu and
%   designates the sphere parameters that will be used in the TS
%   calculation.  The optional SAVE parameter indicates if the data should
%   be saved (TRUE) or not (FALSE; default).  The user
%   will be prompted for the filename to save the comma-separated TS table.

clear; clc; close all;

Freq           = [65.0 : 0.1 : 130.0]*1000;  % frequency (Hz)
Cw             = 1500.0;  % sound speed (m/s)
sphere_diam_mm = 25.4; % sphere diameter (mm)
TYPE           = 'WC';  % sphere material
SAVE           = 1;  % save 1, or not 0
rhow           = 1033.0;  % water density (should be calculated) 

[f, TS] = sphere_TS(Freq, Cw, sphere_diam_mm, TYPE, rhow, SAVE);

f_kHz = f/1000;

figure('Color',[1 1 1])
plot(f_kHz,TS,'.k')
