/**************************************
@ filename    : ddr_ctrl.v
@ author      : yyrwkk
@ create time : 2024/11/27 21:12:20
@ version     : v1.0.0
**************************************/
module ddr_ctrl(
    /**********  self define port ***********/
    input                  i_clk         ,
    input                  i_rst_n       ,
            
    input      [31:0]      ddr_addr      ,
    input                  ddr_en        ,
    input                  ddr_wr        ,
    input      [31:0]      ddr_wdata     ,
    input      [3:0]       ddr_mask      ,
        
    output reg [31:0]      ddr_rdata     ,
    output reg             ddr_rd_vld    ,
        
    output reg             ddr_rdy       ,

    /********** mig app port **************/
    input                  app_cmd_rdy   ,
    output reg [2:0]       app_cmd       ,
    output reg [27:0]      app_addr      ,
    output reg             app_cmd_en    ,
    
    input                  app_wdf_rdy   ,
    output reg [127:0]     app_data      ,
    output reg             app_data_wren ,
    output reg             app_data_end  ,
    output reg [15:0]      app_data_mask ,
    
    input      [127:0]     app_rd_data   ,
    input                  app_rd_vld    ,
    input                  app_rd_end    
);

reg [31:0]  ddr_addr_reg ;
reg         ddr_wr_reg   ;
reg [127:0] ddr_wdata_reg;
reg [15:0]  ddr_mask_reg ;

