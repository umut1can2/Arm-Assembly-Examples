.section .text
.global _start

_start:
  mov r0, #32 
  
  cmp r0, #0
  beq false
  cmp r0, #1
  beq true
  
l:
  mov r2, r0
  mov r3, #2 
  bl modulus

  cmp r2, #0
  beq go_div
  bne check

check:
  cmp r0, #1
  beq true
  bne false

go_div:
  mov r2, r0
  mov r3, #2
  mov r4, #0
  bl udiv
  mov r0, r4
  b l
  
modulus:
  mov r4, #0
  bl udiv
  mul r4, r4, r3
  sub r2, r2, r4
  bx lr

udiv:
  cmp r2, r3
  blt done

  sub r2, r2, r3
  add r4, r4, #1
  b udiv
  
done:
  bx lr

false:
  mov r5, #0
  b exit

true:
  mov r5, #1
  b exit

exit:
  b exit
