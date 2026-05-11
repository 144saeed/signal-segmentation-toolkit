%% DEMO: Signal Despeckling (sovs.segment.prune)
% This script demonstrates how to use the prune function to clean up a
% noisy digital signal by removing spikes and glitches (short segments).
%
% Author: Saeed Oveisi
% Email:  oveisi.saeed@gmail.com

clear; clc; close all;

%% 1. Generate a Digital Signal with Noise
time = 1:200;
% Create a clean square wave
clean_signal = false(1, 200);
clean_signal(20:50) = true;
clean_signal(80:120) = true;
clean_signal(150:180) = true;

% Inject "Speckle Noise" (short high-frequency glitches)
noisy_signal = clean_signal;
noisy_signal([10, 11, 60, 65, 66, 135, 136, 190]) = true;

%% 2. Apply the Prune Function
% We want to remove any segment that is shorter than 5 samples
min_length_to_keep = 5;
pruned_signal = sovs.segment.prune(noisy_signal, min_length_to_keep);

%% 3. Visualization
figure('Name', 'Digital Signal Despeckling', 'Color', 'w', 'Position', [100, 100, 900, 600]);

% -- Subplot 1: Noisy Signal --
subplot(2, 1, 1);
hold on; grid on;

% Plot the noisy signal
stairs(time, noisy_signal, 'Color', [0.4 0.4 0.4], 'LineWidth', 1.5);

% Highlight the glitches using sovs.segment.bounds!
[s, e, len] = sovs.segment.bounds(noisy_signal);
for i = 1:numel(s)
    if len(i) < min_length_to_keep
        % BUG FIX: Added -0.5 and +0.5 to make single-point glitches visible
        patch([time(s(i))-0.5 time(e(i))+0.5 time(e(i))+0.5 time(s(i))-0.5], ...
            [0 0 1.2 1.2], [1 0.2 0.2], 'EdgeColor', 'none', ...
            'FaceAlpha', 0.4, 'HandleVisibility', 'off');
    end
end
title('\bf{Original Noisy Signal (Red patches show glitches length < 5)}');
ylim([-0.2 1.4]); xlim([0 200]); yticks([0 1]); ylabel('Logic State');

% -- Subplot 2: Pruned Clean Signal --
subplot(2, 1, 2);
hold on; grid on;

% Plot the cleaned signal
stairs(time, pruned_signal, 'Color', [0.2 0.8 0.2], 'LineWidth', 2.5);

title('\bf{Pruned Signal (sovs.segment.prune)}');
ylim([-0.2 1.4]); xlim([0 200]); yticks([0 1]); xlabel('Time'); ylabel('Logic State');