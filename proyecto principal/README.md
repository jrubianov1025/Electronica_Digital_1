
## 📘 Descripción general

En esta carpeta se encuentran todos los archivos necesarios para el funcionamiento del proyecto principal de la asignatura.

la estructura del proyecto se muestra acontinuación: 

```Bash

    \proyecto principal

      \Diagramas
        I2C_Datapath.png
        I2C_Estados.png
        I2C_Flujo.png

      \Codigo_pantalla

      \controlador ads1115
        \ADS1115_CONTROLLER
          ADS1115_CONTROL.v
          ADS1115_DATA.v
          ADS1115_TOP.v
          TICK_GENERATOR.v

        \I2C
          \CONTADOR_BITS.v     
          \CONTADOR_BYTES.v    
          \CONTROL.v 
          \I2C_CLOCK_GENERATOR.v
          \SHIFT_REG.v
          \Top_I2C.v

      CONTROLADOR_I2C_i9.lpf
      CONTROLADOR_I2C.v
      Makefile
      tb_CONTROLADOR_I2C.v

    Makefile
    Pantalla_I2C.v
    TOP_PROYECTO_i9.lpf
    TOP_PROYECTO.v

    README.md
  ...

```
La carpeta `build/` contiene las salidas generadas automáticamente por el flujo de síntesis (`.json`, `.config`, `.bit`, `.svf`, `.rpt`) y no debe editarse manualmente; se regenera con `make`.

---

##  PANTALLA LED

<p align="center">
  <img src="./Diagramas/_flujo.png" width="300">
  <img src="./Diagramas/_datapath.png" width="400">
  <img src="./Diagramas/_estados.png" width="350">
</p>

---

##  Controlador  ADS1115 

Esta carpeta contiene una de las partes principales del proyecto principal: un controlador digital para el ADC externo ADS1115.

El objetivo del diseño es leer periódicamente, por el bus I2C, el valor digital de la conversión que realiza el ADS1115 y dejarlo disponible dentro de la FPGA como una palabra de 16 bits (adc_value). Para esto el proyecto se divide en dos bloques independientes que se comunican entre sí:

1. Un controlador (ADS1115_CONTROLER) que conoce el protocolo específico del ADS1115 (registros, secuencia de configuración y tiempos de espera entre lecturas).

2. Un maestro I2C genérico (I2C) que no conoce nada del ADS1115: solo sabe transmitir/recibir bytes por el bus I2C cuando se le indica una dirección, un modo (lectura/escritura) y una cantidad de bytes.



###  📥 ADS1115_CONTROLER 
 
Esta carpeta posee cuatro archivos fundamentales para la comunicacion con el ADS1115; el objetivo principal es implementar una máquina de estados que realice **el protocolo de configuración y lectura periódica del ADS1115**, usando al maestro I2C. No conoce los tiempos del bus I2C bit a bit; solo le pide al maestro escribir o leer N bytes y espera la señal `done`.
 
Secuencia que realiza en cada ciclo de lectura:
 
1. **Configuracion del ADC** escribiendo 4 bytes en el registro `CONFIG` (0x01): dirección + puntero de registro + 2 bytes de configuración. Los dos bytes de configuracion pueden ser modificados dependiendo del uso. (ver comentario en cabecera del archivo con el mapa de bits completo del registro `CONFIG`).

2. **Apuntar al registro de conversión** (0x00) escribiendo el puntero correspondiente.

3. **Leer 2 bytes** (MSB y LSB) del resultado de la conversión y arma `adc_value.

4. **Esperar** un tiempo configurable (`DELAY_MS`, por defecto 500 ms) usando `TICK_GENERATOR`, y vuelve al paso 2 para leer el siguiente dato (no repite la configuración salvo que exista un error o un reset).
 
Estos diagramas, permiten visualizar al detalle el funcionamiento de los modulos.


<p align="center">
  <img src="./Diagramas/ADS1115_flujo.png" width="300">
  <img src="./Diagramas/ADS1115_datapath.png" width="400">
  <img src="./Diagramas/ADS1115_estados.png" width="350">
</p>

El controlador se divide en tres bloques principales y un modulo top:

- `ADS1115_CONTROL.v` — Implementa una máquina de estados encargada de coordinar toda la comunicación con el ADS1115 a través del maestro I2C. Durante el primer ciclo configura el registro `CONFIG` del ADC, posteriormente selecciona el registro de conversión `0x00`, solicita la lectura de dos bytes y espera un tiempo configurable antes de repetir el proceso. Además, supervisa la señal `ack_error` para detectar errores de comunicación.

- `ADS1115_DATA.v` — Se encarga de almacenar los dos bytes recibidos desde el maestro I2C, reconstruir el valor digital de 16 bits `adc_value`, generar un pulso `adc_valid` cuando una nueva conversión está disponible y mantener el índice del byte actualmente transmitido o recibido durante cada transacción.

- `TICK_GENERATOR.v` — Temporizador parametrizable en milisegundos. Cuenta ciclos de reloj hasta alcanzar `(CLK_FREQ_HZ / 1000) * DELAY_MS` y genera un pulso `tick` de un ciclo de duración. Solo cuenta mientras `enable` está activo; si `enable` baja, el contador se reinicia

- `ADS1115_TOP.v` — Módulo superior del controlador. Instancia los módulos ADS1115_CONTROL, ADS1115_DATA y TICK_GENERATOR, conectando las señales de control, datos y temporización. Su función es integrar todos los bloques necesarios para que el controlador interactúe con el maestro I2C y entregue el valor digital leído `adc_value` junto con las señales de estado `adc_valid y error_alert`.
 
---

###  📥 I2C 

en esta carpeta se encuentran los archivos nesesarios para la implementacion de un **maestro I2C** capaz de transmitir o recibir una ráfaga de N bytes hacia/desde un esclavo, gestionando internamente las condiciones de START, STOP, ACK/NACK y el reloj del bus (SCL). Es completamente independiente del ADS1115.

 Para profundizar mejor en el diseño del maestro I2C se encuentran estos 3 diagramas (Diagrama de flujo, Datapath y Diagrama de estados) que permiten una visualizacion del diseño y la separacion de tareas dentro de este.

<p align="center">
  <img src="./Diagramas/I2C_Flujo.png" width="300">
  <img src="./Diagramas/I2C_Datapath.png" width="400"> 
  <img src="./Diagramas/I2C_Estados.png" width="350">
</p>

esta carpeta posee 6 archivos nesesarios para el correcto funcionamiento del protocolo ademas de un archivo adicional encargado de simular su funcionamiento.
 
 
- `Top_I2C.v` — Módulo TOP del maestro. Además de instanciar los submódulos siguientes, implementa la siguiente lógica **open-drain** del bus:
 
 `SDA` se libera a alta impedancia (`1'bz`) o se fuerza a `0`, nunca se maneja en alto directamente. Ademas, Sincroniza la entrada `SDA` con el reloj de la FPGA mediante dos flip-flops en cascada (`sda_meta` → `sda_sync`) para evitar metaestabilidad.

