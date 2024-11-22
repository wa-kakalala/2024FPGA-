#ifndef _TIMER_H
#define _TIMER_H

#include <stdio.h>
#include <stdint.h>
#include <stdarg.h>
#include <stdint.h>
#include <sys/types.h>
#include "platform.h"

typedef struct
{
  volatile uint32_t value    ;
  volatile uint32_t prescale ;
  volatile uint32_t cfg      ;
  volatile uint32_t interrupt;
} timer_s;

#define TIMER  (timer_s*)TIMER_BASE

void timer_enable(timer_s *reg);
void timer_disable(timer_s *reg);
void timer_set_pre( timer_s *reg ,uint32_t prescale );
void timer_set_value( timer_s *reg ,uint32_t value ) ;
void timer_clear( timer_s *reg );
#endif