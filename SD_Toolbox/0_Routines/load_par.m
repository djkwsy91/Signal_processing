clear;clc; % Reset Workspace 

%% --------------------TOOLBOX INITIALIZATION SCRIPT-----------------------
%
%    Initialize default variables to allow quick up-and-running of the 
%                       modulators simulink models

%% SIMULATION AND PSD PARAMETERS:

simu.trantime = 10e-3;	 % Transient simulation time
simu.dcstep = 1e-3;      % Default stepsize for sweep-routines
simu.select = 1;         % Select input signal, 1 = DC - 2 = sinewave - 3 = Chirp - 4 = Ramp - 5 = Step   
simu.dcbias = 0.0;       % Bias control for sweep simulations

psdset.framesize = 8192;            % PSD Resolution
psdset.win = 'Blackman-Harris';     % PSD Window: Blackman-Harris for high SQNRs!
psdset.winbw = 3;                   % Window Main Lobe: 1/2 width for signal power

target_mod = 'sweep_mod1';     % Reference model for sweep routines.
%% MODULATOR VARIABLES:

fb = 24e3;               % Converter bandwidth - Audio(0Hz - 24KHz) - in Hz
OSR = 64;                % Oversampling ratio used to define singal band 
Fs = fb*2*OSR;           % Sampling frequency, in Hz
dc = 0;                  % dc input value
sinfreq = 12e3;          % in Hz. NOTE IT SHOULD REALLY HIT A PSD BIN!
sinamp = 1/sqrt(2);      % Full-scale is +/- 1 (quantiser/DAC output range)
 

%% MODULATOR MODEL SETTINGS:

% add parameters if your model has more elements!
 
mod.igain1 = inf;        % Integrator dc gain (pole at z = 1-1/gain)
mod.igain2 = inf;
mod.igain3 = inf;
mod.igain4 = inf;   

mod.isr1 = inf;          % Integrator Slew-Rate
mod.isr2 = inf;
mod.isr3 = inf;
mod.isr4 = inf;

mod.isat1= inf;          % Integrator saturation
mod.isat2= inf;          % Max integrator output is +/- this number
mod.isat3= inf;
mod.isat4= inf;

mod.qsatin1 = inf;       % Limiting for any pre-quantizer summer
mod.qsatin2 = inf;
mod.qsatin3 = inf;

mod.qsatout1 = 1;        % Quantizer saturation 
mod.qsatout2 = 1;        % Max quantizer output is max +/- this number
mod.qsatout3 = 1;

mod.qlev1=2;             % Number of quantizer output levels (more than
mod.qlev2=2;             % quantizer if a MASH converter);
mod.qlev3=2;

mod.dither  = 0;         % Dither scaling, off by default (0 = none, 1 = full)
mod.dither1 = 0;   

mod.mgain1 = 1;	         % Signal Path Gain factor - Used in MASH models 
mod.mgain2 = 1;
mod.mgain3 = 1;


%% DAC/DEM SETTINGS:

dac.elements = [1 1 1];  % DAC units elements (add more for > 4 levels)
dac.elecount = 3; 		 % How many elements to use (can use < elements)
dac.dem_enable = 0;		 % DEM enable control: 0 = off, 1 = on
dac.dem_dcin = 0;        % Add DC offset to DAC/DEM
dac.dem_select = 4;      % Used in testbench_DEM to select DEM type
dac.dem_sinamp = sinamp;
dac.dem_sinfreq = sinfreq;