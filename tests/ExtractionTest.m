classdef ExtractionTest < matlab.unittest.TestCase

    methods (Test)
        function TestExtractWidths(testCase)
            A = (1:5)' * ones(1, 5);
            scans = 3;
            index = 2;
            input = {A, A, A};
            expectedOutput = ones(5, length(scans)) * index;
            actualOutput = ExtractWidths(input, scans, index);

            verifyEqual(testCase, actualOutput, expectedOutput);
        end

        function TestExtractHeights(testCase)
            A = ones(5, 1) * (1:5);
            scans = [2 3];
            index = 2;
            input = {A, A, A};
            expectedOutput = ones(5, length(scans)) * index;
            actualOutput = ExtractHeights(input, scans, index);

            verifyEqual(testCase, actualOutput, expectedOutput);
        end
    end
end