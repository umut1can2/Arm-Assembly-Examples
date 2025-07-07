.EQU GPIOA_BASE,                0x40020000
.EQU GPIOC_BASE,                0x40020800
.EQU RCC_BASE,                  0x40023800


.EQU RCC_AHB1ENR_OFFSET,        0x30
.EQU GPIOX_MODER_OFFSET,        0x00
.EQU GPIOX_IDR_OFFSET,          0x10
.EQU GPIOX_ODR_OFFSET,          0x14

.EQU RCC_AHB1ENR,               (RCC_BASE + RCC_AHB1ENR_OFFSET)
.EQU GPIOA_MODER,               (GPIOA_BASE + GPIOX_MODER_OFFSET)
.EQU GPIOC_MODER,               (GPIOC_BASE + GPIOX_MODER_OFFSET)
.EQU GPIOA_ODR,                 (GPIOA_BASE + GPIOX_ODR_OFFSET)
.EQU GPIOC_IDR,                 (GPIOC_BASE + GPIOX_IDR_OFFSET)

.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.section .text
.global __main

__main:
    // Clock access for AHB1 Bus
    ldr r0, =RCC_AHB1ENR
    ldr r1, [r0]
    orr r1, r1, #(0b101 << 0)
    str r1, [r0]

    // PA5 as OUTPUT
    ldr r0, =GPIOA_MODER
    ldr r1, [r0]
    orr r1,  r1, #(0b01 << 10)
    str r1, [r0]

    // PC13 as INPUT
    ldr r0, =GPIOC_MODER
    ldr r1, [r0]
    orr r1, r1, #(0b00 << 26)
    str r1, [r0]

loop:
    // Read the 13th bit on IDR
    ldr r0, =GPIOC_IDR
    ldr r1, [r0]
    mov r2, #(1 << 13)
    and r1, r1, r2
    ## If 13th bit is 0 then led_on otherwise led_off
    cmp r1, #0
    beq led_on
    bne led_off
    b loop

led_on:
    ldr r0, =GPIOA_ODR
    ldr r1, [r0]
    orr r1, r1, #(1 << 5)
    str r1, [r0]
    b loop

led_off:
    ldr r0, =GPIOA_ODR
    ldr r1, [r0]
    bic r1, r1, #(1 << 5)
    str r1, [r0]
    b loop
