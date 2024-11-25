#ifndef _UART_H_ 
#define _UART_H_

#include <stdio.h>
#include <stdint.h>
#include <stdarg.h>
#include <stdint.h>
#include <sys/types.h>
#include "platform.h"
#include "common.h"

typedef struct
{
  volatile uint32_t data        ;
  volatile uint32_t status      ;
  volatile uint32_t clockdivider;
  volatile uint32_t frame_config;
} uart_s;

#define UART  (uart_s*)UART_BASE

enum UartParity_E { NONE = 0,EVEN = 1,ODD = 2};
enum UartStop_E   { ONE  = 0,TWO  = 1};

typedef struct {
	uint32_t datalen;
	enum UartParity_E parity;
	enum UartStop_E stop;
	uint32_t clkdiv;
} uart_config_s;


uint32_t uart_write_avail(uart_s *reg);
uint32_t uart_read_occu(uart_s *reg);
void uart_write(uart_s *reg, uint32_t data);
uint8_t uart_read(uart_s *reg) ;
void uart_config(uart_s *reg, uart_config_s *config);
void display(const char *format, ...) ;
/*
example: 
    uart_config_s uart_cfg;
    uart_cfg.datalen = 8;
    uart_cfg.parity = NONE;
    uart_cfg.stop = ONE;
    uart_cfg.clkdiv = CORE_HZ/8/115200-1;
    uart_config(UART,&uart_cfg);

	uart_write(UART, 'a');
    display("%d%c%s",1,'h',"....");
*/



#endif