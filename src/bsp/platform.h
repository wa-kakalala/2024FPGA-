#ifndef _PLATFORM_H
#define _PLATFORM_H

#define CORE_HZ        50000000

// periph
#define UART_BASE      (0xF0010000)
#define TIMER_BASE     (0xF0020000)
// interrupt
#define INT_BASE       (0x50000000)

// interrupt table 
#define UART_IRQ       (0)


#define GPIO_A_BASE    (0xF0000000)
#define GPIO_B_BASE    (0xF0001000)
#define VGA_BASE       (0xF0030000)

#endif