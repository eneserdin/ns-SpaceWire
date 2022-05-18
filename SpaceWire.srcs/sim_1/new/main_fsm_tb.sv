`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/02/2022 01:59:57 PM
// Design Name: 
// Module Name: main_fsm_tb
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


module main_fsm_tb( );



reg clk =0;
reg rst =1;
reg enabled =0;
reg LinkStart = 1;
reg Autostart = 0;

reg fct_req = 0;
reg data_req = 0;
reg tc_req = 0;

reg fct_ack;
reg data_ack;
reg tc_ack;

reg din = 0;
reg sin = 0;

reg dot =0;
reg sot =0;


main_fsm 
    #(.freq(10000))
    uut(
    .clk(clk),
    .rst(rst),
    .enabled(enabled),
    .LinkStart(LinkStart),
    .AutoStart(Autostart),


    .fct_req(fct_req),
    .data_req(data_req),
    .tc_req(tc_req),
    
    .fct_ack(fct_ack),
    .data_ack(data_ack),
    .tc_ack(tc_ack),
    
    .din(din),
    .sin(sin),
    .dot(dot),
    .sot(sot)
    );




always
begin
    #5 clk <=0;
    #5 clk <=1;
end    


always 
begin
    #0.1 din <= dot; sin <= sot;
end

initial
begin
    rst <= 1;
    enabled <= 0;
    #100 rst <= 0; enabled <= 1;
end


initial
begin 

#29us
@(posedge clk);
fct_req <= 1;
@(posedge fct_ack)
fct_req <= 0;
end

initial
begin 

#50us
@(posedge clk);
data_req <= 1;
@(posedge data_ack)
data_req <= 0;
end



endmodule