`SCL` se libera en alta impedancia cuando el generador de reloj interno la marca en alto, permitiendo *clock stretching* por parte del esclavo.

- `CONTROL.v` — Es una máquina de estados que recorre bit a bit y byte a byte toda la transacción I2C, sincronizada con los flancos de subida/bajada de SCL (`scl_rise` / `scl_fall`) que le entrega `I2C_CLOCK_GENERATOR`.
 
 
- `I2C_CLOCK_GENERATOR.v` — Genera la señal `SCL` dividiendo el reloj del sistema, calculando automáticamente el semiperiodo. Además entrega pulsos `scl_rise` y `scl_fall` de un ciclo de duración, usados por la amquina de control para sincronizar toda la máquina de estados. Si `enable` está en bajo, `scl` queda fija y el contador se mantiene en reposo.
 
- `SHIFT_REG.v` Registro de desplazamiento de 8 bits de doble función:  En transmisión (`shift_tx`): desplaza a la izquierda insertando un `0` por el bit menos significativo, y expone siempre el bit más significativo (`tx_bit = shift_reg[7]`) hacia el bus. En recepción (`shift_rx`): desplaza a la izquierda insertando el valor leído de `sda_in`. 

- `CONTADOR_BITS.v`— Contador descendente que cuenta los 8 bits de un byte. La bandera `z_bits` se activa cuando el contador llega a `0`, indicando a la maquina de control que ya se procesaron los 8 bits del byte actual.
 
- `CONTADOR_BYTES.v` — Contador descendente que cuenta los bytes restantes de la transacción completa. La bandera `z_bytes` indica que ya no quedan más bytes por transmitir/recibir, señal que usa la maquina de control para decidir si continuar la ráfaga o pasar a la condición de STOP.
 
- `TESTBENCH.v` — Simula un esclavo I2C que responde con ACK a las tramas de dirección y datos, permitiendo comprobar de forma independiente que `TOP_I2C.v` genera correctamente las condiciones de START/STOP, los 8 bits de cada byte y el manejo de ACK/NACK, antes de integrarlo con la lógica específica del ADS1115.
 
---

Esta separación permite que el maestro I2C sea reutilizable para comunicarse con cualquier periférico I2C, no solo con el ADS1115. Ademas, realizar esta separacion de tareas simplifica el desarrolo del maestro I2C, en especial su FSM.


Ademas de estas carpetas, se encuentran 4 archivos adicionales que complementan el desarrolo del controlador. Estos son:


- `CONTROLADOR_I2C.v` — Módulo top que instancia y conecta el `ADS1115_CONTROLLER` con `TOP_I2C`, y expone hacia la FPGA solo las señales físicas necesarias (reloj, reset y el bus I2C).
 
 - `Makefile` — automatiza tanto la simulación como el flujo de síntesis para la FPGA Colorlight i9:
 
- `CONTROLADOR_I2C_i9.lpf` — define la asignación de pines físicos en la tarjeta Colorlight i9:
 
- `tb_CONTROLADOR_I2C.v` — valida el sistema completo (`CONTROLADOR_I2C`), simulando un **ADS1115 esclavo completo**: responde ACK a la configuración, ACK al puntero de registro, y entrega valores de conversión simulados que van cambiando (0x1A55 → 0x2B66 → 0x3C77) en cada ciclo de lectura. El testbench declara éxito cuando adc_value refleja correctamente las tres lecturas esperadas, y cuenta con un timeout de seguridad de 20 ms simulados por si la máquina de estados quedara bloqueada.

---
 

 
