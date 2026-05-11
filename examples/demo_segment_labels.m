%% DEMO: Signal Segmentation Labels (sovs.segment.labels)
% This script demonstrates how the labels function transforms any sequence
% of changing states into a continuous ID map.
%
% Author: Saeed Oveisi
% Email:  oveisi.saeed@gmail.com

clear; clc; close all;

%% 1. Create a State-Machine Signal
% Let's create a signal that jumps between different states (e.g., gear shifts)
time = 1:50;
states = [ones(1,10)*1, ones(1,5)*3, ones(1,15)*2, ones(1,10)*3, ones(1,10)*1];

%% 2. Run the Labels Function
% Get the sequential ID map. Notice how the second time the state hits '3',
% it gets a NEW unique ID, because the state was broken in between.
id_map = sovs.segment.labels(states);

%% 3. Visualization
figure('Name', 'Segmentation Labels Demo', 'Color', 'w', 'Position', [100, 100, 800, 500]);

% -- Subplot 1: The Raw States --
subplot(2, 1, 1);
hold on; grid on;
plot(time, states, 'k.-', 'LineWidth', 2, 'MarkerSize', 15);
yticks([1 2 3]);
ylabel('System State');
title('\bf{Raw System States over Time}');

% -- Subplot 2: The Generated ID Map --
subplot(2, 1, 2);
hold on; grid on;

% We will plot the ID map and color-code each unique segment
unique_ids = unique(id_map);
colors = lines(numel(unique_ids));

for i = 1:numel(unique_ids)
    current_id = unique_ids(i);
    idx = find(id_map == current_id);

    % Draw the segment line
    plot(time(idx), id_map(idx), 'o-', 'Color', colors(i,:), ...
        'LineWidth', 3, 'MarkerFaceColor', colors(i,:));

    % Add a background patch to clearly distinguish segments
    ymin = 0.5; ymax = max(id_map) + 0.5;
    patch([time(idx(1))-0.5 time(idx(end))+0.5 time(idx(end))+0.5 time(idx(1))-0.5], ...
        [ymin ymin ymax ymax], colors(i,:), 'EdgeColor', 'none', ...
        'FaceAlpha', 0.15, 'HandleVisibility', 'off');
end

ylabel('Generated Segment ID');
xlabel('Time');
yticks(1:max(id_map));
title('\bf{Generated Sequential ID Map (sovs.segment.labels)}');