function [s, e, len] = bounds(A, dim)
%BOUNDS Returns start, end, and length indices of contiguous logical segments.
%
%   StartIdx = sovs.segment.bounds(A)
%   [StartIdx, EndIdx] = sovs.segment.bounds(A)
%   [StartIdx, EndIdx, Lengths] = sovs.segment.bounds(A, dim)
%
%   -----------------------------------------------------------------------
%   Author:     Saeed Oveisi
%   Email:      oveisi.saeed@gmail.com
%   Version:    2.0 (Package Release)
%   -----------------------------------------------------------------------
%
%   # DESCRIPTION
%   The `sovs.segment.bounds` function acts as a high-performance Run-Length
%   Encoding (RLE) analyzer for N-Dimensional logical arrays. It identifies
%   contiguous "True" regions in a binary mask and returns their exact
%   boundary indices.
%
%   # MATHEMATICAL & ALGORITHMIC ARCHITECTURE
%   Unlike standard grouping functions that iterate over elements or use
%   hashing, this algorithm relies on purely vectorized finite difference
%   calculus applied to boolean logic.
%
%   1. Padding Strategy:
%      To detect boundaries that touch the absolute edges of the array
%      without writing complex boundary-condition `if/else` statements,
%      the algorithm artificially injects a `false` (0) at the boundaries.
%      A_padded = [0; A; 0] (Assuming column-wise operation)
%
%   2. Differential Masking:
%      Taking the first-order difference (diff) of the padded boolean array
%      maps transitions into discrete impulse signals:
%         dA = diff(A_padded)
%         dA == +1  --> Indicates a transition from 0 to 1 (Start of segment)
%         dA == -1  --> Indicates a transition from 1 to 0 (End of segment)
%
%   3. Index Shift Correction:
%      Because `diff` consumes one element, the resulting index for the
%      end transition is shifted by exactly +1 relative to the original
%      array coordinate. The algorithm dynamically corrects this mathematically:
%         End_Index = Index(dA == -1) - 1
%
%   # EXAMPLES
%   % Example 1: Basic 1D array analysis
%   mask = logical([0 0 1 1 1 0 1 0]);
%   [s, e, len] = sovs.segment.bounds(mask);
%   % Result: s = [3; 7], e = [5; 7], len = [3; 1]
%
%   % Example 2: Using only start indices (nargout = 1)
%   startsOnly = sovs.segment.bounds(mask);
%
%   # INPUTS
%   A   : Logical array (N-dimensional). The binary mask to be analyzed.
%   dim : (Optional) Integer. The dimension along which to find bounds.
%         Defaults to the first non-singleton dimension of A.
%
%   # OUTPUTS
%   s   : Cell array (or numeric array if 1D) containing Start indices.
%   e   : Cell array (or numeric array if 1D) containing End indices.
%   len : Cell array (or numeric array if 1D) containing segment Lengths.
%
%   For a detailed visual example, run: demo_segment_bounds
%
%   See also: find, bwlabel, sovs.segment.labels, sovs.segment.collect
%
%   -----------------------------------------------------------------------

% -- Argument Validation --
arguments
    A   logical
    dim (1,1) {mustBeInteger, mustBePositive} = find(size(A) > 1, 1, 'first');
end

% Fallback for scalar or completely empty arrays
if isempty(dim)
    dim = 1;
end

%% 1. N-DIMENSIONAL RESHAPING
% To vectorize operations across any dimension, we permute the target
% dimension to the front and flatten the rest into a 2D matrix.
% This avoids slow cellfun/loops over higher dimensions.

sz = size(A);
numDims = ndims(A);

% Order of dimensions: Target 'dim' comes first, followed by the rest
permOrder = [dim, setdiff(1:max(numDims, dim), dim)];
A_perm = permute(A, permOrder);

% Flatten into a 2D matrix: [Length of target dim, Total other elements]
len_dim = size(A_perm, 1);
num_cols = numel(A_perm) / len_dim;
A_2D = reshape(A_perm, len_dim, num_cols);

%% 2. MEMORY PRE-ALLOCATION
% Pre-allocate cells for performance. If the input is purely a 1D vector,
% we will un-cell it at the very end for user convenience.
s_lin = cell(1, num_cols);
if nargout >= 2, e_lin = cell(1, num_cols); end
if nargout >= 3, len_lin = cell(1, num_cols); end

%% 3. CORE RLE ENGINE (VECTORIZED)
% Iterate through the flattened columns. This loop is extremely fast
% because the heavy lifting inside is strictly vectorized.
for i = 1:num_cols
    col = A_2D(:, i);

    % Pad with false to ensure edge-touching segments are captured
    padded = [false; col; false];

    % First-order difference to find impulses (+1 for Start, -1 for End)
    d = diff(padded);

    starts = find(d == 1);
    s_lin{i} = starts;

    if nargout >= 2
        % Shift correction: diff naturally shifts indices forward by 1.
        % Since we also padded at the start, the -1 impulse is exactly
        % 1 index ahead of the true mathematical end of the segment.
        ends = find(d == -1) - 1;
        e_lin{i} = ends;
    end

    if nargout >= 3
        len_lin{i} = ends - starts + 1;
    end
end

%% 4. OUTPUT TOPOLOGY RESTORATION
% Reconstruct the output cell array to match the original N-D shape of A
% minus the dimension that was collapsed.

out_sz = sz;
out_sz(dim) = 1; % The collapsed dimension becomes a singleton

% Ensure out_sz has at least 2 dimensions for reshape
if isscalar(out_sz)
    out_sz = [1, out_sz];
end

s = reshape(s_lin, out_sz);
if nargout >= 2, e = reshape(e_lin, out_sz); end
if nargout >= 3, len = reshape(len_lin, out_sz); end

%% 5. 1D VECTOR CLEANUP
% If the input was a simple 1D vector, returning a cell array is annoying
% for the user. We extract the numeric arrays directly.
if isvector(A) && ~isscalar(A)
    s = s{1};
    if nargout >= 2, e = e{1}; end
    if nargout >= 3, len = len{1}; end
end
end