clear;clc; % Reset Workspace 

%% --------------------TOOLBOX INITIALIZATION SCRIPT-----------------------
%
%    Initialize default variables to allow quick up-and-running of the 
%              CRFF-CT design example model. Similar to load_par.

%% SIMULATION AND PSD PARAMETERS:

simu.trantime = 10e-3;	 % Transient simulation time
simu.dcstep = 1e-3;      % Default stepsize for sweep-routines
simu.select = 2;         % Select input signal, 1 = DC - 2 = sinewave - 3 = Chirp - 4 = Ramp - 5 = Step   
simu.dcbias = 0.0;       % Bias control for sweep simulations

psdset.framesize = 8192;          % PSD Resolution
psdset.win = 'Blackman-Harris';     % PSD Window: Blackman-Harris for high SQNRs!
psdset.winbw = 3;                   % Window Main Lobe: 1/2 width for signal power

target_mod = 'mod3_CRFF_CTExample';      % Reference model for sweep routines.
%% MODULATOR VARIABLES:

fb = 24e3;                 % Converter bandwidth - Audio(0Hz - 24KHz) - in Hz
OSR = 64;                 % Oversampling ratio used to define singal band 
Fs = fb*2*OSR;             % Sampling frequency, in Hz
dc = 0;                    % dc input value
sinfreq = 12e3;            % in Hz. NOTE IT SHOULD REALLY HIT A PSD BIN!
sinamp = 1/sqrt(2);        % Full-scale is +/- 1 (quantiser/DAC output range)
 

%% MODULATOR SETTINGS:
 
mod.igain1 = inf;        % Integrator dc gain (pole at z = 1-1/gain)
mod.igain2 = inf;
mod.igain3 = inf;

mod.isr1 = inf;          % Integrator Slew-Rate
mod.isr2 = inf;
mod.isr3 = inf;

mod.isat1= inf;          % Integrator saturation
mod.isat2= inf;          % Max integrator output is +/- this number
mod.isat3= inf;

mod.qsatin1 = inf;       % Limiting for any pre-quantiser summer
mod.qsatin2 = inf;
mod.qsatin3 = inf;

mod.qsatout1 = 1;        % Quantizer saturation Max quantizer output is max +/- this number

mod.dither  = 0;         % Dither scaling, off by default (0 = none, 1 = full)  

mod.nlg1 = 10;           % Nonlinearity model control
mod.nlg2 = 10;
mod.nlg3 = 10;


%% DAC/DEM SETTINGS:

dac.elements = [1 1 1 1 1 1 1 1];      % DAC units elements (add more for > 7 levels)
dac.elecount = 7; 		     % How many elements to use (can use < elements)
dac.dem_enable = 1;		     % DEM enable control: 0 = off, 1 = on
dac.dem_dcin = 0;
dac.dem_select = 4;
dac.dem_sinamp = sinamp;
dac.dem_sinfreq = sinfreq;