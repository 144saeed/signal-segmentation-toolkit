classdef test_segment_rmNonMonotonic < matlab.unittest.TestCase
    %TEST_SEGMENT_RMNONMONOTONIC Unit tests for sovs.segment.rmNonMonotonic

    methods(Test)

        function testBasicSync(testCase)
            % Test 1: Clean Ref and multiple synced vectors
            % t = [1, 2, 5, 3, 6]. Both the Peak (5) and Drop (3) are removed.
            t = [1, 2, 5, 3, 6];
            v1 = [10, 20, 50, 30, 60];
            v2 = [100, 200, 500, 300, 600];

            [t_c, v1_c, v2_c] = sovs.segment.rmNonMonotonic(t, v1, v2);

            testCase.verifyEqual(t_c, [1, 2, 6], 'Ref vector failed.');
            testCase.verifyEqual(v1_c, [10, 20, 60], 'Sync data 1 failed.');
            testCase.verifyEqual(v2_c, [100, 200, 600], 'Sync data 2 failed.');
        end

        function testSmartDimensionInference(testCase)
            % Test 2: Row Vector Ref vs Matrix (Auto-detect dimension)
            t = [1, 5, 2, 8]; % 1x4 row vector. Peak (5) and Drop (2) are removed.
            M = [10 20 30; 40 50 60; 70 80 90; 100 110 120]; % 4x3 Matrix

            [t_c, M_c] = sovs.segment.rmNonMonotonic(t, M);

            testCase.verifyEqual(t_c, [1, 8], 'Ref row vector failed.');
            testCase.verifyEqual(M_c, [10 20 30; 100 110 120], 'Smart inference matrix slicing failed.');
        end

        function testExplicitDimensionForce(testCase)
            % Test 3: Force a specific dimension and test failure
            t = [1, 2, 1, 4]; % 1x4
            M = [10 20 30; 40 50 60]; % 2x3 Matrix

            % Use local function to force nargout > 0 (bypassing visualization mode)
            testCase.verifyError(@() local_callExplicitDim(t, M), ...
                'sovs:segment:rmNonMonotonic:DimMismatch', ...
                'Did not throw error on forced dimension mismatch.');
        end

        function testLazyEvaluationAndTooManyOutputs(testCase)
            % Test 4: Requesting more outputs than provided inputs
            t = [1, 2, 3];
            v1 = [10, 20, 30];

            testCase.verifyError(@() local_callTooMany(t, v1), ...
                'sovs:segment:rmNonMonotonic:TooManyOutputs', ...
                'Did not throw TooManyOutputs error.');
        end

        function testRefMustBeVector(testCase)
            % Test 5: Passing a matrix as Ref should error out
            M = [1 2; 3 4];
            testCase.verifyError(@() sovs.segment.rmNonMonotonic(M), ...
                'sovs:segment:rmNonMonotonic:NotAVector', ...
                'Did not block matrix reference.');
        end
    end
end

% --- Local Helper Functions ---
% These helpers force nargout > 0 to prevent the function from falling back
% into "Visualization/Report Mode" during error testing.

function [o1, o2] = local_callExplicitDim(t, M)
[o1, o2] = sovs.segment.rmNonMonotonic(t, 2, M);
end

function [o1, o2, o3] = local_callTooMany(t, v)
[o1, o2, o3] = sovs.segment.rmNonMonotonic(t, v);
end