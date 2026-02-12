
## 📘 Descripción general

En esta carpeta se encuentran todos los archivos necesarios para el correcto funcionamiento de una calculadora.
la estructura del proyecto se muestra acontinuación: 

```Bash
\Calculadora
  \firmware
    \asm
  \rtl
    \cores
      ...
      \multiplicador
  ...
  SOC.v
```
Para cada periferico se crean los siguientes archivos:

- Los módulos necesarios para su funcionamiento
- Un módulo TOP
- Un testbench para simulación
- Archivo en assembler adicional utilizado por la calculadora completa
- Periferico para su implementacion 

Además, se encuentran 4 archivos adicionales necesarios para el funcionamiento de la calculadora.

---

### ✖️ Multiplicador 

El módulo multiplicador implementa un multiplicador secuencial basado en corrimientos y sumas parciales. Adicionalmente se diseño con la finalidad de usar numeros tanto positivos como negativos.

Este módulo toma dos operandos de 16 bits y produce un resultado de 32 bits utilizando un proceso iterativo controlado por una máquina de estados.

Se describe con mas detalle el funcionamiento del modulo mediante el uso de 3 diagramas, Diagrama de flujo, Datapath y Diagrama de estados; a continuación se anexan estos 3 diagramas.

<p align="center">
  <img src="./Diagramas/Captura%20desde%202026-02-12%2009-29-14.png" width="350">
  <img src="./Diagramas/Captura%20desde%202026-02-12%2009-33-01.png" width="350"> 
  <img src="./Diagramas/Captura%20desde%202026-02-12%2009-33-45.png" width="350">
</p>


A modo de resumen, se específica en la siguiente tabla las diferentes variables presentes en el diseño.

| Señal    | I/O    | Bits | Descripción                     |
| -------- | ------ | ---- | ------------------------------- |
| ``       | Input  |      | Multiplicando                   |
| ``       | Input  |      | Multiplicador                   |
| ``       | Input  |      | Inicia la operación             |
| ``       | Input  |      | Señal de reloj                  |
| ``       | Output |      | Indica que la operación terminó |
| ``       | Output |      | Resultado final                 |


Hay xxxx archivos relacionados a este Periferico:

- `.S` — Archivo en Assembler con el objetivo de realizar la comunicación entre el periférico y el procesador.

- `.v` — Archivo que instancia el módulo multiplicador como un periférico de un procesador RISC-V.

- `.v` — Módulo TOP del multiplicador, el cual declara las variables de entrada y salida del módulo, además de llamar el resto de módulos necesarios.

- `.v` — 
- `.v` —
- `.v` — 
- `.v` — 
- `.v` — 
- `.v` — 
