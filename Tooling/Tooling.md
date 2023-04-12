#Tooling

The contents of this folder are for tooling that needs additional work to install after cloning the repository.

## `pre-push`

A sample pre-push script for use as the corresponding github hook script. You can install the script by copying it into
`$REPO/.git/hooks`. It will prevent pushing to server if the last commits require being amended by `swiftformat` or
require tweaks to avoid running afoul of `swiftlint`. Both tools are assumed to be installed, in `$PATH` and up to date.
