module tft_colorbar
(
//input wire sys_clk , //输入工作时钟,频率50MHz
input wire sys_rst_n , //输入复位信号,低电平有效

output SDA,       
output SCL,       
output CS,
output wire [15:0] rgb_tft , //输出像素信息
output wire hsync , //输出行同步信号
output wire vsync , //输出场同步信号
output wire tft_clk , //输出TFT时钟信号
output wire tft_de , //输出TFT使能信号
output wire tft_bl, //输出背光信号
output wire tft_rst_n,
output wire init_done
);



////
//\* Parameter and Internal Signal \//
////

//wire define
wire tft_clk_9m ; //TFT工作时钟,频率9MHz
wire [10:0] pix_x ; //TFT有效显示区域X轴坐标
wire [10:0] pix_y ; //TFT有效显示区域Y轴坐标
wire [15:0] pix_data ; //TFT像素点色彩信息
wire sys_clk;


////
//\* Instantiation \//
////
    Gowin_OSC Gowin_OSC_init(
        .oscout(sys_clk), //output oscout
        .oscen(1'b1) //input oscen
    );




//------------- SPI -------------
lcd_initiator lcd_initiator_init (
    .clk                (tft_clk_9m),      
    .rst_n              (sys_rst_n),      
    .SDA                (SDA),  
    .SCL                (SCL),   
    .CS                 (CS),
    .init_done_flag     (init_done)
);

//assign spi_rst_n = ~((~sys_rst_n)|(~tft_rst_n));


Gowin_PLL Gowin_PLL_init(
    .lock(), //output lock
    .clkout0(tft_clk_9m), //output clkout0
    .clkin(sys_clk), //input clkin
    .reset(~sys_rst_n) //input reset
);

//assign tft_rst_n = (sys_rst_n & locked);


//------------- tft_ctrl_inst -------------
tft_ctrl tft_ctrl_inst
(
.tft_clk_9m (tft_clk_9m), //输入时钟,频率9MHz
.sys_rst_n  (tft_rst_n ), //系统复位,低电平有效
.pix_data   (pix_data ), //待显示数据

.pix_x      (pix_x ), //输出TFT有效显示区域像素点X轴坐标
.pix_y      (pix_y ), //输出TFT有效显示区域像素点Y轴坐标
.rgb_tft    (rgb_tft ), //TFT显示数据
.hsync      (hsync ), //TFT行同步信号
.vsync      (vsync ), //TFT场同步信号
.tft_clk    (tft_clk ), //TFT像素时钟
.tft_de     (tft_de ), //TFT数据使能
.tft_bl     (tft_bl) //TFT背光信号
);

//------------- tft_pic_inst -------------

tft_pic tft_pic_inst
(
.tft_clk_9m (tft_clk_9m), //输入工作时钟,频率9MHz
.sys_rst_n  (tft_rst_n ), //输入复位信号,低电平有效
.pix_x      (pix_x ), //输入TFT有效显示区域像素点X轴坐标
.pix_y      (pix_y ), //输入TFT有效显示区域像素点Y轴坐标

.pix_data   (pix_data ) //输出像素点色彩信息

);


reg rst_n_reg;
always @(posedge tft_clk) begin
	rst_n_reg <= sys_rst_n;
end

assign tft_rst_n = ~(sys_rst_n & (~rst_n_reg)) & (~init_done);	

endmodule