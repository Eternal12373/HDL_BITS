SIM = tb_ps2
SRC = ps2.v tb_ps2.v
VCD = $(SIM).vcd
VVP = $(SIM).vvp
GTKWAVE = /mnt/c/iverilog/gtkwave/bin/gtkwave.exe

.PHONY: all wave clean

all: wave

$(VVP): $(SRC)
	iverilog -g2012 -o $(VVP) $(SRC)

$(VCD): $(VVP)
	vvp $(VVP)

wave: $(VCD)
	"$(GTKWAVE)" "$$(wslpath -w $(VCD))"

clean:
	rm -f $(VVP) $(VCD)
