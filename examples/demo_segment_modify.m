%% DEMO: Segment Modification (sovs.segment.modify)
% This script demonstrates morphological operations on logical signals:
% Dilation (Expansion), Erosion (Shrinking), and Translation (Sliding).
%
% Author: Saeed Oveisi
% Email:  oveisi.saeed@gmail.com

clear; clc; close all;

%% 1. Generate a Base Signal
time = 1:100;
% Create a signal with three distinct segments
base_mask = false(1, 100);
base_mask(10:20) = true; % Segment 1
base_mask(30:35) = true; % Segment 2 (Short)
base_mask(60:80) = true; % Segment 3

%% 2. Apply Morphological Modifications
% Case A: Symmetric Expansion by 4 (Scalar K)
expanded_mask = sovs.segment.modify(base_mask, 5);

% Case B: Asymmetric Slide (Shift Right by 10) -> [10, 10]
slid_mask = sovs.segment.modify(base_mask, [30, 30]);

% Case C: Severe Erosion (Shrink by 4 on both sides) -> [4, -4]
% Notice how Segment 2 (length 6) will completely vanish!
eroded_mask = sovs.segment.modify(base_mask, [4, -4]);

%% 3. Visualization
figure('Name', 'Morphological Segment Modification', 'Color', 'w', 'Position', [100, 100, 900, 800]);

% Helper function for plotting blocks
plotBlocks = @(mask, color, titleStr, subplotIdx) ...
    localPlotBlock(time, mask, color, titleStr, subplotIdx);

plotBlocks(base_mask, [0.4 0.4 0.4], '1. Original Base Mask', 1);
plotBlocks(expanded_mask, [0.2 0.8 0.2], '2. Symmetric Expansion (K=5) [Merged if close]', 2);
plotBlocks(slid_mask, [0.2 0.6 1.0], '3. Translation / Slide Right ([30, 30])', 3);
plotBlocks(eroded_mask, [0.9 0.3 0.3], '4. Severe Erosion ([4, -4]) [Short segments vanish!]', 4);

% --- Local Helper Function for Plotting ---
function localPlotBlock(t, mask, color, titleStr, subIdx)
subplot(4, 1, subIdx);
hold on; grid on;

% Get bounds purely for drawing (using fully qualified name)
[s, e] = sovs.segment.bounds(mask);

% Draw baseline
plot([t(1) t(end)], [0 0], 'k-', 'LineWidth', 1.5);

% Draw blocks
for i = 1:numel(s)
    patch([t(s(i)) t(e(i)) t(e(i)) t(s(i))], ...
        [0 0 1 1], color, 'EdgeColor', 'k', 'LineWidth', 1.5, 'FaceAlpha', 0.6);
end

title(['\bf{', titleStr, '}']);
ylim([-0.5 1.5]); xlim([0 100]);
yticks([]);
end