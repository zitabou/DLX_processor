nop
addui r1, r0, #2   ;forwarding r1 to mul
sw 0(r0), r1
lw r2,0(r0)
mult  r2,r2,r2	  ;stalling addui r2 because forwarding cannot solve it immediately 

nop
