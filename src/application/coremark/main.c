
#include <stdio.h>
#include "core_main.h"
#include "uart.h"
#include "timer.h"
#include "interrupt.h"
uint32_t ms_count;

void uart_init(){
	uart_config_s uart_cfg;
    uart_cfg.datalen = 8;
    uart_cfg.parity = NONE;
    uart_cfg.stop = ONE;
    uart_cfg.clkdiv = CORE_HZ/8/115200-1;
    uart_config(UART,&uart_cfg);
    display("uart init is done \r\n");
}

void timer_init(){
    timer_set_pre(TIMER,50);  // 1 MHz 's clk
    timer_set_value(TIMER,10000) ; // 10ms 's preiod 
    timer_clear(TIMER);
    timer_enable(TIMER);
    display("timer init is done \r\n");
}

int main(){
    uart_init ();
    timer_init();
    core_main ();
}

void timer_irq() {
    ms_count ++ ;
    timer_clear(TIMER);
}

void irqCallback(){
    // display("enter irqCallback\n");
	// int int_id = INTERRUPT->status;
    // int_id = int_id >> 24;
    // if( int_id == UART_IRQ ) {
    //     uart_irq();
    // }

    if( ((TIMER) -> interrupt) & 0x01 ){
        // display("timer interrupt \r\n");
        timer_irq();
    }
}




