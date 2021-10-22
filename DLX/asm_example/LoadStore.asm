addui r1, r0, #5
addui r2, r0, #8
slli r1,r1,#16
rori r2,r2,#4
srai  r2,r2,#29
addui r1, r1, #3    ; MSHW= 5, LSHW= 3

sw 3(r0),r1			; store the entire word Big-endian
lw r3,3(r0)			; load the entire word
lb r4,6(r0)
lh r5,5(r0)

sw 7(r0),r2			; store the entire word Big-endian
lw r3,7(r0)			; load the entire word
lb r4,10(r0)
lh r5,9(r0)

lbu r4,10(r0)
lhu r5,9(r0)
