.equ BCD_BASE,    0x00410000   
.equ BCD_OP_A,    0x04
.equ BCD_INIT,    0x08
.equ BCD_RESULT,  0x0C
.equ BCD_DONE,    0x10

.section .text
.globl bin2bcd_hw

# Entrada:  a0 = número binario signed (24 bits útiles)
# Salida:   a0 = resultado BCD empaquetado de 32 bits
#               {SIGN, MILLON, CIENMIL, DIEZMIL, MIL, CENT, DEC, UNIT}

bin2bcd_hw:
    li   gp, BCD_BASE

    sw   a0, BCD_OP_A(gp)        # escribir operando
    li   a0, 1
    
    sw   a0, BCD_INIT(gp)        # init = 1 → arrancar
    sw   zero, BCD_INIT(gp)      # init = 0 → pulso

.wait_bcd:
    li   t0, 1
    lw   t1, BCD_DONE(gp)
    and  t1, t1, t0
    beqz t1, .wait_bcd           # esperar DONE
    
    lw   a0, BCD_RESULT(gp)      # leer resultado de 32 bits
    ret
    