.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb


.equ RCC_AHB1ENR, 0x40023830

.equ GPIOA_BASE,	0x40020000
.equ GPIOA_MODER, 	0x40020000
.equ GPIOA_ODR, 0x40020014

.equ GPIOA_EN,		(1 << 0)
.equ MODER5_OUT, 	(1<<10)
.equ LED_ON, 		(1U<<5)

.equ One_sec, 5333333

.section .text
.global __main

__main:

	// Set Clock for AHB1ENR Bus
	ldr r0,=RCC_AHB1ENR
	ldr r1, [r0]
	orr r1, #(1 << 0)
	str r1, [r0]


	// Set PA5 for out
	ldr r0,=GPIOA_MODER
	ldr r1, [r0]
	orr r1, #MODER5_OUT
	str r1, [r0]

loop:
	// Set high PA5 and wait 1 second
	ldr r3, =One_sec
	ldr r0,=GPIOA_ODR
	mov r1, #(1<<5)
	str r1, [r0]
	bl OneSecondDelayLoop

	// Set low PA5 and wait 1 second
	ldr r3, =One_sec
	mov r1, #(1 << 0)
	str r1,[r0]
	bl OneSecondDelayLoop
	b loop


OneSecondDelayLoop:
	subs r3, r3, #1
	bne OneSecondDelayLoop
	bx lr


.align
.end
