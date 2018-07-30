#!/bin/bash
# Test cases for helpers/generic_helper.sh
## Conditionally source test file
[[ "$(type -t 't_start')" = 'function' ]] || source test_helper.sh
source "$NVOC/helpers/generic_helper.sh"
# unset RUN_ALL

#
# gh_chr
t_start 'gh_chr'
	tf '' '' '' 1
	tf '' 0 '' 0
	tf '' -1 '' 1
	tf '' a '' 1
	tf '' 256 '' 1
	tf '' 97 'a' 0
	tf '' 122 'z' 0
t_end

#
# gh_ord
t_start 'gh_ord'
	tf '' '' 0 0
	tf '' ab '' 1
	tf '' z '122' 0
t_end

#
# gh_is_numeric
t_start 'gh_is_numeric'
	tf '' '' '' 1
	tf '' ',' '' 1
	tf '' a '' 1
	tf '' 0 '' 0
	tf '' 99 '' 0
	tf '' z '' 1
t_end