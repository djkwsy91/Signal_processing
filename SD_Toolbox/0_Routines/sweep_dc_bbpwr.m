%%    sweep_dc_bbpwr - dc sweep a modulator and report baseband powers
%
% The script requires a workspace variable called "target_mod" and points
% to a simulink testbench of a modulator with a dc input block.
%
% Default dc step size for the sweep 1m. This can be changed in the
% initialization script (e.g. simu.dcstep), if required.
%
% Assuming no offset in the model the script assume the dc STF is symmetric 
% around 0, so just sweep for the input range [0,1] and ignore [-1,0).

%% SIMULATION SETTINGS:

psdset.win='hann'; % Set hanning window, Blackman Harris won't give accurate resuls in this case!

simu.select = 1;         % Select dc input
simu.trantime = 0.02;    % Set simulation time
simu.testpoints = (0:simu.dcstep:1); 
simu.numtests = length(simu.testpoints); % Set how many dc tests are to be performed

testbench = 'sweep_testbench';   % All this block automatically load parameters 
open_system([testbench '.mdl']); % in the testbench model 
set_param([testbench '/Modulator'], 'ModelName', [target_mod '.mdl']);
save_system([testbench '.mdl']);
close_system([testbench '.mdl']);
bdclose([testbench '.mdl']);



%% SWEEP DC:

bbpwr = zeros(1,simu.numtests); % Preallocate zeros in dcout array

for indx = 1:simu.numtests % Create an index used to select which test has to be run
   dc = simu.testpoints(indx); % Load the dc value for the test into the dc variable
   SimOut = sim([testbench '.mdl']); % Run the simulation
   bbpwr(indx) = baseband_power(mod_out, Fs, OSR, psdset); % Provide the output
end

dbpwr = 20*log10(bbpwr); % Convert in dB
avepwr = 20*log10(mean(bbpwr)); % Compute average power


%% PLOT RESULTS:

figure;
plot(simu.testpoints, dbpwr, 'b-');
grid on;
hold on;
plot(simu.testpoints, avepwr, 'r-', 'linewidth', 4);
axis([0 1 (avepwr-80) max(dbpwr)]);

tstr = sprintf('Baseband Noise Power vs. DC Input and Average Power Over All Inputs\n for Modulator %s\n%s', target_mod);
title(tstr, 'FontWeight', 'Bold', 'FontSize', 12);
xlabel('DC Input', 'FontWeight', 'Bold', 'FontSize', 10);
ylabel('Total Power (dBW)', 'FontWeight', 'Bold', 'FontSize', 10);

tstr = sprintf('Average Base-band Power = %.1f dBW', avepwr);
text(0.05, max(dbpwr)-10,tstr,'Color','r','FontWeight','Bold','Fontsize', 12);
hold off;