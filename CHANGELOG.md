# 2.2.0
A number of bug fixes and improvements, namely:

1. Fix handling of anonymous kwargs.
2. Fix formatting for nested classes when the parent class has methods.
3. Upgrade to v3.0 of the parser gem.
4. For certain types, the class name cannot be used as a type (eg. anonymous classes). Use `T.untyped` in these cases.
5. Add better support for Minitest via `require 'gelauto/minitest'`. This allows you to add Gelauto directly to your test setup, which works better than using the CLI for some projects.

# 2.1.0
* Do not add duplicate signatures to methods (@wpride, #15).

# 2.0.0
* Fix emission of `T::Array`, `T::Hash`, and `T.any` types (@wpride, #14).
* BREAKING: Add ability to write RBI output to a file via the `--rbi` flag. `--rbi` used to be a switch, but now it's a flag that accepts either a file path or `-` for STDOUT.

# 1.3.0
* Add `GELAUTO_FILES` and `GELAUTO_ANNOTATE` environment variables to RSpec helper.

# 1.2.0
* Print example usage and global help if CLI is run with no arguments.

# 1.1.0
* Print log output to STDERR.
* Add global --silent CLI option to quash all Gelauto log output.
* Add `--rbi` flag to `run` subcommand to separate RBI output functionality from file annotation.

# 1.0.2
* Correctly restore Ruby load path after command execution.

# 1.0.1
* Require gelauto/version in gelauto executable (d'oh!)

# 1.0.0
* Birthday!
