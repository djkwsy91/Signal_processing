function [sqnr,sig_power,bbpwr] = baseband_sqnr(mod_out, Fs, OSR, sinfreq, psdset)
%%   baseband_sqnr - Compute MODOUT signal power and baseband SQN(+D)R
%
% Inputs:
%
% mod_out       Modulator output
% Fs            Sampling frequency
% OSR           Oversampling ratio 
% sinfreq    	Signal fundamental frequency in Hz
% psdset        PSD settings structure
%
% Returns:
%
% sqnr		Estimate of the SQN(+D)R AMPLITUDEs ratio 
% sigpwr	Estimated signal power
% bbpwr		Estimated total baseband power including signal
%
% The routine uses the Welch method to compute the PSD. To change the
% framesize and window type use the structure "psdset". Note, "winbw" 
% control field determines how many bins each side of the signal frequency 
% bin are assumed to contain signal power. 

% If the model being simulated is ideal the sqnr will be the SQNR.
%
% The routine works for Low-pass modulators only!!

%% CHECK SIGNALS:

if(psdset.framesize > length(mod_out))
    warning('MATLAB:Warning', 'Not enough data');
end

if(sinfreq < (Fs/psdset.framesize))
    warning('MATLAB:Warning',...
        'PSD framesize too short - poor accuracy');
end


%% COMPUTE PSD:

psddata = spectrum.welch(psdset.win,psdset.framesize); % PSD Settings
dspdata = psd(psddata,mod_out,'Fs',Fs); % Compute PSD


%%  COMPUTE BASEBAND TOTAL POWER:
% 
% To avoid any relevant dc power component to affect the baseband results
% the first NBW bins are not considered. 

fres = Fs/psdset.framesize;	% Bin width for frequency resolution

sigband_bins = 1+round((Fs/(2*OSR))/fres); 
bbpwr = fres*sum(dspdata.Data(psdset.winbw:sigband_bins));  % Sum powers


%% COMPUTE SIGNAL POWER:

sig_bin = 1+round(sinfreq/fres); % Find closest PSD bin to desired signal

sig_bin_min = max([(sig_bin - psdset.winbw) 1]); % Don't look below dc
sig_bin_max = sig_bin + psdset.winbw; % Window OOB ok for signal power calc...
sig_power = fres*sum(dspdata.Data(sig_bin_min:sig_bin_max));

% Check if the signal is in the passband

if(sig_bin > sigband_bins)
    warning('MATLAB:Warning',...
        'Accuracy warning - signal is out of band');
elseif(sig_bin_max >= sigband_bins)
    warning('MATLAB:Warning',...
        'Accuracy warning - signal window lobe exceeds top of signal band');
end


%% Calculate SQN(+D)R:
%
% An IDEAL model will return the SQNR.
% A model with non-idealities introducing distortion will return the SNDR.

sqnr = sqrt(sig_power/(bbpwr - sig_power)); 
end
