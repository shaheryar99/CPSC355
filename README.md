# CPSC355
CPSC 355 - University of Calgary 

## Assignment Grades:

* Assignment 1: 100% 
Feedback: Well done!

* Assigment 2: 100%
Feedback: IMPORTANT NOTE: please do NOT zip the assignment files. Just upload the content as is.

* Assignment 3: 98.33%
Feedback: Proper loop design:

+----------------------------------+
| Initialization Step, e.g., i = 0 |
+----------------------------------+
| B LOOP_TEST                      |
+----------------------------------+
| LOOP_BODY:                       |
+----------------------------------+
| LOOP_TEST:                       |
+----------------------------------+

If you have nested loops, therefore, it goes like this:


+-----------------------------------+
| Initialization Step For Loop 1    |
+-----------------------------------+
| B LOOP1_TEST                      |
+-----------------------------------+
| LOOP1_BODY:                       |
+--+--------------------------------+
|  | Initialization Step For Loop 2 |
|  +--------------------------------+
|  | B LOOP2_TEST                   |
|  +--------------------------------+
|  | LOOP2_BODY:                    |
|  +--------------------------------+
|  | LOOP2_TEST:                    |
+--+--------------------------------+
| LOOP1_TEST:                       |
+-----------------------------------+

loop increment should be in the final line of loop_body

Local variables should be loaded every time the program reads value from them, e.g. i++, i<j, etc.

* Assignment 4: 89.6%
Feedback: struct cuboid c and int result should be stored on memory -2,
callee-saved register should be restored from memory once subroutine is done -1,
some of52fset values are off -2,
gdb memory examination does not show the proper addresses -1 (this is because of the offset values).

* Assignment 5: 92.1%
Feedback: display function problem (-4) 
overflowed value should not be added to the queue (-1)

* Assignment 6: 100%
Feedback: None. 
