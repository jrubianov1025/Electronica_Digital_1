.equ DIV_BASE,      0x00430000   
.equ DIV_DIVIDENDO, 0x04
.equ DIV_DR,        0x08         # DR = Divisor
.equ DIV_INIT,      0x0C
.equ DIV_RESULTADO, 0x10
.equ DIV_RESIDUO,   0x14         
.equ DIV_DONE,      0x18         # ojo: está en 0x18, no 0x14 como el multiplicador

.section .text
.globl div_hw

# Entrada:  a0 = Dividendo (signed 32-bit)
#           a1 = Divisor   (signed 32-bit)
# Salida:   a0 = Resultado (cociente, signed 32-bit)

div_hw:
    li   gp, DIV_BASE

    sw   a0, DIV_DIVIDENDO(gp)     # escribir dividendo
    sw   a1, DIV_DR(gp)            # escribir divisor
    
    li   a0, 1
    sw   a0, DIV_INIT(gp)          # init = 1 → arrancar
    sw   zero, DIV_INIT(gp)        # init = 0 → pulso

.wait_div:
    li   t0, 1
    lw   t1, DIV_DONE(gp)
    and  t1, t1, t0
    beqz t1, .wait_div             # esperar hasta DONE == 1

    lw   a0, DIV_RESULTADO(gp)     # leer cociente
    ret
    