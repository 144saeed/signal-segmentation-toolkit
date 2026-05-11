classdef test_segment_nonMonotonicMask < matlab.unittest.TestCase
    %TEST_SEGMENT_NONMONOTONICMASK Unit tests for sovs.segment.nonMonotonicMask

    methods(Test)

        function testBasicViolationCluster(testCase)
            % Test 1: Identify a cluster that violates the trend (e.g., [2 3 2])
            y = [1, 2, 3, 2, 4, 5];
            expected = logical([0, 1, 1, 1, 0, 0]);

            mask = sovs.segment.nonMonotonicMask(y);
            testCase.verifyEqual(mask, expected, 'Failed to identify violation cluster.');
        end

        function testStallCondition(testCase)
            % Test 2: Identify stalls (consecutive equal values)
            y = [1, 2, 2, 3];
            expected = logical([0, 1, 1, 0]); % Both 2s are part of a stall

            mask = sovs.segment.nonMonotonicMask(y);
            testCase.verifyEqual(mask, expected, 'Failed to identify stalls.');
        end

        function testPurelyDecreasing(testCase)
            % Test 3: If array is strictly decreasing, ALL elements are violators
            y = [5, 4, 3, 2, 1];
            expected = true(1, 5);

            mask = sovs.segment.nonMonotonicMask(y);
            testCase.verifyEqual(mask, expected, 'Failed on purely decreasing array.');
        end

        function testMatrixProcessing(testCase)
            % Test 4: Process 2D matrix along columns
            M = [1 10; 2 9; 3 11];
            % Col 1: [1 2 3] -> [0 0 0]
            % Col 2: [10 9 11] -> [1 1 0] (10 and 9 violate the path to 11)
            expected = logical([0 1; 0 1; 0 0]);

            mask = sovs.segment.nonMonotonicMask(M, 1);
            testCase.verifyEqual(mask, expected, 'Matrix column-wise processing failed.');
        end

        function testEdgeCases(testCase)
            % Test 5: Empty arrays and scalars
            testCase.verifyEmpty(sovs.segment.nonMonotonicMask([]), 'Failed on empty array.');
            testCase.verifyEqual(sovs.segment.nonMonotonicMask(42), false, 'Failed on scalar.');

            % Already perfectly monotonic
            testCase.verifyEqual(sovs.segment.nonMonotonicMask([1 2 3 4]), false(1,4), 'Failed on perfect monotonic array.');
        end

    end
end