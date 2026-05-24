.equ IO_BASE, 0x400000  
.equ IO_LEDS, 4
.equ IO_UART_DAT, 8
.equ IO_UART_CNTL, 16
.equ WAIT_DELAY, 20            

.section .text
.globl start 
.globl blinker

start:
    li   gp, IO_BASE
    li   sp, 0x2000

blinker:
	li   t0, 62
	sw   t0, IO_LEDS(gp)
	li   a0, WAIT_DELAY        
	call wait

	li   t0, 61
	sw   t0, IO_LEDS(gp)
	li   a0, WAIT_DELAY
	call wait

	li   t0, 59
	sw   t0, IO_LEDS(gp)
	li   a0, WAIT_DELAY
	call wait

	li   t0, 55
	sw   t0, IO_LEDS(gp)
	li   a0, WAIT_DELAY
	call wait

	li   t0, 47
	sw   t0, IO_LEDS(gp)
	li   a0, WAIT_DELAY
	call wait

	li   t0, 31
	sw   t0, IO_LEDS(gp)
	li   a0, WAIT_DELAY
	call wait

	li   t0, 47
	sw   t0, IO_LEDS(gp)
	li   a0, WAIT_DELAY
	call wait

	li   t0, 55
	sw   t0, IO_LEDS(gp)
	li   a0, WAIT_DELAY
	call wait

	li   t0, 59
	sw   t0, IO_LEDS(gp)
	li   a0, WAIT_DELAY
	call wait

	li   t0, 61
	sw   t0, IO_LEDS(gp)
	li   a0, WAIT_DELAY
	call wait

	li   t0, 62
	sw   t0, IO_LEDS(gp)
	li   a0, WAIT_DELAY
	call wait

	la   a0, hello
	call putstring            
    call getchar               
    call putchar             
    li   a0, 0x0A
    call putchar             
	j    blinker

.section .data
hello:
	.asciz "Hello, ASM world\n\r"