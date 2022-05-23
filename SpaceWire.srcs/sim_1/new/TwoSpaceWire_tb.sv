`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2022 04:40:59 AM
// Design Name: 
// Module Name: TwoSpaceWire_tb
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


module TwoSpaceWire_tb();


reg SPW1clk =0;
reg SPW1rst =1;
reg SPW1enabled =0;
reg SPW1LinkStart = 1;
reg SPW1Autostart = 0;

reg SPW1fct_req = 0;
reg SPW1data_req = 0;
reg SPW1tc_req = 0;

reg SPW1fct_ack;
reg SPW1data_ack;
reg SPW1tc_ack;

reg SPW1din = 0;
reg SPW1sin = 0;

reg SPW1dot =0;
reg SPW1sot =0;


reg[7:0] SPW1datain;
reg[7:0] SPW1TCin;

reg[17:0] SPW1dataout;
reg SPW1datavalid;
reg SPW1dissable = 0;




main_fsm 
    #(.freq(100000))
    SPW1(
    .clk(SPW1clk),
    .rst(SPW1rst),
    .enabled(SPW1enabled),
    .LinkStart(SPW1LinkStart),
    .AutoStart(SPW1Autostart),
    
    .datain(SPW1datain),
    .TCin(SPW1TCin),

    .fct_req(SPW1fct_req),
    .data_req(SPW1data_req),
    .tc_req(SPW1tc_req),
    
    .fct_ack(SPW1fct_ack),
    .data_ack(SPW1data_ack),
    .tc_ack(SPW1tc_ack),
    
    .din(SPW1din),
    .sin(SPW1sin),
    .dot(SPW1dot),
    .sot(SPW1sot),
    
    .dataout(SPW1dataout),
    .datavalid(SPW1datavalid)
    );


reg SPW2clk =0;
reg SPW2rst =1;
reg SPW2enabled =0;
reg SPW2LinkStart = 0;
reg SPW2Autostart = 1;

reg SPW2fct_req = 0;
reg SPW2data_req = 0;
reg SPW2tc_req = 0;

reg SPW2fct_ack;
reg SPW2data_ack;
reg SPW2tc_ack;

reg SPW2din = 0;
reg SPW2sin = 0;

reg SPW2dot =0;
reg SPW2sot =0;


reg[7:0] SPW2datain;
reg[7:0] SPW2TCin;

reg[17:0] SPW2dataout;
reg SPW2datavalid;
reg SPW2dissable = 0;



main_fsm 
    #(.freq(50000))
    SPW2(
    .clk(SPW2clk),
    .rst(SPW2rst),
    .enabled(SPW2enabled),
    .LinkStart(SPW2LinkStart),
    .AutoStart(SPW2Autostart),
    
    .datain(SPW2datain),
    .TCin(SPW2TCin),

    .fct_req(SPW2fct_req),
    .data_req(SPW2data_req),
    .tc_req(SPW2tc_req),
    
    .fct_ack(SPW2fct_ack),
    .data_ack(SPW2data_ack),
    .tc_ack(SPW2tc_ack),
    
    .din(SPW2din),
    .sin(SPW2sin),
    .dot(SPW2dot),
    .sot(SPW2sot),
    
    .dataout(SPW2dataout),
    .datavalid(SPW2datavalid)
    );




always
begin
    #5 SPW1clk <=0;
    #5 SPW1clk <=1;
end    

always
begin
    #10 SPW2clk <=0;
    #10 SPW2clk <=1;
end    


initial
begin
    SPW1dissable <= 1;
    #80us SPW1dissable <= 1;
end


always 
begin
    #0.1 SPW1din <= (SPW2dot & SPW1dissable); SPW1sin <= (SPW2sot & SPW1dissable);
    SPW2din <= (SPW1dot & SPW1dissable); SPW2sin <= (SPW1sot & SPW1dissable);
end






initial
begin
    SPW1rst <= 1;
    SPW2rst <= 1;
    SPW1enabled <= 0;
    SPW2enabled <= 0;
    #100 SPW1rst <= 0;
         SPW2rst <= 0;
         SPW1enabled <= 1;
         SPW2enabled <= 1;
end


initial
begin 
#29us
@(posedge SPW1clk);
SPW1fct_req <= 1;
@(posedge SPW1fct_ack)
SPW1fct_req <= 0;
end

initial
begin 
#30us
@(posedge SPW2clk);
SPW2fct_req <= 1;
@(posedge SPW2fct_ack)
SPW2fct_req <= 0;
end

/*
initial
begin 
SPW1datain <= 8'b00110011;

#50us
@(posedge SPW1clk);
SPW1data_req <= 1;
@(posedge SPW1data_ack)
SPW1data_req <= 0;


#1us
SPW1datain <= 8'b01011011;
@(posedge SPW1clk);
SPW1data_req <= 1;
@(posedge SPW1data_ack)
SPW1data_req <= 0;



for (int ii=1; ii<5; ii++)
begin
    #1us
    SPW1datain <= 8'b01011011;
    @(posedge SPW1clk);
    SPW1data_req <= 1;
    @(posedge SPW1data_ack)
    SPW1data_req <= 0;
end



for (int ii=1; ii<8; ii++)
begin
    #1us
    SPW1TCin <= 8'b01001001;
    @(posedge SPW1clk);
    SPW1tc_req <= 1;
    @(posedge SPW1tc_ack)
    SPW1tc_req <= 0;
end


end

*/

endmodule



