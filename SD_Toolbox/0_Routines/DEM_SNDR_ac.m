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
% Same as mod_SNDR, etc. but computes all mod_outs of the testbench_DEM
% Simulink model.

%% CHECK MOD_OUT SIGNAL:

psdset.win = 'hann';

if(psdset.framesize > length(mod_outDWA))
    warning('MATLAB:Warning', 'Not enough data for PSD framesize!'); 
end

if(psdset.framesize > length(mod_outILA))
    warning('MATLAB:Warning', 'Not enough data for PSD framesize!'); 
end

if(psdset.framesize > length(mod_outRES))
    warning('MATLAB:Warning', 'Not enough data for PSD framesize!'); 
end

%% COMPUTE PSD:

% For all 3 DEM Algorithm


%% DWA:

mod_out_acDWA = mod_outDWA - mean(mod_outDWA); % Smooth Out DC Component
psddataDWA = spectrum.welch(psdset.win,psdset.framesize); % PSD Settings
dspdataDWA = psd(psddataDWA,mod_out_acDWA,'Fs',Fs); % Compute PSD

myfreqsDWA = dspdataDWA.Frequencies; % Put the dc term at 1/2 bin so it can be 
myfreqsDWA(1) = myfreqsDWA(2)/2;     % plotted in the log scale of the graph


% PLOT PSD:

figure(1);
loglog(dspdataDWA.Frequencies, sqrt(dspdataDWA.Data), 'r', 'LineWidth', 1.5);
xlabel('Frequency (Hz)', 'FontWeight', 'Bold', 'FontSize', 10);
ylabel('Unit/sqrt (Hz)', 'FontWeight', 'Bold', 'FontSize', 10);
title('DWA Output Spectral Density', 'FontWeight', 'Bold', 'FontSize', 12);
grid on;
hold on;

% Plot Ideal Brickwall Low Pass Filter at the Converter Passband

plot([10 fb], sqrt([0.95 0.95]), 'b--', 'LineWidth', 3);
plot([fb fb], sqrt([0.1*min(dspdataDWA.Data) 1]), 'b--', 'LineWidth', 3);
plot([fb Fs/2], sqrt([0.1*min(dspdataDWA.Data) 0.1*min(dspdataDWA.Data)]), ...
    'b--', 'LineWidth', 3);

text(1.2*fb, sqrt(min(dspdataDWA.Data)+2.5e-2), ...
    'Ideal LPF @ Fs/(2OSR)', 'FontSize', 12, 'FontWeight', 'Bold');
fb_text = sprintf('\n%.1e (Hz)', fb); % Label Passband Value
text(0.9*fb, 2.2e-10, fb_text, 'FontSize', 12, 'FontWeight', 'Bold');


% CALCULATE SQN(+D)R AND ENOB:

% Calculate and return SQN(+D)R (dB) and ENOB (Bit). 
%
% An IDEAL model will return the SQNR.
% A model with non-idealities introducing distortion will return the SNDR.

[DWA_sqnr,sig_power,bbpwr] = baseband_sqnr(mod_outDWA, Fs, OSR, sinfreq, psdset);

DWA_enob = (20*log10(DWA_sqnr)-1.76)/6.02; % In Bit
DWA_sqnr = 20*log10(DWA_sqnr); % Convert SQN(+D)R in dB

% PLOT SQN(+D)R AND ENOB:

sqnr_text = sprintf('Simulated:\nSQN(+D)R = %.1f dB\nENOB = %.1f', DWA_sqnr, DWA_enob);
text(20, sqrt(max(dspdataDWA.Data)), sqnr_text, 'FontSize', 14, ...
    'FontWeight', 'Bold');
hold off;



%% ILA:

mod_out_acILA = mod_outILA - mean(mod_outILA); % Smooth Out DC Component
psddataILA = spectrum.welch(psdset.win,psdset.framesize); % PSD Settings
dspdataILA = psd(psddataILA,mod_out_acILA,'Fs',Fs); % Compute PSD

myfreqsILA = dspdataILA.Frequencies; % Put the dc term at 1/2 bin so it can be 
myfreqsILA(1) = myfreqsILA(2)/2;     % plotted in the log scale of the graph


% PLOT PSD:

figure(2);
loglog(dspdataILA.Frequencies, sqrt(dspdataILA.Data), 'r', 'LineWidth', 1.5);
xlabel('Frequency (Hz)', 'FontWeight', 'Bold', 'FontSize', 10);
ylabel('Unit/sqrt (Hz)', 'FontWeight', 'Bold', 'FontSize', 10);
title('ILA Output Spectral Density', 'FontWeight', 'Bold', 'FontSize', 12);
grid on;
hold on;

