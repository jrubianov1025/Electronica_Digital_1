
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
      \Multiplicador
      \Divisor
      \Raiz
      \Binario-BCD
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

El módulo implementa un multiplicador secuencial basado en corrimientos y sumas parciales. Adicionalmente se diseño con la finalidad de usar numeros tanto positivos como negativos.

Este módulo toma dos operandos de 16 bits y produce un resultado de 32 bits utilizando un proceso iterativo controlado por una máquina de estados.

Se describe con mas detalle el funcionamiento del modulo mediante el uso de 3 diagramas, Diagrama de flujo, Datapath y Diagrama de estados; a continuación se anexan estos 3 diagramas.

<p align="center">
  <img src="./Diagramas/multiplicador_flujo.png" width="300">
  <img src="./Diagramas/multiplicador_datapath.png" width="400"> 
  <img src="./Diagramas/multiplicador_estados.png" width="350">
</p>


A modo de resumen, se específica en la siguiente tabla las diferentes variables presentes en el diseño.

| Señal    | I/O    | Bits | Descripción                     |
| -------- | ------ | ---- | ------------------------------- |
| `A`      | Input  |  16  | Multiplicando                   |
| `B`      | Input  |  16  | Multiplicador                   |
| `init`   | Input  |   1  | Inicia la operación             |
| `clk`    | Input  |   1  | Señal de reloj                  |
| `DONE`   | Output |   1  | Indica que la operación terminó |
| `R`      | Output |  32  | Resultado final                 |


Hay 9 archivos relacionados a este Periferico:

- `.S` — Archivo en Assembler con el objetivo de realizar la comunicación entre el periférico y el procesador.

- `Periferico_Multiplicador.v` — Archivo que instancia el módulo multiplicador como un periférico de un procesador RISC-V.

- `TOP_Multiplicador.v` — Módulo TOP del multiplicador, el cual declara las variables de entrada y salida del módulo, además de llamar el resto de módulos necesarios.

- `Testbench_Multiplicador.v` — Modulo que prueba el correcto funcionamiento de todos los modulos individuales.

- `Control_Multiplicador.v` — Modulo que ejecuta el diagrama de estados para el correcto funcionamiento del algoritmo.

- `Contador_Multiplicador.v` — Contador descendente que analiza los ciclos faltantes.

- `B_long_Multiplicador.v` — Modulo que registra los corrimientos del multiplicador y va guardando el resultado de forma simultanea.

- `A_long_Multiplicador.v` — modulo que almacena el multiplicando.

- `Acumulador_Multiplicador.v` — modulo donde se contruye el resultado. 


---

### ➗ Divisor 

El módulo implementa un divisor secuencial basado en corrimientos y sumas parciales. Adicionalmente se diseño con la finalidad de usar numeros tanto positivos como negativos.

Este módulo toma dos operandos de 16 bits y produce un resultado menor a 16 bits utilizando un proceso iterativo controlado por una máquina de estados.

Se describe con mas detalle el funcionamiento del modulo mediante el uso de 3 diagramas, Diagrama de flujo, Datapath y Diagrama de estados; a continuación se anexan estos 3 diagramas.

<p align="center">
  <img src="./Diagramas/Divisor_flujo.png" width="300">
  <img src="./Diagramas/Divisor_datapath.png" width="400"> 
  <img src="./Diagramas/Divisor_estados.png" width="350">
</p>


A modo de resumen, se específica en la siguiente tabla las diferentes variables presentes en el diseño.

| Señal      | I/O    | Bits | Descripción                     |
| --------   | ------ | ---- | ------------------------------- |
|`Dividendo` | Input  |  32  | Dividendo                       |
|`DR`        | Input  |  32  | Divisor                         |
|`INIT`      | Input  |   1  | Inicia la operación             |
|`CLK`       | Input  |   1  | Señal de reloj                  |
|`DONE`      | Output |   1  | Indica que la operación terminó |
|`Resultado` | Output |  32  | Resultado final                 |
|`Residuo`   | Output |  32  | Residuo final                   |


Hay 10 archivos relacionados a este Periferico:

- `.S` — Archivo en Assembler con el objetivo de realizar la comunicación entre el periférico y el procesador.

