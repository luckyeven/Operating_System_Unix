## Lecture 1 Notes
#### Goal: 
 * To dunderstand and design the high-level operating system.
 * Ganin Hands on experinces by doing the lab
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