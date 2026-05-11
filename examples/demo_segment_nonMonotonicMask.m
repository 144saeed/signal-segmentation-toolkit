%% DEMO: Non-Monotonic Mask (sovs.segment.nonMonotonicMask)
% This script demonstrates how to identify and flag regions in a signal
% that violate a strictly monotonically increasing trend.
%
% Author: Saeed Oveisi
% Email:  oveisi.saeed@gmail.com

clear; clc; close all;

%% 1. Generate a Monotonically Increasing Signal with Noise
% Imagine a sensor tracking distance or total energy (should always increase)
time = 1:100;
clean_signal = time * 0.5;

% Inject stalls (sensor stuck) and backwards drops (glitches)
noisy_signal = clean_signal;
noisy_signal(20:25) = noisy_signal(19); % Stall
noisy_signal(50:60) = noisy_signal(50:60) - 10; % Massive drop
noisy_signal(80:85) = noisy_signal(80:-1:75); % Backward flow
noisy_signal = [0,0,0,0,noisy_signal];
time = [-3:0,time];

%% 2. Apply the Non-Monotonic Mask
% Find all points that ruin the strictly increasing trend
bad_mask = sovs.segment.nonMonotonicMask(noisy_signal);

% Create a "cleaned" signal for visualization by removing bad points
% (This is a preview of what `rmNonMonotonic` will do)
cleaned_time = time(~bad_mask);
cleaned_signal = noisy_signal(~bad_mask);

%% 3. Visualization
figure('Name', 'Non-Monotonic Violation Detection', 'Color', 'w', 'Position', [100, 100, 900, 500]);
hold on; grid on;

% Plot 1: The Raw Noisy Signal
plot(time, noisy_signal, 'Color', [0.6 0.6 0.6], 'LineWidth', 2, 'DisplayName', 'Raw Signal (with drops & stalls)');

% Plot 2: Highlight the Violations (Bad Points)
% We use the bounds function to draw neat red patches around clusters!
[s, e] = sovs.segment.bounds(bad_mask);
ymin = min(noisy_signal) - 5;
ymax = max(noisy_signal) + 5;

for i = 1:numel(s)
    % Draw shaded red region for the bad cluster
    patch([time(s(i))-0.5 time(e(i))+0.5 time(e(i))+0.5 time(s(i))-0.5], ...
        [ymin ymin ymax ymax], [1 0.2 0.2], 'EdgeColor', 'none', ...
        'FaceAlpha', 0.2, 'HandleVisibility', 'off');

    % Plot red markers exactly on the bad data points
    plot(time(s(i):e(i)), noisy_signal(s(i):e(i)), 'ro', 'MarkerFaceColor', 'r', 'HandleVisibility', 'off');
end

% Add dummy patch for legend
patch([NaN NaN NaN NaN], [NaN NaN NaN NaN], [1 0.2 0.2], 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'DisplayName', 'Non-Monotonic Clusters');

% Plot 3: The "Cleaned" Valid Path
plot(cleaned_time, cleaned_signal, 'go', 'LineWidth', 1, 'DisplayName', 'Valid Strictly Increasing Path');


title('\bf{Detecting Non-Monotonic Violations (Stalls & Drops)}');
xlabel('Time / Index');
ylabel('Accumulated Value');
legend('Location', 'northwest');
ylim([ymin ymax]);