`timescale 1ns / 1ps

module lcd_initiator# (
    parameter DIV_FACTOR = 2, // Max:log2(32) = 5
    parameter INS_WIDTH         = 9,
    parameter INSADDRESS_WIDTH  = 8

)(
    input  clk,           // SPI时钟域
    input  rst_n,         // 复位信号，低有效
    output SDA,           // 数据线
    output SCL,           // 时钟线
    output CS,            // 片选线
    output init_done_flag      // 初始化完成信号，高有效
);


// 状态机状态定义
localparam IDLE       = 3'b000;
localparam START_TX   = 3'b001;
localparam SEND_BIT   = 3'b011;
localparam STOP_TX    = 3'b100;
localparam INIT_FINISH= 3'b101;

// Flag
reg init_done;
reg SDA_reg;
reg CS_reg;


assign SDA = SDA_reg;
assign CS = CS_reg ;

// 状态寄存器
reg [2:0] current_state;
reg [2:0] next_state;

// INS定义
reg [INS_WIDTH-1:0]        ins_ram  [0:(1<<INSADDRESS_WIDTH)-1];

// 地址和位计数器
reg [INSADDRESS_WIDTH-1:0]   ins_count;
reg [INS_WIDTH-1:0]          shift_reg;
reg [3:0]                    bit_cnt;  // 4位足以计数16位数据

// 为SCL分频
reg [31:0] clk_div_cnt = 31'd0;
reg scl_reg = 1'b0;

//always @(posedge clk or negedge rst_n) begin
//    if(!rst_n) begin
//        clk_div_cnt <= 32'd0;
//        scl_reg <= 1'b0;
//    end else if (clk_div_cnt == (32'd1<<DIV_FACTOR)-1'b1) begin
//        clk_div_cnt <= 32'd0;
//        scl_reg <= ~scl_reg;
//    end else begin
//        clk_div_cnt <= clk_div_cnt + 1'b1;
//    end
//end
//assign SCL = scl_reg;



always @(posedge clk or negedge rst_n) begin
    if(!rst_n || clk_div_cnt == DIV_FACTOR/2 - 1) begin
        clk_div_cnt <= 32'd0;
    end else begin
        clk_div_cnt <= clk_div_cnt + 1'b1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
            scl_reg <= 1'b0;
    end else if (ins_count == 226)
            scl_reg <= 1'b0;
        else if (clk_div_cnt  == DIV_FACTOR/2 - 1)begin
        scl_reg <= ~scl_reg;
    end else begin
        scl_reg <= scl_reg;
    end
    end
assign SCL = scl_reg;

// 初始化RAM内容（示例数据）
initial begin : ins_ram_init

    ins_ram[0] = 9'b011111111;
    ins_ram[1] = 9'b101110111;
    ins_ram[2] = 9'b100000001;
    ins_ram[3] = 9'b100000000;
    ins_ram[4] = 9'b100000000;
    ins_ram[5] = 9'b100010000;
    ins_ram[6] = 9'b011000000;
    ins_ram[7] = 9'b101100011;
    ins_ram[8] = 9'b100000000;
    ins_ram[9] = 9'b011000001;
    ins_ram[10] = 9'b100001010;
    ins_ram[11] = 9'b100000010;
    ins_ram[12] = 9'b011000010;
    ins_ram[13] = 9'b100110001;
    ins_ram[14] = 9'b100001000;
    ins_ram[15] = 9'b010110000;
    ins_ram[16] = 9'b100000000;
    ins_ram[17] = 9'b100010001;
    ins_ram[18] = 9'b100011001;
    ins_ram[19] = 9'b100001100;
    ins_ram[20] = 9'b100010000;
    ins_ram[21] = 9'b100000110;
    ins_ram[22] = 9'b100000111;
    ins_ram[23] = 9'b100001010;
    ins_ram[24] = 9'b100001001;
    ins_ram[25] = 9'b100100010;
    ins_ram[26] = 9'b100000100;
    ins_ram[27] = 9'b100010000;
    ins_ram[28] = 9'b100001110;
    ins_ram[29] = 9'b100101000;
    ins_ram[30] = 9'b100110000;
    ins_ram[31] = 9'b100011100;
    ins_ram[32] = 9'b010110001;
    ins_ram[33] = 9'b100000000;
    ins_ram[34] = 9'b100010010;
    ins_ram[35] = 9'b100011001;
    ins_ram[36] = 9'b100001101;
    ins_ram[37] = 9'b100010000;
    ins_ram[38] = 9'b100000100;
    ins_ram[39] = 9'b100000110;
    ins_ram[40] = 9'b100000111;
    ins_ram[41] = 9'b100001000;
    ins_ram[42] = 9'b100100011;
    ins_ram[43] = 9'b100000100;
    ins_ram[44] = 9'b100010010;
    ins_ram[45] = 9'b100010001;
    ins_ram[46] = 9'b100101000;
    ins_ram[47] = 9'b100110000;
    ins_ram[48] = 9'b100011100;
    ins_ram[49] = 9'b011111111;
    ins_ram[50] = 9'b101110111;
    ins_ram[51] = 9'b100000001;
    ins_ram[52] = 9'b100000000;
    ins_ram[53] = 9'b100000000;
    ins_ram[54] = 9'b100010001;
    ins_ram[55] = 9'b010110000;
    ins_ram[56] = 9'b101001101;
    ins_ram[57] = 9'b010110001;
    ins_ram[58] = 9'b100111110;
    ins_ram[59] = 9'b010110010;
    ins_ram[60] = 9'b100000111;
    ins_ram[61] = 9'b010110011;
    ins_ram[62] = 9'b110000000;
    ins_ram[63] = 9'b010110101;
    ins_ram[64] = 9'b101000111;
    ins_ram[65] = 9'b010110111;
    ins_ram[66] = 9'b110001010;
    ins_ram[67] = 9'b010111000;
    ins_ram[68] = 9'b100100001;
    ins_ram[69] = 9'b011000001;
    ins_ram[70] = 9'b101111000;
    ins_ram[71] = 9'b011000010;
    ins_ram[72] = 9'b101111000;
    ins_ram[73] = 9'b011010000;
    ins_ram[74] = 9'b110001000;
    ins_ram[75] = 9'b011100000;
    ins_ram[76] = 9'b100000000;
    ins_ram[77] = 9'b100000000;
    ins_ram[78] = 9'b100000010;
    ins_ram[79] = 9'b011100001;
    ins_ram[80] = 9'b100000100;
    ins_ram[81] = 9'b100000000;
    ins_ram[82] = 9'b100000000;
    ins_ram[83] = 9'b100000000;
    ins_ram[84] = 9'b100000101;
    ins_ram[85] = 9'b100000000;
    ins_ram[86] = 9'b100000000;
    ins_ram[87] = 9'b100000000;
    ins_ram[88] = 9'b100000000;
    ins_ram[89] = 9'b100100000;
    ins_ram[90] = 9'b100100000;
    ins_ram[91] = 9'b011100010;
    ins_ram[92] = 9'b100000000;
    ins_ram[93] = 9'b100000000;
    ins_ram[94] = 9'b100000000;
    ins_ram[95] = 9'b100000000;
    ins_ram[96] = 9'b100000000;
    ins_ram[97] = 9'b100000000;
    ins_ram[98] = 9'b100000000;
    ins_ram[99] = 9'b100000000;
    ins_ram[100] = 9'b100000000;
    ins_ram[101] = 9'b100000000;
    ins_ram[102] = 9'b100000000;
    ins_ram[103] = 9'b100000000;
    ins_ram[104] = 9'b100000000;
    ins_ram[105] = 9'b011100011;
    ins_ram[106] = 9'b100000000;
    ins_ram[107] = 9'b100000000;
    ins_ram[108] = 9'b100110011;
    ins_ram[109] = 9'b100000000;
    ins_ram[110] = 9'b011100100;
    ins_ram[111] = 9'b100100010;
    ins_ram[112] = 9'b100000000;
    ins_ram[113] = 9'b011100101;
    ins_ram[114] = 9'b100000100;
    ins_ram[115] = 9'b100110100;
    ins_ram[116] = 9'b110101010;
    ins_ram[117] = 9'b110101010;
    ins_ram[118] = 9'b100000110;
    ins_ram[119] = 9'b100110100;
    ins_ram[120] = 9'b110101010;
    ins_ram[121] = 9'b110101010;
    ins_ram[122] = 9'b100000000;
    ins_ram[123] = 9'b100000000;
    ins_ram[124] = 9'b100000000;
    ins_ram[125] = 9'b100000000;
    ins_ram[126] = 9'b100000000;
    ins_ram[127] = 9'b100000000;
    ins_ram[128] = 9'b100000000;
    ins_ram[129] = 9'b100000000;
    ins_ram[130] = 9'b011100110;
    ins_ram[131] = 9'b100000000;
    ins_ram[132] = 9'b100000000;
    ins_ram[133] = 9'b100110011;
    ins_ram[134] = 9'b100000000;
    ins_ram[135] = 9'b011100111;
    ins_ram[136] = 9'b100100010;
    ins_ram[137] = 9'b100000000;
    ins_ram[138] = 9'b011101000;
    ins_ram[139] = 9'b100000101;
    ins_ram[140] = 9'b100110100;
    ins_ram[141] = 9'b110101010;
    ins_ram[142] = 9'b110101010;
    ins_ram[143] = 9'b100000111;
    ins_ram[144] = 9'b100110100;
    ins_ram[145] = 9'b110101010;
    ins_ram[146] = 9'b110101010;
    ins_ram[147] = 9'b100000000;
    ins_ram[148] = 9'b100000000;
    ins_ram[149] = 9'b100000000;
    ins_ram[150] = 9'b100000000;
    ins_ram[151] = 9'b100000000;
    ins_ram[152] = 9'b100000000;
    ins_ram[153] = 9'b100000000;
    ins_ram[154] = 9'b100000000;
    ins_ram[155] = 9'b011101011;
    ins_ram[156] = 9'b100000010;
    ins_ram[157] = 9'b100000000;
    ins_ram[158] = 9'b101000000;
    ins_ram[159] = 9'b101000000;
    ins_ram[160] = 9'b100000000;
    ins_ram[161] = 9'b100000000;
    ins_ram[162] = 9'b100000000;
    ins_ram[163] = 9'b011101101;
    ins_ram[164] = 9'b111111010;
    ins_ram[165] = 9'b101000101;
    ins_ram[166] = 9'b100001011;
    ins_ram[167] = 9'b111111111;
    ins_ram[168] = 9'b111111111;
    ins_ram[169] = 9'b111111111;
    ins_ram[170] = 9'b111111111;
    ins_ram[171] = 9'b111111111;
    ins_ram[172] = 9'b111111111;
    ins_ram[173] = 9'b111111111;
    ins_ram[174] = 9'b111111111;
    ins_ram[175] = 9'b111111111;
    ins_ram[176] = 9'b111111111;
    ins_ram[177] = 9'b110110000;
    ins_ram[178] = 9'b101010100;
    ins_ram[179] = 9'b110101111;
    ins_ram[180] = 9'b011111111;
    ins_ram[181] = 9'b101110111;
    ins_ram[182] = 9'b100000001;
    ins_ram[183] = 9'b100000000;
    ins_ram[184] = 9'b100000000;
    ins_ram[185] = 9'b100010000;
    ins_ram[186] = 9'b010110000;
    ins_ram[187] = 9'b100000000;
    ins_ram[188] = 9'b100100011;
    ins_ram[189] = 9'b100101010;
    ins_ram[190] = 9'b100001010;
    ins_ram[191] = 9'b100001110;
    ins_ram[192] = 9'b100000011;
    ins_ram[193] = 9'b100010010;
    ins_ram[194] = 9'b100000110;
    ins_ram[195] = 9'b100000110;
    ins_ram[196] = 9'b100101010;
    ins_ram[197] = 9'b100000000;
    ins_ram[198] = 9'b100010000;
    ins_ram[199] = 9'b100001111;
    ins_ram[200] = 9'b100101101;
    ins_ram[201] = 9'b100110100;
    ins_ram[202] = 9'b100011111;
    ins_ram[203] = 9'b010110001;
    ins_ram[204] = 9'b100000000;
    ins_ram[205] = 9'b100100100;
    ins_ram[206] = 9'b100101011;
    ins_ram[207] = 9'b100001111;
    ins_ram[208] = 9'b100010010;
    ins_ram[209] = 9'b100000111;
    ins_ram[210] = 9'b100010101;
    ins_ram[211] = 9'b100001010;
    ins_ram[212] = 9'b100001010;
    ins_ram[213] = 9'b100101011;
    ins_ram[214] = 9'b100001000;
    ins_ram[215] = 9'b100010011;
    ins_ram[216] = 9'b100010000;
    ins_ram[217] = 9'b100101101;
    ins_ram[218] = 9'b100110011;
    ins_ram[219] = 9'b100011111;
    ins_ram[220] = 9'b000010001;
    ins_ram[221] = 9'b000111010;
    ins_ram[222] = 9'b101010101;
    ins_ram[223] = 9'b000110110;
    ins_ram[224] = 9'b100000000;
    ins_ram[225] = 9'b000101001;

end

// 状态寄存器更新
always @(negedge SCL or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

// 状态转移逻辑
always @(*) begin
    if (!rst_n) begin
        next_state = IDLE;
    end else begin
        case (current_state)
            IDLE: begin
                next_state = START_TX;
            end
            START_TX: begin 
                if (ins_count == 226)
                next_state = INIT_FINISH;
                else
                next_state = SEND_BIT;
            end  
            SEND_BIT: begin
                if (bit_cnt == INS_WIDTH - 1)
                    next_state = STOP_TX;
                else
                    next_state = SEND_BIT;
            end
            STOP_TX: begin
                next_state = IDLE;
            end
            INIT_FINISH: begin
                next_state = INIT_FINISH;
            end
            default: next_state = IDLE;
        endcase
    end
end


// 控制信号和数据传输
always @(negedge SCL or negedge rst_n) begin
    if (!rst_n) begin
        CS_reg      <= 1'b1;          // 复位时CS置高
        SDA_reg     <= 1'b0;          // SDA初始化
        init_done   <= 1'b0;
        shift_reg   <= 16'd0;
        ins_count   <= 4'd0;
        bit_cnt     <= 4'd0;
    end else begin
        case (current_state)
            IDLE: begin
                CS_reg      <= 1'b1;          // 空闲时CS拉高
                SDA_reg     <= 1'bZ;         // 高阻状态，避免总线冲突
                bit_cnt     <= 4'd0;
                init_done   <= init_done;
                end
            START_TX: begin
                CS_reg          <= 1'b1;                    
                shift_reg   <= ins_ram[ins_count];      // 从ins_ram读取数据到移位寄存器
                bit_cnt     <= 4'd0;                    // 位计数器清零
                init_done   <= init_done;
            end
            SEND_BIT: begin
                if (~SCL) begin
                    // 在SCL的下降沿设置SDA的数据
                    CS_reg          <= 1'b0;
                    SDA_reg         <= shift_reg[INS_WIDTH-1];
                    shift_reg   <= shift_reg << 1'b1; // 左移1位
                    bit_cnt     <= bit_cnt + 1'b1;
                end else begin
                    // 在SCL的上升沿，保持SDA稳定
                    SDA_reg <= SDA_reg;
                end
            end
            STOP_TX: begin
                CS_reg        <= 1'b1;          // 传输结束，CS拉高
                SDA_reg       <= 1'bZ;          // 设置为高阻状态
                ins_count <= ins_count + 1'b1;
                bit_cnt     <= 4'd0;
            end
            INIT_FINISH: begin
                CS_reg        <= 1'b1;          // 传输结束，CS拉高
                SDA_reg       <= 1'bZ;          // 设置为高阻状态
                ins_count     <= 226;
                shift_reg     <= 16'd0;
                bit_cnt       <= 4'd0;
                init_done     <= 1'b1;
            end
            default: begin
                CS_reg          <= 1'b1;
                SDA_reg         <= 1'bZ;
                shift_reg   <= 16'd0;
                ins_count   <= 8'd0;
                bit_cnt     <= 4'd0;
                init_done     <= 1'b0;           
            end
        endcase
    end
end

reg init_done_reg;

always @(negedge SCL) begin
    init_done_reg <= init_done;
end

assign init_done_flag = (~init_done_reg) & init_done;

endmodule
