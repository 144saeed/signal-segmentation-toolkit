function varargout = collect(mask, varargin)
%COLLECT Splits multiple arrays into cells based on contiguous segments.
%
%   IdxCells = sovs.segment.collect(Mask)
%   DataCells = sovs.segment.collect(Mask, DataArray)
%   [Data1Cells, Data2Cells] = sovs.segment.collect(Mask, Data1, Data2, ...)
%
%   -----------------------------------------------------------------------
%   Author:     Saeed Oveisi
%   Email:      oveisi.saeed@gmail.com
%   Version:    2.0 (Package Release)
%   -----------------------------------------------------------------------
%
%   # DESCRIPTION
%   The `sovs.segment.collect` function is a high-performance "Slicer" for
%   sequential data. It uses a segmentation mask (or any vector defining
%   groups) to cut input arrays into chunks (Cell Arrays).
%
%   It is designed as a faster alternative to `mat2cell` or `accumarray`
%   specifically for Run-Length Encoded data, where groups are contiguous
%   blocks rather than scattered indices.
%
%   # ARCHITECTURE & ALGORITHM
%   Most grouping functions assume data is scattered randomly, requiring
%   slow hashing or sorting. `collect` assumes sequential contiguity.
%   It first extracts boundary indices using `sovs.segment.bounds`.
%   Then, it slices the raw memory blocks directly: `data(start:end, :)`.
%
%   - Mode A (Indices Only): If no data arrays are provided, it returns
%     a cell array containing the absolute indices of each segment.
%   - Mode B (Data Slicing): If data arrays are provided, it slices each
%     array simultaneously and returns one cell array per input.
%
%   # INPUTS
%   Mask     : 1D logical or numeric array representing segments.
%   DataN    : (Optional) Matrices/Vectors to be sliced. Number of rows
%              must exactly match the length of the Mask.
%
%   # OUTPUTS
%   varargout: Cell arrays containing the sliced segments.
%
%   # EXAMPLES
%   % Example 1: Extract indices only
%   mask = logical([0 1 1 0 1]);
%   idx = sovs.segment.collect(mask); % {[2; 3], [5]}
%
%   % Example 2: Slice a data array
%   data = [10; 20; 30; 40; 50];
%   chunks = sovs.segment.collect(mask, data); % {[20; 30], [50]}
%
%   For a detailed visual example, run: demo_segment_collect
%
%   See also: mat2cell, accumarray, sovs.segment.bounds
%   -----------------------------------------------------------------------

% -- Argument Validation --
arguments
    mask {mustBeNumericOrLogical, mustBeVector}
end
arguments (Repeating)
    varargin
end

%% 1. BOUNDARY DETECTION
numPoints = numel(mask);

% Use our own optimized bounds finder (ensuring FQN is used)
[starts, ends] = sovs.segment.bounds(mask);
numSegments = numel(starts);

%% 2. MODE A: INDICES ONLY
if isempty(varargin)
    outCells = cell(numSegments, 1);
    for k = 1:numSegments
        outCells{k} = (starts(k) : ends(k)).';
    end
    varargout{1} = outCells;
    return;
end

%% 3. MODE B: DATA SLICING (Data Extraction)
numInputs = numel(varargin);
varargout = cell(1, nargout);

if nargout > numInputs
    error('sovs:segment:collect:TooManyOutputs', ...
        'Requested more outputs (%d) than provided input data arrays (%d).', ...
        nargout, numInputs);
end

% BUG FIX: Handle cases where nargout is 0 (like inside verifyError or ans)
numToProcess = min(max(1, nargout), numInputs);

for i = 1:numToProcess
    currentData = varargin{i};

    if size(currentData, 1) ~= numPoints
        error('sovs:segment:collect:DimMismatch', ...
            'Input argument %d has %d rows, but mask has %d.', ...
            i, size(currentData, 1), numPoints);
    end

    outCells = cell(numSegments, 1);
    for k = 1:numSegments
        outCells{k} = currentData(starts(k):ends(k), :);
    end

    varargout{i} = outCells;
end
end