## Lecture 1 Notes
Data: May,21 2022 

#### Goal: 
 * To understand and design the high-level operating system.
 
#### Purposes of the O/S
 * Abstract hardwares.
 * Multiplex the hardware among many of applications.
 * Isolation
 * Sharing
 * Security
 * Performance
 * Range of uses
----
 #### O/S organization
 
|Vl, CC, SH,    |USER MODE|
|---|---|
| File System,Process,Memory allocation, Access Control |KERNEL MODE|   

CPU RAM DISK NET  

-----
API <-> kernel (System function call)  
Example:
```C++
    fd = open("out",1) // a function call
    write(fd,"hello\n",6) // write to a file
    pid = fork(); // fork returns the id
```
 ----

 # I/O and File descriptors
 * A file descriptor is a small non negative integer representing a kernel managed object that a process may read from or writ to.
 * Internally, the xv6 kernel uses file descriptor as an index into a preprocessed table.
    * Every process has a private space of file descriptors starting at zero.
    * A process reads from file descriptor 0(Standard input), writes output to file descriptor 1(Standard output), Writes error messages to file descriptor 2(Standard error). 
* The call `read(fd,buf, n)` `reads` at most `n` bytes from the file descriptor `fd`, copies them into `buf`, and returns the number of bytes `read`.
    * Each file descriptor `fd`, refers to a file has an offset associated with it.
    * `Read` reads data from the current file offset and then advances that offset by the number of bytes read: a subsequent `read` will return the bytes following the ones returned by the first `read`.
    * When there are no more bytes to read, `read`returns zero to indicate the end of the file.
* The call `write(fd,buf,n)` writes `n` bytes from `buf` to the file descriptor `fd` and returns the number of bytes written.
    * Like `read`, the `write` writes data at the current file offset and then advances that offset by the number of bytes written: each `write ` picks up where the previous one left off.

# Example code from program `cat`
Copy data from its standard input to its standard output. If an error occurs, writes a message to the standard error.

```C
char buf[512];
int n;

for(;;){
    n = read(0, buf, sizeof buf);
    if(n == 0)
        break;
    if(n < 0){
        fprintf(2, "read error\n");
        exit(1);
    }
    if(write(1, buf, n) != n){
        fprintf(2, "write error\n");
        exit(1);
    }
}
```
Note: 
* `cat` doesn't know whether it is reading from a file, console, or a pipe.
* `cat` doesn't know whether it is printing to a console, a file, or whatever.
* The use of file descriptors and the convention that file descriptor 0 is input and file descriptor 1 is output allows a simple implementation of `cat`

------
The `close` system call releases a file descriptor, making it free for reuse by a future `open, pip, or dup` system call.

File descriptors and `fork` interact to make I/O redirection easy to implement.
`Fork` copies the parent's file descriptor table along with its memory, so that the child starts with exactly the same open files as the parent. The system call ` exec ` replaces the calling process's memory but preserves its file table.   
1) redirection by `fork`.
2) re-opening chosen file descriptors in the child.
3) calling `exec` to run the new program.

A simplified version of the code a shell runs for the command `cat < input.txt`:  
```C
char *argv[2];

argv[0] = "cat";
argv[1] = 0;
if(fork() == 0){
    close(0);
    open("input.txt", O_RDONLY);
    exec("cat", argv);
}
```  
Note: `fork` copies the file descriptor table, each underlying file offset is shared between parent and child.
------

Write `hello world` into a file: 
```c
if(fork() == 0){
    write(1, "hello ", 6);
    exit(0);
} else {
    wait(0);
    write(1, "world\n", 6);
}
```

The `dup` system call duplicates an existing file descriptor, returning a new one that refers to the same underlying I/O object.  
* Both file descriptors share an offset, just as the file descriptors duplicated by `fork` do.

Another way to write `hello world` to a file: 
```c
fd = dup(1);
write(1, "hello ", 6);
write(fd, "world \n", 6);
```
Two file descriptors share an offset if they were derived from the same original file descriptor by a sequences of `fork` and `dup` calls. Otherwise do not share offsets, even they resulted from `open` calls for the same file.

# Pipes 
A *pipe* is a small kernel buffer exposed to processes as a pair of the file descriptors, one for reading and one for writing. 
* Writing data to one end of the pipe makes that data available for reading from the other end of the pipe.
* Pipes provide a way for precesses to communicate.  

The following example code runs the program `wc` with standard input connected to the read end of a pipe.

```c
int p[2];
char *argv[2];

argv[0] = "wc";
argv[1] = 0;

pipe(p);
if(fork() == 0){
    close(0);
    dup(p[0]);
    close(p[0]);
    close(p[1]);
    exec("/bin/wc", argv);
} else {
    close(p[0]);
    write(p[1], "hello world\n", 12);
    close(p[1]);
}
```
1) The program calls `pipe`, which creates a new pipe and records the read and write file descriptors in the array p. 
2) After `fork`, both parent and child have file descriptors referring to the pipe. 
3) The child calls `close` and `dup` to make file descriptor zero refer to the read end of the pipe, closes the file descriptors in `p`, and calls `exec` to run `wc`.
4) When `wc` reads from its standard input, it reads from the pipe. 
5) The parent closes the read side of the pipe, writes to the pipe, and then closes the writes side.

If no data is available, a `read` on a pipe waits for either data to be written or for all file descriptors referring to the write end to be closed;
* In the above cases, `read` will return 0, just as if the end of a data file had been reached.
* The fact `read` blocks until it is impossible for new data to arrive is one reason that it's important for the child to close the write end of the pipe before executing `wc` : if one of `wc` 's file descriptors referred to the write end of the pipe, `wc` would never see end-of-file.
