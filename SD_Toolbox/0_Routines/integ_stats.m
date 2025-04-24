function [intmin intmax intmean intstd] = integ_stats(int)
%%        Function Plotting Integrator Histogram and Its Statistics
%
% Inputs:
%
% Int           Array of integrator output values
%
%
% Outputs:
%
% intmin		Minimum integrator output
% intmax		Maximum integrator output
% intmean		Mean integrator output
% intstd		Standard deviation integrator output
%

%% COMPUTE STATISTICS AND HISTOGRAM:

intmin = min(int);      
intmax = max(int);      
intmean = mean(int);
intstd = std(int);

[counts, bins] = hist(int, 50); % Split into 50 bins


%% PLOT HISTOGRAM:

figure;
bar(bins, counts/sum(counts), 'b', 'EdgeColor', 'w');
grid on;

ylabel('Relative Frequency - Probability Density per Bin', 'FontWeight',...
    'Bold', 'FontSize', 10);
xlabel('Integrator Output Range', 'FontWeight', 'Bold', 'FontSize', 10);
tstr = sprintf('Output Summary for Integrator %s', inputname(1));
title(tstr, 'FontWeight', 'Bold', 'FontSize', 12);
hold on;


%% PLOT STATISTICS:

sndrstr = sprintf('MAX = %.3f\nMIN = %.3f\nmean = %.3f\nstd dev = %.3f',...
    intmax, intmin, intmean, intstd);
text(bins(1), 0.95*(max(counts))/(sum(counts)), sndrstr, 'Color', 'b',...
    'FontWeight', 'Bold', 'FontSize', 12);
hold off;
end
