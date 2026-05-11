classdef test_segment_bounds < matlab.unittest.TestCase
    %TEST_SEGMENT_BOUNDS Unit tests for sovs.segment.bounds

    methods(Test)

        function test1DVector(testCase)
            % Test 1: Simple 1D logical array
            A = logical([0 0 1 1 1 0 1 0]);
            [s, e, len] = sovs.segment.bounds(A);

            testCase.verifyEqual(s, [3; 7], 'Starts failed on 1D vector.');
            testCase.verifyEqual(e, [5; 7], 'Ends failed on 1D vector.');
            testCase.verifyEqual(len, [3; 1], 'Lengths failed on 1D vector.');
        end

        function test2DMatrix(testCase)
            % Test 2: 2D array along default dimension (dim=1)
            A = logical([0 1; 1 1; 1 0; 0 0]);
            [s, e, len] = sovs.segment.bounds(A, 1);

            testCase.verifyEqual(s{1}, 2, 'Starts failed for Col 1.');
            testCase.verifyEqual(s{2}, 1, 'Starts failed for Col 2.');
            testCase.verifyEqual(len{1}, 2, 'Lengths failed for Col 1.');
        end

        function testEdgeCases(testCase)
            % Test 3: Edge cases (All zeros, All ones)

            % All zeros
            A_zero = false(1, 5);
            [s_z, e_z, ~] = sovs.segment.bounds(A_zero);
            testCase.verifyEmpty(s_z, 'Should be empty for all zeros.');
            testCase.verifyEmpty(e_z, 'Should be empty for all zeros.');

            % All ones
            A_one = true(1, 5);
            [s_o, e_o, len_o] = sovs.segment.bounds(A_one);
            testCase.verifyEqual(s_o, 1, 'Start should be 1 for all ones.');
            testCase.verifyEqual(e_o, 5, 'End should be 5 for all ones.');
            testCase.verifyEqual(len_o, 5, 'Length should be 5 for all ones.');
        end

        function testNargoutVariants(testCase)
            % Test 4: Verify behavior for different output requests
            A = logical([1 1 0 1]);

            % 1 Output
            s_only = sovs.segment.bounds(A);
            testCase.verifyEqual(s_only, [1; 4], 'Failed for 1 output.');

            % 2 Outputs
            [s_two, e_two] = sovs.segment.bounds(A);
            testCase.verifyEqual(s_two, [1; 4], 'Starts failed for 2 outputs.');
            testCase.verifyEqual(e_two, [2; 4], 'Ends failed for 2 outputs.');
        end

    end
end