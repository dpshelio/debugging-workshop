# Occasional Example

This exercise focusses on a program that crashes *randomly*. This will help us learn debugging
techniques for intermittent failures, specifically using the `commands` command of `gdb`.

The ultimate goal is to use the debugger to set a breakpoint only when the program fails, allowing
you to inspect the state of the program at the moment of the crash and understand the cause of the
intermittent failure.

## Lesson Objectives

- [x] automate commands to run when a breakpoint is hit
- [x] script debug sessions

## Building

To build the C++/Fortran versions of the occasional example, run:

```bash
make
```

This will compile the source files `occasional.cpp`/`occasional.f90` and produce the executables
`occasional-*.exe`.

## Debugging

This example program uses a pseudo-random number generator to provide the intermittent failure. A
random integer is generated between 0-99 and if it is above a set value (in this case 75) it will
run a deliberate memory violation. In C++ we dereference a null pointer.

```cpp
    int *ptr = nullptr;
    *ptr = 42; // Dereferencing a null pointer to cause a crash
```

In Fortran, we deallocate unallocated memory.

```fortran
    deallocate(arr) ! attempt to deallocate unallocated array
```

### Automate commands on breakpoint

As mentioned above our target program contains a deliberate memory error which is only triggered
pseudo-randomly. We want the debugger to only stop when we hit this error, otherwise we want it to
keep running our program. In this example, I have already explained exactly where the error occurs,
however, let's pretend we don't know -- the more realistic case. 

So, how can we tell the debugger to keep going and only stop when we hit an error. `gdb` gives users
the possibility to execute arbitrary commands when a breakpoint is hit, using the `command` command.
We will take advantage of this feature to automate our debugging session.

Firstly, let's start our debug session

```
$ gdb -q occasional-cpp.exe
Reading symbols from occasional-cpp.exe...
(gdb) start
Temporary breakpoint 1 at 0x11d1: file occasional.cpp, line 9.
Starting program: /workspaces/summer-school-debugging/exercises/ex2_occasional/occasional-cpp.exe 
warning: Error disabling address space randomization: Operation not permitted
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".

Temporary breakpoint 1, main () at occasional.cpp:9
9         std::srand(std::time(0));
(gdb) 
```

C++ and Fortran programs typically call a function before the program terminates called `_exit`. So
if we set a breakpoint on that function i.e., `break _exit` we should be able to stop before the
program terminates.

```
(gdb) break _exit
Breakpoint 2 at 0x7b374c0f43e0
```

Now we will use `command` to automatically run a set of commands when this breakpoint is hit. When
we type `command` into `gdb` it will read user input until it reaches an `end` statement. We will
first create new breakpoint to test our commands on.

```
(gdb) b decoyFunction
Breakpoint 3 at 0x6127e0f861cd: file occasional.cpp, line 9.
```

Now, lets try the following. Type the commands below:

```
commands 3
print "we made it to the decoyFunction!"
end
```

> [!NOTE]
> We specified `command <n>` where `<n>` is the breakpoint number, however, we can omit that and
> `gdb` will apply the commands to the last set breakpoint.

It should look like this

```
(gdb) commands 3
Type commands for breakpoint(s) 3, one per line.
End with a line saying just "end".
>print "we made it to the decoyFunction!"
>end
```

This will run the `print` command every time we hit that breakpoint (breakpoint 3). Let's try
continuing until that breakpoint.

```
(gdb) continue
Continuing.
Generated number: 45

Breakpoint 3, decoyFunction () at occasional.cpp:9
9         return;
$1 = "we made it to the decoyFunction!"
```

It works! we can see our text. You can convince yourself by running the program a few more times if
you wish.

> [!NOTE]
> When we hit the breakpoint `gdb` prints some text, in this case `Breakpoint 3, decoyFunction () at
> occasional.cpp:9`. We can suppress this output using the `silent` command on the first line. We
> will see this in the following example.

Lets move on. We will delete that breakpoint and start preparing our commands for the `_exit`
breakpoint instead.

