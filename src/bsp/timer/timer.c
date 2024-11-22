#include "timer.h"

void timer_enable(timer_s *reg){
    uint32_t timer_cfg = reg -> cfg ;

    reg -> cfg = timer_cfg|0x01;
}

void timer_disable(timer_s *reg){
    uint32_t timer_cfg = reg -> cfg ;

    reg -> cfg = timer_cfg & ( ~0x01 );
}

void timer_set_pre( timer_s *reg ,uint32_t prescale ){
    reg->prescale = prescale;
}

void timer_set_value( timer_s *reg ,uint32_t value ) {
    reg->value = value;
}

void timer_clear( timer_s *reg ) {
    uint32_t timer_cfg = reg -> cfg ;
    reg -> cfg = timer_cfg | 0x02;
}
