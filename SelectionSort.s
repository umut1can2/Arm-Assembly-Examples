.section .data
list:
	.word 4,8,2,9,-5,1,6

.section .text
.global _start
_start:
	ldr r0, =list @pointer for a list
	mov r1, #0 @indexer for first loop
	mov r2, #0 @indexer for second loop
f_loop:
	cmp r1, #24
	bge exit
	
	ldr r6, =list
	add r6, r6, r1 @min index 
	add r2, r1, #4 @next data in a list
	
s_loop:
	cmp r2, #24 
	bgt exit_s
	
	ldr r3, [r6] @ min value
	ldr r4, [r0, r2] @ loop value

	cmp r4, r3
	ITT LT
	ADDLT r9, r0, r2
	MOVLT r6, r9

	add r2, r2, #4
	b s_loop
	

exit_s:
	ldr r10, [r6]
	ldr r11, [r0, r1]
	str r11, [r6]
	str r10, [r0, r1]
	add r1, r1, #4
	b f_loop
	
exit:
	b exit
	
	
	