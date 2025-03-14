Get code to throw internal errors and handle and rethrow external errors?


When running tests, why can't I set breakpoints in find_files_without.sh?


Debugging is difficult because the tests are using newline delimiters \n, so when I set breakspoints and inspect variables I don't see the full result unless I echo to the screen. I don't think this makes it easy to compare the result with the expected result.
  - this might be the reason why the end result is not printing in a grid format.. because of the delimeter issue.


failure_cases.sh is a bit of a mess. I think some of the tests are passing incorrectly. For example, test_excessive_depth should be failing but it's not.