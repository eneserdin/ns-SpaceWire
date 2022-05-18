`timescale 1ns / 1ps


//module encoder_tb();

//reg clk = 0;
//reg rst = 0;



//encoder UUT(
//    .clk(clk),
//    .rst(rst)
//    );

//always begin
//    #5 clk <= 0;
//    #5 clk <= 1;
//end


//initial begin
//rst <= 1;
//#150 rst <= 0;
//end




`timescale 1ns / 1ps



module encoder_tb();
    
    reg din;
    reg sin;
    reg RxClk;
    reg RxClk_dly;
    
    reg [1:0] sampled_data;
    reg [1:0] real_sampled_data;
    
    
    RxClk UUT(
                .din(din),
                .sin(sin),
                .RxClk(RxClk)
              );
    
    encoder encoder_inst(
                .clk(clk),
                .rst(rst),
                .dot(din),
                .sot(sin) 
                );         

    Decoder decoder_inst(
                .RxClk(RxClk_dly),
                .rst(0),
                .din(din)
                );


reg clk = 0;
reg rst = 0;


always begin
    #5 clk <= 0;
    #5 clk <= 1;
end

initial begin
rst <= 1;
#150 rst <= 0;
end


    initial begin
        din <= 0;
        sin <= 0;
    end
    
    
    always_comb begin
        RxClk_dly <= #1 RxClk;
    end
    
    always @(posedge RxClk_dly) begin
        sampled_data[1] <= din;
        real_sampled_data <= sampled_data;
        
    end
    
    always @(negedge RxClk_dly) begin
        sampled_data[0] <= din;
    end    


endmodule
