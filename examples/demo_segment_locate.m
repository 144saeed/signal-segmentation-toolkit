%% DEMO: Steady-State Locator (sovs.segment.locate)
% This script demonstrates how the JIT-optimized state machine finds
% periods where a signal remains stable despite noise and short spikes.
%
% Author: Saeed Oveisi
% Email:  oveisi.saeed@gmail.com

clear; clc; close all;

%% 1. Generate Signal
% Imagine a wind turbine pitch angle sensor.
time = (0:0.1:20)';
signal = zeros(size(time));

% State 1: 0 degrees (with noise)
signal(1:50) = 0.05 * randn(50, 1);

% Short Spike (Should be ignored because duration is too short)
signal(55:60) = 5;

% State 2: 10 degrees (Stable)
signal(70:120) = 10 + 0.02 * randn(51, 1);

% State 3: Drifting (Should not lock)
signal(130:170) = linspace(10, 15, 41)';

% State 4: 15 degrees (Stable)
signal(175:end) = 15 + 0.04 * randn(27, 1);

%% 2. Run the Locator
Tolerance = 0.2;
MinDuration = 2.0; % Needs to be stable for at least 2 seconds

disp('Running Locator...');
[labels, numSegments] = sovs.segment.locate(time, signal, Tolerance, MinDuration);
fprintf('Found %d steady-state segments.\n', numSegments);

%% 3. Visualization
figure('Name', 'Steady-State Detection Demo', 'Color', 'w', 'Position', [100, 100, 900, 500]);
hold on; grid on;

% Plot raw signal
plot(time, signal, 'Color', [0.6 0.6 0.6], 'LineWidth', 1.5, 'DisplayName', 'Raw Sensor Signal');

% Highlight the locked segments using sovs.segment.bounds
% We convert the label map to a logical mask (labels > 0)
isLocked = labels > 0;
[starts, ends] = sovs.segment.bounds(isLocked);

colors = lines(numSegments);
ymin = min(signal) - 1;
ymax = max(signal) + 1;

for i = 1:numel(starts)
    % Draw bounding box
    patch([time(starts(i)) time(ends(i)) time(ends(i)) time(starts(i))], ...
        [ymin ymin ymax ymax], colors(i,:), 'EdgeColor', 'none', ...
        'FaceAlpha', 0.2, 'HandleVisibility', 'off');

    % Overlay the locked data points
    idx = starts(i):ends(i);
    plot(time(idx), signal(idx), '.', 'Color', colors(i,:), 'MarkerSize', 10, ...
        'DisplayName', sprintf('State %d', i));
end

title(sprintf('\\bf{Steady-State Detection (Tol: %.1f, MinDur: %.1fs)}', Tolerance, MinDuration));
xlabel('Time (s)');
ylabel('Amplitude');
ylim([ymin ymax]);
legend('Location', 'northwest');