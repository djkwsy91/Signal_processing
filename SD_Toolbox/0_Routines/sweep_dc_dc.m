%% --------------DC SWEEP A MODULATOR AND REPORT DC POWERS-----------------
%
% The script requires a workspace variable called "target_mod" and points
% to a simulink testbench of a modulator with a dc input block.
%
% Default dc step size for the sweep 1m. This can be changed in the
% initialization script (e.g. simu.dcstep), if required.
%
% Assuming no offset in the model the script assume the dc STF is symmetric
% around 0, so just sweep for the input range [0,1] and ignore [-1,0].

%% SIMULATION SETTINGS:

dc = 0; % set dc to zero

psdset.win = 'hann'; % Set hanning window

simu.select = 1;         % Select dc input
simu.trantime = 0.02;    % Set simulation time
simu.testpoints = (simu.dcbias-0.1:simu.dcstep:simu.dcbias+0.1);
simu.numtests = length(simu.testpoints); % Set how many dc tests are to be performed

testbench = 'sweep_testbench';   % All this block automatically load parameters 
open_system([testbench '.mdl']); % in the testbench model 
set_param([testbench '/Modulator'], 'ModelName', [target_mod '.mdl']);
save_system([testbench '.mdl']);
close_system([testbench '.mdl']);
bdclose([testbench '.mdl']);


%% SWEEP DC:

dcout = zeros(1,simu.numtests); % Preallocate zeros in dcout array

for indx = 1:simu.numtests     % Create an index used to select which test has to be run
   dc = simu.testpoints(indx); % Load the dc value for the test into the dc variable
   SimOut = sim([testbench '.mdl']); % Run the simulation
   dcout(indx) = mean(mod_out); % Provide the output
end


%% PLOT RESULTS:

figure;
plot(simu.testpoints, simu.testpoints, 'g-'); % Ideal Dc Transfer Function
grid on;
hold on;
plot(simu.testpoints, dcout, 'r-'); % Dc Transfer Function of MOD-N

tstr = sprintf('Modulator DC Transfer Function Around DC = %.f\n for %s\n%s',...
    simu.dcbias, target_mod);
title(tstr, 'FontWeight', 'Bold', 'FontSize', 12);
xlabel('DC Input', 'FontWeight', 'Bold', 'FontSize', 10);
ylabel('DC Input (green) and Output (red)', 'FontWeight', 'Bold', 'FontSize', 10);
hold off;