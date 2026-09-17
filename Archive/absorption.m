% Calculating the absorption coefficent of seawater in dB / km
% CWJ for AOR Sept 2010

function [alpha] = absorption(freq, Z, T, S, pH)

% Following Kinsler, et al "Fundamentals of Acoustics, Fourth Edition" p. 226-228.
% freq = frequency in Hz
% Z = depth in km
% T = temperature in C
% S = salinity in ppt
% pH = pH

if nargin < 5
    pH = 8;
end
if nargin < 4
    S = 35;
end
if nargin < 3
    T = 5;
end
if nargin < 2
    Z = 0;
end
    
f_1 = 780*exp(T/29);
f_2 = 42000*exp(T/18);
A = 0.083*(S/35)*exp(T/31 - Z/91 + 1.8*(pH-8));
B = 22*(S/35)*exp(T/14-Z/6);
C = 4.9E-10*exp(-T/26 - Z/25);

boric_acid = A/(f_1^2+freq^2); % contribution from boric acid
MgSO4 = B/(f_2^2+freq^2); % contribution from MgSO4
hydrostatic = C; % contribution from hydrostatic pressure
alpha = (boric_acid + MgSO4 + hydrostatic)*freq^2;



end