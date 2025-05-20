# Occasional Example

This repository contains a toy example of a program that crashes *randomly*. The
main goal is to demonstrate debugging techniques for intermittent failures,
specifically using the `commands` command of `gdb`.

The ultimate goal is to use the debugger to set a breakpoint only when the
program fails, allowing you to inspect the state of the program at the moment of
the crash and understand the cause of the intermittent failure.

## Building

To build the C++/Fortran versions of the occasional example, run:

```bash
make
```

This will compile the source files `occasional.cpp`/`occasional.f90` and produce
the executables `occasional-*.exe`.

Both codes use a pseudo-random number to provide the intermittent failure. A
random integer is generated between 0-99 and if it is above a set value (in this
case 75) it will run a deliberate memory violation. In C++ we dereference a
null pointer.

```cpp
    int *ptr = nullptr;
    *ptr = 42; // Dereferencing a null pointer to cause a crash
```

In fortran, we deallocate unallocated memory.

```fortran
    deallocate(arr) ! attempt to deallocate unallocated array
```

## Debugging

`gdb` debug scripts (`occasional-*.gdb`) are provided to help debug the C++ and
fortran versions of the code. To debug the fortran program using `gdb` and the
provided script, we could run:

```bash
gdb -x occasional-f90.gdb occasional-f90.exe
```

the `-x [filename]` command tells `gdb` to execute `gdb` commands from the file
`[filename]` whilst debugging the program `occasional-f90.exe`.

Let's breakdown the scrip a little so we can understand whats going on. Looking
at the debug script provided `occasional-f90.gdb` (similar version for
c++ `occasional-cpp.gdb`) we have the following:

```gdb
start
b _gfortran_runtime_error_at
b _exit
commands
silent
run
end
c
```

- `start`: Runs the program until the beginning of the `main` function (or
  program entry point), allowing you to set breakpoints before any user code
  executes.
- `b _gfortran_runtime_error_at`: Sets a breakpoint at the Fortran runtime error
  handler, so execution will stop if a Fortran runtime error occurs. (this is
  not necessary for the C++ code as `gdb` with catch the `SIGSEGV` signal)
- `b _exit`: Sets a breakpoint at the program exit function, we will use this in
  combination with the `commands` command to tell `gdb` to continue when the
  program exits normally.
- `commands`: Begins a block of commands to be executed automatically when a
  breakpoint is hit (`commands` will apply to the most recently declared
  breakpoint, but it is possible to specify a space-separated breakpoint list).
  You can then enter `gdb` commands separated by a newline. Finally a `commands`
  block should be terminated by an `end` statement.
    - `silent`: Suppresses `gdb`'s usual output when the breakpoint is hit.
    - `run`: Restarts the program from the beginning when the breakpoint is hit.
    - `end`: Ends the block of commands associated with the breakpoint.
- `c`: Continues program execution after the breakpoints and commands have been
  set up.
