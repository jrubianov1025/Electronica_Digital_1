TOP        = Pantalla
BUILD_DIR  = build

OBJS  = $(TOP).v

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

.PHONY: all sim clean configure_i9

all: $(TOP)_i9.bit

# Simulación (iverilog + gtkwave)

sim: $(OBJS) $(TB_OBJS)
	rm -f a.out *.vcd
	iverilog -g2012 -o a.out $(TB_OBJS) $(OBJS)
	vvp a.out
	gtkwave *.vcd

# Síntesis + PnR + empaquetado (Colorlight i9)

$(TOP)_i9.json: $(OBJS)
	mkdir -p $(BUILD_DIR)
	yosys -p 'verilog_defaults -push; verilog_defaults -add -defer; read_verilog -formal $(OBJS); verilog_defaults -pop; attrmap -tocase keep -imap keep="true" keep=1 -imap keep="false" keep=0 -remove keep=0; synth_ecp5 -top $(TOP); write_json $(BUILD_DIR)/$@' -l $(BUILD_DIR)/$(TOP).rpt

$(TOP)_i9_out.config: $(TOP)_i9.json
	nextpnr-ecp5 --json $(BUILD_DIR)/$< --lpf $(TOP)_i9.lpf --textcfg $(BUILD_DIR)/$@ --45k --package CABGA381 --speed 6 --timing-allow-fail --seed 1 --lpf-allow-unconstrained

$(TOP)_i9.bit: $(TOP)_i9_out.config
	ecppack --bootaddr 0 --compress $(BUILD_DIR)/$< --svf $(BUILD_DIR)/$(TOP).svf --bit $(BUILD_DIR)/$@

configure_i9: $(TOP)_i9.bit
	sudo openFPGALoader -b colorlight-i9 -m $(BUILD_DIR)/$(TOP)_i9.bit

clean:
	rm -rf $(BUILD_DIR) *.json a.out *.vcd *.rpt