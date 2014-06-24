#===================================================================
#
# Makefile
# --------
# Makefile for building core and top simulation.
#
#
# (c) 2013 Joachim Strombergson
#
#===================================================================

QR_SRC=../src/rtl/salsa20_qr.v
QR_TB_SRC=../src/tb/tb_salsa20_qr.v

CORE_SRC=../src/rtl/salsa20_core.v ../src/rtl/salsa20_qr.v
CORE_TB_SRC=../src/tb/tb_salsa20_core.v

TOP_SRC=../src/rtl/salsa20.v $(CORE_SRC)
TOP_TB_SRC=../src/tb/tb_salsa20.v

CC=iverilog


all: top core


top: $(TOP_TB_SRC) $(TOP_SRC)
	$(CC) -o top.sim $(TOP_TB_SRC) $(TOP_SRC)


core: $(CORE_TB_SRC) $(CORE_SRC)
	$(CC) -o core.sim $(CORE_SRC) $(CORE_TB_SRC)

qr:  $(QR_TB_SRC) $(QR_SRC)
	$(CC) -o qr.sim $(QR_SRC) $(QR_TB_SRC)

sim-qr: qr.sim
	./qr.sim

sim-core: core.sim
	./core.sim


sim-top: top.sim
	./top.sim


help:
	@echo "Supported targets:"
	@echo "------------------"
	@echo "all:      Build all simulation targets."
	@echo "top:      Build the top simulation target."
	@echo "core:     Build the top simulation target."
	@echo "sim-top:  Run top level simulation."
	@echo "sim-core: Run core level simulation."
	@echo "debug:    Print the internal varibles."

clean:
	rm -f core.sim
	rm -f top.sim

#===================================================================
# EOF Makefile
#===================================================================

