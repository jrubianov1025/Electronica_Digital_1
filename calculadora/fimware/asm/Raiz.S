.equ SQRT_BASE,      0x00420000   
.equ SQRT_OP_A,      0x04
.equ SQRT_INIT,      0x08
.equ SQRT_RESULTADO, 0x0C
.equ SQRT_DONE,      0x10

.section .data
.section .text
.globl sqrt_hw

# Entrada:  a0 = Operando (debe ser positivo)
# Salida:   a0 = Resultado, o -1 si el input es negativo

sqrt_hw:
    # Validar que a0 >= 0
    bge  a0, zero, .sqrt_ok      # si es positivo, continuar

    # Es negativo retornar -1
    addi sp, sp, -4
    sw   ra, 0(sp)

    lw   ra, 0(sp)
    addi sp, sp, 4
    li   a0, -1                  # código de error
    ret
    
.sqrt_ok:
    
    li   t0, SQRT_BASE
    sw   a0, SQRT_OP_A(t0)          # escribir operando
    li   a1, 1
    sw   a1, SQRT_INIT(t0)          # init = 1 → arrancar
    sw   zero, SQRT_INIT(t0)        # init = 0 → pulso
 
.wait_sqrt:
    
    lw   t1, SQRT_DONE(t0)
    andi t1, t1, 1
    beqz t1, .wait_sqrt             # esperar hasta DONE == 1
 
    lw   a0, SQRT_RESULTADO(t0)     # leer resultado
    ret

