nop
addui r1, r0, #2   ;forwarding r1 to mul
mult  r1,r1,r1	  ;stalling addui r2 because forwarding cannot solve it in 1 cc 
addui r2, r0, #1
addui r3, r0, #2
addui r4, r0, #3
