#ifndef _COMMON_H
#define _COMMON_H

static inline void disable_global_interrupts() {
    asm volatile ("csrci mstatus, 0x8" ::: "memory");
}


static inline void enable_global_interrupts() {
    asm volatile ("csrsi mstatus, 0x8" ::: "memory");
}

#endif  