- `Periferico_Divisor.v` — Archivo que instancia el módulo divisor como un periférico de un procesador RISC-V.

- `Top_Divisor.v` — Módulo TOP del divisor, el cual declara las variables de entrada y salida del módulo, además de llamar el resto de módulos necesarios.

- `Control_Divisor.v` — Máquina de control del periférico. Genera señales de control para el correcto funcionamiento del periférico (basado en el diagrama de estados).

- `Corregir_Divisor.v` — Modulo que se encarga de corregir el signo al resultado final.

- `Contador_Divisor.v` — Contador descendente para llevar un registro de ciclos de ejecución realizados.

- `RegistroA_Divisor.v` — Modulo encargado de llevar y realizar todos los cambios relacionados al registro A, ademas , se almacena el residuo.

- `.RegistroDV_Divisor.v` — Modulo encargado de recibir el dividendo y realizar todos los cambios relacionados a este, ademas de almacenar el resultado final.

- `Sumador_Divisor.v` — Modulo encargado de realizar una operacion de suma en complemento a dos con la finalidad de aprobar o descartar la operacion.

- `Testbench_Divisor.v` — Módulo TESTBENCH para probar el funcionamiento del periférico. Crea un archivo .vcd que puede ser visualizado en GTKWave.



---

### ✔️ Raiz 

Este módulo implementa la Raíz cuadrada binaria mediante un procedimiento similar a una division larga, utiliza corrimientos, comparador con el uso de un sumador en complemento a dos y una máquina de control que coordina las etapas.

Se describe con mas detalle el funcionamiento del modulo mediante el uso de 3 diagramas, Diagrama de flujo, Datapath y Diagrama de estados; a continuación se anexan estos 3 diagramas.

<p align="center">
  <img src="./Diagramas/Raiz_flujo.png" width="300">
  <img src="./Diagramas/Raiz_datapath.png" width="400"> 
  <img src="./Diagramas/Raiz_estados.png" width="350">
</p>

A modo de resumen, se específica en la siguiente tabla las diferentes variables presentes en el diseño.

| Señal      | I/O    | Bits | Descripción                     |
| --------   | ------ | ---- | ------------------------------- |
| `Op_A`     | Input  | 16   | Numero del cual obtener su raíz |
| `INIT`     | Input  | 1    | Inicia la operación             |
| `CLK`      | Input  | 1    | Señal de reloj                  |
| `DONE`     | Output | 1    | Indica que la operación terminó |
| `Resultado`| Output | 16   | Resultado final                 |



Hay 10 archivos relacionados a este Periferico:

- `Raiz.S` — Archivo en Assembler con el objetivo de realizar la comunicación entre el periférico y el procesador.

- `Periferico_raiz.v` — Archivo que instancia el módulo Raíz como un periférico de un procesador RISC-V.

- `RAIZ.v` — Módulo TOP de la Raíz cuadrada, el cual declara las variables de entrada y salida del módulo, además de llamar el resto de módulos necesarios.

- `CONTROL_RAIZ.v` —   Máquina de control del periférico. Genera señales de control para el correcto funcionamiento del periférico (basado en el diagrama de estados).

- `COUNT_RAIZ.v` — Contador descendente para llevar un registro de ciclos de ejecución realizados.

- `LSR_A_RAIZ.v` — Toma el valor original y realiza un desplazamiento de dos bits para realizar la comparación del número con el resultado parcial.

- `LSR_R_RAIZ.v` — Se va construyendo el resultado mediante un corrimiento bit a bit y una señal de control R0.
 
- `LSR_TMP_RAIZ.v` — Registro de almacenamiento temporal del resultado parcial para su posterior uso en el sumador en complemento a dos. 

- `SUM_C2_RAIZ.v` — Sumador en complemento a dos que realiza la comparación directa de la pareja de bits en LSR_A_RAIZ y LSR_TMP_RAIZ concatenado con un uno para validar la operación.
 
- `tb_Periferico_raiz.v` — Módulo TESTBENCH para probar el funcionamiento del periférico. Crea un archivo .vcd que puede ser visualizado en GTKWave.
