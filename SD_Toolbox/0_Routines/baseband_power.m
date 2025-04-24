function [bbpwr dcpwr] = baseband_power(mod_out, Fs, OSR, psdset)
%%            baseband_power - Compute total baseband power
%
% Inputs:
%
% mod_out   Modulator output
% Fs        Sampling frequency
% OSR       Oversampling ratio
% psdset    PSD settings structure
%
% Returns:
%
% bbpwr     Estimate of the TOTAL baseband power (signals + noises) in Watts
% dcpwr     Power in the dc bins
%
%
% The routine uses the Welch method to compute the PSD. To change the
% framesize and window type use the structure "psdset". Note, "winbw" 
% control field determines how many bins each side of the signal frequency 
% bin are assumed to contain signal power.
%
% The routine works for Low-pass modulators only!!

%% CHECK MOD_OUT DATA:

if(psdset.framesize > length(mod_out))
    warning('MATLAB:Warning', 'Not enough data');
end


%% COMPUTE PSD:

psddata = spectrum.welch(psdset.win, psdset.framesize);
dspdata = psd(psddata,mod_out,'Fs',Fs);


%% COMPUTE BASEBAND POWER:

freq_res = Fs/psdset.framesize;	% Bin width for frequency resolution

sigband_bins = 1+round((Fs/(2*OSR))/freq_res); % Compute the top of the baseband 
% as a frequecy (Hz) and a corresponding PSD (nearest) bin location.

% Sum the bins and mutliply by the effective noise bandwidth to get
% the total power in the baseband.

bbpwr = freq_res*sum(dspdata.Data(psdset.winbw:sigband_bins)); 
dcpwr = freq_res*sum(dspdata.Data(1:psdset.winbw)); 
end
