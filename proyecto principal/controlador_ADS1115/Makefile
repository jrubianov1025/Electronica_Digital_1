TOP        = CONTROLADOR_I2C
BUILD_DIR  = build

OBJS  = $(TOP).v
OBJS += ADS1115_CONTROLER/ADS1115_TOP.v
OBJS += ADS1115_CONTROLER/ADS1115_CONTROL.v
OBJS += ADS1115_CONTROLER/ADS1115_DATA.v
OBJS += ADS1115_CONTROLER/TICK_GENERATOR.v

OBJS += I2C/Top_I2C.v
OBJS += I2C/CONTROL.v
OBJS += I2C/SHIFT_REG.v
OBJS += I2C/CONTADOR_BITS.v
OBJS += I2C/CONTADOR_BYTES.v
OBJS += I2C/I2C_CLOCK_GENERATOR.v

TB_OBJS = tb_CONTROLADOR_I2C.v

.PHONY: all sim clean configure_i9

all: $(TOP)_i9.bit

# Simulación (iverilog + gtkwave)

sim: $(OBJS) $(TB_OBJS)
	rm -f a.out *.vcd
	iverilog -o a.out $(TB_OBJS) $(OBJS)
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