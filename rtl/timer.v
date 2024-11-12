/**************************************
@ filename    : timer.v
@ author      : yyrwkk
@ create time : 2024/11/11 14:24:34
@ version     : v1.0.0
**************************************/
module timer # (
    parameter N_REG  =  32    
)(
    input                      i_clk           ,
    input                      i_rst           ,
    
    input  [N_REG-1:0]         i_value         ,
    input  [N_REG-1:0]         i_prescale      ,
        
    input                      i_clear         ,
    input                      i_enable        ,
    
    output                     o_interrupt
);

wire              tick    ;

reg  [N_REG-1:0]  pre_cnt ;
reg  [N_REG-1:0]  counter ;

always @( posedge i_clk or posedge i_rst ) begin 
    if( i_rst ) begin 
        pre_cnt  <= 'b0;
    end else begin 
        if( i_clear ) begin 
            pre_cnt <= 'b0;
        end else if( i_enable ) begin 
            if( pre_cnt == i_prescale - 1'b1 ) begin 
                pre_cnt <= 'b0;
            end else begin 
                pre_cnt <= pre_cnt + 1'b1;
            end
        end else begin 
            pre_cnt <= pre_cnt;
        end
    end
end

assign tick = (pre_cnt == i_prescale - 1'b1) ? 1'b1 : 1'b0;

always @( posedge i_clk or posedge i_rst ) begin 
    if( i_rst ) begin 
        counter <= 'b0;
    end else begin 
        if( i_clear ) begin 
            counter <= 'b0; 
        end else if( tick == 1'b1 ) begin 
            counter <= counter + 1'b1;
        end else begin 
            counter <= counter;
        end
    end
end 

assign o_interrupt = (counter >= i_value - 1'b1) ? 1'b1 : 1'b0; 

endmodule