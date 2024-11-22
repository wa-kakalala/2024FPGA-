#include "interrupt.h"

void enable_int( uint8_t int_id,uint8_t en_global ){
    uint32_t int_cfg = INTERRUPT->int_cfg;
    if( en_global ) int_cfg |= 0x80000000;  
    int_cfg |= (1 << int_id);
    INTERRUPT->int_cfg = int_cfg;
}

void disable_gb(){
    uint32_t int_cfg = INTERRUPT->int_cfg;
    int_cfg &= ~(0x80000000);  
    INTERRUPT->int_cfg = int_cfg;
}

void disable_int( uint8_t int_id ){
    uint32_t int_cfg = INTERRUPT->status;
    int_cfg &= ~(1 << int_id);
    INTERRUPT->status = int_cfg;
}

void set_priority( uint8_t int_id, uint32_t priority){
    INTERRUPT->int_pri[int_id] = priority;
}