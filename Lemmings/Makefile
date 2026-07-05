SIM = tb_lemmings
SRC = Lemmings.v tb_lemmings.v
VCD = $(SIM).vcd
VVP = $(SIM).vvp
GTKW = sim.gtkw
GTKWAVE = /mnt/c/iverilog/gtkwave/bin/gtkwave.exe

.PHONY: all run wave clean

all: run

$(VVP): $(SRC)
	iverilog -g2012 -o $(VVP) $(SRC)

$(VCD): $(VVP)
	vvp $(VVP)

run: $(VCD)

wave: $(VCD)
	@if [ -f "$(GTKW)" ]; then \
		"$(GTKWAVE)" "$$(wslpath -w $(VCD))" "$$(wslpath -w $(GTKW))"; \
	else \
		"$(GTKWAVE)" "$$(wslpath -w $(VCD))"; \
	fi

clean:
	rm -f $(VVP) $(VCD)
