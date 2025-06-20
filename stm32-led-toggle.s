.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.equ RCC_BASE,			0x40023800
.equ RCC_AHB1ENR_OFFSET,0x30
.equ RCC_AHB1ENR, 		(RCC_BASE + RCC_AHB1ENR_OFFSET)

.equ MODER_OFFSET, 		0x00
.equ ODR_OFFSET,  		0x14
.equ IDR_OFFSET, 		0x10
.equ BSSR_OFFSET, 		0x18

.equ GPIOA_BASE,		0x40020000
.equ GPIOA_MODER, 		(GPIOA_BASE + MODER_OFFSET)
.equ GPIOA_BSSR, 		(GPIOA_BASE + BSSR_OFFSET)
.equ GPIOA_ODR,			(GPIOA_BASE + ODR_OFFSET)

.equ GPIOC_BASE, 		0x40020800
.equ GPIOC_MODER, 		(GPIOC_BASE + MODER_OFFSET)
.equ GPIOC_BSSR, 		(GPIOC_BASE + BSSR_OFFSET)
.equ GPIOC_IDR, 		(GPIOC_BASE + IDR_OFFSET)

.equ BSSR_PIN5_SET, 	(1 << 5)
.equ BSSR_PIN5_RESET,	(1 << 21)

.equ GPIOA_AND_C_EN,	(0b101 << 0)

.equ BTN_ON, 			0x0
.equ BTN_OFF,			0x2000

.equ BTN_13_PIN, 		0x2000

.section .text
.global __main

__main:
	bl init

loop:
	//Get value in PC13
	bl get_val
	cmp r0, #BTN_ON
	BEQ led_on
	BNE led_off
	b loop


init:
	// Clock setup for A and B port
	ldr r0, =RCC_AHB1ENR
	ldr r1, [r0]
	orr r1, #GPIOA_AND_C_EN
	str r1, [r0]

	// Set PA5 as output
	ldr r0, =GPIOA_MODER
	ldr r1, [r0]
	orr r1, #(1 << 10)
	str r1, [r0]

	//Set PC13 as input, not important actually because it's initially 00
	ldr r0, =GPIOC_MODER
	ldr r1, [r0]
	bic r1, r1, #(0b11 << 26)
	str r1, [r0]

	bx lr


get_val:
	ldr r0, =GPIOC_IDR
	ldr r1, [r0]
	and r0, r1, #BTN_13_PIN
	bx lr


led_on:
	ldr r0, = GPIOA_BSSR
	mov r1, #(1 << 5)
	str r1, [r0]
	b loop

led_off:
	ldr r0, = GPIOA_BSSR
	mov r1, #(1 << 21)
	str r1, [r0]
	b loop

stop:
	b stop
	.align
	.end
