classdef test_segment_prune < matlab.unittest.TestCase
    %TEST_SEGMENT_PRUNE Unit tests for sovs.segment.prune

    methods(Test)

        function testBasic1DPruning(testCase)
            % Test 1: Remove segments shorter than 3 in a 1D logical array
            x = logical([0 1 1 0 1 1 1 0 1]);
            expected = logical([0 0 0 0 1 1 1 0 0]);

            result = sovs.segment.prune(x, 3);
            testCase.verifyEqual(result, expected, 'Basic 1D pruning failed.');
        end

        function testMatrixDimensions(testCase)
            % Test 2: Multi-dimensionality processing (Rows vs Cols)
            M = logical([1 1 0;
                1 1 1]);

            % Prune along dimension 2 (Rows) with minLen 3
            % Row 1 has length 2 -> becomes 0. Row 2 has length 3 -> stays 1.
            res_row = sovs.segment.prune(M, 3, 2);
            exp_row = logical([0 0 0; 1 1 1]);
            testCase.verifyEqual(res_row, exp_row, 'Matrix dimension 2 pruning failed.');

            % Prune along dimension 1 (Columns) with minLen 2
            % Col 1 & 2 have length 2 -> stay 1. Col 3 has length 1 -> becomes 0.
            res_col = sovs.segment.prune(M, 2, 1);
            exp_col = logical([1 1 0; 1 1 0]);
            testCase.verifyEqual(res_col, exp_col, 'Matrix dimension 1 pruning failed.');
        end

        function testDataTypePreservation(testCase)
            % Test 3: Ensure double stays double and logical stays logical

            % Logical
            L_in = logical([1 1 0]);
            L_out = sovs.segment.prune(L_in, 3);
            testCase.verifyClass(L_out, 'logical', 'Logical class was not preserved.');

            % Double (Output will be 0 and 1, but class must be double)
            D_in = double([5 5 0]);
            D_out = sovs.segment.prune(D_in, 3);
            testCase.verifyClass(D_out, 'double', 'Double class was not preserved.');
        end

        function testEdgeCases(testCase)
            % Test 4: Empty, All False, All True
            testCase.verifyEmpty(sovs.segment.prune([]), 'Empty array failed.');

            x_false = false(1, 10);
            testCase.verifyEqual(sovs.segment.prune(x_false, 5), x_false, 'All false array failed.');

            x_true = true(1, 5);
            testCase.verifyEqual(sovs.segment.prune(x_true, 6), false(1,5), 'All true array (too short) failed.');
        end

    end
end