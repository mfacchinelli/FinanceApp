function testResults = runFinanceAppTests()

% Import test packages.
import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.CodeCoveragePlugin

% Retrieve tests for app.
testSuite = TestSuite.fromPackage("test");

% Add test runner for code coverage.
runner = TestRunner.withTextOutput;
runner.addPlugin(CodeCoveragePlugin.forFolder(pwd));

% Run tests.
testResults = runner.run(testSuite);