classdef test_segment_labels < matlab.unittest.TestCase
    %TEST_SEGMENT_LABELS Unit tests for sovs.segment.labels

    methods(Test)

        function testLogicalArray(testCase)
            % Test 1: Standard logical array (like a binary mask)
            A = logical([0 0 1 1 0]);
            expected = [1 1 2 2 3];

            L = sovs.segment.labels(A);
            testCase.verifyEqual(L, expected, 'Failed on logical 1D array.');
        end

        function testNumericArray(testCase)
            % Test 2: Numeric array with multiple states
            A = [5 5 10 10 10 3 3];
            expected = [1 1 2 2 2 3 3];

            L = sovs.segment.labels(A);
            testCase.verifyEqual(L, expected, 'Failed on numeric 1D array.');
        end

        function testCharArray(testCase)
            % Test 3: Character arrays (diff works on chars too)
            A = 'aabbbc';
            expected = [1 1 2 2 2 3];

            L = sovs.segment.labels(A);
            testCase.verifyEqual(L, expected, 'Failed on character array.');
        end

        function testMatrixDimension(testCase)
            % Test 4: 2D Matrix along different dimensions
            A = [0 0; 0 1; 1 1];

            % Along rows (dim 1)
            L_row = sovs.segment.labels(A, 1);
            expected_row = [1 1; 1 2; 2 2];
            testCase.verifyEqual(L_row, expected_row, 'Failed matrix row-wise (dim 1).');

            % Along columns (dim 2)
            L_col = sovs.segment.labels(A, 2);
            expected_col = [1 1; 1 2; 1 1];
            testCase.verifyEqual(L_col, expected_col, 'Failed matrix col-wise (dim 2).');
        end

        function testEdgeCases(testCase)
            % Test 5: Edge cases (Single element, Empty array)
            testCase.verifyEqual(sovs.segment.labels(5), 1, 'Failed on scalar.');
            testCase.verifyEmpty(sovs.segment.labels([]), 'Failed on empty array.');

            % All identical values
            A_same = ones(1, 5);
            testCase.verifyEqual(sovs.segment.labels(A_same), ones(1, 5), 'Failed on identical array.');
        end

    end
end