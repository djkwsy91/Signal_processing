%%  sweep_sinamp - sine sweep a modulator and report sqnr vs. amplitude
%

%% SIMULATION SETTINGS:

simu.select = 2; % Select sinewave input
simu.trantime = 0.041;  % Set simulation time
simu.testpoints = logspace(-3,0,61);  % 1 dB steps
simu.numtests = length(simu.testpoints);

testbench = 'sweep_testbench';   % All this block automatically load  
open_system([testbench '.mdl']); % parameters in the testbench model 
set_param([testbench '/Modulator'], 'ModelName', [target_mod '.mdl']);
save_system([testbench '.mdl']);
close_system([testbench '.mdl']);
bdclose([testbench '.mdl']);


%% SWEEP SINEWAVE AMPLITUDE:

sndr = zeros(1,simu.numtests); % Preallocate zeros in outputs variables
sig_power = zeros(1,simu.numtests); 

for indx = 1:simu.numtests % Create an index used to select which test has to be run
   sinamp = simu.testpoints(indx); % Load the selected amplitude into sinamp for the model
   SimOut = sim([testbench '.mdl']); % Run the simulation
   [sndr(indx) sig_power(indx)] = baseband_sqnr(mod_out, Fs, OSR, sinfreq, psdset); % Provide the output
end


%% PLOT RESULTS:

figure;
plot(20*log10(simu.testpoints(2:end)), 20*log10(sndr(2:end)), 'b-');
grid on;
hold on;
plot(20*log10(simu.testpoints(2:end)), 20*log10(sndr(2:end)), 'ro');

tstr = sprintf('SQNDR vs. %d Hz Sine Input Amplitude\n for %s\n%s',...
    round(sinfreq), target_mod);
title(tstr, 'FontWeight', 'Bold', 'FontSize', 12);
xlabel('Input Amplitude (dBFS)', 'FontWeight', 'Bold', 'FontSize', 10);
ylabel('SQNDR (dB)', 'FontWeight', 'Bold', 'FontSize', 10);
hold off;