classdef LoadDataTest < matlab.unittest.TestCase
    
    methods(Test)
        
        function testExpectedError(testCase)
            % 2. The "Error" Test
            % Wrap the call in an empty anonymous function: @() 
            % This delays execution so verifyError can catch the crash.
            testCase.verifyError(@() loadData, 'MyApp:MissingConfig');
            
            % Note: In MATLAB, you can also pass the function handle directly 
            % for zero-input functions like this:
            % testCase.verifyError(@myNoInputFunction, 'MyApp:MissingConfig');
        end
        
    end
end