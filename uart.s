
.EQU RCC_BASE,                  0x40023800
.EQU USART2_BASE,               0x40004400
.EQU GPIOA_BASE,                0x40020000


.EQU RCC_APB1ENR_OFFSET,        0x40
.EQU RCC_AHB1ENR_OFFSET,        0x30
.EQU GPIOX_MODER_OFFSET,        0x00
.EQU GPIOX_AFRL_OFFSET,         0x20
.EQU USART2_BRR_OFFSET,         0x08
.EQU USART2_CR1_OFFSET,         0x0C
.EQU USART2_CR2_OFFSET,         0x10
.EQU USART2_CR3_OFFSET,         0x14
.EQU USART2_SR_OFFSET,          0x00
.EQU USART2_DR_OFFSET,          0x04

.EQU RCC_APB1ENR,               (RCC_BASE + RCC_APB1ENR_OFFSET)
.EQU RCC_AHB1ENR,               (RCC_BASE + RCC_AHB1ENR_OFFSET)
.EQU GPIOA_MODER,               (GPIOA_BASE + GPIOX_MODER_OFFSET)
.EQU GPIOA_AFRL,                (GPIOA_BASE + GPIOX_AFRL_OFFSET)
.EQU USART2_BRR,                (USART2_BASE + USART2_BRR_OFFSET)
.EQU USART2_CR1,                (USART2_BASE + USART2_CR1_OFFSET)
.EQU USART2_SR,                 (USART2_BASE + USART2_SR_OFFSET)
.EQU USART2_DR,                 (USART2_BASE + USART2_DR_OFFSET)


.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.section .text
.global __main

__main:
    bl uart_init

loop:
    mov r0, #'!'
    bl uart_outchar
    b loop

uart_init:
    /* Enable clock access for GPIOA pins */
    ldr r0, =RCC_AHB1ENR
    ldr r1, [r0]
    orr r1, r1, #(1 << 0)
    str r1, [r0]

    /* Set UART GPIOA Pin mode to alternate function */
    ldr r0, =GPIOA_MODER
    ldr r1, [r0]
    bic r1, r1, #(0b1111 << 4)
    orr r1, r1, #(0b1010 << 4)
    str r1, [r0]

    /* Set alternate function mode for uart */
    ldr r0, =GPIOA_AFRL
    ldr r1, [r0]
    ldr r2, =0xFF00
    bic r1, r1, r2
    orr r1, r1, (0b0111 << 8)
    orr r1, r1, (0b0111 << 12)
    str r1, [r0]

    /* Enable clock access to UART2 */
    ldr r0, =RCC_APB1ENR
    ldr r1, [r0]
    ldr r2, = 0x20000
    orr r1, r1, r2
    str r1, [r0]

    /* Set baudrate for UART 9600 or 16mHz */
    ldr r0, =USART2_BRR
    ldr r2, =0x683
    str r2, [r0]

    /* Set USART CR1 TransmitEnable for 1 */
    ldr r0, =USART2_CR1
    ldr r1, [r0]
    orr r1, r1, #(1 << 3)
    str r1, [r0]

    /*7. configure control register 2*/
	/* Birsey yapmaya gerek yok reset 0 zaten */

    /*8. Configure control register 3*/
    /* Ayni sekilde 0 da */

    /*9. Enable UART module*/
    ldr r0, =USART2_CR1
    ldr r1, [r0]
    ldr r2, =(1 << 13)
    orr r1, r1, r2
    str r1, [r0]

    bx lr

uart_outchar:
    /* Make sure usart transfer fifo is not full */
    ldr r1, =USART2_SR

lp2:
    ldr r2, [r1]
    and r2, r2, #(1 << 7)
    cmp r2, #0x00
    beq lp2
    /* Write data to data register */
    mov r1, r0
    ldr r2,=USART2_DR
    str r1, [r2]
    bx lr
