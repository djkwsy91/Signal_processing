%% --------------------TOTAL HARMONIC DISTORTION---------------------------
%
% Quickly estimate the THD of the modulator. Note that a Simulink modulator's 
% model of the Toolbox has to be run first.

%% THD:

t = 0:1/Fs:1-1/Fs;   % set the signal lenght to be analysed
[thd_res, harmpow, harmfreq] = thd(mod_out, Fs, 5); %thd(Signal, Sampling Freq., Number of Harmonics to consider);

[harmpow, harmfreq]
thd_res = thd(mod_out, Fs, 5)