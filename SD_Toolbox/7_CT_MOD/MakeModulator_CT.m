%% --------------------------MODULATOR SYNTHESIS---------------------------
% 
% This exemplary code allows to quickly design CT modulators by utilizing the 
% functions of the Schreier's Delta-Sigma Toolbox. It works only for Low-Pass
% modulators and Butterworth NTFs approximations. Other types of
% Sigma-Delta modulators would require modifications of the code.
%
% To make your own design simply change the parameters in STEP[1] only,
% unless you can confidently code in Matlab and know the Schreier's Toolbox
% functions available.
%
% ALL functions used in this code are covered by:
% Copyright (c) 2009, Richard Schreier - All rights reserved.


%% STEP [1] - MODULATOR SPECIFICATIONS:

    order = 3;          % Order of the modulator
    OSR = 64;           % Oversampling ratio of the modulator 
    form = 'FF';        % Modulator architecture (accepted entries include: 
                        % 'FF' and 'FB' for feedforward and feedback structures 
                        % respectively). No need to specify resonators! 
    form1 = 'CRFF';     % Used by DT routines  
    nLev = 2;           % Number of levels in the quantizer 
    OBG = NaN;          % Out of band gain of NTF - NaN for default by Schreier's
                        % toolbox(1.5 - Lee criterion)
    opt = 1;            % Optimization of NTF zeroes (0 = no opt, 1 = opt) 
    f0 = 0;             % Centre frequency - it is advised to leave zero for CT Low
                        % Pass modulators unlessfully confindent with CT-MOD behavior                    
    tdac = [0.5 1.5];	% DAC timing. [0 1] means zero-delay non-return-to-zero
                        % other timing may include [0 0.5] for RZ pulses, [0.5 1]
                        % for HRZ, etc.
                              
% Derived parameters used in the code for plotting purposes
M = nLev-1;

clc
fprintf(1,'\t\t\t%dth-Order Continuous-Time Lowpass Example\n\n',order);
fig_pos = { [  10 595  600 215],
            [ 640 595  600 215],
            [  10 345  300 205],
            };

 
%% STEP [2] - SYNTHESIZE NTF:

    H_DT = synthesizeNTF(order,OSR,opt,OBG, f0);  % Synthesize the NTF for the 
                                                  % modulator according to the
                                                  % specifications defined in
                                                  % Step [1]
                                                  
    [a,g,b,c] = realizeNTF(H_DT,form1)    % realize the same NTF for Simulink coeff.
    %b(2:end) = 0;                         % Use a single feed-in for the input
    ABCDdt = stuffABCD(a,g,b,c,form1);      % Arrange the coefficients from realizeNTF
                                           % into an ABCD matrix form 
                                                  
        % Step [2.1] - Plot NTF and Schreier's SNR Simulations
                                                  
% NTF synthesis and realization
fprintf(1,'Doing NTF synthesis... ');
design_step = 1;
fprintf(1,'Done.\n');
figure(design_step); clf
set(design_step,'position',fig_pos{design_step});
ntf_axes = DocumentNTF(H_DT,OSR,f0);
drawnow;

% Time-domain simulations
fprintf(1,'Doing time-domain simulations... ');
design_step = design_step+1;
figure(design_step); clf;
set(design_step,'position',fig_pos{design_step});

% Example spectrum
subplot('position', [0.05,0.1,0.6 0.8]);
PlotExampleSpectrum(H_DT,M,OSR,f0);
title('Example Spectrum');

% SQNR plot
subplot('position',[.74 .18 .25 .65]);
if nLev==2
    [snr_pred,amp_pred] = predictSNR(H_DT,OSR);   % THEORETICAL SNR
    plot(amp_pred,snr_pred,'-');
    hold on;
end
[snr,amp] = simulateSNR(H_DT,OSR,[],f0,nLev); % SWEEP SNR SIMULATIONS
fprintf(1,'Done.\n');
plot(amp,snr,'og');
figureMagic([-130 0], 10, 2, [0 125], 10, 2, [7 3], 'Discrete-Time Simulation'); %To see DR change size of SQNR plot
xlabel('Input Level (dBFS)');
ylabel('SQNR (dB)');
[peak_snr,peak_amp] = peakSNR(snr,amp);
msg = sprintf('peak SQNR = %4.1fdB  \n@ amp=%4.1fdB  ',peak_snr,peak_amp);
text(peak_amp-10,peak_snr,msg,'hor','right', 'vertical','middle');
msg = sprintf('OSR=%d ',OSR);
text(0,5,msg,'hor','right');
title('SQNR Plot');
drawnow;


%% STEP [3] - CONTINUOUS TIME MAPPING (State-Space method):

fprintf(1,'Mapping  to continuous-time... ');
design_step = design_step+1;
[ABCDc,tdac2] = realizeNTF_ct(H_DT, form, tdac); % Realize the CT NTF from 
                                                 % the DT Calculated in Step [2]
                                                 
