`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2022 06:23:59 PM
// Design Name: 
// Module Name: dataGenerator
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


module dataGenerator(
        output reg dout,
        output reg sout
        );
//    reg dout;
//    reg sout;
    
    reg clk;
    
    reg [43:0] sample_data = 'b0111_0100_0111_0100_0111_0100_0111_0100_0110_1111_0100;
    
    parameter FREQ = 100000;
    parameter PHASE = 0;
    parameter DUTY = 50;
    
    
    real clk_pd = 1.0/(FREQ * 1e3) * 1e9;
    real clk_on = DUTY/100.0 * clk_pd;
    real clk_off = (100.0-DUTY)/100.0 * clk_pd;
    real quarter = clk_pd / 4;
    real start_dly = quarter * PHASE/90; 
    
    reg start_clk;
    reg enable;
    
    //The eight-bit data value shall be transmitted least significant bit first.
    const bit [3:0] FCT = 0'b0100;
    const bit [3:0] EOP = 0'b0101;
    const bit [3:0] EEP = 0'b0110;
    const bit [3:0] ESC = 0'b0111;
    

    
    function int addition (input int in_a, in_b);
        // Return the sum of the two inputs
        return in_a + in_b;
    endfunction : addition    
   
    function reg calc_parity (input reg in_a []);
        reg retval;
        retval = 1;
        begin
            for(int i = 0; i < $size(in_a); i++)
                retval = retval ^ in_a[i];
        end
        return retval;
    endfunction : calc_parity
    
    
    /* 
    Burada bazi guzel seyler yapacagim dikkat
    */
    typedef struct {reg next_preparity;
                    reg [3:0] data;
                    } Byte4;
    typedef struct {reg next_preparity;
                    reg [9:0] data;
                    } Byte10;
    
    /*
    function Byte4 FCT_packet(input reg pre_parity); // FCT is P100 P1 belongs to the previous data for parity calculation. remaining 00 affects the next packet.
        reg parity;
        parity = pre_parity ^ 1;
        FCT_packet.data = {parity, 0'b100}; // this is concatenation
        FCT_packet.next_preparity = 0 ^ 0;
        $display("%p", FCT_packet);
    endfunction: FCT_packet;
        
    function Byte4 EOP_packet(input reg pre_parity); // EOP is P101 P1 belongs to the previous data for parity calculation. remaining 01 affects the next packet.
        reg parity;
        parity = pre_parity ^ 1;
        EOP_packet.data = {parity, 0'b101}; // this is concatenation
        EOP_packet.next_preparity = 0 ^ 1;
        $display("%p", EOP_packet);
    endfunction: EOP_packet;
    
    function Byte4 EEP_packet(input reg pre_parity); // EEP is P110 P1 belongs to the previous data for parity calculation. remaining 10 affects the next packet.
        reg parity;
        parity = pre_parity ^ 1;
        EEP_packet.data = {parity, 0'b110}; // this is concatenation
        EEP_packet.next_preparity = 1 ^ 0;
        $display("%p", EEP_packet);
    endfunction: EEP_packet;
    */
    function Byte4 ESC_packet(input reg pre_parity); // ESC is P111 P1 belongs to the previous data for parity calculation. remaining 11 affects the next packet.
        reg parity;
        parity = pre_parity ^ 1;
        ESC_packet.data = {parity, 0'b111}; // this is concatenation
        ESC_packet.next_preparity = 1 ^ 1;
        $display("%p", ESC_packet);
    endfunction: ESC_packet;
    
    // ESC + FCT is NULL
        
    function Byte10 Data_packet(input reg pre_parity, input reg[7:0] datain); // Data is is P0XXXXXXXX P0 belongs to the previous data for parity calculation. remaining X affects the next packet.
        reg parity;
        parity = pre_parity ^ 0;
        Data_packet.data = {parity, 'b0, datain}; // this is concatenation
        Data_packet.next_preparity = datain[7] ^ datain[6] ^ datain[5] ^ datain[4] ^ datain[3] ^ datain[2] ^ datain[1] ^ datain[0];
        $display("%p", Data_packet);
    endfunction: Data_packet;
        
    
    
   
    initial begin    
        $display("FREQ      = %0d kHz", FREQ);
        $display("PHASE     = %0d deg", PHASE);
        $display("DUTY      = %0d %%",  DUTY);
        
        $display("PERIOD    = %0.3f ns", clk_pd);    
        $display("CLK_ON    = %0.3f ns", clk_on);
        $display("CLK_OFF   = %0.3f ns", clk_off);
        $display("QUARTER   = %0.3f ns", quarter);
        $display("START_DLY = %0.3f ns", start_dly);
    end
  
    // Initialize variables to clk_off 
    initial begin
        clk <= 0;
        start_clk <= 0;
        enable <= 1;
        //sample_data <= 8'b01110100;
    end
  
    // When clock is enabled, delay driving the clock to one in order
    // to achieve the phase effect. start_dly is configured to the 
    // correct delay for the configured phase. When enable is 0,
    // allow enough time to complete the current clock period
    always @ (posedge enable or negedge enable) begin
        if (enable) begin
            #(start_dly) start_clk = 1;
        end else begin
            #(start_dly) start_clk = 0;
        end      
    end
  
    // Achieve duty cycle by a skewed clock on/off time and let this
    // run as long as the clocks are turned on.
    always @(posedge start_clk) begin
        if (start_clk) begin
            clk = 1;
    
            while (start_clk) begin
                #(clk_on)  clk = 0;
                #(clk_off) clk = 1;
            end
    
            clk = 0;
        end
    end 
    
    
    //here we do all edge 
    always @(clk) begin
        if (enable_sending == 1) begin
            //dout <= sample_data[43];
            sample_data <= {sample_data[42:0],sample_data[43]};
        end
    end
    
    always_comb begin
        sout <= dout ^ clk; //xor
    end
    
    //
    
    reg [3:0] simdata;
    
    initial begin
        simdata = FCT_packet('b0).data;
        $display(">>>>>>>>> %b",simdata);
    end
    
    
    
    //This is my experimental part 
    reg test_sig = 0;
    int local_cnt = 0;
    int inner_cnt = 0;
    int jj = 0;
    
    typedef struct {reg next_preparity;
                    reg [13:0] data;
                    int length;
                    } ByteGeneric; 
                           
    function ByteGeneric NULL_packet(input pre_parity); // Data is is P0XXXXXXXX P0 belongs to the previous data for parity calculation. remaining X affects the next packet.
        bit parity;
        ByteGeneric retval;
        $display("%t", $time);
        $display("pre_parity is %0d", pre_parity);
        parity = pre_parity ^ 0;
        $display("parity is: preparity xor 0 = %0d", parity);
        retval.data = {6'b000000 ,parity, 7'b1110100}; // this is concatenation
        retval.next_preparity = 0;
        retval.length = 8;
        $display("%p", NULL_packet);
        $display("%B", retval.data);
        return retval;
    endfunction: NULL_packet;
    
    function ByteGeneric EOP_packet(input reg pre_parity); // EOP is P101 P1 belongs to the previous data for parity calculation. remaining 01 affects the next packet.
        reg parity;
        ByteGeneric retval;
        parity = pre_parity ^ 0;
        retval.data = {10'bZZZZZZZZZZ, parity, 3'b101}; // this is concatenation
        retval.next_preparity = 0 ^ 1;
        retval.length = 4;
        $display("%p", EOP_packet);
        return retval;
    endfunction: EOP_packet;

    function ByteGeneric FCT_packet(input reg pre_parity); // FCT is P100 P1 belongs to the previous data for parity calculation. remaining 00 affects the next packet.
        reg parity;
        parity = pre_parity ^ 0;
        FCT_packet.data = {10'bZZZZZZZZZZ, parity, 3'b100}; // this is concatenation
        FCT_packet.next_preparity = 0 ^ 0;
        FCT_packet.length = 4;
        $display("%p", FCT_packet);
    endfunction: FCT_packet;

    function ByteGeneric EEP_packet(input reg pre_parity); // EEP is P110 P1 belongs to the previous data for parity calculation. remaining 10 affects the next packet.
        reg parity;
        parity = pre_parity ^ 0;
        EEP_packet.data = {10'bZZZZZZZZZZ, parity, 3'b110}; // this is concatenation
        EEP_packet.next_preparity = 1 ^ 0;
        EEP_packet.length = 4;
        $display("%p", EEP_packet);
    endfunction: EEP_packet;


    function ByteGeneric TC_packet(input reg pre_parity,input reg[7:0] TCode); // EEP is P110 P1 belongs to the previous data for parity calculation. remaining 10 affects the next packet.
        reg parity;
        reg[7:0] localTcode;
        for(int kk = 0;kk < 8;kk++)
            localTcode[kk] = TCode[7-kk];
        parity = pre_parity ^ 0;
        TC_packet.data = {parity, 5'b11110 , localTcode}; // this is concatenation
        TC_packet.next_preparity = 1 ^ localTcode[7] ^ localTcode[6] ^ localTcode[5] ^ localTcode[4] ^ localTcode[3] ^ localTcode[2] ^ localTcode[1] ^ localTcode[0];
        TC_packet.length = 14;
        $display("%p", TC_packet);
    endfunction: TC_packet;

    function ByteGeneric DATA_packet(input reg pre_parity,input reg[7:0] Data); // EEP is P110 P1 belongs to the previous data for parity calculation. remaining 10 affects the next packet.
        reg parity;
        reg[7:0] localData;
        for(int kk = 0;kk < 8;kk++)
            localData[kk] = Data[7-kk];
        parity = pre_parity ^ 1;
        DATA_packet.data = {4'bZZZZ ,parity, 1'b0 , localData}; // this is concatenation
        DATA_packet.next_preparity = localData[7] ^ localData[6] ^ localData[5] ^ localData[4] ^ localData[3] ^ localData[2] ^ localData[1] ^ localData[0];
        DATA_packet.length = 10;
        $display("%p", DATA_packet);
    endfunction: DATA_packet;



    reg enable_sending = 0;
    always begin 
        @(negedge clk) begin
            if ($realtime > 151) begin
                if (enable_sending == 0) begin
                    enable_sending <= 1;
                end
            end
        end
    end

    ByteGeneric testdata;
    reg active_parity = 0;
    int pkt_cntr = 0;
    reg [13:0] data2send;
    
    always begin 
        @(posedge clk or negedge clk) begin
            if ($realtime > 150) begin if (enable_sending == 1) begin
                if (inner_cnt == 0) begin
                    case (pkt_cntr) 
                        5       : testdata = EOP_packet(active_parity);
                        8       : testdata = EEP_packet(active_parity);
                        13      : testdata = FCT_packet(active_parity);
                        15      : testdata = TC_packet(.pre_parity(active_parity), .TCode(8'h53));
                        19      : testdata = DATA_packet(.pre_parity(active_parity), .Data(8'h67));
                        default : testdata = NULL_packet(active_parity);
                    endcase 
                
                
                
                    /*if (pkt_cntr == 5) begin
                        testdata = EOP_packet(active_parity);
                    end else begin
                        if (pkt_cntr == 8) begin
                            testdata = EEP_packet(active_parity);
                        end else begin
                            if (pkt_cntr == 13) begin
                                testdata = FCT_packet(active_parity);
                            end else begin
                                $display("active parity is %0h", active_parity);
                                testdata = NULL_packet(active_parity);
                                $display("testdata.data is %B", testdata.data);
                            end
                        end
                    end*/
                    data2send = testdata.data;
                    inner_cnt = testdata.length;
                    jj = inner_cnt;
                    active_parity = testdata.next_preparity;
                    pkt_cntr ++;
                end
                
                
                if (jj>0) begin
                   dout <= data2send[jj-1];
                   test_sig <= data2send[jj-1];
                   jj--;
                   inner_cnt--;
                end else begin
                   dout <= 1;
                   test_sig <= 1;
                end
                                        
            end end
        end
    end
    
    
    
endmodule
