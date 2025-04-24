%% ---------------------PLOT PSD AND COMPUTE SQN(+D)R----------------------
% 
% The routine uses the Welch method to compute the PSD. To change the
% framesize and window type use the structure "psdset". Note, "winbw" 
% control field determines how many bins each side of the signal frequency 
% bin are assumed to contain signal power. So, set to span the main lobe
% width of whatever window you chose at least!
%
% The routine works for Low-pass modulators only!!
%
% The routine works for the model mod3_2plus1MASH. It allows to
% calculate the SNDR for each of the single stages forming the MASH
% modulator


%% CHECK MOD_OUT SIGNAL:

if(psdset.framesize > length(Qout1))
    warning('MATLAB:Warning', 'Not enough data for PSD framesize!'); 
end

if(psdset.framesize > length(Qout2))
    warning('MATLAB:Warning', 'Not enough data for PSD framesize!'); 
end

if(psdset.framesize > length(Qout3))
    warning('MATLAB:Warning', 'Not enough data for PSD framesize!'); 
end


%% COMPUTE PSD:



%% First Stage Modulator - Qout1:

psddata1 = spectrum.welch(psdset.win,psdset.framesize); % PSD Settings
dspdata1 = psd(psddata1,Qout1,'Fs',Fs); % Compute PSD

myfreqs1 = dspdata1.Frequencies; % Put the dc term at 1/2 bin so it can be 
myfreqs1(1) = myfreqs1(2)/2;     % plotted in the log scale of the graph
fb = Fs/(2*OSR);               % Ensure fb is updated from defaults

% PLOT PSD:

figure(1);
loglog(dspdata1.Frequencies, sqrt(dspdata1.Data), 'r', 'LineWidth', 1.5);
xlabel('Frequency (Hz)', 'FontWeight', 'Bold', 'FontSize', 10);
ylabel('Unit/sqrt (Hz)', 'FontWeight', 'Bold', 'FontSize', 10);
title('MOD Output Spectral Density', 'FontWeight', 'Bold', 'FontSize', 12);
grid on;
hold on;

% Plot Ideal Brickwall Low Pass Filter at the Converter Passband

plot([10 fb], sqrt([0.95 0.95]), 'b--', 'LineWidth', 3);
plot([fb fb], sqrt([0.1*min(dspdata1.Data) 1]), 'b--', 'LineWidth', 3);
plot([fb Fs/2], sqrt([0.1*min(dspdata1.Data) 0.1*min(dspdata1.Data)]), ...
    'b--', 'LineWidth', 3);

text(1.2*fb, sqrt(min(dspdata1.Data)+2.5e-2), ...
    'Ideal LPF @ Fs/(2OSR)', 'FontSize', 12, 'FontWeight', 'Bold');
fb_text = sprintf('\n%.1e (Hz)', fb); % Label Passband Value
text(1.2*fb, sqrt(min(dspdata1.Data)), fb_text, 'FontSize', 12,...
    'FontWeight', 'Bold');


% CALCULATE SQN(+D)R AND ENOB:

% Calculate and return SQN(+D)R (dB) and ENOB (Bit). 
%
% An IDEAL model will return the SQNR.
% A model with non-idealities introducing distortion will return the SNDR.

[sqnr1,sigpwr,bbpwr] = baseband_sqnr(Qout1, Fs, OSR, sinfreq, psdset);

enob1 = (20*log10(sqnr1)-1.76)/6.02; % In Bit
sqnr1 = 20*log10(sqnr1); % Convert SQN(+D)R in dB

% PLOT SQN(+D)R AND ENOB:

sqnr_text = sprintf('Simulated:\nSQN(+D)R = %.1f dB\nENOB = %.1f', sqnr1, enob1);
text(20, sqrt(max(dspdata1.Data)), sqnr_text, 'FontSize', 14, ...
    'FontWeight', 'Bold');
hold off;


%% Second Stage Modulator - Qout2:

psddata2 = spectrum.welch(psdset.win,psdset.framesize); % PSD Settings
dspdata2 = psd(psddata2,Qout2,'Fs',Fs); % Compute PSD

myfreqs2 = dspdata2.Frequencies; % Put the dc term at 1/2 bin so it can be 
myfreqs2(1) = myfreqs2(2)/2;     % plotted in the log scale of the graph
fb = Fs/(2*OSR);               % Ensure fb is updated from defaults

% PLOT PSD:

figure(2);
loglog(dspdata2.Frequencies, sqrt(dspdata2.Data), 'r', 'LineWidth', 1.5);
xlabel('Frequency (Hz)', 'FontWeight', 'Bold', 'FontSize', 10);
ylabel('Unit/sqrt (Hz)', 'FontWeight', 'Bold', 'FontSize', 10);
title('MOD Output Spectral Density', 'FontWeight', 'Bold', 'FontSize', 12);
grid on;
hold on;

% Plot Ideal Brickwall Low Pass Filter at the Converter Passband

plot([10 fb], sqrt([0.95 0.95]), 'b--', 'LineWidth', 3);
plot([fb fb], sqrt([0.1*min(dspdata2.Data) 1]), 'b--', 'LineWidth', 3);
plot([fb Fs/2], sqrt([0.1*min(dspdata2.Data) 0.1*min(dspdata2.Data)]), ...
    'b--', 'LineWidth', 3);

text(1.2*fb, sqrt(min(dspdata2.Data)+2.5e-2), ...
    'Ideal LPF @ Fs/(2OSR)', 'FontSize', 12, 'FontWeight', 'Bold');
fb_text = sprintf('\n%.1e (Hz)', fb); % Label Passband Value
text(1.2*fb, sqrt(min(dspdata2.Data)), fb_text, 'FontSize', 12,...
    'FontWeight', 'Bold');


% CALCULATE SQN(+D)R AND ENOB:

% Calculate and return SQN(+D)R (dB) and ENOB (Bit). 
%
% An IDEAL model will return the SQNR.
% A model with non-idealities introducing distortion will return the SNDR.

[sqnr2,sigpwr,bbpwr] = baseband_sqnr(Qout2, Fs, OSR, sinfreq, psdset);

enob2 = (20*log10(sqnr2)-1.76)/6.02; % In Bit
sqnr2 = 20*log10(sqnr2); % Convert SQN(+D)R in dB

% PLOT SQN(+D)R AND ENOB:

sqnr_text = sprintf('Simulated:\nSQN(+D)R = %.1f dB\nENOB = %.1f', sqnr2, enob2);
text(20, sqrt(max(dspdata2.Data)), sqnr_text, 'FontSize', 14, ...
    'FontWeight', 'Bold');
hold off;