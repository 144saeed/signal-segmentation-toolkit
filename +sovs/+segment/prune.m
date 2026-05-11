function A = prune(A, minLen, dim)
%PRUNE Removes active segments shorter than a specified length.
%
%   A_clean = sovs.segment.prune(A, minLen)
%   A_clean = sovs.segment.prune(A, minLen, dim)
%
%   -----------------------------------------------------------------------
%   Author:     Saeed Oveisi
%   Email:      oveisi.saeed@gmail.com
%   Version:    2.0 (Package Release)
%   -----------------------------------------------------------------------
%
%   # DESCRIPTION
%   The `sovs.segment.prune` function acts as a "Length Filter" or "Despeckler"
%   for binary signals. It removes contiguous runs of `true` (or non-zero)
%   values that strictly fail to meet a minimum length requirement.
%
%   # ARCHITECTURE & ALGORITHM (The "Derivative-Integration" Method)
%   Iterating over segments to check their length is slow. This function
%   uses a fully vectorized mathematical approach:
%
%   1. Topology Normalization: Permutes the target dimension to the front
%      and flattens the rest into a 2D matrix.
%   2. Isolation Padding: Zeros are padded to the top/bottom of every column
%      to prevent segment merging during linearization.
%   3. Edge Detection (Diff): `diff` identifies Start (+1) and End (-1) points.
%   4. Length Filtering: Start/End pairs that are too close are deleted.
%   5. Reconstruction (Cumsum): Places +1 at valid starts and -1 at valid
%      ends, then integrates (`cumsum`) to rebuild the square waves.
%
%   # INPUTS
%   A      : Input array (Logical or Numeric). Non-zero elements are "Active".
%   minLen : (Optional) Minimum inclusive length to keep. Defaults to 3.
%   dim    : (Optional) Dimension to operate along. Defaults to first non-singleton.
%
%   # OUTPUTS
%   A      : Filtered array. Preserves the logical/numeric class of the input.
%
%   # EXAMPLES
%   x = logical([0 1 1 0 1 1 1 0 1]);
%   sovs.segment.prune(x, 3) % Result: [0 0 0 0 1 1 1 0 0]
%
%   For a detailed visual example, run: demo_segment_prune
%
%   See Also: diff, cumsum, sovs.segment.bounds, sovs.segment.modify
%   -----------------------------------------------------------------------

% -- Argument Validation --
arguments
    A
    minLen (1,1) {mustBeInteger, mustBePositive} = 3;
    dim (1,1) {mustBeInteger, mustBeNonnegative} = 0;
end

%% 1. INPUT SANITIZATION
if dim == 0
    dim = find(size(A) > 1, 1);
    if isempty(dim), dim = 1; end
end

wasLogical = islogical(A);

%% 2. TOPOLOGY PREPARATION
perm_order = [dim, 1:dim-1, dim+1:ndims(A)];
A = permute(A, perm_order);
sz = size(A);

% Flatten to 2D
A = reshape(A, sz(1), []);

%% 3. ISOLATION PADDING & LINEARIZATION
num_cols = size(A, 2);
A_padded = [zeros(1, num_cols); A; zeros(1, num_cols)];

d = diff(A_padded(:));

%% 4. EDGE DETECTION & FILTERING
starts = find(d == 1);
ends = find(d == -1);
lengths = ends - starts;

bad_mask = lengths < minLen;
starts(bad_mask) = [];
ends(bad_mask)   = [];

%% 5. RECONSTRUCTION
A_reconstructed = zeros(size(A_padded(:)));

A_reconstructed(starts + 1) = 1;
A_reconstructed(ends + 1) = -1;

A_reconstructed = cumsum(A_reconstructed);

%% 6. SHAPE RESTORATION
A_reconstructed = reshape(A_reconstructed, sz(1) + 2, []);
A_reconstructed = A_reconstructed(2:end-1, :);
A_reconstructed = reshape(A_reconstructed, sz);
A = ipermute(A_reconstructed, perm_order);

if wasLogical
    A = A ~= 0;
end
end