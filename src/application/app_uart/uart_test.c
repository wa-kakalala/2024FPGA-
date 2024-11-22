#include <stdio.h>
#include "uart.h"
#include "timer.h"
#include "interrupt.h"

void uart_init(){
	uart_config_s uart_cfg;
    uart_cfg.datalen = 8;
    uart_cfg.parity = NONE;
    uart_cfg.stop = ONE;
    uart_cfg.clkdiv = CORE_HZ/8/115200-1;
    uart_config(UART,&uart_cfg);
    display("uart init done\r\n");
}

void timer_init(){
    timer_set_pre(TIMER,5);  // 10 MHz 's clk
    timer_set_value(TIMER,1000) ; // 1ms 's preiod / 10 ms
    timer_clear(TIMER);
    timer_enable(TIMER);
    display("timer init done\r\n");
}
// display("timer init is running ...\n");

int main(){
	uart_init();
    
    int res ;
    display("system is running ...\n");
    
    // enable_int( UART_IRQ, 1);
    // set_priority(UART_IRQ,1);
    timer_init();
    while( 1 ) {
        // display( "hello world \n");
        // display("enter interrupt...\n");
        // display("int_id : %d \n",1);
        // display("exit interrupt\n");
    }
};

void uart_irq () {
    //display("enter uart irq...\n");
    uint8_t r = uart_read(UART);
    uart_write(UART,r);
    // display("%c\r\n",r);
}

void timer_irq() {
    
    display("enter timer_irq\n");
    timer_clear(TIMER);
}


int count = 0;
void irqCallback(){
    // display("enter irqCallback\n");
	// int int_id = INTERRUPT->status;
    // int_id = int_id >> 24;
    // if( int_id == UART_IRQ ) {
    //     uart_irq();
    // }

    if( ((TIMER) -> interrupt) & 0x01 ){
        timer_irq();
    }
}
