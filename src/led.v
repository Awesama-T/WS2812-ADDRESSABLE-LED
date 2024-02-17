`timescale 1ns / 1ns
`define T0H     350.0   // 0.35 us
`define T0L     800.0   // 0.8 us
`define T1H     700.0   // 0.7 us
`define T1L     600.0   // 0.6 us
`define MARGIN  150.0   // +/- 150 ns
`define RET     50000.0 // 50 us

module led(
    input           i_serial,
	//input			  clk,
    output          o_serial,
    output [23:0]   o_led);
    //***********************************************************************
    //  Doing "Things"
    //***********************************************************************
    localparam       CLK_PRD  = 50; //Clock period in ns
    localparam [4:0] T0H_MIN  = ((`T0H - `MARGIN)/CLK_PRD);
    localparam [4:0] T0H_MAX  = ((`T0H + `MARGIN)/CLK_PRD);
    localparam [4:0] T1H_MIN  = ((`T1H - `MARGIN)/CLK_PRD);
    localparam [4:0] T1H_MAX  = ((`T1H + `MARGIN)/CLK_PRD);
    localparam [9:0] RST_MIN  = ((`RET)/CLK_PRD);
    //***********************************************************************
    //  Signal Declaration
    //***********************************************************************
    reg [9:0]rst_timer = 0;
    reg [4:0]bit_timer = 0;
    reg [4:0]bit_cntr  = 0;
    reg [1:0]state_reg = 0;
    reg [1:0]state_nxt = 0;
    reg [0:23]data     = 0;
    reg i_serial_tmp   = 0;
    reg i_serial_sync  = 0;
    reg clk            = 0;
    //***********************************************************************
    //  States Declaration
    //***********************************************************************
    localparam[1:0]
    idle    = 2'd0,
    measure = 2'd1,
    check   = 2'd2;
    //***********************************************************************
    //  Clock Simulation
    //***********************************************************************
    always #(CLK_PRD/2) clk = ~clk;
    //***********************************************************************
    //  Input(i_serial) Synchronization
    //***********************************************************************   
    always@(posedge clk) 
    begin
        i_serial_tmp <= i_serial;
        i_serial_sync <= i_serial_tmp;
    end
    //***********************************************************************
    //  State Register, Reset Timer, Bit Timer & Bit Counter
    //***********************************************************************   
    always@(posedge clk) 
    begin
        state_reg <= state_nxt;
        //Things to do in "idle" state
        if (state_reg == idle) begin
            bit_timer <= 0;
            if (~i_serial_sync)         
                rst_timer <= (rst_timer<RST_MIN)?rst_timer+10'd1:RST_MIN;
            else rst_timer  <= 0;
        end
        //Things to do in "measure" state        
        if (state_reg == measure) begin
            bit_timer <= bit_timer+5'd1;
        end
        //Things to do in "check" state
        if (state_reg == check) begin
            bit_cntr <= bit_cntr+5'd1;
            if((bit_timer>=T0H_MIN)&&(bit_timer<=T0H_MAX)) 
            data[bit_cntr] <= 1'd0; else if
            ((bit_timer>=T1H_MIN)&&(bit_timer<=T1H_MAX)) 
            data[bit_cntr] <= 1'd1; else 
            data[bit_cntr] <= 1'd0;
        end
        //Things to do when reset is detected
        if (rst_timer==RST_MIN) begin
            bit_cntr <= 0;
            data <= 0;
        end
    end
    //***********************************************************************
    //  Next State Logic
    //***********************************************************************   
    always@* 
    begin
        state_nxt = state_reg;
        case(state_reg)
            idle: begin
                if(bit_cntr<24)
                if(i_serial_sync) state_nxt = measure;
            end
            measure: begin
                if(~i_serial_sync) state_nxt = check;
            end
            check: begin
                state_nxt = idle;
            end
            default: state_nxt = idle;
        endcase
    end
    //***********************************************************************
    // Output Assignment
    //***********************************************************************   
    assign o_serial = (bit_cntr==24)?i_serial:1'd0;
    assign o_led = (bit_cntr==24)?data:24'd0;
endmodule