classdef test_segment_locate < matlab.unittest.TestCase
    %TEST_SEGMENT_LOCATE Unit tests for sovs.segment.locate

    methods(Test)

        function testPerfectSteadyState(testCase)
            % Test 1: A perfect step function
            t = (1:10)';
            u = [0; 0; 5; 5; 5; 5; 0; 0; 0; 0];

            % Tol=0.1, MinDur=2.
            % First zeros (t=1,2) -> dur = 1 < 2 (Ignored)
            % The '5' block (t=3 to 6) -> dur = 3 >= 2 (Segment 1)
            % Final zeros (t=7 to 10) -> dur = 3 >= 2 (Segment 2)
            [labels, n] = sovs.segment.locate(t, u, 0.1, 2.0);

            testCase.verifyEqual(n, 2, 'Should detect exactly two valid steady states.');
            testCase.verifyEqual(labels(3:6), ones(4,1), 'Failed to label the first valid steady state block correctly.');
        end

        function testNoiseWithinTolerance(testCase)
            % Test 2: Signal fluctuates but stays within tolerance
            t = (1:10)';
            u = [10; 10.05; 9.95; 10.08; 9.92; 0; 0; 0; 0; 0];

            % Tol=0.15, MinDur=3.
            % First 5 points within [9.85, 10.15] -> dur = 4 >= 3 (Segment 1)
            [labels, n] = sovs.segment.locate(t, u, 0.15, 3.0);

            testCase.verifyEqual(n, 2, 'Should detect noisy block as one steady state.');
            testCase.verifyEqual(labels(1:5), ones(5,1), 'Failed to maintain lock through acceptable noise.');
        end

        function testRejectionOfShortSpikes(testCase)
            % Test 3: A spike that is large but too short in duration
            t = (1:10)';
            u = [0; 0; 0; 10; 10; 0; 0; 0; 0; 0];

            % Tol=0.1, MinDur=3.
            % First zeros (t=1 to 3) -> dur = 2 < 3 (Ignored)
            % Spike (t=4 to 5) -> dur = 1 < 3 (Ignored)
            % Final zeros (t=6 to 10) -> dur = 4 >= 3 (Segment 1)
            [labels, n] = sovs.segment.locate(t, u, 0.1, 3.0);

            testCase.verifyEqual(n, 1, 'Should reject the short spike and the initial too-short zero block.');
            testCase.verifyEqual(labels(4:5), [0; 0], 'Spike should remain unlabeled (0).');
        end

        function testDimensionMismatch(testCase)
            % Test 4: Passing vectors of different lengths
            t = (1:10)';
            u = (1:5)';

            testCase.verifyError(@() sovs.segment.locate(t, u, 0.1, 1), ...
                'sovs:segment:locate:DimMismatch', ...
                'Did not catch dimension mismatch.');
        end

        function testEdgeCases(testCase)
            % Test 5: Empty arrays and completely flat signals

            % Empty array check
            t_empty = double.empty(0,1);
            u_empty = double.empty(0,1);
            [L_empty, n_empty] = sovs.segment.locate(t_empty, u_empty);

            testCase.verifyEmpty(L_empty, 'Failed to handle empty array gracefully.');
            testCase.verifyEqual(n_empty, 0, 'Number of segments should be 0 for empty arrays.');

            % Perfectly flat signal check
            t_flat = (1:5)';
            u_flat = zeros(5,1);
            [L_flat, n_flat] = sovs.segment.locate(t_flat, u_flat, 0.1, 2.0);

            testCase.verifyEqual(n_flat, 1, 'Failed to lock onto a perfectly flat signal.');
            testCase.verifyEqual(L_flat, ones(5,1), 'Flat signal should be labeled entirely as segment 1.');
        end

    end
end