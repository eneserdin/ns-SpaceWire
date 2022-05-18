`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2022 05:22:53 PM
// Design Name: 
// Module Name: RxClk_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RxClk_tb();
    
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
    
    dataGenerator gen_inst(
                .dout(din),
                .sout(sin) 
                );         

    Decoder decoder_inst(
                .RxClk(RxClk_dly),
                .rst(0),
                .din(din)
                );

    
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
    
    

