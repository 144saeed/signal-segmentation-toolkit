%% DEMO: Signal Segmentation Collect (sovs.segment.collect)
% This script demonstrates how to slice and extract chunks of raw data
% from vectors or matrices based on a logical mask.
%
% Author: Saeed Oveisi
% Email:  oveisi.saeed@gmail.com

clear; clc; close all;

%% 1. Generate Sample Data
% Imagine an experiment where we record velocity and pressure over time.
time = linspace(0, 10, 500)';
velocity = sin(2*pi*0.2*time) + 0.1*randn(size(time));
pressure = cos(2*pi*0.2*time) * 100 + 50*randn(size(time)); % Noisy pressure

% We only care about the data when velocity is highly positive (e.g., > 0.6)
threshold = 0.6;
mask = velocity > threshold;

%% 2. Run the Collect Function
% Mode A: Get just the indices of the valid segments
indices = sovs.segment.collect(mask);

% Mode B: Simultaneously slice the time, velocity, and pressure arrays!
[t_chunks, v_chunks, p_chunks] = sovs.segment.collect(mask, time, velocity, pressure);

fprintf('Extracted %d valid data chunks.\n', numel(t_chunks));

%% 3. Visualization
% Let's plot the original signal and overlay the extracted chunks.
figure('Name', 'Data Collection Demo', 'Color', 'w', 'Position', [100, 100, 900, 700]);

% -- Subplot 1: Original Velocity Signal and Mask --
subplot(3, 1, 1);
hold on; grid on;
plot(time, velocity, 'Color', [0.7 0.7 0.7], 'LineWidth', 1.5, 'DisplayName', 'Raw Velocity');
yline(threshold, 'r--', 'Threshold', 'LineWidth', 1.5, 'DisplayName', 'Threshold');

ymin = min(velocity); ymax = max(velocity);
for i = 1:numel(indices)
    idx = indices{i};
    patch([time(idx(1)) time(idx(end)) time(idx(end)) time(idx(1))], ...
        [ymin ymin ymax ymax], [0.2 0.9 0.2], 'EdgeColor', 'none', ...
        'FaceAlpha', 0.3, 'HandleVisibility', 'off');
end
title('\bf{Original Velocity Data & Valid Regions (Mask)}');
ylabel('Velocity');
legend('Location', 'best');

% -- Subplot 2: Extracted Velocity Chunks --
subplot(3, 1, 2);
hold on; grid on;
colors = lines(numel(t_chunks));
for i = 1:numel(t_chunks)
    plot(t_chunks{i}, v_chunks{i}, 'o-', 'Color', colors(i,:), ...
        'LineWidth', 2, 'MarkerFaceColor', colors(i,:), ...
        'DisplayName', sprintf('Chunk %d', i));
end
title('\bf{Spliced and Collected Velocity Chunks}');
ylabel('Velocity');
xlim([0 10]);

% -- Subplot 3: Extracted Pressure Chunks --
subplot(3, 1, 3);
hold on; grid on;
for i = 1:numel(t_chunks)
    plot(t_chunks{i}, p_chunks{i}, 's-', 'Color', colors(i,:), ...
        'LineWidth', 1.5, 'MarkerFaceColor', colors(i,:), ...
        'DisplayName', sprintf('Chunk %d', i));
end
title('\bf{Spliced and Collected Pressure Chunks}');
xlabel('Time (s)');
ylabel('Pressure (Pa)');
xlim([0 10]);