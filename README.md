# M19 Run Tests Script

A Simple and "good looking" script to test m19 compiler.

<p align="center">
  <img width="593px" height="697px" src="https://raw.githubusercontent.com/filipeom/m19-runtests/master/images/runscript.png">
</p>

## Getting Started

### Configuring Paths

In the `config.sh` file:

Add absolute path to **TEST_DIR**: the directory containting all the text `.m19` files (exclude the last / from path), example:

```
TEST_DIR=${HOME}/m19/tests-201903052202
```

Then add the absolute path to **COMP_DIR**: the directory containing the `m19` executable (exclude the last / from path), example:

```
COMP_DIR=${HOME}/m19/m19
```

If you need to, add absolute path to **ROOT**: this directory contains the libcdk and librts code, this should be equal to root path in m19 `Makefile`

```
ROOT=${HOME}/compiladores/root
```

Make the script executable:

```
chmod +x run_tests.sh
```

## Running the tests

### Usage

```
USAGE: ./run_tests.sh [-h] [-p PREFIX] [-t TARGET]
Runs test files with m19. if PREFIX is set then only the tests that
begin with said PREFIX will be ran. TARGET is either xml or asm, the
default value of TARGET is asm.

-h        display this help and exit
-p PREFIX run test starting with PREFIX
-t TARGET run m19 to generate TARGET

```

### Examples

To run all tests do:

```
./run_tests.sh
```

If the paths are well configured then the script can be ran from any directory!

To run test groups, for example, if you only want to run the tests begining with A:

```
./run_tests.sh -p A
```

You can then run, individually, all the test groups: A, B, C, D, E, F, J, K, L, M, O, P, Q

To run all tests in xml simply do:

```
./run_tests.sh -t xml
```

## Built With

* [Bash](https://www.gnu.org/software/bash/) - Bash is the Bourne Again SHell

## Authors

* **Filipe Marques** - *Maintainer* - [filipeom](https://github.com/filipeom)

## Acknowledgments

* Hat tip to David Matos
