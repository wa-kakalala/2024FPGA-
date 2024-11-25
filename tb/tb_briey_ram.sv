/**************************************
@ filename    : tb_briey_ram.sv
@ author      : yyrwkk
@ create time : 2024/10/06 21:34:13
@ version     : v1.0.0
**************************************/
`timescale 1ns/1ns
module tb_briey_ram();

logic          io_asyncReset            ;
logic          io_axiClk                ;
logic          io_vgaClk                ;
logic          io_jtag_tms              ;
logic          io_jtag_tdi              ;
logic          io_jtag_tdo              ;
logic          io_jtag_tck              ;
logic [31:0]   io_gpioA_read            ;
logic [31:0]   io_gpioA_write           ;
logic [31:0]   io_gpioA_writeEnable     ;
logic [31:0]   io_gpioB_read            ;
logic [31:0]   io_gpioB_write           ;
logic [31:0]   io_gpioB_writeEnable     ;
logic          io_uart_txd              ;
logic          io_uart_rxd              ;
logic          io_vga_vSync             ;
logic          io_vga_hSync             ;
logic          io_vga_colorEn           ;
logic [4:0]    io_vga_color_r           ;
logic [5:0]    io_vga_color_g           ;
logic [4:0]    io_vga_color_b           ;
logic          io_timerExternal_clear   ;
logic          io_timerExternal_tick    ;
// logic          io_coreInterrupt         ;   
// logic [7:0]    io_ext_interrupt         ; 

logic [7:0]  tx_din    ;
logic        tx_wr_en  ;
logic        tx_busy   ;

uart_tx_v2 uart_tx_v2_inst(
    .clk    (io_axiClk  ),
    .din    (tx_din     ),
    .wr_en  (tx_wr_en   ),
    .tx_busy(tx_busy    ),
    .tx_p   (io_uart_rxd)     
);

briey_ram briey_ram_inst (
    .io_asyncReset         (io_asyncReset         ),
    .io_axiClk             (io_axiClk             ),
    .io_vgaClk             (io_vgaClk             ),
    .io_jtag_tms           (io_jtag_tms           ),
    .io_jtag_tdi           (io_jtag_tdi           ),
    .io_jtag_tdo           (io_jtag_tdo           ),
    .io_jtag_tck           (io_jtag_tck           ),
    .io_gpio_read          (io_gpioA_read         ),
    .io_gpio_write         (io_gpioA_write        ),
    .io_gpio_writeEnable   (io_gpioA_writeEnable  ),
    .io_uart_txd           (io_uart_txd           ),
    .io_uart_rxd           (io_uart_rxd           )
    // .io_coreInterrupt      (io_coreInterrupt      ),
    // .io_ext_interrupt      (io_ext_interrupt      )
);

`define ITCM      briey_ram_inst.axi_ram
`define ITCM_NUM  16383
`define UART_TX   briey_ram_inst.axi_uartCtrl.uartCtrl_1.tx
initial begin 
    forever begin 
        @(posedge io_axiClk);
        if( `UART_TX.io_write_ready && `UART_TX.io_write_valid ) begin 
            $fwrite(32'h80000002, "%c", `UART_TX.io_write_payload);
        end
    end
end

logic [7:0] instruction [`ITCM_NUM*4-1:0];
int fid0,fid1 , fid2 ,fid3;
initial begin
    $readmemh("../mcs/uart_test.verilog",instruction);
    // fid0 = $fopen("../mcs/mnist_v2_f0");
    // fid1 = $fopen("../mcs/mnist_v2_f1");
    // fid2 = $fopen("../mcs/mnist_v2_f2");
    // fid3 = $fopen("../mcs/mnist_v2_f3");
    for( int i=0;i<`ITCM_NUM;i++) begin
        
        `ITCM.ram_symbol0[i] = instruction[i*4 + 0];
        `ITCM.ram_symbol1[i] = instruction[i*4 + 1];
        `ITCM.ram_symbol2[i] = instruction[i*4 + 2];
        `ITCM.ram_symbol3[i] = instruction[i*4 + 3];

        // $fwrite(fid0,"%x\n",instruction[i*4 + 0]);
        // $fwrite(fid1,"%x\n",instruction[i*4 + 1]);
        // $fwrite(fid2,"%x\n",instruction[i*4 + 2]);
        // $fwrite(fid3,"%x\n",instruction[i*4 + 3]);


    end
    // $fclose(fid0);
    // $fclose(fid1);
    // $fclose(fid2);
    // $fclose(fid3);
end

initial begin
    io_asyncReset           = 'b1; // high active
    io_axiClk               = 'b0;
    io_vgaClk               = 'b0;
    io_jtag_tms             = 'b0;
    io_jtag_tdi             = 'b0;
    io_jtag_tck             = 'b0;
    io_gpioA_read           = 'b0;         
    io_gpioB_read           = 'b0;
    // io_uart_rxd             = 'b1; // 串口有损坏检测
    io_timerExternal_clear  = 'b0;
    io_timerExternal_tick   = 'b0;
    // io_coreInterrupt        = 'b0; 
    // io_ext_interrupt        = 8'h0;  

    tx_din                  = 'b0;
    tx_wr_en                = 'b0;
end

// assign io_uart_rxd = io_uart_txd;

initial begin
    forever #10 io_axiClk = ~io_axiClk;
end

byte data [$];

initial begin 
    data = '{
        8'd65,
        8'd66,
        8'd67,
        8'd68,
        8'd69,
        8'd70
    };
end

initial begin
    @(posedge io_axiClk);
    io_asyncReset <= 1'b0; 
    @(posedge io_axiClk);
    // repeat( 100_000 ) @(posedge io_axiClk);
    // $display( " running ..." );
    // for( int i=0;i<data.size(); ) begin 
    //     @(posedge io_axiClk);
    //     if(tx_busy == 'b0 ) begin 
    //         tx_din <= data[i];
    //         tx_wr_en <= 1'b1;
    //         i++;
    //     end
    //      @(posedge io_axiClk); 
    //         tx_din   <= 'b0;
    //         tx_wr_en <= 1'b0;
    // end
    for( int i=0;i<1000;i++) begin 
        repeat(100_000_000) @(posedge io_axiClk);
    end
    $stop;
end

endmodule

