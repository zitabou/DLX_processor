nop
addui r1, r0, 2   ;forwarding r1 to mul
mult  r1,r1,r1	  ;stalling addui r2 because forwarding cannot solve it immediately 
addui r2, r1, 1
nop
