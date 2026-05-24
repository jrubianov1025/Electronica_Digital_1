.section .text
.globl start 
.globl blinker
.globl put_hello
.globl calculator

calculator:

loopM:  
li   sp, 0x2000

# PRIMER NÚMERO
la   a0, number
call putstring
call get_number          # retorna BCD empaquetado {SIGN,d6..d0}
call bcd2bin             # retorna binario signed en a0
add  s0, a0, zero        # guardar primer número en s0 (callee-saved)

# OPERADOR
la   a0, operator
call putstring 
call getchar             # leer operador
add  s2, a0, zero        # guardar operador en s2
add  a0, s2, zero
call putchar             # eco del operador

# DECIDIR OPERACIÓN
li   t4, 64              # '@' = raíz cuadrada (un solo operando)
beq  s2, t4, OP_SQRT

# SEGUNDO NÚMERO (solo si no es SQRT)
la   a0, number
call putstring
call get_number          # retorna BCD empaquetado
call bcd2bin             # retorna binario signed en a0
add  s3, a0, zero        # guardar segundo número en s3 (callee-saved)

li   t4, 42              # '*'
beq  s2, t4, OP_MUL

li   t4, 47              # '/'
beq  s2, t4, OP_DIV

li   t4, 43              # '+'
beq  s2, t4, OP_ADD

li   t4, 45              # '-'
beq  s2, t4, OP_SUB

# operador no reconocido → volver al inicio
j    loopM

# OPERACIONES

OP_MUL:

add  a0, s0, zero
add  a1, s3, zero
call mult_hw
add  s1, a0, zero
j    print_result

OP_DIV:

# Validar división por cero
beqz s3, error_div_zero
add  a0, s0, zero
add  a1, s3, zero
call div_hw
add  s1, a0, zero
j    print_result

OP_ADD:
add  s1, s0, s3
j    print_result

OP_SUB:
sub  s1, s0, s3
j    print_result

OP_SQRT:
add  a0, s0, zero
call sqrt_hw
li   t4, -1
beq  a0, t4, error_sqrt  # sqrt_hw retorna -1 si el input es negativo
add  s1, a0, zero
j    print_result

# ERRORES

error_div_zero:
la   a0, msg_div_zero
call putstring
j    loopM

error_sqrt:
la   a0, msg_sqrt_neg
call putstring
j    loopM

# IMPRIMIR RESULTADO

print_result:
la   a0, result
call putstring
add  a0, s1, zero
call bin2bcd_hw          # retorna {SIGN,MILLON,CIENMIL,DIEZMIL,MIL,CENT,DEC,UNIT}
add  s1, a0, zero

# Verificar signo (nibble bits 31:28)
srli t0, s1, 28
andi t0, t0, 0xF
li   t4, 0xA             # A = negativo
beq  t0, t4, .es_negativo
j    .print_digits

.es_negativo:
li   a0, 45              # '-' ASCII
call putchar

.print_digits:
li   t3, 7               # 7 dígitos (MILLON a UNIT)

.print_loop:
slli s1, s1, 4           # descartar nibble ya procesado
srli t0, s1, 28          # extraer siguiente dígito
andi t0, t0, 0x0F
addi t0, t0, 0x30        # convertir a ASCII
add  a0, t0, zero
call putchar
addi t3, t3, -1
bnez t3, .print_loop
j    loopM               # volver al inicio

# STRINGS
.section .data
number:
    .asciz "\n\rNumber: "
operator:
    .asciz "\n\rOperator: "
result:
    .asciz "\n\rResult = "
msg_div_zero:
    .asciz "\n\rError: division por cero"
msg_sqrt_neg:
    .asciz "\n\rError: raiz de numero negativo"