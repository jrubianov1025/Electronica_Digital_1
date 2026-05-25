.equ BCD2BIN_BASE,    0x00460000  
.equ BCD2BIN_BCD_IN,  0x04        # entrada: {SIGN,MILLON,CIENMIL,DIEZMIL,MIL,CENT,DEC,UNIT}
.equ BCD2BIN_INIT,    0x08
.equ BCD2BIN_RESULT,  0x0C        # salida: binario 24 bits
.equ BCD2BIN_DONE,    0x10

.section .text
.globl bcd2bin

# Entrada:  a0 = BCD empaquetado de 32 bits
#               {SIGN, MILLON, CIENMIL, DIEZMIL, MIL, CENT, DEC, UNIT}
# Salida:   a0 = número binario signed (24 bits)

bcd2bin:
    addi sp, sp, -4
    sw   ra, 0(sp)
 
    li   t0, BCD2BIN_BASE           
    sw   a0, BCD2BIN_BCD_IN(t0)     # escribir BCD empaquetado completo
    li   a1, 1
    sw   a1, BCD2BIN_INIT(t0)       # init = 1 → arrancar
    sw   zero, BCD2BIN_INIT(t0)     # init = 0 → pulso
 
.wait_bcd2bin:
    lw   a1, BCD2BIN_DONE(t0)
    andi a1, a1, 1
    beqz a1, .wait_bcd2bin          # esperar DONE
 
    lw   a0, BCD2BIN_RESULT(t0)     # leer resultado binario 24 bits
 
    slli a0, a0, 8                  # desplazar para que bit 23 quede en bit 31
    srai a0, a0, 8                  # shift aritmético: propaga signo a bits [31:24]
 
    lw   ra, 0(sp)
    addi sp, sp, 4
    ret

