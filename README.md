# M19 Run Tests Script

A Simple and goodlooking script to test m19 compiler.

## Getting Started

### Configuring Paths

Add absolute path to **TEST_DIR**: the directory containting all the text *.m19* files (exclude the last / from path)

```
TEST_DIR=${HOME}/m19/tests-201903052202
```

Then add the absolute path to **COMP_DIR**: the directory containing the *m19* executable (exclude the last / from path)

```
COMP_DIR=${HOME}/m19/m19
```

If you need to, add absolute path to **ROOT**: this directory contains the libcdk and librts code, this should be equal to root path in *m19* Makefile

```
 ROOT=${HOME}/compiladores/root
```

Make the script executable:

```
chmod +x run_tests.sh
```

## Running the tests

To run all tests do:

```
./run_tests.sh
```

If the paths are well configured then the script can be ran from any directory!

To run test groups, for example, if you only want to run the tests begining with A:

```
./run_tests.sh A
```

You can then run, individually, all the test groups: A, B, C, D, E, F, J, K, L, M, O, P, Q

## Built With

* [Bash](https://www.gnu.org/software/bash/) - Bash is the Bourne Again SHell

## Authors

* **Filipe Marques** - *Maintainer* - [PurpleBooth](https://github.com/filipeom)

## Acknowledgments

* Hat tip to David Matos