[Ac Bc Cc Dc] = partitionABCD(ABCDc);   % Partition the coefficient for ABCD matrix 
sys_c = ss(Ac,Bc,Cc,Dc);               
fprintf(1,'Done.\n');


    %  Step [3.1] - Check & Plot DT Impulse Response and CT Sample Response

% Verify that the sampled pulse response of the CT loop filter
% matches the impulse response of the DT prototype
figure(design_step); clf;
set(design_step,'position',fig_pos{design_step});
set(design_step,'name','Continuous-Time Mapping')
set(design_step,'numbertitle','off');
set(design_step,'MenuBar','none');
n_imp = 10;
y = -impL1(H_DT,n_imp); % Negate impL1 to make the plot prettier
lollipop(0:n_imp,y);
hold on;
yl = floor(0.9*max(y)); plot([0.5 2], [yl yl], 'b', [0.5 2], [yl yl], 'bo');
text(2,yl,'   discrete-time');
grid on;
dt = 1/16;
yy = -pulse(sys_c,[0 0;tdac2(2:end,:)],dt,n_imp);
t = 0:dt:n_imp;
plot(t,yy,'g');
yl = floor(0.7*max(y)); plot([0.5 2], [yl yl], 'g');
text(2,yl,'  continuous-time');
title('Loop filter pulse/impulse responses (negated)')


%% STEP [4] - MAP THE CT SYSTEM TO ITS DT EQUIVALENT AND CHECK THE NTF:

sys_d = mapCtoD(sys_c,tdac2);
ABCD = [sys_d.a sys_d.b; sys_d.c sys_d.d];
[ntf G] = calculateTF(ABCD);
ntf = cancelPZ(ntf);


                    % Step [4.1] - Plot NTF & STF

%Plot NTF
axes(ntf_axes(1));
hold on;
plotPZ(ntf,'c',6);
hold off;

% Also plot the STF
LF = zpk(sys_c);
L0 = LF(1);
f = linspace(0,0.5);
G = evalTFP(L0,ntf,f);
axes(ntf_axes(2));
hold on; 
plot(f, dbv(G), 'm');
hold off;
set(gcf,'name','NTF and STF')
if 0
    subplot('position',[.74 .25 .25 .5]);
    [f1x,f2x] = ds_f1f2(OSR/1.5,f0);
    f = linspace(f1x,f2x);
    G = evalTFP(L0,ntf,f);
    plot(f*Fs/1e6, dbv(G), 'm');
    hold on; plot([f1 f2]*Fs/1e6, [-0.5 -0.5], 'k', 'LineWidth',3);
    figureMagic([f1x f2x]*Fs/1e6,0.5,2, [-0.5 0.5],.1,5, [6 2.5], 'NTF and STF Frequency Response');
    ylabel('dB')
    xlabel('MHz');
    title('Passband')
end

if 0
    design_step = design_step+1;
    fprintf(1,'Re-evaluating the SNR... ');
    figure(design_step); clf;
    set(design_step,'position',[830 15 400 400]);
    [snr amp] = simulateSNR(ABCD,OSR,[],f0,nLev);
    fprintf(1,'Done.\n');
    plot(amp,snr,'o',amp,snr,'-')
    [peak_snr peak_amp] = peakSNR(snr,amp);
    msg = sprintf('Peak SNR \\approx %.0fdB at amp \\approx %-.0fdB',peak_snr,peak_amp);
    text(peak_amp-10, peak_snr, msg, 'hor', 'right');
    figureMagic([-100 0],10,1, [0 100],10,1, [3 3], 'SQNR vs. Input Amplitude');
    set(gca,'position',[0.12 0.15 0.8 0.7]);
    xlabel('Input Amplitude (dBFS)');
    ylabel('SNR (dB)');
    title('Continuous-Time Implementation');
end


%% STEP [5] - DYNAMIC RANGE SCALING 

design_step = design_step+1;
fprintf(1,'Doing dynamic range scaling... ');

[ABCDscaled umax] = scaleABCD(ABCDdt, nLev); 

[a g b c] = mapABCD(ABCDscaled,form1) % This coeff. go into simulink models

% ABCDcs would need to be checked with CT simulations to
% 1. Verify pulse response
% 2. Verify signal swings  




%% Schreier's original example code:

% !!! This code assumes that the scale factors for the DT equivalent apply 
% !!! to the CT system. A system with an RZ DAC will have inter-sample peaks 
% !!! that exceed the values an the sampling instants.
%
% !!! Note that the output of the ABCDs matrix would have to be mapped for
% !!! Simulink Coeff. in order to be used in the Simulnik Models



%[ABCDs,umax,S] = scaleABCD(ABCD,nLev,f0,1,[],[],1e5);
%S = S(1:order,1:order);	% Don't worry about the extra states used in the d-t model
%Sinv = inv(S);
%Acs=S*Ac*Sinv; Bcs=S*Bc;  Ccs=Cc*Sinv;
%ABCDcs = [Acs Bcs; Ccs Dc];
%sys_cs = ss(Acs,Bcs,Ccs,Dc);
%fprintf(1,'Done.\n');

% ABCDcs needs to be checked with CT simulations to
% 1. Verify pulse response
% 2. Verify signal swings    