always @(posedge i_clk or negedge i_rst_n ) begin 
    if( !i_rst_n ) begin 
        ddr_addr_reg  <= 'b0;
        ddr_wr_reg    <= 'b0;
        ddr_wdata_reg <= 'b0;
        ddr_mask_reg  <= 'b0;
    end else begin 
        if( ddr_rdy & ddr_en ) begin 
            ddr_addr_reg  <= ddr_addr; 
            ddr_wr_reg    <= ddr_wr   ;
            ddr_wdata_reg <= (ddr_addr[3:2] == 'd0) ? {96'b0,ddr_wdata      } :
                             (ddr_addr[3:2] == 'd1) ? {64'b0,ddr_wdata,32'b0} :
                             (ddr_addr[3:2] == 'd2) ? {32'b0,ddr_wdata,64'b0} :
                             {ddr_wdata,96'b0} ;
            ddr_mask_reg  <= (ddr_addr[3:2] == 'd0) ? {{12{1'b1}},~ddr_mask    } :   // ddr_mask is 0 valid , 1 invalid
                             (ddr_addr[3:2] == 'd1) ? {{8{1'b1}},~ddr_mask,4'hf} :
                             (ddr_addr[3:2] == 'd2) ? {4'hf,~ddr_mask,{8{1'b1}}} :
                             {~ddr_mask,{12{1'b1}}} ; 
        end else begin 
            ddr_addr_reg  <= ddr_addr_reg ;
            ddr_wr_reg    <= ddr_wr_reg   ;
            ddr_wdata_reg <= ddr_wdata_reg;
            ddr_mask_reg  <= ddr_mask_reg ;
        end
    end
end

localparam s_idle  = 2'd0 ;
localparam s_write = 2'd1 ;
localparam s_read  = 2'd2 ;
localparam s_wait  = 2'd3 ;

reg [1:0] curr_state ;
reg [1:0] next_state ;


always @(posedge i_clk or negedge i_rst_n ) begin 
    if( !i_rst_n ) begin 
        ddr_rdy <= 1'b1;
    end else begin 
        if( curr_state == s_idle ) begin 
            ddr_rdy <= 1'b1;
        end else if( ddr_rdy & ddr_en ) begin 
            ddr_rdy <= 1'b0;
        end else begin 
            ddr_rdy <= ddr_rdy;
        end
    end 
end

reg cmd_en_rdy ;
reg wdf_wen_rdy;
always @( posedge i_clk or negedge i_rst_n ) begin 
    if( !i_rst_n ) begin 
        cmd_en_rdy <= 1'b0;
    end else begin
        if( !ddr_rdy &  app_cmd_en & app_cmd_rdy) begin 
            cmd_en_rdy <= 1'b1;
        end else if( !ddr_rdy ) begin 
            cmd_en_rdy <= cmd_en_rdy;
        end else begin 
            cmd_en_rdy <= 1'b0;
        end
    end
end

always @( posedge i_clk or negedge i_rst_n ) begin 
    if( !i_rst_n ) begin 
        wdf_wen_rdy <= 1'b0;
    end else begin 
        if( (next_state == s_write) & app_data_wren & app_wdf_rdy ) begin 
            wdf_wen_rdy <= 1'b1;
        end else if( next_state == s_write) begin 
            wdf_wen_rdy <= wdf_wen_rdy;
        end else begin 
            wdf_wen_rdy <= 1'b0;
        end
    end 
end

always @( posedge i_clk or negedge i_rst_n ) begin 
    if( !i_rst_n ) begin 
        curr_state <= s_idle;
    end else begin 
        curr_state <= next_state;
    end
end

always @( * ) begin 
    case( curr_state )
    s_idle : begin 
        if( ddr_rdy & ddr_en & ddr_wr ) begin 
            next_state = s_write;
        end else if( ddr_rdy & ddr_en & !ddr_wr)begin 
            next_state = s_read;
        end else begin 
            next_state = s_idle;
        end
    end
    s_write: begin 
        if( wdf_wen_rdy & cmd_en_rdy ) begin 
            next_state = s_idle;
        end else begin 
            next_state = s_write;
        end
    end
    s_read : begin 
        if( cmd_en_rdy ) begin 
            next_state = s_wait;
        end else begin 
            next_state = s_read;
        end
    end
    s_wait : begin 
        if( app_rd_vld & app_rd_end ) begin 
            next_state = s_idle;
        end else begin 
            next_state = s_wait;
        end
    end
    default: begin 
        next_state = s_idle;
    end
    endcase
end

always @( posedge i_clk or negedge i_rst_n ) begin 
    if( !i_rst_n ) begin 
        app_cmd        <= 'b0;
        app_addr       <= 'b0;
        app_cmd_en     <= 'b0;
        app_data       <= 'b0;
        app_data_wren  <= 'b0;
        app_data_end   <= 'b0;
        app_data_mask  <= 'b0;
    end else begin  
        app_cmd        <= 'b0;
        app_addr       <= 'b0;
        app_cmd_en     <= 'b0;
        app_data       <= 'b0;
        app_data_wren  <= 'b0;
        app_data_end   <= 'b0;
        app_data_mask  <= 'b0;
        case( curr_state )
        s_idle : begin 
    
        end
        s_write: begin 
            if(  !( (app_cmd_en & app_cmd_rdy) | (cmd_en_rdy))) begin 
                app_cmd    <= 3'b000;   
                app_addr   <= {ddr_addr_reg[27:4],4'b0};
                app_cmd_en <= 1'b1;
            end else begin 
                app_cmd    <= 'b0;
                app_addr   <= 'b0;
                app_cmd_en <= 'b0;
            end

            if( !((wdf_wen_rdy) | ( app_data_wren & app_wdf_rdy ) ) ) begin 
                app_data      <= ddr_wdata;
                app_data_wren <= 1'b1;
                app_data_end  <= 1'b1;
                app_data_mask <= ddr_mask;
            end else begin 
                app_data      <= 'b0;
                app_data_wren <= 'b0;
                app_data_end  <= 'b0;
                app_data_mask <= 'b0;
            end
        end
        s_read : begin 
            if( !((app_cmd_en & app_cmd_rdy) | (cmd_en_rdy)) ) begin 
                app_cmd    <= 3'b001;   
                app_addr   <= {ddr_addr_reg[27:4],4'b0};
                app_cmd_en <= 1'b1;
            end else begin 
                app_cmd    <= 'b0;
                app_addr   <= 'b0;
                app_cmd_en <= 'b0;
            end
        end
        s_wait : begin 
            
        end
        default: begin 

        end
        endcase
    end
end

always @( posedge i_clk or negedge i_rst_n ) begin 
    if( !i_rst_n ) begin 
        ddr_rdata   <= 'b0;  
        ddr_rd_vld  <= 'b0;       
    end else begin 
        if( app_rd_vld & app_rd_end ) begin 
            ddr_rdata   <= (ddr_addr_reg[3:2] == 'd0) ? app_rd_data[31:0]  :
                           (ddr_addr_reg[3:2] == 'd1) ? app_rd_data[63:32] :
                           (ddr_addr_reg[3:2] == 'd2) ? app_rd_data[95:64] :
                           app_rd_data[127:96] ;
            ddr_rd_vld  <= 1'b1;
        end else begin 
            ddr_rdata   <= 'b0;  
            ddr_rd_vld  <= 'b0;  
        end
    end
end 

endmodule  