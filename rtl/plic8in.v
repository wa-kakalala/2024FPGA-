/**************************************
@ filename    : plic8in.v
@ author      : yyrwkk
@ create time : 2024/10/28 20:09:00
@ version     : v1.0.0
**************************************/
module plic8in (
    input               i_clk           ,
    input               i_rst_n         ,

    input        [7:0]  i_interrupt     ,
    
    input        [31:0] i_int_cfg       ,

    input        [31:0] i_int_pri_0     ,
    input        [31:0] i_int_pri_1     ,
    input        [31:0] i_int_pri_2     ,
    input        [31:0] i_int_pri_3     ,
    input        [31:0] i_int_pri_4     ,
    input        [31:0] i_int_pri_5     ,
    input        [31:0] i_int_pri_6     ,
    input        [31:0] i_int_pri_7     ,

    output reg   [31:0] o_int  
);

reg  [31:0] pri_res_0 [3:0];
reg  [2:0]  pri_id_0  [3:0];

reg  [31:0] pri_res_1 [1:0];      
reg  [2:0]  pri_id_1  [1:0];
    
reg  [2:0]  pri_id_2  ;

wire [31:0] pri_list [7:0];

wire [7:0] int_pending ;

assign int_pending = i_int_cfg[7:0] & i_interrupt;

assign pri_list[0] = i_int_pri_0 & ( {32{int_pending[0]}});
assign pri_list[1] = i_int_pri_1 & ( {32{int_pending[1]}});
assign pri_list[2] = i_int_pri_2 & ( {32{int_pending[2]}});
assign pri_list[3] = i_int_pri_3 & ( {32{int_pending[3]}});
assign pri_list[4] = i_int_pri_4 & ( {32{int_pending[4]}});
assign pri_list[5] = i_int_pri_5 & ( {32{int_pending[5]}});
assign pri_list[6] = i_int_pri_6 & ( {32{int_pending[6]}});
assign pri_list[7] = i_int_pri_7 & ( {32{int_pending[7]}});

genvar i;
generate
    for(i=0;i<4;i = i+1) begin : stage_0
        always @(*)  begin 
            if( pri_list[2*i] >= pri_list[2*i +1] ) begin 
                pri_id_0[i]  = 2*i;
                pri_res_0[i] = pri_list[2*i];
            end else begin 
                pri_id_0[i]  = 2*i+1;
                pri_res_0[i] = pri_list[2*i+1];
            end
        end
    end
endgenerate

genvar j;
generate
    for(j=0;j<2;j = j+1) begin  : stage_1
        always @(*)  begin 
            if( pri_res_0[2*j] >= pri_res_0[2*j+1] ) begin 
                pri_id_1[j]  = pri_id_0[2*j];
                pri_res_1[j] = pri_res_0[2*j];
            end else begin 
                pri_id_1[j]  = pri_id_0[2*j+1];
                pri_res_1[j] = pri_res_0[2*j+1];
            end
        end
    end
endgenerate

always @(*) begin : stage_2
    if(pri_res_1[0] >= pri_res_1[1] ) begin 
        pri_id_2 = pri_id_1[0];
    end else begin 
        pri_id_2 = pri_id_1[1];
    end
end

always @(posedge i_clk or negedge i_rst_n ) begin 
    if( !i_rst_n ) begin 
        o_int <= 'b0;
    end else begin 
        if( (|int_pending) & i_int_cfg[31] ) begin 
            o_int <= {5'b0,pri_id_2,8'b0,int_pending,7'b0,1'b1};
        end else begin 
            o_int <= 'b0;
        end
    end
end

endmodule