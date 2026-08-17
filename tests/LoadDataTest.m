% tests/CalculateDataTest.m
classdef LoadDataTest < matlab.unittest.TestCase

    methods (Test)

        % --- Test 2: Verify loading ---
        function testLoadData(testCase)
            testCase.verifyError(@() loadData, 'calculateData:NegativeInput');
        end

    end
end