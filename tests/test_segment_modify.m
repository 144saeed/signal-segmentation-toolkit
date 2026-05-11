classdef test_segment_modify < matlab.unittest.TestCase
    %TEST_SEGMENT_MODIFY Unit tests for sovs.segment.modify

    methods(Test)

        function testSymmetricExpansion(testCase)
            % Test 1: Expand by Scalar K
            A = logical([0 0 0 1 1 0 0 0]);
            expected = logical([0 0 1 1 1 1 0 0]); % Expanded by 1 on both sides

            result = sovs.segment.modify(A, 1);
            testCase.verifyEqual(result, expected, 'Symmetric expansion failed.');
        end

        function testAsymmetricSlide(testCase)
            % Test 2: Slide right by 2 ([2, 2])
            A = logical([0 1 1 0 0 0]);
            expected = logical([0 0 0 1 1 0]);

            result = sovs.segment.modify(A, [2, 2]);
            testCase.verifyEqual(result, expected, 'Slide right failed.');
        end

        function testErosionAndVanish(testCase)
            % Test 3: Shrink a segment. If shrinkage > length, it vanishes.
            A = logical([0 1 1 1 0 0 1 0]); % Lengths: 3 and 1
            expected = logical([0 0 1 0 0 0 0 0]); % Shrink by 1 -> Length 3 becomes 1, Length 1 vanishes

            % Shrink by 1: Start moves right (+1), End moves left (-1)
            result = sovs.segment.modify(A, [1, -1]);
            testCase.verifyEqual(result, expected, 'Erosion/Vanish logic failed.');
        end

        function testEdgeMerge(testCase)
            % Test 4: Segments should merge if they grow into each other
            A = logical([0 1 0 0 1 0]);
            expected = logical([1 1 1 1 1 1]); % Expand by 1, they meet in the middle

            result = sovs.segment.modify(A, 1);
            testCase.verifyEqual(result, expected, 'Segment merging failed.');
        end

        function testMatrixDimension(testCase)
            % Test 5: 2D Matrix processing along specific dimensions
            A = logical([0 1 0; 0 0 0]);

            % Expand along columns (dim 2)
            res_col = sovs.segment.modify(A, 1, 2);
            expected_col = logical([1 1 1; 0 0 0]);
            testCase.verifyEqual(res_col, expected_col, 'Matrix column expansion failed.');

            % Slide down (dim 1)
            res_row = sovs.segment.modify(A, [1, 1], 1);
            expected_row = logical([0 0 0; 0 1 0]);
            testCase.verifyEqual(res_row, expected_row, 'Matrix row slide failed.');
        end

    end
end