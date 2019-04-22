#!/usr/bin/env bash

set -o nounset

#==============================================================================
#                   CONFIGURE THESE VARIABLES IF NEEDED
#==============================================================================

# GIVE ABSOLUTE DIR PATHS!
TEST_DIR=${HOME}/m19/tests-201903052202
COMP_DIR=${HOME}/m19/m19

# ROOT - SAME PATH AS ROOT VAR IN M19 MAKEFILE!
ROOT=${HOME}/compiladores/root

#==============================================================================
#       PROBABLY, THERE'S NO NEED TO CHANGE ANYTHING BEYOND THIS POINT
#==============================================================================
# LIB PATH - USED IN LINKER
LIB_DIR=${ROOT}/usr/lib

# COMPILER PROGRAM NAME
COMP=m19
# TARGET IS WHAT CODE WILL BE GENERATED
TARGET="asm"
# TEST GROUP TO RUN - DEFAULT RUNS ALL
TESTS=""

declare -i COMPOK=0
declare -i YASMOK=0
declare -i LDOK=0
declare -i OK=0

declare -i PASSED=0
declare -i TOTAL=0

# GENERATE CODE
function compiler() {
  cd ${COMP_DIR}

  ./$COMP --target $TARGET ${TEST_DIR}/$1.$COMP > /dev/null 2>&1

  if [[ $? -eq 0 ]]; then
    COMPOK=$(( COMPOK += 1 ))
    printf "\e[32mok\e[39m"
  else
    printf "\e[31mfailed\e[39m"
  fi
  cd ${TEST_DIR}
}

# YASM
function assembler() {
  declare test_name="$1"

  if [[ ! -f $test_name.asm ]]; then
    printf "\e[31mfailed\e[39m"
    return
  fi

  yasm -felf32 $test_name.asm > /dev/null 2>&1

  if [[ $? -eq 0 ]]; then
    YASMOK=$(( YASMOK += 1 ))
    printf "\e[32mok\e[39m"
  else
    printf "\e[31mfailed\e[39m"
  fi
}

# LINKER
function linker() {
  declare test_name="$1"

  if [[ ! -f $test_name.o ]]; then
    printf "\e[31mfailed\e[39m"
    return
  fi

  ld $test_name.o -m elf_i386 -L${LIB_DIR} -lrts -o $test_name > /dev/null 2>&1

  if [[ $? -eq 0 ]]; then
    LDOK=$(( LDOK += 1 ))
    printf "\e[32mok\e[39m"
  else
    printf "\e[31mfailed\e[39m"
  fi
}

# RUNNING
function running() {
  declare test="$1"

  if [[ ! -f $test ]]; then
    printf "\e[31mfailed\e[39m\n"
    return
  fi

  ./$test > expected/$test.myout
  if [[ $? -eq 0 ]]; then
    printf "\e[32mok\e[39m\n"
    OK=$(( OK += 1 ))
  else
    printf "\e[31mfailed\e[39m\n"
  fi

  if [[ "$(diff -w -E -B expected/$test.out expected/$test.myout)" ]]; then
    printf "\e[31mTEST FAILED!!\e[39m\n"
    printf "$(diff -c expected/$test.out expected/$test.myout)"
    printf "\n"
  else
    printf "\e[32mTEST PASSED!!\e[39m\n"
    PASSED=$(( PASSED +=1 ))
  fi
  rm $test
}

function runtest() {
  declare test_name="$1"

  printf "\e[44m                              \e[97m$test_name\e[39m                              \e[49m\n"

  printf "Compiler: "
  compiler $test_name

  if [[ $TARGET != "asm" ]]; then
    printf "\n"
    return
  fi

  printf ", YASM: "
  assembler $test_name

  printf ", LD: "
  linker $test_name

  printf ", Running: "
  running $test_name
}

function runtests() {
  cd ${TEST_DIR}
  for file in $TESTS*.m19; do
    # INCREMENT TEST COUNT
    TOTAL=$(( TOTAL += 1 ))

    # GET TEST NAME
    NAME=`echo "$file" | cut -d'.' -f1`

    runtest $NAME
  done
}

function results() {
  printf "\n"
  printf "\e[97m==============================[ \e[94mRESULTS\e[97m ]================================\e[39m\n"
  printf "\e[33mCOMPILER\e[39m: $COMPOK/$TOTAL tests with \e[32mOK\n"
  if [[ $TARGET == "asm" ]]; then
    printf "\e[33mYASM\e[39m    : $YASMOK/$TOTAL tests with \e[32mOK\n"
    printf "\e[33mLD\e[39m      : $LDOK/$TOTAL tests with \e[32mOK\n"
    printf "\e[33mRUN\e[39m     : $OK/$TOTAL tests with \e[32mOK\n"
    printf "\e[33mPASSED\e[39m  : $PASSED/$TOTAL tests with \e[32mOK\n"
  fi
  printf "\e[97m=========================================================================\e[39m\n"
  printf "\n"
}

function cleanup() {
  if [[ $TARGET == "asm" ]]; then
    rm *.o *.asm expected/*.myout
  else
    rm *.xml
  fi
}

function show_help() {
  printf "USAGE: ${0##*/} [-p PREFIX] [-t TARGET]\n\n"
  printf "Runs tests files with m19. if PREFIX is set then only the tests that\n"
  printf "begin with said PREFIX will be ran. TARGET is either xml or asm, the\n"
  printf "default value of TARGET is asm.\n"
  printf "    -h         display this help and exit\n"
  printf "    -p PREFIX  run test beginig with PREFIX\n"
  printf "    -t TARGET  run m19 to generate TARGET\n\n"
}

function parse_args() {
  local OPTIND=1

  while getopts "hp:t:" opt; do
    case "${opt}" in
      h)
        show_help
        exit 0
        ;;
      p)
        TESTS="$OPTARG"
        ;;
      t)
        TARGET="$OPTARG"
        ;;
    esac
  done
  shift "$(( OPTIND - 1 ))"
}

function main() {
  parse_args "$@"
  runtests
  results
  cleanup
}

# EXECUTE MAIN
main "$@"
