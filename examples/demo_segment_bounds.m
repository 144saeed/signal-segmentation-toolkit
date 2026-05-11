%% DEMO: Signal Segmentation Bounds (sovs.segment.bounds)
% This script demonstrates how to use the bounds function to extract
% the start, end, and lengths of contiguous segments in a signal.
%
% Author: Saeed Oveisi
% Email:  oveisi.saeed@gmail.com

clear; clc; close all;

%% 1. Generate a Sample Signal
% Let's create a noisy signal and apply a threshold to create a logical mask.
rng(42); % For reproducibility
time = linspace(0, 10, 500);
signal = sin(2*pi*0.3*time) + 0.3*randn(size(time));

% Create a logical mask where the signal is above a certain threshold
threshold = 0.5;
mask = signal > threshold;

%% 2. Run the bounds function
% We use the toolkit to find where the signal stays above the threshold.

[starts, ends, lengths] = sovs.segment.bounds(mask);

% Display raw numerical results in the command window
fprintf('Found %d contiguous segments above threshold:\n', numel(starts));
for i = 1:numel(starts)
    fprintf('  Segment %d: Start Idx = %3d, End Idx = %3d, Length = %3d\n', ...
        i, starts(i), ends(i), lengths(i));
end

%% 3. Advanced Use Case: 2D Array
% The function vectorizes seamlessly over N-dimensional arrays.
matrix2D = logical([
    0 1 0;
    0 1 0;
    1 0 1;
    1 0 0
    ]);

% Find bounds along the columns (dimension 1)
[s2d, e2d, l2d] = sovs.segment.bounds(matrix2D, 1);
fprintf('\n2D Matrix Analysis (Column-wise):\n');
disp('Starts (Cell Array):'); disp(s2d);

%% 4. Visualization (The Fun Part!)
% Let's plot the 1D signal and highlight the detected segments.

figure('Name', 'Segmentation Bounds Demo', 'Color', 'w', 'Position', [100, 100, 800, 400]);
hold on; grid on;

% Plot the raw signal and threshold line
plot(time, signal, 'Color', [0.6 0.6 0.6], 'LineWidth', 1.5, 'DisplayName', 'Raw Signal');
yline(threshold, 'r--', 'Threshold', 'LineWidth', 1.5, 'DisplayName', 'Threshold');

% Highlight the segments found by our function
ymin = min(signal) - 0.5;
ymax = max(signal) + 0.5;

for i = 1:numel(starts)
    tStart = time(starts(i));
    tEnd = time(ends(i));

    % Draw a shaded rectangle for each segment
    patch([tStart tEnd tEnd tStart], [ymin ymin ymax ymax], ...
        [0.2 0.6 1], 'FaceAlpha', 0.2, 'EdgeColor', 'none', ...
        'HandleVisibility', 'off');

    % Mark the exact Start and End points
    plot(time(starts(i)), signal(starts(i)), 'go', 'MarkerFaceColor', 'g', 'HandleVisibility', 'off');
    plot(time(ends(i)), signal(ends(i)), 'rs', 'MarkerFaceColor', 'r', 'HandleVisibility', 'off');
end

% Add a dummy patch for the legend
patch([NaN NaN NaN NaN], [NaN NaN NaN NaN], [0.2 0.6 1], 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'DisplayName', 'Detected Segments');

title('\bf{Run-Length Encoding (RLE) Boundary Detection}');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Location', 'best');
ylim([ymin ymax]);