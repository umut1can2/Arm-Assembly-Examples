// Created 2,Aug,2025
.equ RCC_BASE,				0x40023800

.equ RCC_AHB1ENR_OFFSET,	0x30
.equ RCC_AHB1ENR,			RCC_BASE+ RCC_AHB1ENR_OFFSET

.equ RCC_APB2ENR_OFFSET,	0x44
.equ RCC_APB2ENR,			RCC_BASE + RCC_APB2ENR_OFFSET

.equ GPIOA_BASE,			0x40020000
.equ GPIOA_MODER_OFFSET,	0x00
.equ GPIOA_MODER,			GPIOA_BASE + GPIOA_MODER_OFFSET
.equ GPIOA_ODR_OFFSET,		0x14
.equ GPIOA_ODR,				GPIOA_BASE + GPIOA_ODR_OFFSET

.equ GPIOC_BASE,			0x40020800
.equ GPIOC_MODER_OFFSET,	0x00
.equ GPIOC_MODER,			GPIOC_BASE + GPIOC_MODER_OFFSET

.equ SYSCFG_BASE,			0x40013800
.equ SYSCFG_EXTICR4_OFFSET, 0x14
.equ SYSCFG_EXTICR4,		SYSCFG_BASE + SYSCFG_EXTICR4_OFFSET


.equ EXTI_BASE,				0x40013C00
.equ EXTI_IMR_OFFSET,		0x00
.equ EXTI_IMR,				EXTI_BASE + EXTI_IMR_OFFSET
.equ EXTI_RTSR_OFFSET,		0x08
.equ EXTI_RTSR,				EXTI_BASE + EXTI_RTSR_OFFSET
.equ EXTI_FTSR_OFFSET,		0x0C
.equ EXTI_FTSR,				EXTI_BASE + EXTI_FTSR_OFFSET
.equ EXTI_PR_OFFSET,		0x14
.equ EXTI_PR,				EXTI_BASE + EXTI_PR_OFFSET

.equ NVIC_ISER_BASE,		0xE000E100
.equ NVIC_ISER1_OFFSET,		0x04
.equ NVIC_ISER1,			NVIC_ISER_BASE + NVIC_ISER1_OFFSET

.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb
.section .text
.globl main
.global EXTI15_10_IRQHandler
.type EXTI15_10_IRQHandler, %function
main:
	 bl gpio_init
	 bl int_init

lp1:
	b lp1


gpio_init:
	/* Clock access for AHB1 bus[GPIOA, GPIOC] */
	ldr r0, =RCC_AHB1ENR
	ldr r1, [r0]
	orr r1, r1, #(0b101 << 0) // Enable GPIOA and GPIOC
	str r1, [r0]

	// Set PA5 as output
	ldr r0, =GPIOA_MODER
	ldr r1, [r0]
	bic r1, r1, #(0b11 << 10)
	orr r1, r1, #(0b01 << 10)
	str r1, [r0]

	// Set PC13 as input
	ldr r0, =GPIOC_MODER
	ldr r1, [r0]
	bic r1, r1, #(0b11 << 26)
	str r1, [r0]

	bx lr

int_init:
	// Clock access for APB2[Syscfg]
	ldr r0, =RCC_APB2ENR
	ldr r1, [r0]
	orr r1, r1, #(1 << 14);
	str r1, [r0]

    // pin 13 in GPIOC as a interrupt pin 
	// Burada GPIOC de ki 13. pini ayarliyoruz
	ldr r0, =SYSCFG_EXTICR4
	ldr r1, [r0]
	bic r1, r1, #(0xF << 4);
	orr r1, r1, #(0x2 << 4);
	str r1, [r0]

    // InterruptMaskRegister setup
	// 13.pin interrupt olarak kullanilacak
	ldr r0, =EXTI_IMR
	ldr r1, [r0]
	orr r1, r1, #(1 << 13)
	str r1, [r0]

    //risingTSR setup
    // Yukselen kenar tetikleme, buton deaktif olunca
	ldr r0, =EXTI_RTSR
	ldr r1, [r0]
	orr r1, r1, #(1 << 13)
	str r1, [r0]

    // FallingTSR setup.
    // Dusen kenar tetikleme, butona nbasilinca 
	ldr r0, =EXTI_FTSR
	ldr r1, [r0]
	orr r1, r1, #(1 << 13)
	str r1, [r0]

	// Nvic pher. Setup [ her bir register 32 den sonra atliyor yani iser1 in 8.biti]
    // M4 dokumantasyonunda var
	ldr r0, =NVIC_ISER1
	ldr r1, [r0]
	orr r1, r1, #(1 << 8)
	str r1, [r0]

	bx lr

// Setup pre defined function called EXTI15_10_IRQHandler[PC13 goes that line]
// Bu fonksiyon startupta vardi..
EXTI15_10_IRQHandler:
	ldr r0, =EXTI_PR
	ldr r1, [r0]
	tst r1, #(1 << 13)
	beq end_handler

	ldr r2, =GPIOA_ODR
	ldr r3, [r2]
	eor r3, r3, #(1 << 5)
	str r3, [r2]

	mov r1, #(1 << 13)
	str r1, [r0]

end_handler:
	bx lr
