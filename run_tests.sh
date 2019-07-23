#!/usr/bin/env bash

# COMPILER PROGRAM NAME
COMP="m19"

# TARGET IS WHAT CODE WILL BE GENERATED
TARGET="asm"

# TEST GROUP TO RUN - DEFAULT RUNS ALL
TESTS=""

# COLORS
B="\e[1;94m"
W="\e[1;97m"

R="\e[1;31m"
G="\e[1;32m"
O="\e[1;33m"
D="\e[0;39m"

BK_B="\e[0;44m"
BK_D="\e[0;49m"

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
    printf "${G}ok${D}"
  else
    printf "${R}failed${D}"
  fi
  cd ${TEST_DIR}
}

# YASM
function assembler() {
  declare test_name="$1"

  if [[ ! -f $test_name.asm ]]; then
    printf "${R}failed${D}"
    return
  fi

  yasm -felf32 $test_name.asm > /dev/null 2>&1

  if [[ $? -eq 0 ]]; then
    YASMOK=$(( YASMOK += 1 ))
    printf "${G}ok${D}"
  else
    printf "${R}failed${D}"
  fi
}

# LINKER
function linker() {
  declare test_name="$1"

  if [[ ! -f $test_name.o ]]; then
    printf "${R}failed${D}"
    return
  fi

  ld $test_name.o -m elf_i386 -L${LIB_DIR} -lrts -o $test_name > /dev/null 2>&1

  if [[ $? -eq 0 ]]; then
    LDOK=$(( LDOK += 1 ))
    printf "${G}ok${D}"
  else
    printf "${R}failed${D}"
  fi
}

# RUNNING
function running() {
  declare test="$1"

  if [[ ! -f $test ]]; then
    printf "${R}failed${D}"
    return
  fi

  ./$test > expected/$test.myout
  if [[ $? -eq 0 ]]; then
    printf "${G}ok${D}"
    OK=$(( OK += 1 ))
  else
    printf "${R}failed${D}"
  fi

  if [[ "$(diff -w -E -B expected/$test.out expected/$test.myout)" ]]; then
    printf "\n${R}TEST FAILED!!${D}\n"
    printf "$(diff -c expected/$test.out expected/$test.myout)"
    printf "\n"
  else
    printf "\n${G}TEST PASSED!!${D}\n"
    PASSED=$(( PASSED +=1 ))
  fi
  rm $test
}

function runtest() {
  declare test_name="$1"

  printf "${BK_B}                              ${W}$test_name${D}${BK_B}                              ${BK_D}\n"

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
  for file in $TESTS*.$COMP; do
    # INCREMENT TEST COUNT
    TOTAL=$(( TOTAL += 1 ))

    # GET TEST NAME
    NAME=`echo "$file" | cut -d'.' -f1`

    runtest $NAME
  done
}

function results() {
  printf "\n"
  printf "${W}==============================[ ${B}RESULTS${W} ]================================${D}\n"
  printf "   ${O}COMPILER${D} ${B}:${D} $COMPOK/$TOTAL tests with ${G}OK\n"
  if [[ $TARGET == "asm" ]]; then
    printf "       ${O}YASM${D} ${B}:${D} $YASMOK/$TOTAL tests with ${G}OK\n"
    printf "         ${O}LD${D} ${B}:${D} $LDOK/$TOTAL tests with ${G}OK\n"
    printf "        ${O}RUN${D} ${B}:${D} $OK/$TOTAL tests with ${G}OK\n"
    printf "     ${O}PASSED${D} ${B}:${D} $PASSED/$TOTAL tests with ${G}OK\n"
  fi
  printf "${W}=========================================================================${D}\n"
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
  source "${HOME}/runtests-m19/config.sh" > /dev/null 2>&1

  if [[ $? -ne 0 ]]; then
    printf "[${R}!${D}] Unable to load configuration file!\n"
    exit -1
  fi

  parse_args "$@"
  runtests
  results
  cleanup
}

# EXECUTE MAIN
main "$@"