```
(gdb) delete 3
(gdb) info break
Num     Type           Disp Enb Address            What
2       breakpoint     keep y   0x00007a1df3ba33e0 <_exit>
```

If we reach the end of the program, we want to re-run it. To do that we could use something like
this

```
commands 2
run
end
```

This set of commands will prompt the debugger to start from the beginning when it reaches the exit
successfully. In C++, this is enough because memory errors are caught by the debugger. However, if
you are running the Fortran example, you will need to set an additional breakpoint `break
_gfortran_runtime_error_at`. This will stop execution if the debugger hits a Fortran runtime error.

Now let's see our hard work in action. Use the `continue` command to run our program until `gdb`
catches the memory error.

```
(gdb) commands 2
Type commands for breakpoint(s) 2, one per line.
End with a line saying just "end".
>run
>end
(gdb) continue
Continuing.
Program completed successfully.

Breakpoint 2, 0x00007a1df3ba33e0 in _exit () from /lib/x86_64-linux-gnu/libc.so.6
warning: Error disabling address space randomization: Operation not permitted
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".
Generated number: 65
Program completed successfully.

Breakpoint 2, 0x0000713e617143e0 in _exit () from /lib/x86_64-linux-gnu/libc.so.6
warning: Error disabling address space randomization: Operation not permitted
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".
Generated number: 22
Program completed successfully.

...

Breakpoint 2, 0x00007a47694123e0 in _exit () from /lib/x86_64-linux-gnu/libc.so.6
warning: Error disabling address space randomization: Operation not permitted
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".
Generated number: 96
Number is greater than 75. Crashing the program...

Program received signal SIGSEGV, Segmentation fault.
0x0000634e4bcd22b7 in main () at occasional.cpp:31
31          *ptr = 42; // Dereferencing a null pointer to cause a crash
```

That's it! The code is pseudo-random, so your output may look different to mine. If you hit the
memory error first try, try running the code again with the `run` command. And you can convince
yourself that it does what we intended.

### Scripting Debug Sessions

So we can now script breakpoints, but did you know we can also script the entire debug session.

This is unrelated to the fact that we can _script_/automate breakpoints, but I thought it was a
sensible time to bring it up.

There are two ways to run user debug scripts in `gdb`. You can either pass them as a command line
argument when `gdb` is launched, or you can `source` them from within `gdb`.

Open a new file called `myscript.gdb`. In it we will create our first `gdb` script. `gdb` will run
each line of this file, one at a time. For example, lets add the following to our file.

```
# myscript.`gdb`
start
print "hello debug world!"
break decoyFunction
continue
quit
```

Quit your previous debug session using the `quit` command. We will now start a new one to test our
script out. `gdb` has a command line argument `-x [path-to-script]` which executes the script given
at the path `[path-to-script]`. For example,

```
$ gdb -q -x myscript.gdb ./occasional-f90.exe
Reading symbols from ./occasional-f90.exe...
Temporary breakpoint 1 at 0x11ef: file occasional.f90, line 1.
warning: Error disabling address space randomization: Operation not permitted
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".

Temporary breakpoint 1, occasional () at occasional.f90:1
1       program occasional
$1 = 'hello debug world!'
Breakpoint 2 at 0x62f5ad5901e1: file occasional.f90, line 30.
 Generated number:          66

Breakpoint 2, occasional::decoyfunction () at occasional.f90:30
30        end subroutine decoyFunction
(gdb)
```

This will run the commands we specified in the script file (`myscript.gdb`) and then leave us in the
debug session ready to interact. This can be really helpful for a number of reasons e.g.,

* sharing debug sessions with collaborators
* documenting your progress towards finding a bug
* automating commands for multiple related binaries

> [!NOTE]
> This notion of scripted debug sessions will be particularly helpful when we come to look at MPI
> debugging.

### Putting it all together

Try to use what you have learned in this lesson to script a debug session.

- [ ] Try creating a script that uses the `command` command to automatically find the program crash
- [ ] Go back to the previous exercise and create a script that automates that debug session

`gdb` debug scripts (`occasional-*.gdb`) are provided for you to compare if you get stuck.
