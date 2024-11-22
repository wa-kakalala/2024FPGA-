#ifndef _INTERRUPT_H_
#define _INTERRUPT_H_
#include <stdarg.h>
#include <stdint.h>
#include <sys/types.h>
#include "platform.h"

typedef struct
{
  volatile uint32_t int_cfg     ;
  volatile uint32_t status      ;
  volatile uint32_t int_pri[8]  ;
} interrupt_s;

#define INTERRUPT  ((interrupt_s*)INT_BASE)

void enable_int( uint8_t int_id,uint8_t en_global );
void disable_gb();
void disable_int( uint8_t int_id );
void set_priority( uint8_t int_id, uint32_t priority);

#endif