ISSUE:

**eza formatting and multi-column format gets stripped.**

All methods like eval, bash -c, bash -s, or even here-docs break TTY detection, so eza disables --grid formatting.

eza --grid will only show proper columns if stdout is a real terminal (TTY) — not a subshell, pipe, or redirected stream.



Results look like this:

 src/      README.md      index.js

(Columns are intact, and color. But icons aren't rendering.)

Add this to settings;
    "terminal.integrated.fontFamily": "JetBrainsMono Nerd Font"

Add this to launch.json:
    "terminalKind": "integrated"

  - Printing it in the terminal instead of Debug Console helps with the grid columns.
    - it seems as if Debug Console can only print things in a single column. # LEARN



Get code to throw internal errors and handle and rethrow external errors?


When running tests, why can't I set breakpoints in find_files_without.sh?


Debugging is difficult because the tests are using newline delimiters \n, so when I set breakspoints and inspect variables I don't see the full result unless I echo to the screen. I don't think this makes it easy to compare the result with the expected result.
  - this might be the reason why the end result is not printing in a grid format.. because of the delimeter issue.


failure_cases.sh is a bit of a mess. I think some of the tests are passing incorrectly. For example, test_excessive_depth should be failing but it's not.



pipeline/a.sh and pipeline/b.sh functions are not even being called.