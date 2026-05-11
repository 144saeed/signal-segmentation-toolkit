function [labels, numSegments] = locate(t, u, Tolerance, MinDuration)
%LOCATE Detects steady-state segments in a signal.
%
%   [labels, n] = sovs.segment.locate(t, u, tol, minDur)
%
%   -----------------------------------------------------------------------
%   Author:     Saeed Oveisi
%   Email:      oveisi.saeed@gmail.com
%   Version:    2.0 (Package Release)
%   -----------------------------------------------------------------------
%
%   # DESCRIPTION
%   This function implements a JIT-optimized State Machine to find regions
%   in a signal `u` that remain stable (within `Tolerance`) for at least
%   a specific amount of time (`MinDuration`).
%
%   # ARCHITECTURE & ALGORITHM (The State Machine)
%   This function is explicitly written using pre-allocated arrays and
%   scalar states to maximize the efficiency of MATLAB's JIT compiler,
%   achieving near-C++ speeds without the need for MEX compilation.
%
%   States:
%   - 0 (SEARCHING) : Looking for a new anchor point.
%   - 1 (VALIDATING): Checking if the signal stays near the anchor long enough.
%   - 2 (LOCKED)    : Minimum duration met. Forward-filling labels until drift.
%
%   # INPUTS
%   t           : Time vector (column).
%   u           : Signal vector (column). Must match `t` in size.
%   Tolerance   : Maximum allowed deviation from the anchor value (Default: 0.1).
%   MinDuration : Minimum time the signal must remain within Tolerance (Default: 0.5).
%
%   # OUTPUTS
%   labels      : Integer array indexing the detected steady states (0 = Unstable).
%   numSegments : Total number of valid steady segments found.
%
%   # EXAMPLES
%   t = (0:0.1:10)';
%   u = [zeros(30,1); ones(50,1); zeros(21,1)];
%   [lbl, n] = sovs.segment.locate(t, u, 0.1, 2.0);
%
%   For a detailed visual example, run: demo_segment_locate
%
%   See Also: sovs.segment.bounds, sovs.segment.prune
%   -----------------------------------------------------------------------

% -- Argument Validation --
arguments
    t (:,1) double {mustBeReal, mustBeFinite}
    u (:,1) double {mustBeReal, mustBeFinite}
    Tolerance (1,1) double {mustBeNonnegative} = 0.1
    MinDuration (1,1) double {mustBeNonnegative} = 0.5
end

if numel(t) ~= numel(u)
    error('sovs:segment:locate:DimMismatch', 'Time and Signal vectors must have the same length.');
end

%% 1. PRE-ALLOCATION & STATE DEFINITIONS
n = numel(u);
labels = zeros(n, 1);
numSegments = 0;

% State Constants
STATE_SEARCHING  = 0;
STATE_VALIDATING = 1;
STATE_LOCKED     = 2;

currentState = STATE_SEARCHING;

% Memory Variables
anchorVal = 0.0;
candidateStartIdx = 1;

%% 2. THE DETECTION LOOP (JIT-Optimized State Machine)
for i = 1:n
    val = u(i);
    time = t(i);

    if currentState == STATE_SEARCHING
        % --- STATE 0: SEARCHING ---
        anchorVal = val;
        candidateStartIdx = i;
        currentState = STATE_VALIDATING;

    elseif currentState == STATE_VALIDATING
        % --- STATE 1: VALIDATING ---
        if abs(val - anchorVal) > Tolerance
            % Drifted -> Reset
            anchorVal = val;
            candidateStartIdx = i;
        else
            % Check Duration
            currentDur = time - t(candidateStartIdx);
            if currentDur >= MinDuration
                % Success -> Confirm & Back-Fill
                numSegments = numSegments + 1;
                for k = candidateStartIdx : i
                    labels(k) = numSegments;
                end
                currentState = STATE_LOCKED;
            end
        end

    elseif currentState == STATE_LOCKED
        % --- STATE 2: LOCKED ---
        if abs(val - anchorVal) > Tolerance
            % Break -> Reset
            anchorVal = val;
            candidateStartIdx = i;
            currentState = STATE_VALIDATING;
        else
            % Maintain -> Forward-Fill
            labels(i) = numSegments;
        end
    end
end
end