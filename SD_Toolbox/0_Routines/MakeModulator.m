%% --------------------------MODULATOR SYNTHESIS---------------------------
% 
% This exemplary code allows to quickly design modulators by utilizing the 
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

    order = 3;      % Order of the modulator
    OSR = 64;       % Oversampling ratio of the modulator 
    form = 'CRFB';  % Modulator architecture (accepted entries include: 
                    % 'CIFF','CIFB','CRFF' and 'CRFB') 
    nLev = 2;       % Number of levels in the quantizer 
    OBG = NaN;      % Out of band gain of NTF - NaN for default by Schreier's
                    % toolbox(OBG = 1.5, Lee criterion)
    f0 = 0;         % Centre frequency 
    opt = 1;        % Optimization of NTF zeroes (0 = no opt, 1 = opt)
    
    
%% STEP [2] - SYNTHESIZE NTF:

    H_DT = synthesizeNTF(order,OSR,opt,OBG, f0)   % Synthesize the NTF for the 
                                                  % modulator according to the
                                                  % specifications defined in
                                                  % Step [1]
     
    H_CT = d2c(H_DT);       % Equivalent Continuous Time
                            % NTF transfer function,
                            % assuming a NRZ feedback DAC
                            % pulse and ideal conditions
                            % (e.g. no ELD, Clock Jitter, etc.)
                                           
%% STEP [3] - REALIZE NTF:

    [a,g,b,c] = realizeNTF(H_DT,form); % This function converts the NTF 
                                       % synthesized in step[2] into coeffiecients
                                       % for circuit implementation
                                       % accordingly to the architecture
                                       % specified in step[1]
    
                                    
%% STEP [4] - GENERATE LOOP FILTER DESCRIPTION IN ABCD FORMAT
    
    %b(2:end) = 0;                   % Use a single feed-in for the input
                                     
    ABCD = stuffABCD(a,g,b,c,form);  % Arrange the coefficients from realizeNTF
                                     % into an ABCD matrix form 
    
                                     
%% STEP [5] - DYNAMIC RANGE SCALING OF ABCD MATRIX:

    % realizeNTF returns coefficients for an unscaled modulator whose internal
    % stages occupy an unspecified range. So dynamic range scaling must be
    % performed. Use scaleABCD to determine scaling factors for each state of
    % the modulator. Modulator is simulated with inputs of different amplitudes
    % to determine maximum stable input amplitude (umax).
   
    [ABCDscaled umax] = scaleABCD(ABCD, nLev);     
    
    % ABCDscaled is the scaled state space matrix description
    % umax is the maximum possible amplitude of the signal that can be
    % applied to the modulator.
    
    
%% STEP [6]: CONVERT SCALED ABCD MATRIX BACK TO COEFFICIENTS FOR CIRCUIT IMPLEMENTATION:
   
    [a g b c] = mapABCD(ABCDscaled,form) % This data goes into simulink models
    
    
%% ADDITIONAL SCHREIER'S FUNCTIONS FOR PLOTTING AND ANALYSIS:    
    
    fig0 = figure('NumberTitle','off','Name','Plots from toolbox');
    scrn = get(0,'ScreenSize');
    set(fig0,'Position',[scrn(3)/4 scrn(4)/4 0.5*scrn(3) 0.5*scrn(4)]);    
    clf;

    subplot(1,2,1);
    plotPZ(H_DT);  %Plots the poles and Zeroes of NTF synthesized above
    title('Poles and Zeroes of NTF');


    %To plot STF and NTF
    [Ha Ga] = calculateTF(ABCD); % Calculates STF from ABCD matrix. Ha = NTF eq, Ga = STF eq
    f = linspace(0,0.5,100);
    z = exp(2i*pi*f);
    magHa = dbv(evalTF(Ha,z)); 
    magGa = dbv(evalTF(Ga,z));
    
    subplot(1,2,2);
    plot(f,magHa,'b',f,magGa,'m','Linewidth',1);
    grid on;
    title('STF and NTF')
    leg3 = legend('NTF','STF');
    set(leg3,'Location', 'SouthEast');
       