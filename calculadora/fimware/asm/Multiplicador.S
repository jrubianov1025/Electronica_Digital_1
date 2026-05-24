.equ MUL_BASE,       0x00440000   
.equ MUL_MULTIPLICANDO, 0x04
.equ MUL_MULTIPLICADOR, 0x08
.equ MUL_INIT,          0x0C
.equ MUL_RESULTADO,     0x10
.equ MUL_DONE,          0x14

.section .text
.globl mult_hw

# Entrada:  a0 = Multiplicando (signed 16-bit)
#           a1 = Multiplicador  (signed 16-bit)
# Salida:   a0 = Resultado      (signed 32-bit)

mult_hw:
    li   gp, MUL_BASE

    sw   a0, MUL_MULTIPLICANDO(gp)   # escribir primer operando
    sw   a1, MUL_MULTIPLICADOR(gp)   # escribir segundo operando

    li   a0, 1
    sw   a0, MUL_INIT(gp)            # init = 1 → arrancar
    sw   zero, MUL_INIT(gp)          # init = 0 → pulso

.wait_mul:
    li   t0, 1  
    lw   t1, MUL_DONE(gp)            # leer DONE
    and  t1, t1, t0
    beqz t1, .wait_mul               # esperar hasta DONE == 1

    lw   a0, MUL_RESULTADO(gp)       # leer resultado de 32 bits
    ret