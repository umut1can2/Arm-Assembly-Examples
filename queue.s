.data
front:	                .space 4
rear:	                .space 4

.equ SIZE,	            8
queue:	.space          SIZE

.equ queue_addr,	    queue

.text
.global _start
_start:
	/* Tests */
	bl queue_init
	mov r0, #5
	bl enqueue
	mov r0, #7
	bl enqueue
	mov r0, #9
	bl enqueue
	
	bl dequeue
	bl dequeue
	
	b exit

/*
    Intilizes the queue and returns to queue_addr to register 0
 */
queue_init:
	ldr r1, =front
	mov r2, #0
	str r2, [r1]
	ldr r1, =rear
	str r2, [r1]
	ldr r3, =queue_addr
	mov r0, r3
	bx lr
	
	
/*
	argument: r0
	If enqueue succeeds the return value in R0 will be 1, otherwise 0
*/
enqueue:
	push {r4, r5, r6, r7, r8, r9, lr}
	ldr r4, =rear
	ldr r5, [r4]
	add r6, r5, #1
	and r6, r6, #(SIZE - 1)
	ldr r7, =front
	ldr r7, [r7]
	cmp r6, r7
	beq queue_full
	
	ldr r8, =queue_addr
	add r8, r8, r5
	strb r0, [r8]
	add r5, r5, #1
	and r5, r5, #(SIZE - 1)
	str r5, [r4]
	
	mov r0, #1
	pop {r4, r5, r6, r7, r8, r9, lr}
	bx lr

queue_full:
	pop {r4, r5, r6, r7, r8, r9, lr}
	mov r0, #0
	bx lr
	
/*
	argument: r0
	If dequeue succeeds the return value in R0 will be the value which we are dequeued, otherwise 0.
*/
dequeue:
	push {r4, lr}
	ldr r1, =rear
	ldr r1, [r1]
	ldr r2, =front
	ldr r2, [r2]
	cmp r1, r2
	beq queue_empty
	ldr r3, =queue_addr
	add r3, r3, r2
	ldrb r4, [r3]
	mov r0, r4
	add r2, r2, #1
	and r2, r2, #(SIZE - 1)
	ldr r3,=front
	str r2, [r3]
	pop {r4, lr}
	bx lr
	
queue_empty:
	pop {r4, lr}
	mov r0, #0
	bx lr

exit:
	
