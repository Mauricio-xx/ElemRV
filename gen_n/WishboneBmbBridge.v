// Generator : SpinalHDL v1.13.0    git head : d9d72474863badf47d8585d187f3e04ae4749c59
// Component : WishboneBmbBridge

`timescale 1ns/1ps

module WishboneBmbBridge (
  input  wire          io_wb_CYC,
  input  wire          io_wb_STB,
  output wire          io_wb_ACK,
  input  wire          io_wb_WE,
  input  wire [9:0]    io_wb_ADR,
  output wire [31:0]   io_wb_DAT_MISO,
  input  wire [31:0]   io_wb_DAT_MOSI,
  input  wire          clk,
  input  wire          resetn
);

  wire       [31:0]   bridge_io_wb_DAT_MISO;
  wire                bridge_io_wb_ACK;
  wire                bridge_io_bmb_cmd_valid;
  wire                bridge_io_bmb_cmd_payload_last;
  wire       [3:0]    bridge_io_bmb_cmd_payload_fragment_source;
  wire       [0:0]    bridge_io_bmb_cmd_payload_fragment_opcode;
  wire       [9:0]    bridge_io_bmb_cmd_payload_fragment_address;
  wire       [5:0]    bridge_io_bmb_cmd_payload_fragment_length;
  wire       [31:0]   bridge_io_bmb_cmd_payload_fragment_data;
  wire       [3:0]    bridge_io_bmb_cmd_payload_fragment_mask;
  wire       [3:0]    bridge_io_bmb_cmd_payload_fragment_context;
  wire                bridge_io_bmb_rsp_ready;
  wire                ram_io_bmb_cmd_ready;
  wire                ram_io_bmb_rsp_valid;
  wire                ram_io_bmb_rsp_payload_last;
  wire       [3:0]    ram_io_bmb_rsp_payload_fragment_source;
  wire       [0:0]    ram_io_bmb_rsp_payload_fragment_opcode;
  wire       [31:0]   ram_io_bmb_rsp_payload_fragment_data;
  wire       [3:0]    ram_io_bmb_rsp_payload_fragment_context;

  WishboneToBmbMaster bridge (
    .io_wb_CYC                           (io_wb_CYC                                      ), //i
    .io_wb_STB                           (io_wb_STB                                      ), //i
    .io_wb_ACK                           (bridge_io_wb_ACK                               ), //o
    .io_wb_WE                            (io_wb_WE                                       ), //i
    .io_wb_ADR                           (io_wb_ADR[9:0]                                 ), //i
    .io_wb_DAT_MISO                      (bridge_io_wb_DAT_MISO[31:0]                    ), //o
    .io_wb_DAT_MOSI                      (io_wb_DAT_MOSI[31:0]                           ), //i
    .io_bmb_cmd_valid                    (bridge_io_bmb_cmd_valid                        ), //o
    .io_bmb_cmd_ready                    (ram_io_bmb_cmd_ready                           ), //i
    .io_bmb_cmd_payload_last             (bridge_io_bmb_cmd_payload_last                 ), //o
    .io_bmb_cmd_payload_fragment_source  (bridge_io_bmb_cmd_payload_fragment_source[3:0] ), //o
    .io_bmb_cmd_payload_fragment_opcode  (bridge_io_bmb_cmd_payload_fragment_opcode      ), //o
    .io_bmb_cmd_payload_fragment_address (bridge_io_bmb_cmd_payload_fragment_address[9:0]), //o
    .io_bmb_cmd_payload_fragment_length  (bridge_io_bmb_cmd_payload_fragment_length[5:0] ), //o
    .io_bmb_cmd_payload_fragment_data    (bridge_io_bmb_cmd_payload_fragment_data[31:0]  ), //o
    .io_bmb_cmd_payload_fragment_mask    (bridge_io_bmb_cmd_payload_fragment_mask[3:0]   ), //o
    .io_bmb_cmd_payload_fragment_context (bridge_io_bmb_cmd_payload_fragment_context[3:0]), //o
    .io_bmb_rsp_valid                    (ram_io_bmb_rsp_valid                           ), //i
    .io_bmb_rsp_ready                    (bridge_io_bmb_rsp_ready                        ), //o
    .io_bmb_rsp_payload_last             (ram_io_bmb_rsp_payload_last                    ), //i
    .io_bmb_rsp_payload_fragment_source  (ram_io_bmb_rsp_payload_fragment_source[3:0]    ), //i
    .io_bmb_rsp_payload_fragment_opcode  (ram_io_bmb_rsp_payload_fragment_opcode         ), //i
    .io_bmb_rsp_payload_fragment_data    (ram_io_bmb_rsp_payload_fragment_data[31:0]     ), //i
    .io_bmb_rsp_payload_fragment_context (ram_io_bmb_rsp_payload_fragment_context[3:0]   ), //i
    .clk                                 (clk                                            ), //i
    .resetn                              (resetn                                         )  //i
  );
  SimpleBmbRam ram (
    .io_bmb_cmd_valid                    (bridge_io_bmb_cmd_valid                        ), //i
    .io_bmb_cmd_ready                    (ram_io_bmb_cmd_ready                           ), //o
    .io_bmb_cmd_payload_last             (bridge_io_bmb_cmd_payload_last                 ), //i
    .io_bmb_cmd_payload_fragment_source  (bridge_io_bmb_cmd_payload_fragment_source[3:0] ), //i
    .io_bmb_cmd_payload_fragment_opcode  (bridge_io_bmb_cmd_payload_fragment_opcode      ), //i
    .io_bmb_cmd_payload_fragment_address (bridge_io_bmb_cmd_payload_fragment_address[9:0]), //i
    .io_bmb_cmd_payload_fragment_length  (bridge_io_bmb_cmd_payload_fragment_length[5:0] ), //i
    .io_bmb_cmd_payload_fragment_data    (bridge_io_bmb_cmd_payload_fragment_data[31:0]  ), //i
    .io_bmb_cmd_payload_fragment_mask    (bridge_io_bmb_cmd_payload_fragment_mask[3:0]   ), //i
    .io_bmb_cmd_payload_fragment_context (bridge_io_bmb_cmd_payload_fragment_context[3:0]), //i
    .io_bmb_rsp_valid                    (ram_io_bmb_rsp_valid                           ), //o
    .io_bmb_rsp_ready                    (bridge_io_bmb_rsp_ready                        ), //i
    .io_bmb_rsp_payload_last             (ram_io_bmb_rsp_payload_last                    ), //o
    .io_bmb_rsp_payload_fragment_source  (ram_io_bmb_rsp_payload_fragment_source[3:0]    ), //o
    .io_bmb_rsp_payload_fragment_opcode  (ram_io_bmb_rsp_payload_fragment_opcode         ), //o
    .io_bmb_rsp_payload_fragment_data    (ram_io_bmb_rsp_payload_fragment_data[31:0]     ), //o
    .io_bmb_rsp_payload_fragment_context (ram_io_bmb_rsp_payload_fragment_context[3:0]   ), //o
    .clk                                 (clk                                            ), //i
    .resetn                              (resetn                                         )  //i
  );
  assign io_wb_ACK = bridge_io_wb_ACK;
  assign io_wb_DAT_MISO = bridge_io_wb_DAT_MISO;

endmodule

module SimpleBmbRam (
  input  wire          io_bmb_cmd_valid,
  output wire          io_bmb_cmd_ready,
  input  wire          io_bmb_cmd_payload_last,
  input  wire [3:0]    io_bmb_cmd_payload_fragment_source,
  input  wire [0:0]    io_bmb_cmd_payload_fragment_opcode,
  input  wire [9:0]    io_bmb_cmd_payload_fragment_address,
  input  wire [5:0]    io_bmb_cmd_payload_fragment_length,
  input  wire [31:0]   io_bmb_cmd_payload_fragment_data,
  input  wire [3:0]    io_bmb_cmd_payload_fragment_mask,
  input  wire [3:0]    io_bmb_cmd_payload_fragment_context,
  output wire          io_bmb_rsp_valid,
  input  wire          io_bmb_rsp_ready,
  output wire          io_bmb_rsp_payload_last,
  output wire [3:0]    io_bmb_rsp_payload_fragment_source,
  output wire [0:0]    io_bmb_rsp_payload_fragment_opcode,
  output wire [31:0]   io_bmb_rsp_payload_fragment_data,
  output wire [3:0]    io_bmb_rsp_payload_fragment_context,
  input  wire          clk,
  input  wire          resetn
);

  reg        [31:0]   mem_spinal_port0;
  reg                 _zz_1;
  wire       [7:0]    wordAddr;
  wire                cmdFired;
  reg                 wasRead;
  reg        [3:0]    srcLatched;
  reg        [3:0]    ctxLatched;
  reg                 rspValid;
  wire                _zz_readData;
  wire       [31:0]   readData;
  wire                when_WishboneBmbBridgeVerilog_l101;
  reg [7:0] mem_symbol0 [0:255];
  reg [7:0] mem_symbol1 [0:255];
  reg [7:0] mem_symbol2 [0:255];
  reg [7:0] mem_symbol3 [0:255];
  reg [7:0] _zz_memsymbol_read;
  reg [7:0] _zz_memsymbol_read_1;
  reg [7:0] _zz_memsymbol_read_2;
  reg [7:0] _zz_memsymbol_read_3;

  always @(*) begin
    mem_spinal_port0 = {_zz_memsymbol_read_3, _zz_memsymbol_read_2, _zz_memsymbol_read_1, _zz_memsymbol_read};
  end
  always @(posedge clk) begin
    if(_zz_readData) begin
      _zz_memsymbol_read <= mem_symbol0[wordAddr];
      _zz_memsymbol_read_1 <= mem_symbol1[wordAddr];
      _zz_memsymbol_read_2 <= mem_symbol2[wordAddr];
      _zz_memsymbol_read_3 <= mem_symbol3[wordAddr];
    end
  end

  always @(posedge clk) begin
    if(io_bmb_cmd_payload_fragment_mask[0] && _zz_1) begin
      mem_symbol0[wordAddr] <= io_bmb_cmd_payload_fragment_data[7 : 0];
    end
    if(io_bmb_cmd_payload_fragment_mask[1] && _zz_1) begin
      mem_symbol1[wordAddr] <= io_bmb_cmd_payload_fragment_data[15 : 8];
    end
    if(io_bmb_cmd_payload_fragment_mask[2] && _zz_1) begin
      mem_symbol2[wordAddr] <= io_bmb_cmd_payload_fragment_data[23 : 16];
    end
    if(io_bmb_cmd_payload_fragment_mask[3] && _zz_1) begin
      mem_symbol3[wordAddr] <= io_bmb_cmd_payload_fragment_data[31 : 24];
    end
  end

  always @(*) begin
    _zz_1 = 1'b0;
    if(when_WishboneBmbBridgeVerilog_l101) begin
      _zz_1 = 1'b1;
    end
  end

  assign wordAddr = io_bmb_cmd_payload_fragment_address[9 : 2];
  assign io_bmb_cmd_ready = 1'b1;
  assign cmdFired = (io_bmb_cmd_valid && io_bmb_cmd_ready);
  assign _zz_readData = (io_bmb_cmd_valid && (! (io_bmb_cmd_payload_fragment_opcode == 1'b1)));
  assign readData = mem_spinal_port0;
  assign when_WishboneBmbBridgeVerilog_l101 = (io_bmb_cmd_valid && (io_bmb_cmd_payload_fragment_opcode == 1'b1));
  assign io_bmb_rsp_valid = rspValid;
  assign io_bmb_rsp_payload_fragment_data = readData;
  assign io_bmb_rsp_payload_last = 1'b1;
  assign io_bmb_rsp_payload_fragment_source = srcLatched;
  assign io_bmb_rsp_payload_fragment_context = ctxLatched;
  assign io_bmb_rsp_payload_fragment_opcode = 1'b0;
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      wasRead <= 1'b0;
      srcLatched <= 4'b0000;
      ctxLatched <= 4'b0000;
      rspValid <= 1'b0;
    end else begin
      if(cmdFired) begin
        wasRead <= (! (io_bmb_cmd_payload_fragment_opcode == 1'b1));
      end
      if(cmdFired) begin
        srcLatched <= io_bmb_cmd_payload_fragment_source;
      end
      if(cmdFired) begin
        ctxLatched <= io_bmb_cmd_payload_fragment_context;
      end
      rspValid <= cmdFired;
    end
  end


endmodule

module WishboneToBmbMaster (
  input  wire          io_wb_CYC,
  input  wire          io_wb_STB,
  output reg           io_wb_ACK,
  input  wire          io_wb_WE,
  input  wire [9:0]    io_wb_ADR,
  output reg  [31:0]   io_wb_DAT_MISO,
  input  wire [31:0]   io_wb_DAT_MOSI,
  output reg           io_bmb_cmd_valid,
  input  wire          io_bmb_cmd_ready,
  output wire          io_bmb_cmd_payload_last,
  output wire [3:0]    io_bmb_cmd_payload_fragment_source,
  output reg  [0:0]    io_bmb_cmd_payload_fragment_opcode,
  output wire [9:0]    io_bmb_cmd_payload_fragment_address,
  output wire [5:0]    io_bmb_cmd_payload_fragment_length,
  output wire [31:0]   io_bmb_cmd_payload_fragment_data,
  output wire [3:0]    io_bmb_cmd_payload_fragment_mask,
  output wire [3:0]    io_bmb_cmd_payload_fragment_context,
  input  wire          io_bmb_rsp_valid,
  output wire          io_bmb_rsp_ready,
  input  wire          io_bmb_rsp_payload_last,
  input  wire [3:0]    io_bmb_rsp_payload_fragment_source,
  input  wire [0:0]    io_bmb_rsp_payload_fragment_opcode,
  input  wire [31:0]   io_bmb_rsp_payload_fragment_data,
  input  wire [3:0]    io_bmb_rsp_payload_fragment_context,
  input  wire          clk,
  input  wire          resetn
);

  wire       [11:0]   _zz_io_bmb_cmd_payload_fragment_address;
  reg        [1:0]    state;
  wire       [1:0]    IDLE;
  wire       [1:0]    ISSUE;
  wire       [1:0]    WAIT_RSP;
  reg                 writeLatched;
  wire                when_WishboneBmbBridgeVerilog_l58;

  assign _zz_io_bmb_cmd_payload_fragment_address = ({2'd0,io_wb_ADR} <<< 2'd2);
  assign IDLE = 2'b00;
  assign ISSUE = 2'b01;
  assign WAIT_RSP = 2'b10;
  always @(*) begin
    io_wb_ACK = 1'b0;
    if((state == IDLE)) begin
    end else if((state == ISSUE)) begin
    end else if((state == WAIT_RSP)) begin
        if(io_bmb_rsp_valid) begin
          io_wb_ACK = 1'b1;
        end
    end
  end

  always @(*) begin
    io_wb_DAT_MISO = 32'h0;
    if((state == IDLE)) begin
    end else if((state == ISSUE)) begin
    end else if((state == WAIT_RSP)) begin
        if(io_bmb_rsp_valid) begin
          io_wb_DAT_MISO = io_bmb_rsp_payload_fragment_data;
        end
    end
  end

  always @(*) begin
    io_bmb_cmd_valid = 1'b0;
    if((state == IDLE)) begin
    end else if((state == ISSUE)) begin
        io_bmb_cmd_valid = 1'b1;
    end else if((state == WAIT_RSP)) begin
    end
  end

  assign io_bmb_cmd_payload_fragment_source = 4'b0000;
  assign io_bmb_cmd_payload_fragment_context = 4'b0000;
  assign io_bmb_cmd_payload_fragment_address = _zz_io_bmb_cmd_payload_fragment_address[9:0];
  assign io_bmb_cmd_payload_fragment_length = 6'h03;
  assign io_bmb_cmd_payload_fragment_data = io_wb_DAT_MOSI;
  assign io_bmb_cmd_payload_fragment_mask = 4'b1111;
  assign io_bmb_cmd_payload_last = 1'b1;
  always @(*) begin
    io_bmb_cmd_payload_fragment_opcode = 1'b0;
    if((state == IDLE)) begin
    end else if((state == ISSUE)) begin
        io_bmb_cmd_payload_fragment_opcode = writeLatched;
    end else if((state == WAIT_RSP)) begin
    end
  end

  assign io_bmb_rsp_ready = 1'b1;
  assign when_WishboneBmbBridgeVerilog_l58 = (io_wb_CYC && io_wb_STB);
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      state <= 2'b00;
      writeLatched <= 1'b0;
    end else begin
      if((state == IDLE)) begin
          if(when_WishboneBmbBridgeVerilog_l58) begin
            writeLatched <= io_wb_WE;
            state <= ISSUE;
          end
      end else if((state == ISSUE)) begin
          if(io_bmb_cmd_ready) begin
            state <= WAIT_RSP;
          end
      end else if((state == WAIT_RSP)) begin
          if(io_bmb_rsp_valid) begin
            state <= IDLE;
          end
      end
    end
  end


endmodule