% Plot Ideal Brickwall Low Pass Filter at the Converter Passband

plot([10 fb], sqrt([0.95 0.95]), 'b--', 'LineWidth', 3);
plot([fb fb], sqrt([0.1*min(dspdataILA.Data) 1]), 'b--', 'LineWidth', 3);
plot([fb Fs/2], sqrt([0.1*min(dspdataILA.Data) 0.1*min(dspdataILA.Data)]), ...
    'b--', 'LineWidth', 3);

text(1.2*fb, sqrt(min(dspdataILA.Data)+2.5e-2), ...
    'Ideal LPF @ Fs/(2OSR)', 'FontSize', 12, 'FontWeight', 'Bold');
fb_text = sprintf('\n%.1e (Hz)', fb); % Label Passband Value
text(0.9*fb, 2.2e-10, fb_text, 'FontSize', 12, 'FontWeight', 'Bold');


% CALCULATE SQN(+D)R AND ENOB:

% Calculate and return SQN(+D)R (dB) and ENOB (Bit). 
%
% An IDEAL model will return the SQNR.
% A model with non-idealities introducing distortion will return the SNDR.

[ILA_sqnr,sig_power,bbpwr] = baseband_sqnr(mod_outILA, Fs, OSR, sinfreq, psdset);

ILA_enob = (20*log10(ILA_sqnr)-1.76)/6.02; % In Bit
ILA_sqnr = 20*log10(ILA_sqnr); % Convert SQN(+D)R in dB

% PLOT SQN(+D)R AND ENOB:

sqnr_text = sprintf('Simulated:\nSQN(+D)R = %.1f dB\nENOB = %.1f', ILA_sqnr, ILA_enob);
text(20, sqrt(max(dspdataILA.Data)), sqnr_text, 'FontSize', 14, ...
    'FontWeight', 'Bold');
hold off;



%% RES:

mod_out_acRES = mod_outRES - mean(mod_outRES); % Smooth Out DC Component
psddataRES = spectrum.welch(psdset.win,psdset.framesize); % PSD Settings
dspdataRES = psd(psddataRES,mod_out_acRES,'Fs',Fs); % Compute PSD

myfreqsRES = dspdataRES.Frequencies; % Put the dc term at 1/2 bin so it can be 
myfreqsRES(1) = myfreqsRES(2)/2;     % plotted in the log scale of the graph


% PLOT PSD:

figure(3);
loglog(dspdataRES.Frequencies, sqrt(dspdataRES.Data), 'r', 'LineWidth', 1.5);
xlabel('Frequency (Hz)', 'FontWeight', 'Bold', 'FontSize', 10);
ylabel('Unit/sqrt (Hz)', 'FontWeight', 'Bold', 'FontSize', 10);
title('RES Output Spectral Density', 'FontWeight', 'Bold', 'FontSize', 12);
grid on;
hold on;

% Plot Ideal Brickwall Low Pass Filter at the Converter Passband

plot([10 fb], sqrt([0.95 0.95]), 'b--', 'LineWidth', 3);
plot([fb fb], sqrt([0.1*min(dspdataRES.Data) 1]), 'b--', 'LineWidth', 3);
plot([fb Fs/2], sqrt([0.1*min(dspdataRES.Data) 0.1*min(dspdataRES.Data)]), ...
    'b--', 'LineWidth', 3);

text(1.2*fb, sqrt(min(dspdataRES.Data)+2.5e-2), ...
    'Ideal LPF @ Fs/(2OSR)', 'FontSize', 12, 'FontWeight', 'Bold');
fb_text = sprintf('\n%.1e (Hz)', fb); % Label Passband Value
text(0.9*fb, 2.2e-10, fb_text, 'FontSize', 12, 'FontWeight', 'Bold');


% CALCULATE SQN(+D)R AND ENOB:

% Calculate and return SQN(+D)R (dB) and ENOB (Bit). 
%
% An IDEAL model will return the SQNR.
% A model with non-idealities introducing distortion will return the SNDR.

[RES_sqnr,sig_power,bbpwr] = baseband_sqnr(mod_outRES, Fs, OSR, sinfreq, psdset);

RES_enob = (20*log10(RES_sqnr)-1.76)/6.02; % In Bit
RES_sqnr = 20*log10(RES_sqnr); % Convert SQN(+D)R in dB

% PLOT SQN(+D)R AND ENOB:

sqnr_text = sprintf('Simulated:\nSQN(+D)R = %.1f dB\nENOB = %.1f', RES_sqnr, RES_enob);
text(20, sqrt(max(dspdataRES.Data)), sqnr_text, 'FontSize', 14, ...
    'FontWeight', 'Bold');
hold off;