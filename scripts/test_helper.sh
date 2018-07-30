#!/bin/bash
# package name:t
# Test helper file
#

# GLOBAL VARIABLES
N='\e[0m'     # Normal
B='\e[1m'     # Bold
R='\e[31m'    # Red
G='\e[32m'    # Green
C='\e[36m'    # Cyan
Y='\e[33m'    # Yellow

# Get scripts location
## conditionally load the NVOC folder
# CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/../"
[[ ! -z $NVOC ]] || NVOC='/shared/nvoc'

declare -A TOTAL_RUN
declare -A TOTAL_FAIL
# RUN_ALL='1'
####################################     Public Functions Start     ##################################


## Mark the Starting point of the tests for each function
 # ARGUMENTS:
 #    $1 str  - Assign test function name to FUNC
 #    $2 obj  - Run tests defined after this point
 #    GLOBAL:
 #        FUNC
 #        RUN_TEST
function t_start () {
  FUNC=$1
  RUN_TEST=$2
  if ! [[ -z $RUN_ALL && -z $RUN_TEST ]]; then
    TOTAL_RUN[$FUNC]=0
    TOTAL_FAIL[$FUNC]=0
    echo -e "${Y}${B}==================== $FUNC TESTS START ====================${N}"
  else
    echo -e "${Y}- Skip $FUNC Tests${N}"
  fi
}

## Mark the Ending point of the tests for each function
 # ARGUMENTS:
 #    - n/a
 #    GLOBAL:
 #        FUNC
 #        RUN_TEST
function t_end () {
  if ! [[ -z $RUN_ALL && -z $RUN_TEST ]]; then
    echo -e "${Y}${B}==================== $FUNC TESTS END ====================\n${N}"
  fi
  unset FUNC
  unset RUN_TEST
}

## Test Function
 # - Run the predefined function with supply arguments, printing result and analysis to stdout
 # ARGUMENTS:
 #    $1 str  - Test description
 #    $2 str  - arguments with quotes
 #    $3 str  - The expected value
 #    $4 int  - The expected return code, if unset, te function will not check return code value
 #    GLOBAL:
 #        RUN_ALL - Run all tests
 #        RUN_TEST- Run only this 
 #        FUNC    - Predefined Function 
 # NOTES:
 #   - functions and arguments will be run with: $(eval $FUNC ${args})
 #   - Function is run in subshell, use run expression if you wish to run command that affect current scope
function tf () { 
  if ! [[ -z $RUN_ALL && -z $RUN_TEST ]]; then
    local desc=$1 \
      args=$2 \
      expected=$3 \
      expected_return_code=$4 \
      actual \
      actual_return_code \
      report=''
    # echo "FUNC '$FUNC'"
    # echo "args '$args'"
    actual=$(eval $FUNC ${args})
    actual_return_code=$?
    (( TOTAL_RUN[$FUNC]++ ))
    [[ "$actual" == "$expected" ]] && report="${G}${B}PASSED!${N}" || { report="${R}${B}FAILED!${N}" ; (( TOTAL_FAIL[$FUNC]++ )); }
    echo -e "$report - ${C}${B}$FUNC${N} - ${desc:-"args: '${args}'"} ${C}${B}EXPECTING${N}:'$expected'; ${C}${B}ACTUAL${N}:'$actual'"
    if [[ ! -z $expected_return_code ]]; then
      (( TOTAL_RUN[$FUNC]++ ))
      [[ $expected_return_code -eq $actual_return_code ]] && report="${G}${B}PASSED!${N}" || { report="${R}${B}FAILED!${N}"; (( TOTAL_FAIL[$FUNC]++ )); }
      echo -e "$report - ${C}$FUNC${N} - $desc ${C}EXPECTING RETURN CODE${N}:'$expected_return_code'; ${C}ACTUAL${N}:'$actual_return_code'"
    fi
  fi
}

## Test Expression
 # Run the supplied expression, printing result and analysis to stdout
 # ARGUMENTS:
 #    $1 str  - Test description
 #    $2 str  - Expression to be eval and check
 #    $3 str  - The expected value
 #    $4 int  - The expected return code, if unset, te function will not check return code value
 #    GLOBAL:
 #        RUN_ALL - Run all tests
 #        RUN_TEST- Run only this
 # NOTES:
 #   - Expression will be run with: eval ac="$expression"
function te () {
  if ! [[ -z $RUN_ALL && -z $RUN_TEST ]]; then
    local desc=$1 \
      expression=$2 \
      expected=$3 \
      expected_return_code=$4 \
      ac ac_return_code \
      report=''

    eval ac="$expression"
    ac_return_code=$?
    (( TOTAL_RUN[$FUNC]++ ))
    [[ "$ac" == "$expected" ]] && report="${G}${B}PASSED!${N}" || { report="${R}${B}FAILED!${N}"; (( TOTAL_FAIL[$FUNC]++ )); }
    echo -e "$report - ${C}${B}$expression${N} - $desc ${C}${B}EXPECTING${N}:'$expected'; ${C}${B}ACTUAL${N}:'$ac'"
    if [[ ! -z $expected_return_code ]]; then
      (( TOTAL_RUN[$FUNC]++ ))
      [[ $expected_return_code -eq $ac_return_code ]] && report="${G}${B}PASSED!${N}" || { report="${R}${B}FAILED!${N}"; (( TOTAL_FAIL[$FUNC]++ )); }
      echo -e "$report - ${C}$expression${N} - $desc ${C}EXPECTING RETURN CODE${N}:'$expected_return_code'; ${C}ACTUAL${N}:'$ac_return_code'"
    fi
  fi
}

####################################      Public Functions End      ##################################
