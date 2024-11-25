module verilog2byte();
`define ITCM_NUM  16383

logic [7:0] instruction [`ITCM_NUM*4-1:0];
int fid0,fid1 , fid2 ,fid3;
initial begin 
    $readmemh("../mcs/uart_test.verilog",instruction);
    fid0 = $fopen("../mcs/mnist_v2_f0");
    fid1 = $fopen("../mcs/mnist_v2_f1");
    fid2 = $fopen("../mcs/mnist_v2_f2");
    fid3 = $fopen("../mcs/mnist_v2_f3");
    for( int i=0;i<`ITCM_NUM;i++) begin
        $fwrite(fid0,"%x\n",instruction[i*4 + 0]);
        $fwrite(fid1,"%x\n",instruction[i*4 + 1]);
        $fwrite(fid2,"%x\n",instruction[i*4 + 2]);
        $fwrite(fid3,"%x\n",instruction[i*4 + 3]);
    end
    $fclose(fid0);
    $fclose(fid1);
    $fclose(fid2);
    $fclose(fid3);
    $display("done~~~~~~~");
end 

endmodule 