.section .data
list:
    .word 4,10,11,15,23,38,47,58

.section .text
.global _start
_start:
    ldr r0,=list
    mov r1, #0 @low index
    mov r3, #7 @high index
    mov r5, #47

loop:
    cmp r1, r3
    bgt l_exit
    
    add r2, r1, r3
    LSR r2, r2, #1 @Div 2
    lsl r4, r2, #2 @Mul 4 for word access

    ldr r6, [r0, r4] @get value in middle

    cmp r5, r6
    beq exit_success
    
    bgt div_high
    blt div_low

    b loop

div_high:
    add r1, r2, #1
    b loop

div_low:
    sub r3, r2, #1
    b loop

l_exit:
    cmp r5, r6
    beq exit_success
    bne exit_failed

exit_success:
    mov r0, r5
    b exit_success

exit_failed:
    mov r0, #-1
    b exit_failed