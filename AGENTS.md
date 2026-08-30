# Repo rules

## Scope narrowly
Declare variables, functions, and config at the tightest scope that works.
Widen only when a second consumer actually exists.

## Name your regexes
Never inline a regex. Bind it to a variable named for what it matches, then
use the variable.
