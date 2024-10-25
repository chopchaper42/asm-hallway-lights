@ TST - bitwise AND

.syntax unified @ divided nebo unified

.word 0x20001000
.word _start

.global _start
.type _start, %function

.set RCC_APB2ENR, 0x40021018 @ enable clock for ports

.set GPIOC_CRH, 0x40011004
.set GPIOC_IDR, 0x40011008
.set GPIOC_ODR, 0x4001100C

.set GPIOA_CRL, 0x40010800
.set GPIOA_ODR, 0x4001080C
.set GPIOA_IDR, 0x40010808

.set SHORT_PHASE_LENGTH, 0x54759  @A8EB2  @ 0,1 sec * 3 = 0,3 sec
.set  LONG_PHASE_LENGTH, 0xE1398  @1C2730 @ 0,1 sec * 8 = 0,8 sec
.set DELAY_LENGTH, 0x8CC3F        @11987E       @ 0,1 sec * 5 = 0,5 sec
.set PAUSE_LENGTH, 0x384E60       @709CC0       @ 0,1 sec * 20 = 2 sec

@ R5 - BUTTON_TIMER
@ R6 - LED_TIMER

_start:
    bl setup_clock
    bl setup_gpio

    mov r5, #0          @ set BUTTON_TIMER to 0
    mov r6, #0          @ set LED_TIMER to 0
    
loop:
    ldr r0, =GPIOA_IDR  @ Read input of port A
    ldr r1, [r0]        @ load the value stored on address from r0 to r1. r1 = 0x40010808
    tst r1, #1          @ Test if 1st pin is HIGH
    
    beq timer           @ if button isnt pressed, skip debouncing

    bl green_led_on     @ if button is pressed, turn the green on

    
    
    

    @ debounce
debounce:
    ldr r0, =0x8CC3F     @ ~0,5sec
debounce_internal:
    subs r0, #1
    bne debounce_internal
b timer


timer:
    cmp r5, #0          @ compare TIMER with 0
    beq on_timer_zero   @ if TIMER == 0, jump to on_timer_zero

    subs r5, #1          @ else subtract 1 from TIMER
    b loop               @ and jump to loop


on_timer_zero:

    

b loop

blue_led_on:
    ldr r0, =GPIOC_ODR @ load GPIOC_ODR address to R0
    ldr r1, [r0]         @ move r0 to r1
    orr r1, #0x100     @ set 8th pin to 1
    str r1, [r0]       @ store R1 to [R0] - GPIOC_ODR

bx lr

green_led_on:
    ldr r0, =GPIOC_ODR @ load GPIOC_ODR address to R0
    ldr r1, [r0]         @ move r0 to r1
    orr r1, #0x200     @ set 9th pin to 1
    str r1, [r0]       @ store R1 to [R0] - GPIOC_ODR

bx lr

blue_led_off:
    ldr r0, =GPIOC_ODR  @ load GPIOC_ODR address to R0
    ldr r1, [r0]
    bic r1, #0x100        @ put 0 to r1
    str r1, [r0]        @ store 0 from r1 to GPIOC_ODR

bx lr

green_led_off:
    ldr r0, =GPIOC_ODR  @ load GPIOC_ODR address to R0
    ldr r1, [r0]
    bic r1, #0x200        @ put 0 to r1
    str r1, [r0]        @ store 0 from r1 to GPIOC_ODR

bx lr

setup_clock:
    ldr r0, =RCC_APB2ENR @ load from rcc_apb2enr to r0
    ldr r1, [r0] @ load value from r0 to r1
    orr r1, #0x1C @ start clock for ports A, B and C
    str r1, [r0]

bx lr   @ skok do link registru


setup_gpio:
    ldr r0, =GPIOC_CRH @ CRH - control register high
    ldr r1, [r0]       @ write value of r0 to r1
    bic r1, #0xFF      @ clear first 8 bits (pins 8 and 9)
    orr r1, #0x11       @ set first 8 bits to 0000 0001 (push-pull OUT 10MHz) PC8
    str r1, [r0]       @ store R1 to GPIOC_CRH

    ldr r0, =GPIOA_CRL   @ load GPIOA_CRL to R0
    ldr r1, [r0]
    bic r1, #0xFF
    orr r1, #0x8         @ set PA0 to INPUT pull down
    str r1, [r0]

bx lr