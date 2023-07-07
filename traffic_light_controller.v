`timescale 1s / 1s

module Clock_divider(clock_in,clock_out
    );
input clock_in; 
output reg clock_out; 
reg[31:0] counter=32'd0;
parameter DIVISOR = 32'd125000000;

always @(posedge clock_in)
begin
 counter <= counter + 32'd1;
 if(counter>=(DIVISOR-1))
  counter <= 32'd0;
 clock_out <= (counter<DIVISOR/2)?1'b1:1'b0;
end
endmodule
 
module traffic_light_controller(
    input clk_in,
    input rst,
    input sw0,
    input sw1,
    input [2:0] btn,
    output reg [6:0] seg,
    output reg red,
    output reg yellow,
    output reg green,
    output reg red2,
    output reg yellow2,
    output reg green2 
);

Clock_divider m1(clk_in, clk);

parameter RED = 3'b001;
parameter YELLOW = 3'b010;
parameter GREEN = 3'b100;

reg [2:0] state;
reg [23:0] timer;
reg [23:0] count;


integer red_time = 6;
integer yellow_time = 1;
integer green_time = 2;

always @(posedge clk) begin
    if (rst) begin
        state <= RED;
        timer <= 0;
        count <= red_time;
        red <= 1;
        yellow <= 0;
        green <= 0;
        red2 <= 0;
        yellow2 <= 0;
        green2 <= 1;
    end else begin
    if (!sw1) begin
        if(btn[0]) red_time = red_time-1;
        if(btn[1]) yellow_time = yellow_time-1;
        if(btn[2]) green_time = green_time-1;
    end else begin
        if(btn[0]) red_time = red_time+1;
        if(btn[1]) yellow_time = yellow_time+1;
        if(btn[2]) green_time = green_time+1;
    end
         if (!sw0) begin
            case (state)
                RED: begin
                    if(timer == 2)begin 
                        red2 <= 0; 
                        yellow2 <= 1; 
                        green2 <= 0;
                        end
                    if(timer == 4)begin 
                        red2 <= 1; 
                        yellow2 <= 0; 
                        green2 <= 0;
                        end
                    if (timer == red_time) begin
                        state <= GREEN;
                        timer <= 0;
                        count <= green_time;
                        red <= 0;
                        yellow <= 0;
                        green <= 1;
                        red2 <= 1;
                        yellow2 <= 0;
                        green2 <= 0;
                    
                    end else begin
                        timer <= timer + 1;
                        count <= count - 1;
                    end
                end
                GREEN: begin
                    
                    if (timer == green_time) begin
                        state <= YELLOW;
                        timer <= 0;
                        count <= yellow_time;
                        red <= 0;
                        yellow <= 1;
                        green <= 0;
                        red2 <= 1;
                        yellow2 <= 0;
                        green2 <= 0;
                    end else begin
                        timer <= timer + 1; 
                        count <= count - 1; 
                    end 
                end 
                YELLOW: begin 
                    if (timer == yellow_time) begin 
                        red <= 1; 
                        yellow <= 0; 
                        green <= 0;
                        red2 <= 1; 
                        yellow2 <= 0; 
                        green2 <= 0;
                        count <= red_time;
                        timer <= timer + 1; 
                        
                    end
                    else if (timer == yellow_time + 1) begin 
                        state <= RED; 
                        timer <= 0; 
                        red <= 1; 
                        yellow <= 0; 
                        green <= 0;
                        red2 <= 0; 
                        yellow2 <= 0; 
                        green2 <= 1;

                    end else begin 
                        timer <= timer + 1; 
                        count <= count - 1; 
                    end 
                end 
            endcase 
        end else if (sw0) begin 
		  red <= 0;
		  green <= 0;
		  red2 <= 0;
		  green2 <= 0;
		  count <= 10;
		  yellow <= 0;
		  yellow2 <= 1;
            if (timer == 1) begin 
                yellow <= ~yellow;
                yellow2 <= ~yellow2;
                timer <= 0;
            end else if(timer > 1) begin
                timer <= 0;
            end else begin 
                timer <= timer + 1;
            end  
        end  
    end  
end  
always @(*) begin
    case(count)
        4'd0: seg = 7'b1000000; // display "0"
        4'd1: seg = 7'b1111001; // display "1"
        4'd2: seg = 7'b0100100; // display "2"
        4'd3: seg = 7'b0110000; // display "3"
        4'd4: seg = 7'b0011001; 
	    4'd5: seg = 7'b0010010;
	    4'd6: seg = 7'b0000010;
	    4'd7: seg = 7'b1111000;
	    4'd8: seg = 7'b0000000;
	    4'd9: seg = 7'b0010000;
        default: seg = 7'b1111111; // display nothing
    endcase
end

endmodule
