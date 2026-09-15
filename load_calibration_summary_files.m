% Load Sig100 calibration summary data

% format long g;

clear; close all; clc

inpath = 'D:\dev\Sig100\Calibrate_Sig100\Results';
% infn = 'CAL_sn101134_fw2212.mat';

infn = 'Sig100_calibration_combined.mat'

load( fullfile(inpath, infn));

c = calibration_accum;
c(1,4)
c{1,4}