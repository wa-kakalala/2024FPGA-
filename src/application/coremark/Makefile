TARGET := core_mark

target := main
# do not use relative path
tool_chain = /home/wkk/software/riscv1007/bin/
work_dir = /home/wkk/code/spinal_hdl/briey_test/briey_soc/
prefix = riscv32-unknown-elf-

src_path := $(work_dir)bsp/uart/ 
src := $(shell find $(src_path) -name '*.c')
src_path := $(work_dir)bsp/timer/ 
src += $(shell find $(src_path) -name '*.c')
src_path := $(work_dir)bsp/interrupt/ 
src += $(shell find $(src_path) -name '*.c')
src += $(shell find "./" -name '*.c')
# src += $(shell find "./barebones/" -name '*.c') # include multi times 
# $(info $(src))
link_file = $(work_dir)board/briey.ld
startup_file = $(work_dir)board/crt.s

INC := -I$(work_dir)bsp 
INC += -I$(work_dir)bsp/uart 
INC += -I$(work_dir)bsp/timer 
INC += -I$(work_dir)bsp/interrupt 
INC += -I./
INC += -I./barebones

build:
	$(prefix)gcc -march=rv32im_zicsr -mabi=ilp32 $(INC) $(src)  $(startup_file) -T $(link_file) -o $(TARGET).elf -nostartfiles
	$(prefix)objcopy -O verilog $(TARGET).elf $(TARGET).verilog
	sed -i 's/@800/@000/g' $(TARGET).verilog
show:
	$(prefix)objdump -d -S $(TARGET).elf > $(TARGET).dump
size:
	$(prefix)size $(TARGET).elf
.PHONY: build show size
