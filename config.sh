#!/usr/bin/env bash

set -o nounset

#==============================================================================
#                   CONFIGURE THESE VARIABLES IF NEEDED
#==============================================================================
# GIVE ABSOLUTE DIR PATHS!
TEST_DIR="${HOME}/runtests-m19/tests"
COMP_DIR="${HOME}/m19"

# ROOT - SAME PATH AS ROOT VAR IN M19 MAKEFILE!
ROOT="${HOME}/compiladores/root"

#==============================================================================
#       PROBABLY, THERE'S NO NEED TO CHANGE ANYTHING BEYOND THIS POINT
#==============================================================================
# LIB PATH - USED IN LINKER
LIB_DIR="${ROOT}/usr/lib"
