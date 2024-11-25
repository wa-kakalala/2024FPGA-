#include "uart.h"

uint32_t uart_write_avail(uart_s *reg){
	return (reg->status >> 16) & 0xFF;
}
uint32_t uart_read_occu(uart_s *reg){
	return reg->status >> 24;
}

void uart_write(uart_s *reg, uint32_t data){
	
	while(uart_write_avail(reg) == 0);
	reg->data = data;
	
}

uint8_t uart_read(uart_s *reg) {
	while( uart_read_occu(reg) == 0);
	return (reg->data) & 0xff;
}

void uart_config(uart_s *reg, uart_config_s *config){
	reg->status = 2;  //enable rx interrupts
	reg->clockdivider = config->clkdiv;
	reg->frame_config = ((config->datalen-1) << 0) | (config->parity << 8) | (config->stop << 16);
}

void put_c(char c){
	uart_write(UART, c);
}

static void printf_c(int c)
{
	put_c(c);
}

static void printf_s(char *p)
{
	while (*p)
		put_c(*(p++));
}

static void printf_d(int val)
{
	char buffer[32];
	char *p = buffer;
	if (val < 0) {
		printf_c('-');
		val = -val;
	}
	while (val || p == buffer) {
		*(p++) = '0' + val % 10;
		val = val / 10;
	}
	while (p != buffer)
		printf_c(*(--p));
}

void display(const char *format, ...) {
	disable_global_interrupts();
	int i;
	va_list ap;

	va_start(ap, format);

	for (i = 0; format[i]; i++) {
		if (format[i] == '%') {
			while (format[++i]) {
				if (format[i] == 'c') {
					printf_c(va_arg(ap,int));
					break;
				}
				if (format[i] == 's') {
					printf_s(va_arg(ap,char*));
					break;
				}
				if (format[i] == 'd') {
					printf_d(va_arg(ap,int));
					break;
				}
			}
		} else {
			printf_c(format[i]);
		}
	}
	va_end(ap);
	enable_global_interrupts();
}

__attribute__((weak)) ssize_t _write(int fd, const void* ptr, size_t len)
{
    const uint8_t *writebuf = (const uint8_t *)ptr;
    for (size_t i = 0; i < len; i++) {
        if (writebuf[i] == '\n') {
            uart_write(UART, '\r');
        }
        uart_write(UART, writebuf[i]);
    }
    return len;
}
