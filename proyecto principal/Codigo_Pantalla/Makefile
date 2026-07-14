TARGET = Pantalla
TOP    = Pantalla

OBJS  = Pantalla.v

OBJS += Timer_ws2812/comp_timer_ws2812.v
OBJS += Timer_ws2812/Control_Timer_WS2812.v
OBJS += Timer_ws2812/count_out.v
OBJS += Timer_ws2812/mux_timer_ws2812.v
OBJS += Timer_ws2812/Timer_WS2812.v

OBJS += WS2812_led/Control_WS2812_LED.v
OBJS += WS2812_led/Count_24.v
OBJS += WS2812_led/LSR_RGB.v
OBJS += WS2812_led/WS2812_led.v

OBJS += WS2812_Led_Array/Comp_Addr.v
OBJS += WS2812_Led_Array/Control_WS2812_Led_Array.v
OBJS += WS2812_Led_Array/Count_Addr.v
OBJS += WS2812_Led_Array/Image_0.v
OBJS += WS2812_Led_Array/Image_1.v
OBJS += WS2812_Led_Array/Image_2.v
OBJS += WS2812_Led_Array/Image_3.v
OBJS += WS2812_Led_Array/Led_Mem.v
OBJS += WS2812_Led_Array/WS2812_Led_Array.v

TB_OBJS = Pantalla_TB.v
BUILD_DIR = build

sim: $(OBJS) $(TB_OBJS)
	rm -f a.out *.vcd
	iverilog -g2012 -o a.out $(TB_OBJS) $(OBJS)
	vvp a.out
	gtkwave *.vcd

$(TARGET)_i9.json: $(OBJS)
	mkdir -p $(BUILD_DIR)
	yosys -p 'synth_ecp5 -top $(TARGET); write_json $(BUILD_DIR)/$@' -l $(BUILD_DIR)/$(TARGET).rpt

$(TARGET)_i9_out.config: $(TARGET)_i9.json
	nextpnr-ecp5 --json $(BUILD_DIR)/$< --lpf $(TARGET)_i9.lpf --textcfg $(BUILD_DIR)/$@ --45k --package CABGA381 --speed 6 --timing-allow-fail --seed 1 --lpf-allow-unconstrained

$(TARGET)_i9.bit: $(TARGET)_i9_out.config
	ecppack --bootaddr 0 --compress $(BUILD_DIR)/$< --svf $(BUILD_DIR)/$(TARGET).svf --bit $(BUILD_DIR)/$@

configure_i9: $(TARGET)_i9.bit
	sudo openFPGALoader -b colorlight-i9 -m $(BUILD_DIR)/$(TARGET)_i9.bit

clean:
	rm -rf $(BUILD_DIR) *.json *.rpt *.vcd a.out