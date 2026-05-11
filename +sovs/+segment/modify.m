function A = modify(A, adjustments, dim)
%MODIFY Expands, shrinks, or slides segments by modifying boundaries.
%
%   A_mod = sovs.segment.modify(A, K)
%   A_mod = sovs.segment.modify(A, [LeftAdj, RightAdj])
%   A_mod = sovs.segment.modify(A, Adjustments, dim)
%
%   -----------------------------------------------------------------------
%   Author:     Saeed Oveisi
%   Email:      oveisi.saeed@gmail.com
%   Version:    2.0 (Package Release)
%   -----------------------------------------------------------------------
%
%   # DESCRIPTION
%   The `sovs.segment.modify` function is a high-performance morphological engine
%   for 1D signals and N-Dimensional arrays. It allows for precise
%   manipulation of segment start and end points without needing to convert
%   to indices or loop through segments.
%
%   # ARCHITECTURE & ALGORITHM
%   Instead of iterating through segments (O(N_segments)), this function
%   maps the problem to "1D Morphology" using Fast Convolution (`movsum`).
%
%   - L (Left Offset): Added to the Start Index.
%     (Negative = Moves Start Left/Expands, Positive = Moves Start Right/Shrinks).
%   - R (Right Offset): Added to the End Index.
%     (Positive = Moves End Right/Expands, Negative = Moves End Left/Shrinks).
%
%   MODE 1: DILATION / SLIDE (L <= R)
%       Implemented via `movsum(A) > 0`. Segments merge if they grow into
%       each other.
%   MODE 2: EROSION (L > R)
%       Implemented via `movsum(A) == WindowSize`. Segments shorter than
%       the shrinkage amount vanish completely.
%   MODE 3: TRANSLATION & BOUNDARY PROTECTION
%       Zero-padding is applied dynamically to prevent data from falling off
%       the array edges during morphological expansion. A non-wrapping shift
%       aligns the new shape before cropping back to the original size.
%
%   # INPUTS
%   A           : Input logical array (or numeric mask).
%   adjustments : Scalar K or Vector [L, R].
%                 - Scalar K: Implies [-K, K] (Symmetric Expansion by K).
%   dim         : (Optional) Dimension to operate along.
%
%   # EXAMPLES
%   y = logical([0 0 0 1 1 1 0 0 0]);
%
%   % Example 1: Symmetric Expansion (Grow by 1 on both sides)
%   sovs.segment.modify(y, 1) % Result: [0 0 1 1 1 1 1 0 0]
%
%   % Example 2: Slide Right by 2
%   sovs.segment.modify(y, [2, 2]) % Result: [0 0 0 0 0 1 1 1 0]
%
%   See Also:
%       movsum, circshift, sovs.segment.bounds
%   -----------------------------------------------------------------------

% -- Argument Validation --
arguments
    A
    adjustments (1,:) {mustBeNumeric}
    dim (1,1) {mustBeInteger, mustBeNonnegative} = 0;
end

%% 1. INPUT SANITIZATION
if dim == 0
    dim = find(size(A) ~= 1, 1);
    if isempty(dim), dim = 1; end
end

if ~islogical(A)
    A = A ~= 0;
end

%% 2. OFFSET MAPPING
if isscalar(adjustments)
    % User wants symmetric expansion by K.
    % Start moves left (-K), End moves right (+K).
    l_offset = -abs(adjustments);
    r_offset =  abs(adjustments);
else
    % Specific offsets [StartOffset, EndOffset]
    l_offset = adjustments(1);
    r_offset = adjustments(2);
end

%% 3. BOUNDARY SHIELD (Padding)
% Pad the array to ensure expanded segments don't fall off the edge
% before they are shifted back into their final positions.
pad_size = max(abs(l_offset), abs(r_offset));

if pad_size > 0
    sz = size(A);
    sz(dim) = pad_size;
    padding = false(sz);
    A_pad = cat(dim, padding, A, padding);
else
    A_pad = A;
end

%% 4. CORE LOGIC: COMPACT MORPHOLOGY
K = abs(r_offset - l_offset);

if l_offset <= r_offset
    % --- MODE 1: DILATION (Growth / Slide) ---
    mask = movsum(A_pad, [K, 0], dim) > 0;
else
    % --- MODE 2: EROSION (Shrink / Vanish) ---
    mask = movsum(A_pad, [0, K], dim) == (K + 1);
end

%% 5. GLOBAL SHIFT & CROPPING
% Shift the data to correct absolute positioning
mask_shifted = shiftArray(mask, l_offset, dim);

% Crop the padding back off to restore original array topology
if pad_size > 0
    idx = repmat({':'}, 1, ndims(A));
    idx{dim} = (pad_size + 1) : (size(mask_shifted, dim) - pad_size);
    A = mask_shifted(idx{:});
else
    A = mask_shifted;
end
end

function out = shiftArray(in, k, dim)
%SHIFTARRAY Performs a non-wrapping shift along a specific dimension.
if k == 0
    out = in;
    return;
end

sz = size(in);
sz(dim) = abs(k);
padding = false(sz);

idx = repmat({':'}, 1, ndims(in));

if k > 0
    % Shift Right / Down (Positive Shift)
    idx{dim} = 1 : (size(in, dim) - k);
    out = cat(dim, padding, in(idx{:}));
else
    % Shift Left / Up (Negative Shift)
    idx{dim} = (1 + abs(k)) : size(in, dim);
    out = cat(dim, in(idx{:}), padding);
end
end