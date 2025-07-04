.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.equ AHB1_BASE,					0x40020000
.equ GPIOA_BASE,				0x40020000
.equ RCC_BASE,					0x40023800
.equ ADC_BASE,					0x40012000

.equ RCC_AHB1ENR_OFFSET,		0x30
.equ GPIO_MODER_OFFSET,			0x00
.equ GPIO_BSSR_OFFSET,			0x18
.equ RCC_APB2_OFFSET,			0x44
.equ ADC_CR2_OFFSET,			0x08
.equ ADC_SQR3_OFFSET,			0x34
.equ ADC_SQR1_OFFSET,			0x2C
.equ ADC_SR_OFFSET,				0x00
.equ ADC_DR_OFFSET,				0x4C

.equ RCC_AHB1ENR,				(RCC_BASE + RCC_AHB1ENR_OFFSET)
.equ GPIOA_MODER,				(GPIOA_BASE + GPIO_MODER_OFFSET)
.equ GPIOA_BSSR,				(GPIOA_BASE + GPIO_BSSR_OFFSET)

.equ RCC_APB2ENR,				(RCC_BASE + RCC_APB2_OFFSET)
.equ ADC_CR2,					(ADC_BASE + ADC_CR2_OFFSET)
.equ ADC_SQR3,					(ADC_BASE + ADC_SQR3_OFFSET)
.equ ADC_SQR1,					(ADC_BASE + ADC_SQR1_OFFSET)
.equ ADC_SR,					(ADC_BASE + ADC_SR_OFFSET)
.equ ADC_DR,					(ADC_BASE + ADC_DR_OFFSET)

.equ GPIOAEN,					(1 << 0)
.equ PA5_OUTPUT,				(1 << 10)
.equ PA5_HIGH,					(1 << 5)
.equ PA5_LOW,					(1 << 21)
.equ ADC1EN,					(1 << 8)
.equ PA1_ANALOG,				(0b11 << 2)

.equ THRESHOLD,					3000

.section .text
.global _main


_main:
	bl gpioa_init
	bl adc_init
l1:
	bl adc_read
	b l1


gpioa_init:
	// Open clock access for AHB1 BUS
	ldr r0, = RCC_AHB1ENR
	ldr r1, [r0]
	orr r1, r1, #GPIOAEN
	str r1, [r0]

	// Set PA5 as output
	ldr r0, =GPIOA_MODER
	ldr r1, [r0]
	orr r1, r1, #PA5_OUTPUT
	str r1, [r0]

	//Set PA1 as analog
	ldr r0, =GPIOA_MODER
	ldr r1, [r0]
	orr r1, r1, #PA1_ANALOG
	str r1, [r0]

	bx lr

led_on:
	// Set PA5 as high
	ldr r0, =GPIOA_BSSR
	ldr r1, =PA5_HIGH
	str r1, [r0]
	bx lr

led_off:
	// Set PA5 as low
	ldr r0, =GPIOA_BSSR
	ldr r1, =PA5_LOW
	str r1, [r0]
	bx lr

adc_init:
	// Open clock access for APB2 Bus
	ldr r0, =RCC_APB2ENR
	ldr r1, [r0]
	orr r1, r1, #ADC1EN
	str r1, [r0]

	// Clear CR2 for software trigger
	ldr r0, =ADC_CR2
	mov r1, #0
	str r1, [r0]

	// SQR3 Setup
	ldr r0, =ADC_SQR3
	ldr r1, [r0]
	orr r1, r1, #(1 << 0)
	str r1, [r0]

	// SQR1 Setup
	ldr r0, =ADC_SQR1
	ldr r1, [r0]
	bic r1, r1, #0xFFFFFFFF
	str r1, [r0]

	// ADC ON
	ldr r0, =ADC_CR2
	ldr r1, [r0]
	orr r1, r1, #(1 << 0)
	str r1, [r0]

	bx lr

adc_read:
	ldr r0, =ADC_CR2
	ldr r1, [r0]
	orr r1, r1, #(1 << 30)
	str r1, [r0]

wait:
	ldr r0, =ADC_SR
	ldr r1, [r0]
	and r2, r1, #(0b10)

	cmp r2, #2
	bne wait

	ldr r0, =ADC_DR
	ldr r1, [r0]
	ldr r2, =0xFFF
	and r1, r1, r2
	ldr r2, =THRESHOLD
	cmp r1, r2
	bgt led_on
	blt led_off

	bx lr


exit:
	b exit
