/**************************************
@ filename    : tb_timer.sv
@ author      : yyrwkk
@ create time : 2024/11/11 14:47:12
@ version     : v1.0.0
**************************************/
`timescale 1ns/1ps

module tb_timer;

parameter N_REG  =  32    ;

logic                     i_clk           ;
logic                     i_rst           ;
logic [N_REG-1:0]         i_value         ;
logic [N_REG-1:0]         i_prescale      ;
logic                     i_clear         ;
logic                     i_enable        ;
logic                     o_interrupt     ;

timer # (
    .N_REG  (N_REG) 
)timer_inst(
    .i_clk           (i_clk        ),
    .i_rst           (i_rst        ),
    .i_value         (i_value      ),
    .i_prescale      (i_prescale   ),  
    .i_clear         (i_clear      ),
    .i_enable        (i_enable     ),
    .o_interrupt     (o_interrupt  )
);

initial begin 
    i_clk       = 'b0;
    i_rst       = 'b1;
    i_value     = 'b0;
    i_prescale  = 'b0;
    i_clear     = 'b0;
    i_enable    = 'b0;
end 

initial begin 
    forever #5 i_clk = ~i_clk;
end 

initial begin 
    @(posedge i_clk);
    i_rst = 'b0;
    @(posedge i_clk);

    i_enable    <= 'b1 ;
    i_value     <=  100;
    i_prescale  <=  2  ;
    i_clear     <=  'b1;
    @(posedge i_clk);
    i_clear     <=  'b0;
    @(posedge i_clk);

    repeat(200) @(posedge i_clk);
    i_clear     <=  'b1;
    @(posedge i_clk);
    i_clear     <=  'b0;
    @(posedge i_clk);

    repeat(1000) @(posedge i_clk);
    $stop;
end



endmodule