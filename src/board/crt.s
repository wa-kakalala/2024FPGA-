.section .init
.globl _start
.global crtStart
.global main
.global irqCallback

crtStart:
  j _start
  nop
  nop
  nop
  nop
  nop
  nop
  nop

.global  trap_entry

trap_entry:
  sw x1,  - 1*4(sp)
  sw x5,  - 2*4(sp)
  sw x6,  - 3*4(sp)
  sw x7,  - 4*4(sp)
  sw x10, - 5*4(sp)
  sw x11, - 6*4(sp)
  sw x12, - 7*4(sp)
  sw x13, - 8*4(sp)
  sw x14, - 9*4(sp)
  sw x15, -10*4(sp)
  sw x16, -11*4(sp)
  sw x17, -12*4(sp)
  sw x28, -13*4(sp)
  sw x29, -14*4(sp)
  sw x30, -15*4(sp)
  sw x31, -16*4(sp)
  addi sp,sp,-16*4
  call irqCallback
  lw x1 , 15*4(sp)
  lw x5,  14*4(sp)
  lw x6,  13*4(sp)
  lw x7,  12*4(sp)
  lw x10, 11*4(sp)
  lw x11, 10*4(sp)
  lw x12,  9*4(sp)
  lw x13,  8*4(sp)
  lw x14,  7*4(sp)
  lw x15,  6*4(sp)
  lw x16,  5*4(sp)
  lw x17,  4*4(sp)
  lw x28,  3*4(sp)
  lw x29,  2*4(sp)
  lw x30,  1*4(sp)
  lw x31,  0*4(sp)
  addi sp,sp,16*4
  mret
  .text
/**
 * Reset Handler called on controller reset
 */
_start:
    /* ===== Startup Stage 1 ===== */

    /* Initialize GP and Stack Pointer SP */
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop
    la sp, _sp

    /*
     * Set Trap Entry MTVEC to trap_entry
     */

    /* Direct Mode: All exceptions set pc to BASE. */

    /* ===== Startup Stage 2 ===== */

#ifdef __riscv_flen
    /* Enable FPU */  

#endif

    /* ===== Startup Stage 3 ===== */
    /*
     * Load code section frm FLASH to ILM
     * when code LMA is different with VMA
     */
    la a0, _ilm_lma
    la a1, _ilm
    /* If the ILM phy-address same as the logic-address, then quit */
    beq a0, a1, 2f
    la a2, _eilm
    bgeu a1, a2, 2f

1:
    /* Load code section if necessary */
    lw t0, (a0)
    sw t0, (a1)
    addi a0, a0, 4
    addi a1, a1, 4
    bltu a1, a2, 1b
2:
    /* Load data section */
    la a0, _data_lma
    la a1, _data
    la a2, _edata
    bgeu a1, a2, 2f
1:
    lw t0, (a0)
    sw t0, (a1)
    addi a0, a0, 4
    addi a1, a1, 4
    bltu a1, a2, 1b
2:
    /* Clear bss section */
    la a0, __bss_start
    la a1, _end
    bgeu a0, a1, 2f
1:
    sw zero, (a0)
    addi a0, a0, 4
    bltu a0, a1, 1b
2:

    /*
     * Call vendor defined SystemInit to
     * initialize the micro-controller system
     */

    /* Call global constructors */
    la a0, __libc_fini_array
    call atexit
    /* Call C/C++ constructor start up code */
    call __libc_init_array

    /* do pre-init steps before main */
    /* ===== Call Main Function  ===== */
    /* argc = argv = 0 */
    li a0, 0
    li a1, 0

#ifdef RTOS_RTTHREAD
    /* Call entry function when using RT-Thread*/
#else

    li a0, 0x880      /*880 enable timer + external interrupts*/
    csrw mie,a0
    li a0, 0x1808     /*1808 enable interrupts*/
    csrw mstatus,a0
    call main
#endif
    /* do post-main steps after main */

1:
    j 1b

