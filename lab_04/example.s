.global _start
 
.section .text
_start:
    # Any code here
    li a0, 0 # Initialize counter 
    li a1, 10 # Set maximum count 
loop: 
     addi a0, a0, 1 # Increment counter 
     blt a0, a1, loop  # Loop if counter < max
 
    # Code to exit for Spike (DONT REMOVE IT)
    li t0, 1
    la t1, tohost
    sd t0, (t1)
 
    # Loop forever if spike does not exit
1:  j 1b
 
.section .tohost
.align 3
tohost: .dword 0
fromhost: .dword 0
