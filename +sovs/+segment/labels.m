function outLabels = labels(A, dim)
%LABELS Generates a sequential ID map for contiguous segments in an array.
%
%   ID_Map = sovs.segment.labels(A)
%   ID_Map = sovs.segment.labels(A, dim)
%
%   -----------------------------------------------------------------------
%   Author:     Saeed Oveisi
%   Email:      oveisi.saeed@gmail.com
%   Version:    2.0 (Package Release)
%   -----------------------------------------------------------------------
%
%   # DESCRIPTION
%   The `sovs.segment.labels` function acts as a "State Change Counter." It
%   transforms any array (Logical, Numeric, Character) into a sequential
%   ID map where every contiguous run of identical values gets a unique ID.
%
%   # COMPARISON WITH BWLABEL
%   - `bwlabel`: Only labels "Foreground" (non-zero) objects. Background
%     is always 0. (e.g., [0 0 1 1 0] -> [0 0 1 1 0])
%   - `labels`: Labels EVERYTHING. Every state change starts a new segment.
%     (e.g., [0 0 1 1 0] -> [1 1 2 2 3])
%
%   # ARCHITECTURE & ALGORITHM
%   This function is fully vectorized and loop-free.
%   1. `diff`: Computes the derivative. Any non-zero value is a state change.
%   2. `cat`: A logical `true` is padded at the start because the first
%      element always initiates Segment #1.
%   3. `cumsum`: Cumulatively sums the boolean change-mask, naturally
%      building an ascending integer ID map.
%
%   # INPUTS
%   A   : Input array of any type that supports `diff` (Logical, Numeric, Char).
%   dim : (Optional) Dimension to operate along. Defaults to first non-singleton.
%
%   # OUTPUTS
%   outLabels : Numeric array of the same size as A, containing segment IDs.
%
%   # EXAMPLES
%   % Labeling a simple state-machine array
%   A = [0 0 5 5 5 2 2];
%   L = sovs.segment.labels(A); % Returns [1 1 2 2 2 3 3]
%
%   For a detailed visual example, run: demo_segment_labels
%
%   See also: bwlabel, diff, cumsum, sovs.segment.bounds
%   -----------------------------------------------------------------------

% -- Argument Validation --
arguments
    A
    dim (1,1) {mustBeInteger, mustBeNonnegative} = 0; % 0 implies auto-detect
end

%% 1. INPUT SANITIZATION & SETUP
% Auto-detect the first non-singleton dimension if not provided
if dim == 0
    dim = find(size(A) ~= 1, 1);
    if isempty(dim)
        dim = 1; % Fallback for scalar or empty arrays
    end
end

%% 2. CORE LOGIC (Vectorized State Counter)

% 1. Detect Transitions
% 'diff' returns non-zero wherever adjacent elements differ.
d = diff(A, 1, dim) ~= 0;

% 2. Create Start Padding
% The first element is ALWAYS the start of a new segment.
sz = size(A);
sz(dim) = 1;
pads = true(sz);

% 3. Reconstruct the Change Mask
mask = cat(dim, pads, d);

% 4. Build Sequential IDs
% Cumulative sum integrates the logical impulses into stepped IDs.
outLabels = cumsum(mask, dim);
end