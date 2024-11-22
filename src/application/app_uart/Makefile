target := uart_test
# do not use relative path
tool_chain = /home/wkk/software/riscv1007/bin/
work_dir = /home/wkk/code/spinal_hdl/briey_test/briey_soc/

prefix = riscv32-unknown-elf-

# src_path = ../bsp/uart 
# src = $(foreach dir, $(src_path), $(wildcard $(dir)*.c))

INC = -I./
INC += -I$(work_dir)bsp 
INC += -I$(work_dir)bsp/uart 
INC += -I$(work_dir)bsp/timer 
INC += -I$(work_dir)bsp/interrupt 

%.o : %.c
	$(CC) $(DEBUG) $(INC) $^ -o $@ 

build:
	$(prefix)gcc -march=rv32im_zicsr -mabi=ilp32 $(INC) $(work_dir)bsp/uart/uart.c $(work_dir)bsp/timer/timer.c $(work_dir)bsp/interrupt/interrupt.c crt.s $(target).c -T briey.ld -o $(target).elf -nostartfiles
	$(prefix)objcopy -O verilog $(target).elf $(target).verilog
	sed -i 's/@800/@000/g' $(target).verilog
show:
	$(prefix)objdump -d -S $(target).elf > $(target).dump


.PHONY: build show

# reference: https://blog.csdn.net/xyyangxiaoliang/article/details/122550718