%% ---------------------PLOT PSD AND COMPUTE SQN(+D)R----------------------
% 
% The routine uses the Welch method to compute the PSD. To change the
% framesize and window type use the structure "psdset". Note, "winbw" 
% control field determines how many bins each side of the signal frequency 
% bin are assumed to contain signal power. So, set to span the main lobe
% width of whatever window you chose at least!
%
% The routine works for Low-pass modulators only!!


%% CHECK MOD_OUT SIGNAL:

if(psdset.framesize > length(mod_out))
    warning('MATLAB:Warning', 'Not enough data'); 
end


%% COMPUTE PSD:

psddata = spectrum.welch(psdset.win,psdset.framesize); % PSD Settings
dspdata = psd(psddata,mod_out,'Fs',Fs); % Compute PSD

myfreqs = dspdata.Frequencies; % Put the dc term at 1/2 bin so it can be 
myfreqs(1) = myfreqs(2)/2;     % plotted in the log scale of the graph
fb = Fs/(2*OSR);               % Ensure fb is updated from defaults

% PLOT PSD:

figure;
loglog(dspdata.Frequencies, sqrt(dspdata.Data), 'r', 'LineWidth', 1.5);
xlabel('Frequency (Hz)', 'FontWeight', 'Bold', 'FontSize', 10);
ylabel('Unit/sqrt (Hz)', 'FontWeight', 'Bold', 'FontSize', 10);
title('MOD Output Spectral Density', 'FontWeight', 'Bold', 'FontSize', 12);
grid on;
hold on;

% Plot Ideal Brickwall Low Pass Filter at the Converter Passband

plot([10 fb], sqrt([0.95 0.95]), 'b--', 'LineWidth', 3);
plot([fb fb], sqrt([0.1*min(dspdata.Data) 1]), 'b--', 'LineWidth', 3);
plot([fb Fs/2], sqrt([0.1*min(dspdata.Data) 0.1*min(dspdata.Data)]), ...
    'b--', 'LineWidth', 3);

text(1.2*fb, sqrt(min(dspdata.Data)+2.5e-2), ...
    'Ideal LPF @ Fs/(2OSR)', 'FontSize', 12, 'FontWeight', 'Bold');
fb_text = sprintf('\n%.1e (Hz)', fb); % Label Passband Value
text(1.2*fb, sqrt(min(dspdata.Data)), fb_text, 'FontSize', 12,...
    'FontWeight', 'Bold');


%% CALCULATE SQN(+D)R AND ENOB:

% Calculate and return SQN(+D)R (dB) and ENOB (Bit). 
%
% An IDEAL model will return the SQNR.
% A model with non-idealities introducing distortion will return the SNDR.

[sqnr,sig_power,bbpwr] = baseband_sqnr(mod_out, Fs, OSR, sinfreq, psdset);

enob = (20*log10(sqnr)-1.76)/6.02; % In Bit
sqnr = 20*log10(sqnr); % Convert SQN(+D)R in dB

% PLOT SQN(+D)R AND ENOB:

sqnr_text = sprintf('Simulated:\nSQN(+D)R = %.1f dB\nENOB = %.1f', sqnr, enob);
text(20, sqrt(max(dspdata.Data)), sqnr_text, 'FontSize', 14, ...
    'FontWeight', 'Bold');
hold off;