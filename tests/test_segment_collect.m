classdef test_segment_collect < matlab.unittest.TestCase
    %TEST_SEGMENT_COLLECT Unit tests for sovs.segment.collect

    methods(Test)

        function testModeA_IndicesOnly(testCase)
            mask = logical([0 1 1 0 1]);
            idxCells = sovs.segment.collect(mask);

            testCase.verifyEqual(numel(idxCells), 2, 'Should find 2 segments.');
            testCase.verifyEqual(idxCells{1}, [2; 3], 'First segment indices failed.');
            testCase.verifyEqual(idxCells{2}, 5, 'Second segment index failed.');
        end

        function testModeB_SingleDataVector(testCase)
            mask = logical([1 1 0 1]);
            data = [10; 20; 30; 40];
            dataCells = sovs.segment.collect(mask, data);

            testCase.verifyEqual(dataCells{1}, [10; 20], 'First chunk failed.');
            testCase.verifyEqual(dataCells{2}, 40, 'Second chunk failed.');
        end

        function testModeB_MatrixSlicing(testCase)
            mask = logical([0 1 1 0]);
            matrixData = [1 2; 3 4; 5 6; 7 8];
            matCells = sovs.segment.collect(mask, matrixData);

            testCase.verifyEqual(matCells{1}, [3 4; 5 6], 'Matrix slicing failed.');
        end

        function testModeB_MultipleOutputs(testCase)
            mask = logical([1 0 1]);
            d1 = [10; 20; 30];
            d2 = [0.1; 0.2; 0.3];

            [out1, out2] = sovs.segment.collect(mask, d1, d2);

            testCase.verifyEqual(out1{2}, 30, 'Multiple output D1 failed.');
            testCase.verifyEqual(out2{2}, 0.3, 'Multiple output D2 failed.');
        end

        function testError_DimMismatch(testCase)
            mask = logical([1 0]);
            data = [10; 20; 30];

            testCase.verifyError(@() sovs.segment.collect(mask, data), ...
                'sovs:segment:collect:DimMismatch', ...
                'Did not throw dimension mismatch error.');
        end

        function testError_TooManyOutputs(testCase)
            mask = logical([1 0]);
            data = [10; 20];

            % Using a local function to safely request multiple outputs
            testCase.verifyError(@() local_callTwoOutputs(mask, data), ...
                'sovs:segment:collect:TooManyOutputs', ...
                'Did not throw too many outputs error.');
        end

    end
end

% --- Local Helper Functions ---
function [o1, o2] = local_callTwoOutputs(mask, data)
[o1, o2] = sovs.segment.collect(mask, data);
end