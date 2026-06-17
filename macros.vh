`define SET_WRITE(addr,val,bytes,cs) \
   rw_ <= 1'b0; \
   chip_select <= cs; \
   byte_en <= bytes; \
   address <= addr; \
   data_in <= val;

`define SET_READ(addr,cs) \
   rw_ <= 1'b1; \
   chip_select <= cs; \
   byte_en <= 2'b00; \
   address <= addr; \
   data_in <= 16'h0;

`define CLEAR_BUS \
   chip_select <= 1'b0; \
   address <= 7'h0; \
   byte_en <= 2'h0; \
   rw_ <= 1'b1; \
   data_in <= 16'h0;

`define CLEAR_ALL \
   export_disable <= 1'b0; \
   maroon <= 1'b0; \
   gold <= 1'b0; \
   `CLEAR_BUS

`define CHIP_RESET \
   wait(clk == 1'b0); \
   rst_b <= 1'b0; \
   wait(clk == 1'b1); \
   rst_b <= 1'b1; \
   wait(clk == 1'b0); \
   wait(clk == 1'b1); \
   wait(clk == 1'b0);

`define SET_EXPORT_DISABLE(val) \
   wait(clk == 1'b0); \
   export_disable <= val; \
   wait(clk == 1'b1); \
   wait(clk == 1'b0);

`define CHECK_VAL(val) \
   if (data_out !== val) $display("bad read, got %h but expected %h at %t", data_out, val, $time());

`define WRITE_REG(addr,val,bytes,cs) \
   wait(clk == 1'b0); \
   `SET_WRITE(addr,val,bytes,cs) \
   wait(clk == 1'b1); \
   wait(clk == 1'b0); \
   `CLEAR_BUS

`define READ_REG(addr,cs) \
   wait(clk == 1'b0); \
   `SET_READ(addr,cs) \
   wait(clk == 1'b1); \
   wait(clk == 1'b0); \
   `CLEAR_BUS

`define CHECK_CMD_RW \
   `WRITE_REG(VCHIP_CMD_ADDR, ~tests[i], 2'b11, 1'b1) \
   `READ_REG(VCHIP_CMD_ADDR, 1'b1) `CHECK_VAL(((~tests[i]) & 16'h800F)) \
   `ENSURE_NORM \
   `WRITE_REG(VCHIP_CMD_ADDR, tests[i], 2'b11, 1'b1) \
   `READ_REG(VCHIP_CMD_ADDR, 1'b1) `CHECK_VAL((tests[i] & 16'h800F)) \
   `ENSURE_NORM

`define CHANGE_STATE(m,g) \
   wait(clk == 1'b0); \
   maroon <= m; \
   gold <= g; \
   wait(clk == 1'b1); \
   wait(clk == 1'b0); \
   maroon <= 1'b0; \
   gold <= 1'b0; \
   wait(clk == 1'b1); \
   wait(clk == 1'b0);

`define WAIT_CYC \
   wait(clk == 1'b1); \
   wait(clk == 1'b0);

`define MATH_CMD(left, right, cmd) \
   `WRITE_REG(VCHIP_ALU_LEFT_ADDR, left, 2'b11, 1'b1) \
   `WRITE_REG(VCHIP_ALU_RIGHT_ADDR, right, 2'b11, 1'b1) \
   `WRITE_REG(VCHIP_CMD_ADDR, cmd, 2'b11, 1'b1) \
   `WAIT_CYC

// Register Test macros

`define CHECK_RW(addr, mask, expected) \
   `WRITE_REG(addr, ~tests[i], 2'b11, 1'b1) \
   `READ_REG(addr, 1'b1) `CHECK_VAL(((~tests[i]) & mask) | expected) \
   `WRITE_REG(addr, tests[i], 2'b11, 1'b1) \
   `READ_REG(addr, 1'b1) `CHECK_VAL((tests[i] & mask) | expected)

`define ENSURE_NORM \
   wait(clk == 1'b0); \
   maroon <= 1'b1; \
   gold <= 1'b0; \
   wait(clk == 1'b1); \
   wait(clk == 1'b0); \
   maroon <= 1'b0; \
   gold <= 1'b0; \
   wait(clk == 1'b1); \
   wait(clk == 1'b0);

`define TEST_BE(ADDR, MASK, DEF_VAL) \
   `WRITE_REG(ADDR, 16'h0000, 2'b11, 1'b1) \
   `WRITE_REG(ADDR, 16'h5555, 2'b00, 1'b1) \
   `READ_REG(ADDR, 1'b1) `CHECK_VAL(DEF_VAL) \
   `WRITE_REG(ADDR, 16'h0000, 2'b11, 1'b1) \
   `WRITE_REG(ADDR, 16'h5555, 2'b01, 1'b1) \
   `READ_REG(ADDR, 1'b1) `CHECK_VAL((16'h0055 & MASK) | DEF_VAL) \
   `WRITE_REG(ADDR, 16'h0000, 2'b11, 1'b1) \
   `WRITE_REG(ADDR, 16'h5555, 2'b10, 1'b1) \
   `READ_REG(ADDR, 1'b1) `CHECK_VAL((16'h5500 & MASK) | DEF_VAL) \
   `WRITE_REG(ADDR, 16'h0000, 2'b11, 1'b1) \
   `WRITE_REG(ADDR, 16'h5555, 2'b11, 1'b1) \
   `READ_REG(ADDR, 1'b1) `CHECK_VAL((16'h5555 & MASK) | DEF_VAL) \
   `WRITE_REG(ADDR, 16'hFFFF, 2'b11, 1'b1) \
   `WRITE_REG(ADDR, 16'h0000, 2'b01, 1'b1) \
   `READ_REG(ADDR, 1'b1) `CHECK_VAL((16'hFF00 & MASK) | DEF_VAL)


`define CHECK_ACCESS_RW(ADDR, MASK, EXPECTED) \
   `WRITE_REG(ADDR, ~tests[i], 2'b11, 1'b1) `WAIT_CYC \
   `WRITE_REG(ADDR, tests[i], 2'b11, 1'b0) `WAIT_CYC \
   `READ_REG(ADDR, 1'b0) `CHECK_VAL(16'h0000) \
   `READ_REG(ADDR, 1'b1) `CHECK_VAL(((~tests[i]) & MASK) | EXPECTED) \
   `WRITE_REG(ADDR | 7'h40, tests[i], 2'b11, 1'b1) `WAIT_CYC \
   `READ_REG(ADDR | 7'h40, 1'b1) `CHECK_VAL((tests[i] & MASK) | EXPECTED) \
   `READ_REG(ADDR, 1'b1) `CHECK_VAL((tests[i] & MASK) | EXPECTED) \
   `WRITE_REG(ADDR | 7'h20, ~tests[i], 2'b11, 1'b1) `WAIT_CYC \
   `READ_REG(ADDR, 1'b1) `CHECK_VAL((tests[i] & MASK) | EXPECTED)

`define CHECK_ACCESS_CMD \
   `WRITE_REG(VCHIP_CMD_ADDR, ~tests[i], 2'b11, 1'b1) `WAIT_CYC `ENSURE_NORM \
   `WRITE_REG(VCHIP_CMD_ADDR, tests[i], 2'b11, 1'b0) `WAIT_CYC `ENSURE_NORM \
   `READ_REG(VCHIP_CMD_ADDR, 1'b0) `CHECK_VAL(16'h0000) \
   `READ_REG(VCHIP_CMD_ADDR, 1'b1) `CHECK_VAL(((~tests[i]) & 16'h800F)) \
   `WRITE_REG(VCHIP_CMD_ADDR | 7'h40, tests[i], 2'b11, 1'b1) `WAIT_CYC `ENSURE_NORM \
   `READ_REG(VCHIP_CMD_ADDR | 7'h40, 1'b1) `CHECK_VAL((tests[i] & 16'h800F)) \
   `READ_REG(VCHIP_CMD_ADDR, 1'b1) `CHECK_VAL((tests[i] & 16'h800F)) \
   `WRITE_REG(VCHIP_CMD_ADDR | 7'h20, ~tests[i], 2'b11, 1'b1) `WAIT_CYC `ENSURE_NORM \
   `READ_REG(VCHIP_CMD_ADDR, 1'b1) `CHECK_VAL((tests[i] & 16'h800F)) \
   `WRITE_REG(VCHIP_CMD_ADDR, 16'h0000, 2'b11, 1'b1) `ENSURE_NORM

`define CHECK_ACCESS_RO(ADDR, EXPECTED) \
   `WRITE_REG(ADDR, tests[i], 2'b11, 1'b0) `WAIT_CYC \
   `READ_REG(ADDR, 1'b0) `CHECK_VAL(16'h0000) \
   `READ_REG(ADDR, 1'b1) `CHECK_VAL(EXPECTED) \
   `WRITE_REG(ADDR | 7'h40, tests[i], 2'b11, 1'b1) `WAIT_CYC \
   `READ_REG(ADDR | 7'h40, 1'b1) `CHECK_VAL(EXPECTED) \
   `READ_REG(ADDR, 1'b1) `CHECK_VAL(EXPECTED) \
   `WRITE_REG(ADDR | 7'h20, ~tests[i], 2'b11, 1'b1) `WAIT_CYC \
   `READ_REG(ADDR, 1'b1) `CHECK_VAL(EXPECTED)

`define CHECK_ACCESS_ALU_OUT \
   `MATH_CMD(tests[i], 16'h0000, 16'h8001) \
   `WRITE_REG(VCHIP_ALU_OUT_ADDR, ~tests[i], 2'b11, 1'b0) `WAIT_CYC \
   `READ_REG(VCHIP_ALU_OUT_ADDR, 1'b0) `CHECK_VAL(16'h0000) \
   `READ_REG(VCHIP_ALU_OUT_ADDR, 1'b1) `CHECK_VAL(tests[i]) \
   `WRITE_REG(VCHIP_ALU_OUT_ADDR | 7'h40, ~tests[i], 2'b11, 1'b1) `WAIT_CYC \
   `READ_REG(VCHIP_ALU_OUT_ADDR | 7'h40, 1'b1) `CHECK_VAL(tests[i]) \
   `READ_REG(VCHIP_ALU_OUT_ADDR, 1'b1) `CHECK_VAL(tests[i]) \
   `WRITE_REG(VCHIP_ALU_OUT_ADDR | 7'h20, ~tests[i], 2'b11, 1'b1) `WAIT_CYC \
   `READ_REG(VCHIP_ALU_OUT_ADDR, 1'b1) `CHECK_VAL(tests[i])


// coverage macros
`define CHECK_RW_C(addr,bytes) \
   `WRITE_REG(addr, 16'hFFFF, bytes, 1'b0) \
	`WAIT_CYC\
   `READ_REG_C(addr,bytes, 1'b0)\
	`WAIT_CYC  

`define SET_READ_C(addr,bytes,cs) \
   rw_ <= 1'b1; \
   chip_select <= cs; \
   byte_en <= bytes; \
   address <= addr; \
   data_in <= 16'h0;

`define READ_REG_C(addr,bytes,cs) \
   wait(clk == 1'b0); \
   `SET_READ_C(addr,bytes,cs) \
   wait(clk == 1'b1); \
   wait(clk == 1'b0); \
   `CLEAR_BUS



