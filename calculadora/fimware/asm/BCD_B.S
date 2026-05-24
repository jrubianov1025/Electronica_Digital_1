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

  li   gp, BCD2BIN_BASE
  sw   a0, BCD2BIN_BCD_IN(gp)   # escribir BCD empaquetado completo
  li   a0, 1
  sw   a0, BCD2BIN_INIT(gp)     # init = 1 → arrancar
  sw   zero, BCD2BIN_INIT(gp)   # init = 0 → pulso
.wait_bcd2bin:
  li   t0, 1
  lw   t1, BCD2BIN_DONE(gp)
  and  t1, t1, t0
  beqz t1, .wait_bcd2bin        # esperar DONE
  lw   a0, BCD2BIN_RESULT(gp)   # leer resultado binario 24 bits

  lw   ra, 0(sp)
  addi sp, sp, 4
  ret