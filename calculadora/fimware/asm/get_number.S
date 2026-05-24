.section .text
.globl get_number
get_number:
    addi sp, sp, -24        
    sw   ra, 20(sp)         
    sw   s0, 16(sp)         
    sw   s1, 12(sp)         # s1 = flag de signo
    sw   s2, 8(sp)          # s2 = registro temporal para carácter (reemplaza t6)
    sw   t0, 4(sp)          
    sw   t1, 0(sp)          
    li   s0, 0              # acumulador BCD
    li   s1, 0              # flag signo: 0=positivo, 1=negativo
    
    # Leer primer carácter para detectar signo
    call getchar
    li   t0, 45             # '-'
    bne  a0, t0, .no_negativo
    
    # Es negativo
    li   s1, 1              # marcar negativo
    call putchar            # eco del '-'
    j    get_number_loop    # leer dígitos

.no_negativo:

    # No es '-', validar antes de hacer eco
    add  s2, a0, zero       # CORRECCIÓN: guardar en s2 (callee-saved) en vez de t6

    # Verificar terminadores
    li   t0, 10
    beq  s2, t0, get_number_done
    li   t0, 13
    beq  s2, t0, get_number_done
    li   t0, 32
    beq  s2, t0, get_number_done

    # Verificar dígito válido
    li   t0, 48
    blt  s2, t0, get_number_loop  # inválido: releer sin hacer eco
    li   t0, 57
    bgt  s2, t0, get_number_loop  # inválido: releer sin hacer eco

    # CORRECCIÓN: eco solo después de validar
    add  a0, s2, zero
    call putchar
    add  a0, s2, zero
    andi a0, a0, 15
    slli s0, s0, 4
    or   s0, s0, a0

get_number_loop:

    call getchar
    add  s2, a0, zero       # guardar en s2

    # Verificar terminadores
    li   t0, 10
    beq  s2, t0, get_number_done
    li   t0, 13
    beq  s2, t0, get_number_done
    li   t0, 32
    beq  s2, t0, get_number_done

    # Verificar dígito válido
    li   t0, 48
    blt  s2, t0, get_number_loop  # inválido: releer sin hacer eco
    li   t0, 57
    bgt  s2, t0, get_number_loop  # inválido: releer sin hacer eco

    # CORRECCIÓN: eco solo después de validar
    add  a0, s2, zero
    call putchar
    add  a0, s2, zero
    andi a0, a0, 15
    slli s0, s0, 4
    or   s0, s0, a0
    j    get_number_loop

get_number_done:

    # Colocar SIGN en bits [31:28] 
    li   t1, 28
    li   t0, 0xF             # positivo por defecto
    beqz s1, .poner_sign
    li   t0, 0xA             # negativo

.poner_sign:

    sll  t0, t0, t1          # t0 = SIGN << 28
    or   s0, s0, t0          # s0 = {SIGN, dígitos}
    add  a0, s0, zero
    lw   t1, 0(sp)
    lw   t0, 4(sp)
    lw   s2, 8(sp)
    lw   s1, 12(sp)
    lw   s0, 16(sp)
    lw   ra, 20(sp)
    addi sp, sp, 24
    ret