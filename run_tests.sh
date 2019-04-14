#!/bin/bash
#==============================================================================
#                   CONFIGURE THESE VARIABLES IF NEEDED
#==============================================================================

# GIVE ABSOLUTE DIR PATHS!
TEST_DIR=${HOME}/m19/tests-201903052202
COMP_DIR=${HOME}/m19/m19

# ROOT - SAME MACROS AS IN M19 MAKEFILE
# ONLY CHANGE ROOT ACCORDING TO SYSTEM ARCHITECTURE
ROOT=${HOME}/compiladores/root

LIB_DIR=${ROOT}/usr/lib

# COMPILER EXECUTABLE NAME, SHOULDN'T HAVE TO CHANGE THIS
COMP=m19
# TARGET IS WHAT CODE TO GENERATE
TARGET=asm
TESTS=$1

#==============================================================================
#       PROBABLY, THERE'S NO NEED TO CHANGE ANYTHING BEYOND THIS POINT
#==============================================================================

declare -i COMPOK=0
declare -i YASMOK=0
declare -i LDOK=0
declare -i OK=0
declare -i PASSED=0
declare -i TOTAL=0

# GENERATE CODE
function compiler() {
  cd $COMP_DIR

  ./$COMP --target $TARGET $TEST_DIR/$1.$COMP > /dev/null 2>&1

  if [ $? -eq 0 ]; then
    COMPOK=$(( COMPOK += 1 ))
    printf "\e[32mok\e[39m"
  else
    printf "\e[31mfailed\e[39m"
  fi
  cd $TEST_DIR
}

# YASM
function assembler() {
  if [ ! -f $1.asm ]; then
    printf "\e[31mfailed\e[39m"
    return
  fi

  yasm -felf32 $1.asm > /dev/null 2>&1

  if [ $? -eq 0 ]; then
    YASMOK=$(( YASMOK += 1 ))
    printf "\e[32mok\e[39m"
  else
    printf "\e[31mfailed\e[39m"
  fi
}

# LINKER
function linker() {
  if [ ! -f $1.o ]; then
    printf "\e[31mfailed\e[39m"
    return
  fi

  ld $1.o -m elf_i386 -L$LIB_DIR -lrts -o $1 > /dev/null 2>&1

  if [ $? -eq 0 ]; then
    LDOK=$(( LDOK += 1 ))
    printf "\e[32mok\e[39m"
  else
    printf "\e[31mfailed\e[39m"
  fi
}

# RUNNING
function running() {
  if [ ! -f $1 ]; then
    printf "\e[31mfailed\e[39m\n"
    return
  fi

  ./$1 > expected/$1.myout
  if [ $? -eq 0 ]; then
    printf "\e[32mok\e[39m\n"
    OK=$(( OK += 1 ))
  else
    printf "\e[31mfailed\e[39m\n"
  fi

  if [ "$(diff -w -E -B expected/$1.out expected/$1.myout)" != "" ]; then
    printf "\e[31mTEST FAILED!!\e[39m\n"
    printf "$(diff -c expected/$1.out expected/$1.myout)"
    printf "\n"
  else
    printf "\e[32mTEST PASSED!!\e[39m\n"
    PASSED=$(( PASSED +=1 ))
  fi
  rm $1
}

function results() {
  printf "\n"
  printf "\e[97m==============================[ \e[94mRESULTS\e[97m ]================================\e[39m\n"
  printf "\e[33mCOMPILER\e[39m: $COMPOK/$TOTAL tests with \e[32mOK\n"
  if [ $TARGET == asm ]; then
    printf "\e[33mYASM\e[39m    : $YASMOK/$TOTAL tests with \e[32mOK\n"
    printf "\e[33mLD\e[39m      : $LDOK/$TOTAL tests with \e[32mOK\n"
    printf "\e[33mRUN\e[39m     : $OK/$TOTAL tests with \e[32mOK\n"
    printf "\e[33mPASSED\e[39m  : $PASSED/$TOTAL tests with \e[32mOK\n"
  fi
  printf "\e[97m=========================================================================\e[39m\n"
  printf "\n"
}

function cleanup() {
  if [ $TARGET == asm ]; then
    rm *.o *.asm expected/*.myout
  else
    rm *.xml
  fi
}

# RUN
clear
cd $TEST_DIR
for file in $TESTS*.m19; do
  TOTAL=$(( TOTAL += 1 ))

  NAME=`echo "$file" | cut -d'.' -f1`

  printf "\e[44m                              \e[97m$NAME\e[39m                              \e[49m\n"

  printf "Compiler: "
  compiler $NAME

  if [ $TARGET == asm ]; then
    printf ", YASM: "
    assembler $NAME
    printf ", LD: "
    linker $NAME
    printf ", Running: "
    running $NAME
  fi
done
# PRINT RESULTS
results
cleanup
