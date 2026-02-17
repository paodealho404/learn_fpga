module fifo (
    input  wire       clk,
    input  wire       rst_n,
    // Write side
    input  wire       write_en,
    input  wire [7:0] write_data,
    output wire       write_full,  // Combinational (depends on pointers)
    // Read side
    input  wire       read_en,
    output wire [7:0] read_data,   // Combinational (memory read)
    output wire       read_empty,  // Combinational (depends on pointers)
    // Status
    output wire [4:0] count        // Combinational (derived from pointers)
);

    parameter integer DEPTH = 16;
    parameter integer ADDR_WIDTH = 4;

    // Memory (sequential component: DEPTH x 8 bits)
    // Structure: Array of 16 bytes (16 positions x 8 bits each)
    //
    //   Index:  |   0   |   1   |   2   |  ...  |  15   |
    //           +-------+-------+-------+-------+-------+
    // fifo_mem: | byte0 | byte1 | byte2 |  ...  | byte15|
    //           +-------+-------+-------+-------+-------+
    //
    reg [         7:0] fifo_mem  [DEPTH-1:0];

    // Pointers (sequential - updated on clock)
    reg [ADDR_WIDTH:0] write_ptr;
    reg [ADDR_WIDTH:0] read_ptr;

    // ===== SEQUENTIAL LOGIC (updated by clock) =====
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_ptr <= 5'd0;
            read_ptr  <= 5'd0;
        end else begin
            // Write side
            if (write_en && !write_full) begin
                fifo_mem[write_ptr[ADDR_WIDTH-1:0]] <= write_data;
                write_ptr                           <= write_ptr + 1'b1;
            end

            // Read side
            if (read_en && !read_empty) begin
                read_ptr <= read_ptr + 1'b1;
            end
        end
    end

    // ===== COMBINATIONAL LOGIC (responds immediately) =====

    // FIFO FULL condition:
    // Full when difference between pointers equals DEPTH (16)
    // The 5-bit arithmetic naturally handles wrap-around
    // Example 1: write_ptr = 16, read_ptr = 0 → 16-0 = 16 → FULL
    // Example 2: write_ptr = 4, read_ptr = 20 → (4-20) = -16 ≡ 16 (mod 32) → FULL
    assign write_full = (write_ptr - read_ptr) == DEPTH;

    // FIFO EMPTY condition:
    // Empty when both pointers are exactly equal (same lap, same address)
    // Example: write_ptr = 00101 (5), read_ptr = 00101 (5) → nothing to read
    assign read_empty = (write_ptr == read_ptr);

    // DATA OUTPUT:
    // Read directly from memory at read_ptr address (lower 4 bits only)
    // Example: read_ptr = 10011 (19) → actual address = 19 % 16 = 3 (0011)
    assign read_data = fifo_mem[read_ptr[ADDR_WIDTH-1:0]];

    // COUNT:
    // Number of valid bytes currently stored in FIFO
    // If write_ptr >= read_ptr: simple subtraction (same lap)
    // If write_ptr < read_ptr: write_ptr wrapped, so add DEPTH to calculate
    // Example 1: write=5, read=2 → count = 5-2 = 3 bytes
    // Example 2: write=2, read=14 → count = 16-14+2 = 4 bytes (wrapped)
    assign count = (write_ptr >= read_ptr) ? 
                   (write_ptr[ADDR_WIDTH-1:0] - read_ptr[ADDR_WIDTH-1:0]) :
                   (DEPTH - read_ptr[ADDR_WIDTH-1:0] + write_ptr[ADDR_WIDTH-1:0]);

endmodule

