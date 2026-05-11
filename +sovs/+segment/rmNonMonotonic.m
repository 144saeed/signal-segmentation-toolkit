function [cleanRef, varargout] = rmNonMonotonic(refData, varargin)
%RMNONMONOTONIC Removes non-monotonic elements from a vector and associated data.
%
%   [REF, ...] = sovs.segment.rmNonMonotonic(REF, ...)
%   [REF, A, B] = sovs.segment.rmNonMonotonic(REF, A, B, C)
%   [REF, ...] = sovs.segment.rmNonMonotonic(REF, DIM, ...)
%   sovs.segment.rmNonMonotonic(...) % Triggers diagnostic plot
%
%   -----------------------------------------------------------------------
%   Author:     Saeed Oveisi
%   Email:      oveisi.saeed@gmail.com
%   Version:    2.0 (Package Release)
%   -----------------------------------------------------------------------
%
%   # DESCRIPTION
%   This function acts as a "Gatekeeper" for time-series, phase angles, or
%   encoder data. It strictly enforces the rule: x(k) > x(k-1).
%
%   It utilizes a global cumulative check via `sovs.segment.nonMonotonicMask`.
%   It removes the invalid elements from REF and systematically removes the
%   corresponding slices from any additional input arrays to maintain
%   synchronization.
%
%   # SMART DIMENSION HANDLING
%   1. Explicit Mode: If 'DIM' is provided, it is strictly enforced for all.
%   2. Auto Mode: If omitted, the function detects the reference vector's
%      length and attempts to find a matching dimension in the associated
%      arrays (e.g., cleaning a row vector against a column-major matrix).
%
%   # PERFORMANCE (Lazy Evaluation)
%   It iterates through and processes additional inputs ONLY if requested
%   as outputs (nargout). Inputs not assigned to an output are ignored.
%
%   # INPUTS
%   refData  : The Master Vector (numeric, MUST be 1D).
%   dim      : (Optional) Positive integer dimension.
%   varargin : Additional arrays (vectors/matrices) to filter synchronously.
%
%   # OUTPUTS
%   cleanRef  : The cleaned, strictly increasing reference vector.
%   varargout : The additional arrays, sliced with the same validity mask.
%
%   # EXAMPLES
%   t = [1, 2, 3, 2, 4]; v = [10, 20, 30, 40, 50];
%   [t_new, v_new] = sovs.segment.rmNonMonotonic(t, v);
%   % Result: t_new=[1, 4], v_new=[10, 50]
%
%   See Also: sovs.segment.nonMonotonicMask, cummax, rmmissing
%   -----------------------------------------------------------------------

% -- Argument Validation --
if ~isvector(refData) && ~isempty(refData)
    error('sovs:segment:rmNonMonotonic:NotAVector', ...
        'The reference input must be a 1D vector.');
end

%% 1. PARSE ARGUMENTS (DIM vs DATA)
dim = [];
isDimExplicit = false;
dataStartIdx = 1;

if ~isempty(varargin) && isscalar(varargin{1}) && ...
        isnumeric(varargin{1}) && (varargin{1} > 0) && ...
        (floor(varargin{1}) == varargin{1})

    dim = varargin{1};
    isDimExplicit = true;
    dataStartIdx = 2;
end

if isempty(dim)
    dim = find(size(refData) ~= 1, 1);
    if isempty(dim), dim = 1; end
end

%% 2. GENERATE VALIDITY MASK
isBad = sovs.segment.nonMonotonicMask(refData, dim);
keepMask = ~isBad;

%% 3. CLEAN REFERENCE ARRAY
cleanRef = subsetData(refData, keepMask, dim);

%% 4. CLEAN ASSOCIATED DATA (LAZY EVALUATION)
if nargout > 0
    numRequested = nargout - 1;
    inputDataArgs = varargin(dataStartIdx:end);
    numAvailable = length(inputDataArgs);

    if numRequested > numAvailable
        error('sovs:segment:rmNonMonotonic:TooManyOutputs', ...
            'Requested %d extra outputs, but only %d data inputs provided.', ...
            numRequested, numAvailable);
    end

    varargout = cell(1, numRequested);
    refLen = length(keepMask);

    for k = 1:numRequested
        currData = inputDataArgs{k};
        opDim = dim;
        matchesOnRefDim = (size(currData, opDim) == refLen);

        % Smart Dimension Inference
        if ~matchesOnRefDim && ~isDimExplicit
            matchingDims = find(size(currData) == refLen);
            if isscalar(matchingDims)
                opDim = matchingDims;
            elseif ~isempty(matchingDims)
                opDim = matchingDims(1);
            end
        end

        if size(currData, opDim) ~= refLen
            error('sovs:segment:rmNonMonotonic:DimMismatch', ...
                'Input argument %d size (%d) on dim %d does not match reference length (%d).', ...
                k+dataStartIdx, size(currData, opDim), opDim, refLen);
        end

        varargout{k} = subsetData(currData, keepMask, opDim);
    end
end

%% 5. VISUALIZATION MODE (NO OUTPUTS)
if nargout == 0
    generateReport(refData, isBad, cleanRef, dim);
    clear cleanRef varargout;
end
end

% --- LOCAL HELPER FUNCTIONS ---

function out = subsetData(in, mask, dim)
if isequal(size(in), size(mask))
    % BUG FIX: Removed the manual transpose. MATLAB natively preserves
    % the orientation (row/col) when indexing with a mask of the exact same size.
    out = in(mask);
else
    idx = repmat({':'}, 1, ndims(in));
    idx{dim} = mask;
    out = in(idx{:});
end
end

function generateReport(original, isBad, cleaned, dim)
totalPts = numel(original);
badPts = sum(isBad);
percent = (badPts / totalPts) * 100;

fprintf('<strong>[sovs.segment.rmNonMonotonic Report]</strong>\n');
fprintf('  Dimension:       %d\n', dim);
fprintf('  Total Samples:   %d\n', totalPts);
fprintf('  Violations:      %d (%.2f%%)\n', badPts, percent);
fprintf('  Cleaned Samples: %d\n', numel(cleaned));

if badPts == 0
    fprintf('  Status:          Data is strictly monotonic. No changes.\n');
    return;
end

x_axis = 1:length(original);
figure('Name', 'rmNonMonotonic Diagnostic', 'Color', 'w', 'Position', [100, 100, 800, 500]);

subplot(2,1,1);
hold on; grid on; box on;
plot(x_axis, original, '-', 'Color', [0.7 0.7 0.7], 'LineWidth', 1.5, 'DisplayName', 'Original Trace');
plot(x_axis(isBad), original(isBad), 'rx', 'MarkerSize', 8, 'LineWidth', 1.5, 'DisplayName', 'Removed');
plot(x_axis(~isBad), original(~isBad), 'g.', 'MarkerSize', 6, 'DisplayName', 'Kept');
title(sprintf('\\bf{Detected Monotonicity Violations (Dim: %d)}', dim));
ylabel('Value'); legend('Location', 'best');

subplot(2,1,2);
plot(1:length(cleaned), cleaned(:), '-b', 'LineWidth', 1.5);
grid on; box on;
title('\bf{Final Strictly Monotonic Signal}');
xlabel('New Index'); ylabel('Value');
end