.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.equ size, 7
max		.req r0
count	.req r1
pointer .req r2
data	.req r3


.section .data
liste:
	.word 45,7,32,99,12,6,8


.section .text
.global _start

_start:

	mov max, #0
	mov count, #0
	mov data, #0
	ldr pointer, =liste

program:
	cmp count, size
	bge stop

	ldr data, [pointer]

	cmp data, max

	bgt swap

next:
	add count, count, #1
	add pointer, pointer, #4

	b program


swap:
	ldr max, [pointer]
	b next

stop:
	b stop
	.align
	.end
