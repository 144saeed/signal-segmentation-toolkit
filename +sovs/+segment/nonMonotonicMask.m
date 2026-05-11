function I = nonMonotonicMask(y, dim)
%NONMONOTONICMASK Identifies violations of strictly monotonic increase.
%
%   I = sovs.segment.nonMonotonicMask(y)
%   I = sovs.segment.nonMonotonicMask(y, dim)
%
%   -----------------------------------------------------------------------
%   Author:     Saeed Oveisi
%   Email:      oveisi.saeed@gmail.com
%   Version:    2.0 (Package Release)
%   -----------------------------------------------------------------------
%
%   # DESCRIPTION
%   This function detects points in an array that disrupt a strictly
%   increasing sequence. An element is considered a violation if it is not
%   strictly greater than the preceding elements. This includes both
%   backward flows (drops) and stalls (consecutive equal values).
%
%   # ARCHITECTURE & ALGORITHM
%   It uses a Global Cumulative strategy rather than local differentiation
%   (`diff < 0`). This ensures that entire non-monotonic clusters are marked,
%   preserving the integrity of the global trend.
%
%   1. Forward Check (High Water Mark): `cummax` tracks the highest value
%      seen so far. If a value fails to exceed this, it dropped or stalled.
%   2. Reverse Check (Low Water Mark): `cummin(..., "reverse")` tracks the
%      lowest value from the future. It identifies peaks that are invalid
%      because the signal immediately drops after them.
%
%   # INPUTS
%   y   : Input array (Vector, Matrix, or N-D Array).
%   dim : (Optional) Dimension to operate along. Defaults to first non-singleton.
%
%   # OUTPUTS
%   I   : Logical array of the same size as y. True where violations occur.
%
%   # EXAMPLES
%   % The sequence [2, 3, 2] violates the trend required to reach 4.
%   y = [1, 2, 3, 2, 4, 5];
%   mask = sovs.segment.nonMonotonicMask(y);
%   % Result: [0 1 1 1 0 0] (Indices 2, 3, 4 are marked as violators)
%
%   See also: cummax, cummin, diff, sovs.segment.bounds
%   -----------------------------------------------------------------------

% -- Argument Validation --
arguments
    y {mustBeNumeric}
    dim (1,1) {mustBeInteger, mustBeNonnegative} = 0;
end

%% 1. INPUT SANITIZATION
if dim == 0
    dim = find(size(y) ~= 1, 1);
    if isempty(dim), dim = 1; end
end

%% 2. CORE LOGIC: GLOBAL CUMULATIVE STRATEGY

% 1. Cumulative Max (Forward Validity)
% Tracks the "High Water Mark". Any value falling below this is invalid.
cmx = cummax(y, dim);

% 2. Cumulative Min (Reverse Validity)
% Tracks the "Low Water Mark" from the future.
cmn = cummin(y, dim, "reverse");

%% 3. MASK GENERATION
sz = size(y);
sz(dim) = 1;
false_mat = false(sz);

% Condition 1: Forward Check
% If diff(cmx) == 0, it means the current value dropped or stalled.
mask1 = cat(dim, false_mat, diff(cmx, 1, dim) == 0);

% Condition 2: Reverse Check
% If diff(cmn) == 0, it means the current value is >= the next minimum.
mask2 = cat(dim, diff(cmn, 1, dim) == 0, false_mat);

%% 4. FINAL OUTPUT
% Combine conditions: A point is bad if it fails EITHER check.
I = mask1 | mask2;
end