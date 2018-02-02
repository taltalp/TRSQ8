// test.trsq
module prom (
    input CLK_ip,
    input [12:0] ADDR_ip,
    output [14:0] DATA_op);

    assign DATA_op = 
        ADDR_ip==13'd0 ? 15'b010111000000001: // 
        ADDR_ip==13'd1 ? 15'b010110000001010: // 
        ADDR_ip==13'd2 ? 15'b010111000000001: // 
        ADDR_ip==13'd3 ? 15'b010000000001010: // 
        ADDR_ip==13'd4 ? 15'b010110000001010: // 
        ADDR_ip==13'd5 ? 15'b010110100001010: // 
        ADDR_ip==13'd6 ? 15'b010110000001011: // 
        ADDR_ip==13'd7 ? 15'b110000000000010: // 
        ADDR_ip==13'd8 ? 15'b000000100000000: // 
                           15'b000000000000000;
endmodule
