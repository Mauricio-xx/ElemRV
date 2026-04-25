// Generator : SpinalHDL v1.13.0    git head : d9d72474863badf47d8585d187f3e04ae4749c59
// Component : WishboneBmbSpiXipController
// Git hash  : c46981392eb50d83a12c687a69933cc658cd2128

`timescale 1ns/1ps

module WishboneBmbSpiXipController (
  input  wire          io_wb_CYC,
  input  wire          io_wb_STB,
  output wire          io_wb_ACK,
  input  wire          io_wb_WE,
  input  wire [13:0]   io_wb_ADR,
  output wire [31:0]   io_wb_DAT_MISO,
  input  wire [31:0]   io_wb_DAT_MOSI,
  output wire [0:0]    io_spi_cs,
  output wire          io_spi_sclk,
  input  wire [3:0]    io_spi_dq_read,
  output wire [3:0]    io_spi_dq_write,
  output wire [3:0]    io_spi_dq_writeEnable,
  output wire          io_interrupt,
  input  wire          clk,
  input  wire          resetn
);

  wire                ctrl_io_dataBus_cmd_ready;
  wire                ctrl_io_dataBus_rsp_valid;
  wire                ctrl_io_dataBus_rsp_payload_last;
  wire       [3:0]    ctrl_io_dataBus_rsp_payload_fragment_source;
  wire       [0:0]    ctrl_io_dataBus_rsp_payload_fragment_opcode;
  wire       [31:0]   ctrl_io_dataBus_rsp_payload_fragment_data;
  wire       [3:0]    ctrl_io_dataBus_rsp_payload_fragment_context;
  wire       [31:0]   ctrl_io_cfgSpiBus_DAT_MISO;
  wire                ctrl_io_cfgSpiBus_ACK;
  wire       [31:0]   ctrl_io_cfgXipBus_DAT_MISO;
  wire                ctrl_io_cfgXipBus_ACK;
  wire       [0:0]    ctrl_io_spi_cs;
  wire                ctrl_io_spi_sclk;
  wire       [3:0]    ctrl_io_spi_dq_write;
  wire       [3:0]    ctrl_io_spi_dq_writeEnable;
  wire                ctrl_io_interrupt;
  wire       [31:0]   dataBridge_io_wb_DAT_MISO;
  wire                dataBridge_io_wb_ACK;
  wire                dataBridge_io_bmb_cmd_valid;
  wire                dataBridge_io_bmb_cmd_payload_last;
  wire       [3:0]    dataBridge_io_bmb_cmd_payload_fragment_source;
  wire       [0:0]    dataBridge_io_bmb_cmd_payload_fragment_opcode;
  wire       [11:0]   dataBridge_io_bmb_cmd_payload_fragment_address;
  wire       [5:0]    dataBridge_io_bmb_cmd_payload_fragment_length;
  wire       [31:0]   dataBridge_io_bmb_cmd_payload_fragment_data;
  wire       [3:0]    dataBridge_io_bmb_cmd_payload_fragment_mask;
  wire       [3:0]    dataBridge_io_bmb_cmd_payload_fragment_context;
  wire                dataBridge_io_bmb_rsp_ready;
  reg                 cfgSpiWb_CYC;
  reg                 cfgSpiWb_STB;
  wire                cfgSpiWb_ACK;
  wire                cfgSpiWb_WE;
  wire       [9:0]    cfgSpiWb_ADR;
  wire       [31:0]   cfgSpiWb_DAT_MISO;
  wire       [31:0]   cfgSpiWb_DAT_MOSI;
  reg                 cfgXipWb_CYC;
  reg                 cfgXipWb_STB;
  wire                cfgXipWb_ACK;
  wire                cfgXipWb_WE;
  wire       [9:0]    cfgXipWb_ADR;
  wire       [31:0]   cfgXipWb_DAT_MISO;
  wire       [31:0]   cfgXipWb_DAT_MOSI;
  reg                 dataWb_CYC;
  reg                 dataWb_STB;
  wire                dataWb_ACK;
  wire                dataWb_WE;
  wire       [9:0]    dataWb_ADR;
  wire       [31:0]   dataWb_DAT_MISO;
  wire       [31:0]   dataWb_DAT_MOSI;
  wire       [1:0]    bank;
  wire                active;
  wire                when_WishboneBmbSpiXipControllerVerilog_l70;
  wire                when_WishboneBmbSpiXipControllerVerilog_l71;
  wire                when_WishboneBmbSpiXipControllerVerilog_l72;

  BmbSpiXipController ctrl (
    .io_dataBus_cmd_valid                    (dataBridge_io_bmb_cmd_valid                         ), //i
    .io_dataBus_cmd_ready                    (ctrl_io_dataBus_cmd_ready                           ), //o
    .io_dataBus_cmd_payload_last             (dataBridge_io_bmb_cmd_payload_last                  ), //i
    .io_dataBus_cmd_payload_fragment_source  (dataBridge_io_bmb_cmd_payload_fragment_source[3:0]  ), //i
    .io_dataBus_cmd_payload_fragment_opcode  (dataBridge_io_bmb_cmd_payload_fragment_opcode       ), //i
    .io_dataBus_cmd_payload_fragment_address (dataBridge_io_bmb_cmd_payload_fragment_address[11:0]), //i
    .io_dataBus_cmd_payload_fragment_length  (dataBridge_io_bmb_cmd_payload_fragment_length[5:0]  ), //i
    .io_dataBus_cmd_payload_fragment_data    (dataBridge_io_bmb_cmd_payload_fragment_data[31:0]   ), //i
    .io_dataBus_cmd_payload_fragment_mask    (dataBridge_io_bmb_cmd_payload_fragment_mask[3:0]    ), //i
    .io_dataBus_cmd_payload_fragment_context (dataBridge_io_bmb_cmd_payload_fragment_context[3:0] ), //i
    .io_dataBus_rsp_valid                    (ctrl_io_dataBus_rsp_valid                           ), //o
    .io_dataBus_rsp_ready                    (dataBridge_io_bmb_rsp_ready                         ), //i
    .io_dataBus_rsp_payload_last             (ctrl_io_dataBus_rsp_payload_last                    ), //o
    .io_dataBus_rsp_payload_fragment_source  (ctrl_io_dataBus_rsp_payload_fragment_source[3:0]    ), //o
    .io_dataBus_rsp_payload_fragment_opcode  (ctrl_io_dataBus_rsp_payload_fragment_opcode         ), //o
    .io_dataBus_rsp_payload_fragment_data    (ctrl_io_dataBus_rsp_payload_fragment_data[31:0]     ), //o
    .io_dataBus_rsp_payload_fragment_context (ctrl_io_dataBus_rsp_payload_fragment_context[3:0]   ), //o
    .io_cfgSpiBus_CYC                        (cfgSpiWb_CYC                                        ), //i
    .io_cfgSpiBus_STB                        (cfgSpiWb_STB                                        ), //i
    .io_cfgSpiBus_ACK                        (ctrl_io_cfgSpiBus_ACK                               ), //o
    .io_cfgSpiBus_WE                         (cfgSpiWb_WE                                         ), //i
    .io_cfgSpiBus_ADR                        (cfgSpiWb_ADR[9:0]                                   ), //i
    .io_cfgSpiBus_DAT_MISO                   (ctrl_io_cfgSpiBus_DAT_MISO[31:0]                    ), //o
    .io_cfgSpiBus_DAT_MOSI                   (cfgSpiWb_DAT_MOSI[31:0]                             ), //i
    .io_cfgXipBus_CYC                        (cfgXipWb_CYC                                        ), //i
    .io_cfgXipBus_STB                        (cfgXipWb_STB                                        ), //i
    .io_cfgXipBus_ACK                        (ctrl_io_cfgXipBus_ACK                               ), //o
    .io_cfgXipBus_WE                         (cfgXipWb_WE                                         ), //i
    .io_cfgXipBus_ADR                        (cfgXipWb_ADR[9:0]                                   ), //i
    .io_cfgXipBus_DAT_MISO                   (ctrl_io_cfgXipBus_DAT_MISO[31:0]                    ), //o
    .io_cfgXipBus_DAT_MOSI                   (cfgXipWb_DAT_MOSI[31:0]                             ), //i
    .io_spi_cs                               (ctrl_io_spi_cs                                      ), //o
    .io_spi_sclk                             (ctrl_io_spi_sclk                                    ), //o
    .io_spi_dq_read                          (io_spi_dq_read[3:0]                                 ), //i
    .io_spi_dq_write                         (ctrl_io_spi_dq_write[3:0]                           ), //o
    .io_spi_dq_writeEnable                   (ctrl_io_spi_dq_writeEnable[3:0]                     ), //o
    .io_interrupt                            (ctrl_io_interrupt                                   ), //o
    .clk                                     (clk                                                 ), //i
    .resetn                                  (resetn                                              )  //i
  );
  WishboneToBmbMaster dataBridge (
    .io_wb_CYC                           (dataWb_CYC                                          ), //i
    .io_wb_STB                           (dataWb_STB                                          ), //i
    .io_wb_ACK                           (dataBridge_io_wb_ACK                                ), //o
    .io_wb_WE                            (dataWb_WE                                           ), //i
    .io_wb_ADR                           (dataWb_ADR[9:0]                                     ), //i
    .io_wb_DAT_MISO                      (dataBridge_io_wb_DAT_MISO[31:0]                     ), //o
    .io_wb_DAT_MOSI                      (dataWb_DAT_MOSI[31:0]                               ), //i
    .io_bmb_cmd_valid                    (dataBridge_io_bmb_cmd_valid                         ), //o
    .io_bmb_cmd_ready                    (ctrl_io_dataBus_cmd_ready                           ), //i
    .io_bmb_cmd_payload_last             (dataBridge_io_bmb_cmd_payload_last                  ), //o
    .io_bmb_cmd_payload_fragment_source  (dataBridge_io_bmb_cmd_payload_fragment_source[3:0]  ), //o
    .io_bmb_cmd_payload_fragment_opcode  (dataBridge_io_bmb_cmd_payload_fragment_opcode       ), //o
    .io_bmb_cmd_payload_fragment_address (dataBridge_io_bmb_cmd_payload_fragment_address[11:0]), //o
    .io_bmb_cmd_payload_fragment_length  (dataBridge_io_bmb_cmd_payload_fragment_length[5:0]  ), //o
    .io_bmb_cmd_payload_fragment_data    (dataBridge_io_bmb_cmd_payload_fragment_data[31:0]   ), //o
    .io_bmb_cmd_payload_fragment_mask    (dataBridge_io_bmb_cmd_payload_fragment_mask[3:0]    ), //o
    .io_bmb_cmd_payload_fragment_context (dataBridge_io_bmb_cmd_payload_fragment_context[3:0] ), //o
    .io_bmb_rsp_valid                    (ctrl_io_dataBus_rsp_valid                           ), //i
    .io_bmb_rsp_ready                    (dataBridge_io_bmb_rsp_ready                         ), //o
    .io_bmb_rsp_payload_last             (ctrl_io_dataBus_rsp_payload_last                    ), //i
    .io_bmb_rsp_payload_fragment_source  (ctrl_io_dataBus_rsp_payload_fragment_source[3:0]    ), //i
    .io_bmb_rsp_payload_fragment_opcode  (ctrl_io_dataBus_rsp_payload_fragment_opcode         ), //i
    .io_bmb_rsp_payload_fragment_data    (ctrl_io_dataBus_rsp_payload_fragment_data[31:0]     ), //i
    .io_bmb_rsp_payload_fragment_context (ctrl_io_dataBus_rsp_payload_fragment_context[3:0]   ), //i
    .clk                                 (clk                                                 ), //i
    .resetn                              (resetn                                              )  //i
  );
  always @(*) begin
    cfgSpiWb_CYC = 1'b0;
    if(when_WishboneBmbSpiXipControllerVerilog_l70) begin
      cfgSpiWb_CYC = 1'b1;
    end
  end

  always @(*) begin
    cfgSpiWb_STB = 1'b0;
    if(when_WishboneBmbSpiXipControllerVerilog_l70) begin
      cfgSpiWb_STB = 1'b1;
    end
  end

  assign cfgSpiWb_WE = io_wb_WE;
  assign cfgSpiWb_ADR = io_wb_ADR[9:0];
  assign cfgSpiWb_DAT_MOSI = io_wb_DAT_MOSI;
  always @(*) begin
    cfgXipWb_CYC = 1'b0;
    if(when_WishboneBmbSpiXipControllerVerilog_l71) begin
      cfgXipWb_CYC = 1'b1;
    end
  end

  always @(*) begin
    cfgXipWb_STB = 1'b0;
    if(when_WishboneBmbSpiXipControllerVerilog_l71) begin
      cfgXipWb_STB = 1'b1;
    end
  end

  assign cfgXipWb_WE = io_wb_WE;
  assign cfgXipWb_ADR = io_wb_ADR[9:0];
  assign cfgXipWb_DAT_MOSI = io_wb_DAT_MOSI;
  always @(*) begin
    dataWb_CYC = 1'b0;
    if(when_WishboneBmbSpiXipControllerVerilog_l72) begin
      dataWb_CYC = 1'b1;
    end
  end

  always @(*) begin
    dataWb_STB = 1'b0;
    if(when_WishboneBmbSpiXipControllerVerilog_l72) begin
      dataWb_STB = 1'b1;
    end
  end

  assign dataWb_WE = io_wb_WE;
  assign dataWb_ADR = io_wb_ADR[9:0];
  assign dataWb_DAT_MOSI = io_wb_DAT_MOSI;
  assign bank = io_wb_ADR[11 : 10];
  assign active = (io_wb_CYC && io_wb_STB);
  assign when_WishboneBmbSpiXipControllerVerilog_l70 = (active && (bank == 2'b00));
  assign when_WishboneBmbSpiXipControllerVerilog_l71 = (active && (bank == 2'b01));
  assign when_WishboneBmbSpiXipControllerVerilog_l72 = (active && (bank == 2'b10));
  assign io_wb_ACK = ((cfgSpiWb_ACK || cfgXipWb_ACK) || dataWb_ACK);
  assign io_wb_DAT_MISO = (cfgSpiWb_ACK ? cfgSpiWb_DAT_MISO : (cfgXipWb_ACK ? cfgXipWb_DAT_MISO : dataWb_DAT_MISO));
  assign cfgSpiWb_ACK = ctrl_io_cfgSpiBus_ACK;
  assign cfgSpiWb_DAT_MISO = ctrl_io_cfgSpiBus_DAT_MISO;
  assign cfgXipWb_ACK = ctrl_io_cfgXipBus_ACK;
  assign cfgXipWb_DAT_MISO = ctrl_io_cfgXipBus_DAT_MISO;
  assign io_spi_cs = ctrl_io_spi_cs;
  assign io_spi_sclk = ctrl_io_spi_sclk;
  assign io_spi_dq_write = ctrl_io_spi_dq_write;
  assign io_spi_dq_writeEnable = ctrl_io_spi_dq_writeEnable;
  assign io_interrupt = ctrl_io_interrupt;
  assign dataWb_ACK = dataBridge_io_wb_ACK;
  assign dataWb_DAT_MISO = dataBridge_io_wb_DAT_MISO;

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
  output wire [11:0]   io_bmb_cmd_payload_fragment_address,
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

  reg        [1:0]    state_2;
  wire       [1:0]    IDLE;
  wire       [1:0]    ISSUE;
  wire       [1:0]    WAIT_RSP;
  reg                 writeLatched;
  wire                when_WishboneBmbBridgeVerilog_l59;

  assign IDLE = 2'b00;
  assign ISSUE = 2'b01;
  assign WAIT_RSP = 2'b10;
  always @(*) begin
    io_wb_ACK = 1'b0;
    if((state_2 == IDLE)) begin
    end else if((state_2 == ISSUE)) begin
    end else if((state_2 == WAIT_RSP)) begin
        if(io_bmb_rsp_valid) begin
          io_wb_ACK = 1'b1;
        end
    end
  end

  always @(*) begin
    io_wb_DAT_MISO = 32'h0;
    if((state_2 == IDLE)) begin
    end else if((state_2 == ISSUE)) begin
    end else if((state_2 == WAIT_RSP)) begin
        if(io_bmb_rsp_valid) begin
          io_wb_DAT_MISO = io_bmb_rsp_payload_fragment_data;
        end
    end
  end

  always @(*) begin
    io_bmb_cmd_valid = 1'b0;
    if((state_2 == IDLE)) begin
    end else if((state_2 == ISSUE)) begin
        io_bmb_cmd_valid = 1'b1;
    end else if((state_2 == WAIT_RSP)) begin
    end
  end

  assign io_bmb_cmd_payload_fragment_source = 4'b0000;
  assign io_bmb_cmd_payload_fragment_context = 4'b0000;
  assign io_bmb_cmd_payload_fragment_address = ({2'd0,io_wb_ADR} <<< 2'd2);
  assign io_bmb_cmd_payload_fragment_length = 6'h03;
  assign io_bmb_cmd_payload_fragment_data = io_wb_DAT_MOSI;
  assign io_bmb_cmd_payload_fragment_mask = 4'b1111;
  assign io_bmb_cmd_payload_last = 1'b1;
  always @(*) begin
    io_bmb_cmd_payload_fragment_opcode = 1'b0;
    if((state_2 == IDLE)) begin
    end else if((state_2 == ISSUE)) begin
        io_bmb_cmd_payload_fragment_opcode = writeLatched;
    end else if((state_2 == WAIT_RSP)) begin
    end
  end

  assign io_bmb_rsp_ready = 1'b1;
  assign when_WishboneBmbBridgeVerilog_l59 = (io_wb_CYC && io_wb_STB);
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      state_2 <= 2'b00;
      writeLatched <= 1'b0;
    end else begin
      if((state_2 == IDLE)) begin
          if(when_WishboneBmbBridgeVerilog_l59) begin
            writeLatched <= io_wb_WE;
            state_2 <= ISSUE;
          end
      end else if((state_2 == ISSUE)) begin
          if(io_bmb_cmd_ready) begin
            state_2 <= WAIT_RSP;
          end
      end else if((state_2 == WAIT_RSP)) begin
          if(io_bmb_rsp_valid) begin
            state_2 <= IDLE;
          end
      end
    end
  end


endmodule

module BmbSpiXipController (
  input  wire          io_dataBus_cmd_valid,
  output reg           io_dataBus_cmd_ready,
  input  wire          io_dataBus_cmd_payload_last,
  input  wire [3:0]    io_dataBus_cmd_payload_fragment_source,
  input  wire [0:0]    io_dataBus_cmd_payload_fragment_opcode,
  input  wire [11:0]   io_dataBus_cmd_payload_fragment_address,
  input  wire [5:0]    io_dataBus_cmd_payload_fragment_length,
  input  wire [31:0]   io_dataBus_cmd_payload_fragment_data,
  input  wire [3:0]    io_dataBus_cmd_payload_fragment_mask,
  input  wire [3:0]    io_dataBus_cmd_payload_fragment_context,
  output reg           io_dataBus_rsp_valid,
  input  wire          io_dataBus_rsp_ready,
  output wire          io_dataBus_rsp_payload_last,
  output wire [3:0]    io_dataBus_rsp_payload_fragment_source,
  output reg  [0:0]    io_dataBus_rsp_payload_fragment_opcode,
  output wire [31:0]   io_dataBus_rsp_payload_fragment_data,
  output wire [3:0]    io_dataBus_rsp_payload_fragment_context,
  input  wire          io_cfgSpiBus_CYC,
  input  wire          io_cfgSpiBus_STB,
  output wire          io_cfgSpiBus_ACK,
  input  wire          io_cfgSpiBus_WE,
  input  wire [9:0]    io_cfgSpiBus_ADR,
  output reg  [31:0]   io_cfgSpiBus_DAT_MISO,
  input  wire [31:0]   io_cfgSpiBus_DAT_MOSI,
  input  wire          io_cfgXipBus_CYC,
  input  wire          io_cfgXipBus_STB,
  output wire          io_cfgXipBus_ACK,
  input  wire          io_cfgXipBus_WE,
  input  wire [9:0]    io_cfgXipBus_ADR,
  output reg  [31:0]   io_cfgXipBus_DAT_MISO,
  input  wire [31:0]   io_cfgXipBus_DAT_MOSI,
  output wire [0:0]    io_spi_cs,
  output wire          io_spi_sclk,
  input  wire [3:0]    io_spi_dq_read,
  output wire [3:0]    io_spi_dq_write,
  output wire [3:0]    io_spi_dq_writeEnable,
  output wire          io_interrupt,
  input  wire          clk,
  input  wire          resetn
);
  localparam RspState_IDLE = 2'd0;
  localparam RspState_ERROR = 2'd1;
  localparam RspState_CMD = 2'd2;
  localparam RspState_RESPONSE = 2'd3;
  localparam SpiBusWidth_Single = 2'd0;
  localparam SpiBusWidth_Dual = 2'd1;
  localparam SpiBusWidth_Quad = 2'd2;
  localparam SpiBusWidth_Octa = 2'd3;
  localparam CmdMode_DATA = 2'd0;
  localparam CmdMode_CS = 2'd1;
  localparam CmdMode_DUMMYCYCLES = 2'd2;

  reg                 spiXipControllerCtrl_1_io_config_configure;
  reg                 spiXipControllerCtrl_1_io_busCmd_valid;
  reg                 spiXipControllerCtrl_1_io_busRsp_ready;
  wire       [0:0]    spiControllerCtrl_1_io_spi_cs;
  wire                spiControllerCtrl_1_io_spi_sclk;
  wire       [3:0]    spiControllerCtrl_1_io_spi_dq_write;
  wire       [3:0]    spiControllerCtrl_1_io_spi_dq_writeEnable;
  wire                spiControllerCtrl_1_io_interrupt;
  wire                spiControllerCtrl_1_io_cmd_ready;
  wire                spiControllerCtrl_1_io_rsp_valid;
  wire       [7:0]    spiControllerCtrl_1_io_rsp_payload;
  wire                spiXipControllerCtrl_1_io_busCmd_ready;
  wire                spiXipControllerCtrl_1_io_busRsp_valid;
  wire       [31:0]   spiXipControllerCtrl_1_io_busRsp_payload_data;
  wire                spiXipControllerCtrl_1_io_busRsp_payload_last;
  wire                spiXipControllerCtrl_1_io_cmd_valid;
  wire       [1:0]    spiXipControllerCtrl_1_io_cmd_payload_mode;
  wire       [12:0]   spiXipControllerCtrl_1_io_cmd_payload_args;
  wire       [31:0]   ipIdentificationCtrl_2_io_header;
  wire       [31:0]   ipIdentificationCtrl_2_io_version;
  wire       [31:0]   ipIdentificationCtrl_3_io_header;
  wire       [31:0]   ipIdentificationCtrl_3_io_version;
  wire       [3:0]    _zz__zz_spiCmd_count;
  wire       [5:0]    _zz__zz_spiCmd_count_1;
  wire       [23:0]   spiCmd_addr;
  wire       [7:0]    spiCmd_count;
  reg        [23:0]   _zz_spiCmd_addr;
  reg        [7:0]    _zz_spiCmd_count;
  reg        [3:0]    io_dataBus_cmd_payload_fragment_source_regNextWhen;
  reg        [3:0]    io_dataBus_cmd_payload_fragment_context_regNextWhen;
  reg        [1:0]    stateMachine_state;
  wire                when_BmbSpiXipController_l89;
  wire                when_BmbSpiXipController_l93;
  wire                spiXipControllerCtrl_1_io_busCmd_fire;
  wire                io_dataBus_rsp_fire;
  wire                cfgSpiBusFactory_readErrorFlag;
  wire                cfgSpiBusFactory_writeErrorFlag;
  wire                cfgSpiBusFactory_askWrite;
  wire                cfgSpiBusFactory_askRead;
  wire                cfgSpiBusFactory_doWrite;
  wire                cfgSpiBusFactory_doRead;
  reg                 _zz_io_cfgSpiBus_ACK;
  wire       [11:0]   cfgSpiBusFactory_byteAddress;
  reg        [15:0]   _zz_io_cfgSpiBus_DAT_MISO;
  reg        [0:0]    _zz_io_cfgSpiBus_DAT_MISO_1;
  reg        [15:0]   _zz_io_cfgSpiBus_DAT_MISO_2;
  reg        [15:0]   _zz_io_cfgSpiBus_DAT_MISO_3;
  reg        [15:0]   _zz_io_cfgSpiBus_DAT_MISO_4;
  reg                 _zz_io_cfgSpiBus_DAT_MISO_5;
  reg                 _zz_io_cfgSpiBus_DAT_MISO_6;
  wire       [1:0]    _zz_io_modeConfig_busWidth;
  wire                cfgXipBusFactory_readErrorFlag;
  wire                cfgXipBusFactory_writeErrorFlag;
  wire                cfgXipBusFactory_askWrite;
  wire                cfgXipBusFactory_askRead;
  wire                cfgXipBusFactory_doWrite;
  wire                cfgXipBusFactory_doRead;
  reg                 _zz_io_cfgXipBus_ACK;
  wire       [11:0]   cfgXipBusFactory_byteAddress;
  reg        [3:0]    _zz_io_cfgXipBus_DAT_MISO;
  reg        [4:0]    _zz_io_cfgXipBus_DAT_MISO_1;
  reg        [7:0]    spiXipControllerCtrl_1_io_config_evcr_driver;
  `ifndef SYNTHESIS
  reg [63:0] stateMachine_state_string;
  reg [47:0] _zz_io_modeConfig_busWidth_string;
  `endif


  assign _zz__zz_spiCmd_count = (_zz__zz_spiCmd_count_1 >>> 2'd2);
  assign _zz__zz_spiCmd_count_1 = (io_dataBus_cmd_payload_fragment_length - 6'h03);
  SpiControllerCtrl spiControllerCtrl_1 (
    .io_config_clockDivider  (_zz_io_cfgSpiBus_DAT_MISO[15:0]                 ), //i
    .io_config_cs_activeHigh (_zz_io_cfgSpiBus_DAT_MISO_1                     ), //i
    .io_config_cs_setup      (_zz_io_cfgSpiBus_DAT_MISO_2[15:0]               ), //i
    .io_config_cs_hold       (_zz_io_cfgSpiBus_DAT_MISO_3[15:0]               ), //i
    .io_config_cs_disable    (_zz_io_cfgSpiBus_DAT_MISO_4[15:0]               ), //i
    .io_modeConfig_cpol      (_zz_io_cfgSpiBus_DAT_MISO_5                     ), //i
    .io_modeConfig_cpha      (_zz_io_cfgSpiBus_DAT_MISO_6                     ), //i
    .io_modeConfig_busWidth  (_zz_io_modeConfig_busWidth[1:0]                 ), //i
    .io_spi_cs               (spiControllerCtrl_1_io_spi_cs                   ), //o
    .io_spi_sclk             (spiControllerCtrl_1_io_spi_sclk                 ), //o
    .io_spi_dq_read          (io_spi_dq_read[3:0]                             ), //i
    .io_spi_dq_write         (spiControllerCtrl_1_io_spi_dq_write[3:0]        ), //o
    .io_spi_dq_writeEnable   (spiControllerCtrl_1_io_spi_dq_writeEnable[3:0]  ), //o
    .io_interrupt            (spiControllerCtrl_1_io_interrupt                ), //o
    .io_pendingInterrupts    (                                                ), //i
    .io_cmd_valid            (spiXipControllerCtrl_1_io_cmd_valid             ), //i
    .io_cmd_ready            (spiControllerCtrl_1_io_cmd_ready                ), //o
    .io_cmd_payload_mode     (spiXipControllerCtrl_1_io_cmd_payload_mode[1:0] ), //i
    .io_cmd_payload_args     (spiXipControllerCtrl_1_io_cmd_payload_args[12:0]), //i
    .io_rsp_valid            (spiControllerCtrl_1_io_rsp_valid                ), //o
    .io_rsp_payload          (spiControllerCtrl_1_io_rsp_payload[7:0]         ), //o
    .clk                     (clk                                             ), //i
    .resetn                  (resetn                                          )  //i
  );
  SpiXipControllerCtrl spiXipControllerCtrl_1 (
    .io_config_mode          (_zz_io_cfgXipBus_DAT_MISO[3:0]                     ), //i
    .io_config_dummyCycles   (_zz_io_cfgXipBus_DAT_MISO_1[4:0]                   ), //i
    .io_config_evcr          (spiXipControllerCtrl_1_io_config_evcr_driver[7:0]  ), //i
    .io_config_configure     (spiXipControllerCtrl_1_io_config_configure         ), //i
    .io_busCmd_valid         (spiXipControllerCtrl_1_io_busCmd_valid             ), //i
    .io_busCmd_ready         (spiXipControllerCtrl_1_io_busCmd_ready             ), //o
    .io_busCmd_payload_addr  (spiCmd_addr[23:0]                                  ), //i
    .io_busCmd_payload_count (spiCmd_count[7:0]                                  ), //i
    .io_busRsp_valid         (spiXipControllerCtrl_1_io_busRsp_valid             ), //o
    .io_busRsp_ready         (spiXipControllerCtrl_1_io_busRsp_ready             ), //i
    .io_busRsp_payload_data  (spiXipControllerCtrl_1_io_busRsp_payload_data[31:0]), //o
    .io_busRsp_payload_last  (spiXipControllerCtrl_1_io_busRsp_payload_last      ), //o
    .io_cmd_valid            (spiXipControllerCtrl_1_io_cmd_valid                ), //o
    .io_cmd_ready            (spiControllerCtrl_1_io_cmd_ready                   ), //i
    .io_cmd_payload_mode     (spiXipControllerCtrl_1_io_cmd_payload_mode[1:0]    ), //o
    .io_cmd_payload_args     (spiXipControllerCtrl_1_io_cmd_payload_args[12:0]   ), //o
    .io_rsp_valid            (spiControllerCtrl_1_io_rsp_valid                   ), //i
    .io_rsp_payload          (spiControllerCtrl_1_io_rsp_payload[7:0]            ), //i
    .clk                     (clk                                                ), //i
    .resetn                  (resetn                                             )  //i
  );
  IpIdentificationCtrl ipIdentificationCtrl_2 (
    .io_header  (ipIdentificationCtrl_2_io_header[31:0] ), //o
    .io_version (ipIdentificationCtrl_2_io_version[31:0]), //o
    .clk        (clk                                    ), //i
    .resetn     (resetn                                 )  //i
  );
  IpIdentificationCtrl_1 ipIdentificationCtrl_3 (
    .io_header  (ipIdentificationCtrl_3_io_header[31:0] ), //o
    .io_version (ipIdentificationCtrl_3_io_version[31:0]), //o
    .clk        (clk                                    ), //i
    .resetn     (resetn                                 )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(stateMachine_state)
      RspState_IDLE : stateMachine_state_string = "IDLE    ";
      RspState_ERROR : stateMachine_state_string = "ERROR   ";
      RspState_CMD : stateMachine_state_string = "CMD     ";
      RspState_RESPONSE : stateMachine_state_string = "RESPONSE";
      default : stateMachine_state_string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_io_modeConfig_busWidth)
      SpiBusWidth_Single : _zz_io_modeConfig_busWidth_string = "Single";
      SpiBusWidth_Dual : _zz_io_modeConfig_busWidth_string = "Dual  ";
      SpiBusWidth_Quad : _zz_io_modeConfig_busWidth_string = "Quad  ";
      SpiBusWidth_Octa : _zz_io_modeConfig_busWidth_string = "Octa  ";
      default : _zz_io_modeConfig_busWidth_string = "??????";
    endcase
  end
  `endif

  assign io_spi_cs = spiControllerCtrl_1_io_spi_cs;
  assign io_spi_sclk = spiControllerCtrl_1_io_spi_sclk;
  assign io_spi_dq_write = spiControllerCtrl_1_io_spi_dq_write;
  assign io_spi_dq_writeEnable = spiControllerCtrl_1_io_spi_dq_writeEnable;
  assign io_interrupt = 1'b0;
  always @(*) begin
    spiXipControllerCtrl_1_io_busRsp_ready = 1'b0;
    case(stateMachine_state)
      RspState_IDLE : begin
      end
      RspState_ERROR : begin
      end
      RspState_CMD : begin
      end
      default : begin
        if(spiXipControllerCtrl_1_io_busRsp_valid) begin
          if(io_dataBus_rsp_fire) begin
            spiXipControllerCtrl_1_io_busRsp_ready = 1'b1;
          end
        end
      end
    endcase
  end

  assign spiCmd_addr = _zz_spiCmd_addr;
  assign spiCmd_count = _zz_spiCmd_count;
  always @(*) begin
    spiXipControllerCtrl_1_io_busCmd_valid = 1'b0;
    case(stateMachine_state)
      RspState_IDLE : begin
      end
      RspState_ERROR : begin
      end
      RspState_CMD : begin
        spiXipControllerCtrl_1_io_busCmd_valid = 1'b1;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_dataBus_rsp_valid = 1'b0;
    case(stateMachine_state)
      RspState_IDLE : begin
      end
      RspState_ERROR : begin
        io_dataBus_rsp_valid = 1'b1;
      end
      RspState_CMD : begin
      end
      default : begin
        if(spiXipControllerCtrl_1_io_busRsp_valid) begin
          io_dataBus_rsp_valid = 1'b1;
        end
      end
    endcase
  end

  always @(*) begin
    io_dataBus_cmd_ready = 1'b0;
    case(stateMachine_state)
      RspState_IDLE : begin
        if(when_BmbSpiXipController_l89) begin
          io_dataBus_cmd_ready = 1'b1;
        end
        if(when_BmbSpiXipController_l93) begin
          io_dataBus_cmd_ready = 1'b1;
        end
      end
      RspState_ERROR : begin
      end
      RspState_CMD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_dataBus_rsp_payload_fragment_opcode = 1'b1;
    case(stateMachine_state)
      RspState_IDLE : begin
      end
      RspState_ERROR : begin
      end
      RspState_CMD : begin
      end
      default : begin
        if(spiXipControllerCtrl_1_io_busRsp_valid) begin
          io_dataBus_rsp_payload_fragment_opcode = 1'b0;
        end
      end
    endcase
  end

  assign io_dataBus_rsp_payload_fragment_data = spiXipControllerCtrl_1_io_busRsp_payload_data;
  assign io_dataBus_rsp_payload_last = spiXipControllerCtrl_1_io_busRsp_payload_last;
  assign io_dataBus_rsp_payload_fragment_source = io_dataBus_cmd_payload_fragment_source_regNextWhen;
  assign io_dataBus_rsp_payload_fragment_context = io_dataBus_cmd_payload_fragment_context_regNextWhen;
  assign when_BmbSpiXipController_l89 = (io_dataBus_cmd_valid && (io_dataBus_cmd_payload_fragment_opcode == 1'b1));
  assign when_BmbSpiXipController_l93 = (io_dataBus_cmd_valid && (io_dataBus_cmd_payload_fragment_opcode == 1'b0));
  assign spiXipControllerCtrl_1_io_busCmd_fire = (spiXipControllerCtrl_1_io_busCmd_valid && spiXipControllerCtrl_1_io_busCmd_ready);
  assign io_dataBus_rsp_fire = (io_dataBus_rsp_valid && io_dataBus_rsp_ready);
  assign cfgSpiBusFactory_readErrorFlag = 1'b0;
  assign cfgSpiBusFactory_writeErrorFlag = 1'b0;
  always @(*) begin
    io_cfgSpiBus_DAT_MISO = 32'h0;
    case(cfgSpiBusFactory_byteAddress)
      12'h0 : begin
        io_cfgSpiBus_DAT_MISO[31 : 0] = ipIdentificationCtrl_2_io_header;
      end
      12'h004 : begin
        io_cfgSpiBus_DAT_MISO[31 : 0] = ipIdentificationCtrl_2_io_version;
      end
      12'h008 : begin
        io_cfgSpiBus_DAT_MISO[31 : 0] = {{8'h0,16'h0001},8'h04};
      end
      12'h00c : begin
        io_cfgSpiBus_DAT_MISO[31 : 0] = {24'h0,8'h10};
      end
      12'h010 : begin
        io_cfgSpiBus_DAT_MISO[31 : 0] = {{16'h0,8'h10},8'h10};
      end
      12'h014 : begin
        io_cfgSpiBus_DAT_MISO[31 : 0] = {30'h0,{1'b1,1'b1}};
      end
      12'h028 : begin
        io_cfgSpiBus_DAT_MISO[15 : 0] = _zz_io_cfgSpiBus_DAT_MISO;
      end
      12'h030 : begin
        io_cfgSpiBus_DAT_MISO[15 : 0] = _zz_io_cfgSpiBus_DAT_MISO_3;
      end
      12'h034 : begin
        io_cfgSpiBus_DAT_MISO[15 : 0] = _zz_io_cfgSpiBus_DAT_MISO_4;
      end
      12'h038 : begin
        io_cfgSpiBus_DAT_MISO[0 : 0] = _zz_io_cfgSpiBus_DAT_MISO_1;
      end
      12'h02c : begin
        io_cfgSpiBus_DAT_MISO[15 : 0] = _zz_io_cfgSpiBus_DAT_MISO_2;
      end
      12'h03c : begin
        io_cfgSpiBus_DAT_MISO[0 : 0] = _zz_io_cfgSpiBus_DAT_MISO_5;
      end
      12'h040 : begin
        io_cfgSpiBus_DAT_MISO[0 : 0] = _zz_io_cfgSpiBus_DAT_MISO_6;
      end
      default : begin
      end
    endcase
  end

  assign cfgSpiBusFactory_askWrite = ((io_cfgSpiBus_CYC && io_cfgSpiBus_STB) && io_cfgSpiBus_WE);
  assign cfgSpiBusFactory_askRead = ((io_cfgSpiBus_CYC && io_cfgSpiBus_STB) && (! io_cfgSpiBus_WE));
  assign cfgSpiBusFactory_doWrite = (((io_cfgSpiBus_CYC && io_cfgSpiBus_STB) && ((io_cfgSpiBus_CYC && io_cfgSpiBus_ACK) && io_cfgSpiBus_STB)) && io_cfgSpiBus_WE);
  assign cfgSpiBusFactory_doRead = (((io_cfgSpiBus_CYC && io_cfgSpiBus_STB) && ((io_cfgSpiBus_CYC && io_cfgSpiBus_ACK) && io_cfgSpiBus_STB)) && (! io_cfgSpiBus_WE));
  assign io_cfgSpiBus_ACK = (_zz_io_cfgSpiBus_ACK && io_cfgSpiBus_STB);
  assign cfgSpiBusFactory_byteAddress = ({2'd0,io_cfgSpiBus_ADR} <<< 2'd2);
  assign _zz_io_modeConfig_busWidth = SpiBusWidth_Single;
  assign cfgXipBusFactory_readErrorFlag = 1'b0;
  assign cfgXipBusFactory_writeErrorFlag = 1'b0;
  always @(*) begin
    io_cfgXipBus_DAT_MISO = 32'h0;
    case(cfgXipBusFactory_byteAddress)
      12'h0 : begin
        io_cfgXipBus_DAT_MISO[31 : 0] = ipIdentificationCtrl_3_io_header;
      end
      12'h004 : begin
        io_cfgXipBus_DAT_MISO[31 : 0] = ipIdentificationCtrl_3_io_version;
      end
      12'h00c : begin
        io_cfgXipBus_DAT_MISO[3 : 0] = _zz_io_cfgXipBus_DAT_MISO;
        io_cfgXipBus_DAT_MISO[12 : 8] = _zz_io_cfgXipBus_DAT_MISO_1;
        io_cfgXipBus_DAT_MISO[23 : 16] = spiXipControllerCtrl_1_io_config_evcr_driver;
      end
      default : begin
      end
    endcase
  end

  assign cfgXipBusFactory_askWrite = ((io_cfgXipBus_CYC && io_cfgXipBus_STB) && io_cfgXipBus_WE);
  assign cfgXipBusFactory_askRead = ((io_cfgXipBus_CYC && io_cfgXipBus_STB) && (! io_cfgXipBus_WE));
  assign cfgXipBusFactory_doWrite = (((io_cfgXipBus_CYC && io_cfgXipBus_STB) && ((io_cfgXipBus_CYC && io_cfgXipBus_ACK) && io_cfgXipBus_STB)) && io_cfgXipBus_WE);
  assign cfgXipBusFactory_doRead = (((io_cfgXipBus_CYC && io_cfgXipBus_STB) && ((io_cfgXipBus_CYC && io_cfgXipBus_ACK) && io_cfgXipBus_STB)) && (! io_cfgXipBus_WE));
  assign io_cfgXipBus_ACK = (_zz_io_cfgXipBus_ACK && io_cfgXipBus_STB);
  assign cfgXipBusFactory_byteAddress = ({2'd0,io_cfgXipBus_ADR} <<< 2'd2);
  always @(*) begin
    spiXipControllerCtrl_1_io_config_configure = 1'b0;
    case(cfgXipBusFactory_byteAddress)
      12'h008 : begin
        if(cfgXipBusFactory_doWrite) begin
          spiXipControllerCtrl_1_io_config_configure = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  always @(posedge clk) begin
    if(io_dataBus_cmd_ready) begin
      _zz_spiCmd_addr <= {12'd0, io_dataBus_cmd_payload_fragment_address};
    end
    if(io_dataBus_cmd_ready) begin
      _zz_spiCmd_count <= {4'd0, _zz__zz_spiCmd_count};
    end
    if(io_dataBus_cmd_ready) begin
      io_dataBus_cmd_payload_fragment_source_regNextWhen <= io_dataBus_cmd_payload_fragment_source;
    end
    if(io_dataBus_cmd_ready) begin
      io_dataBus_cmd_payload_fragment_context_regNextWhen <= io_dataBus_cmd_payload_fragment_context;
    end
    case(cfgXipBusFactory_byteAddress)
      12'h00c : begin
        if(cfgXipBusFactory_doWrite) begin
          spiXipControllerCtrl_1_io_config_evcr_driver <= io_cfgXipBus_DAT_MOSI[23 : 16];
        end
      end
      default : begin
      end
    endcase
  end

  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      stateMachine_state <= RspState_IDLE;
      _zz_io_cfgSpiBus_ACK <= 1'b0;
      _zz_io_cfgSpiBus_DAT_MISO <= 16'h0003;
      _zz_io_cfgSpiBus_DAT_MISO_2 <= 16'h0003;
      _zz_io_cfgSpiBus_DAT_MISO_3 <= 16'h0003;
      _zz_io_cfgSpiBus_DAT_MISO_4 <= 16'h0003;
      _zz_io_cfgSpiBus_DAT_MISO_1 <= 1'b0;
      _zz_io_cfgSpiBus_DAT_MISO_5 <= 1'b0;
      _zz_io_cfgSpiBus_DAT_MISO_6 <= 1'b0;
      _zz_io_cfgXipBus_ACK <= 1'b0;
      _zz_io_cfgXipBus_DAT_MISO <= 4'b0000;
      _zz_io_cfgXipBus_DAT_MISO_1 <= 5'h0;
    end else begin
      case(stateMachine_state)
        RspState_IDLE : begin
          if(when_BmbSpiXipController_l89) begin
            stateMachine_state <= RspState_ERROR;
          end
          if(when_BmbSpiXipController_l93) begin
            stateMachine_state <= RspState_CMD;
          end
        end
        RspState_ERROR : begin
          if(io_dataBus_rsp_ready) begin
            stateMachine_state <= RspState_IDLE;
          end
        end
        RspState_CMD : begin
          if(spiXipControllerCtrl_1_io_busCmd_fire) begin
            stateMachine_state <= RspState_RESPONSE;
          end
        end
        default : begin
          if(spiXipControllerCtrl_1_io_busRsp_valid) begin
            if(io_dataBus_rsp_fire) begin
              if(spiXipControllerCtrl_1_io_busRsp_payload_last) begin
                stateMachine_state <= RspState_IDLE;
              end
            end
          end
        end
      endcase
      _zz_io_cfgSpiBus_ACK <= (io_cfgSpiBus_STB && io_cfgSpiBus_CYC);
      _zz_io_cfgXipBus_ACK <= (io_cfgXipBus_STB && io_cfgXipBus_CYC);
      case(cfgSpiBusFactory_byteAddress)
        12'h028 : begin
          if(cfgSpiBusFactory_doWrite) begin
            _zz_io_cfgSpiBus_DAT_MISO <= io_cfgSpiBus_DAT_MOSI[15 : 0];
          end
        end
        12'h030 : begin
          if(cfgSpiBusFactory_doWrite) begin
            _zz_io_cfgSpiBus_DAT_MISO_2 <= io_cfgSpiBus_DAT_MOSI[15 : 0];
          end
        end
        12'h034 : begin
          if(cfgSpiBusFactory_doWrite) begin
            _zz_io_cfgSpiBus_DAT_MISO_3 <= io_cfgSpiBus_DAT_MOSI[15 : 0];
          end
        end
        12'h038 : begin
          if(cfgSpiBusFactory_doWrite) begin
            _zz_io_cfgSpiBus_DAT_MISO_4 <= io_cfgSpiBus_DAT_MOSI[15 : 0];
            _zz_io_cfgSpiBus_DAT_MISO_1 <= io_cfgSpiBus_DAT_MOSI[0 : 0];
          end
        end
        12'h03c : begin
          if(cfgSpiBusFactory_doWrite) begin
            _zz_io_cfgSpiBus_DAT_MISO_5 <= io_cfgSpiBus_DAT_MOSI[0];
          end
        end
        12'h040 : begin
          if(cfgSpiBusFactory_doWrite) begin
            _zz_io_cfgSpiBus_DAT_MISO_6 <= io_cfgSpiBus_DAT_MOSI[0];
          end
        end
        default : begin
        end
      endcase
      case(cfgXipBusFactory_byteAddress)
        12'h00c : begin
          if(cfgXipBusFactory_doWrite) begin
            _zz_io_cfgXipBus_DAT_MISO <= io_cfgXipBus_DAT_MOSI[3 : 0];
            _zz_io_cfgXipBus_DAT_MISO_1 <= io_cfgXipBus_DAT_MOSI[12 : 8];
          end
        end
        default : begin
        end
      endcase
    end
  end


endmodule

module IpIdentificationCtrl_1 (
  output wire [31:0]   io_header,
  output wire [31:0]   io_version,
  input  wire          clk,
  input  wire          resetn
);
  localparam Ids_Gpio = 4'd0;
  localparam Ids_Pio = 4'd1;
  localparam Ids_Pwm = 4'd2;
  localparam Ids_Uart = 4'd3;
  localparam Ids_I2cController = 4'd4;
  localparam Ids_I2cDevice = 4'd5;
  localparam Ids_SpiController = 4'd6;
  localparam Ids_SpiXipController = 4'd7;
  localparam Ids_SpiDevice = 4'd8;
  localparam Ids_AesAccelerator = 4'd9;
  localparam Ids_AesMaskedAccelerator = 4'd10;
  localparam Ids_Reset = 4'd11;
  localparam Ids_Clock = 4'd12;

  wire       [15:0]   _zz_header;
  wire       [3:0]    _zz_header_1;
  wire       [31:0]   header;
  wire       [31:0]   version;

  assign _zz_header_1 = Ids_SpiXipController;
  assign _zz_header = {12'd0, _zz_header_1};
  assign header = {{8'h0,8'h08},_zz_header};
  assign version = {{8'h01,8'h0},16'h0};
  assign io_header = header;
  assign io_version = version;

endmodule

module IpIdentificationCtrl (
  output wire [31:0]   io_header,
  output wire [31:0]   io_version,
  input  wire          clk,
  input  wire          resetn
);
  localparam Ids_Gpio = 4'd0;
  localparam Ids_Pio = 4'd1;
  localparam Ids_Pwm = 4'd2;
  localparam Ids_Uart = 4'd3;
  localparam Ids_I2cController = 4'd4;
  localparam Ids_I2cDevice = 4'd5;
  localparam Ids_SpiController = 4'd6;
  localparam Ids_SpiXipController = 4'd7;
  localparam Ids_SpiDevice = 4'd8;
  localparam Ids_AesAccelerator = 4'd9;
  localparam Ids_AesMaskedAccelerator = 4'd10;
  localparam Ids_Reset = 4'd11;
  localparam Ids_Clock = 4'd12;

  wire       [15:0]   _zz_header;
  wire       [3:0]    _zz_header_1;
  wire       [31:0]   header;
  wire       [31:0]   version;

  assign _zz_header_1 = Ids_SpiController;
  assign _zz_header = {12'd0, _zz_header_1};
  assign header = {{8'h0,8'h08},_zz_header};
  assign version = {{8'h01,8'h0},16'h0};
  assign io_header = header;
  assign io_version = version;

endmodule

module SpiXipControllerCtrl (
  input  wire [3:0]    io_config_mode,
  input  wire [4:0]    io_config_dummyCycles,
  input  wire [7:0]    io_config_evcr,
  input  wire          io_config_configure,
  input  wire          io_busCmd_valid,
  output reg           io_busCmd_ready,
  input  wire [23:0]   io_busCmd_payload_addr,
  input  wire [7:0]    io_busCmd_payload_count,
  output reg           io_busRsp_valid,
  input  wire          io_busRsp_ready,
  output wire [31:0]   io_busRsp_payload_data,
  output reg           io_busRsp_payload_last,
  output wire          io_cmd_valid,
  input  wire          io_cmd_ready,
  output wire [1:0]    io_cmd_payload_mode,
  output wire [12:0]   io_cmd_payload_args,
  input  wire          io_rsp_valid,
  input  wire [7:0]    io_rsp_payload,
  input  wire          clk,
  input  wire          resetn
);
  localparam CmdMode_DATA = 2'd0;
  localparam CmdMode_CS = 2'd1;
  localparam CmdMode_DUMMYCYCLES = 2'd2;
  localparam State_1_IDLE = 3'd0;
  localparam State_1_ENABLESPI = 3'd1;
  localparam State_1_COMMAND = 3'd2;
  localparam State_1_ADDRESS = 3'd3;
  localparam State_1_DUMMYCYCLES = 3'd4;
  localparam State_1_DATA = 3'd5;
  localparam State_1_DISABLESPI = 3'd6;
  localparam OpType_WRITE_ENABLE = 2'd0;
  localparam OpType_WRITE_REGISTER = 2'd1;
  localparam OpType_READ_REGISTER = 2'd2;
  localparam OpStep_IDLE = 3'd0;
  localparam OpStep_ENABLESPI = 3'd1;
  localparam OpStep_COMMAND = 3'd2;
  localparam OpStep_ADDRESS = 3'd3;
  localparam OpStep_DATA = 3'd4;
  localparam OpStep_DISABLESPI = 3'd5;

  reg                 rspFifo_io_pop_ready;
  wire                rspFifo_io_push_ready;
  wire                rspFifo_io_pop_valid;
  wire       [7:0]    rspFifo_io_pop_payload;
  wire       [4:0]    rspFifo_io_occupancy;
  wire       [4:0]    rspFifo_io_availability;
  wire       [5:0]    _zz_rspHandler_data;
  wire       [0:0]    _zz_cmdStream_payload_args_1;
  wire       [5:0]    _zz_cmdStream_payload_args_2;
  wire       [4:0]    _zz_cmdStream_payload_args_3;
  wire       [0:0]    _zz_cmdStream_payload_args_4;
  wire       [0:0]    _zz_cmdStream_payload_args_5;
  wire       [0:0]    _zz_cmdStream_payload_args_6;
  reg                 cmdStream_valid;
  wire                cmdStream_ready;
  reg        [1:0]    cmdStream_payload_mode;
  reg        [12:0]   cmdStream_payload_args;
  reg                 cfgPending;
  reg                 cfgInProgress;
  reg        [23:0]   burst_address;
  reg        [7:0]    burst_count;
  reg        [7:0]    burst_countResponse;
  reg        [2:0]    burst_size;
  reg        [3:0]    configuration_mode;
  reg        [4:0]    configuration_dummyCycles;
  reg        [7:0]    configuration_cmd;
  reg        [31:0]   rspHandler_data;
  reg        [1:0]    rspHandler_counter;
  reg                 rspHandler_push;
  wire                when_SpiXipControllerCtrl_l94;
  wire                when_SpiXipControllerCtrl_l96;
  wire                when_SpiXipControllerCtrl_l100;
  wire                when_SpiXipControllerCtrl_l106;
  wire                io_busRsp_fire;
  reg        [2:0]    stateMachine_state;
  reg        [1:0]    stateMachine_counter_value;
  wire                when_SpiXipControllerCtrl_l129;
  wire                when_SpiXipControllerCtrl_l177;
  wire                when_SpiXipControllerCtrl_l179;
  wire                when_SpiXipControllerCtrl_l212;
  wire                when_SpiXipControllerCtrl_l215;
  reg        [1:0]    configureFlash_currentOp;
  reg        [2:0]    configureFlash_currentStep;
  wire                when_SpiXipControllerCtrl_l251;
  reg        [7:0]    _zz_cmdStream_payload_args;
  wire                when_SpiXipControllerCtrl_l273;
  wire                when_SpiXipControllerCtrl_l284;
  wire                when_SpiXipControllerCtrl_l315;
  `ifndef SYNTHESIS
  reg [87:0] io_cmd_payload_mode_string;
  reg [87:0] cmdStream_payload_mode_string;
  reg [87:0] stateMachine_state_string;
  reg [111:0] configureFlash_currentOp_string;
  reg [79:0] configureFlash_currentStep_string;
  `endif


  assign _zz_rspHandler_data = (4'b1000 * rspHandler_counter);
  assign _zz_cmdStream_payload_args_1 = 1'b1;
  assign _zz_cmdStream_payload_args_2 = (4'b1000 * stateMachine_counter_value);
  assign _zz_cmdStream_payload_args_3 = configuration_dummyCycles;
  assign _zz_cmdStream_payload_args_4 = 1'b0;
  assign _zz_cmdStream_payload_args_5 = 1'b1;
  assign _zz_cmdStream_payload_args_6 = 1'b0;
  StreamFifo rspFifo (
    .io_push_valid   (io_rsp_valid                ), //i
    .io_push_ready   (rspFifo_io_push_ready       ), //o
    .io_push_payload (io_rsp_payload[7:0]         ), //i
    .io_pop_valid    (rspFifo_io_pop_valid        ), //o
    .io_pop_ready    (rspFifo_io_pop_ready        ), //i
    .io_pop_payload  (rspFifo_io_pop_payload[7:0] ), //o
    .io_flush        (1'b0                        ), //i
    .io_occupancy    (rspFifo_io_occupancy[4:0]   ), //o
    .io_availability (rspFifo_io_availability[4:0]), //o
    .clk             (clk                         ), //i
    .resetn          (resetn                      )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_cmd_payload_mode)
      CmdMode_DATA : io_cmd_payload_mode_string = "DATA       ";
      CmdMode_CS : io_cmd_payload_mode_string = "CS         ";
      CmdMode_DUMMYCYCLES : io_cmd_payload_mode_string = "DUMMYCYCLES";
      default : io_cmd_payload_mode_string = "???????????";
    endcase
  end
  always @(*) begin
    case(cmdStream_payload_mode)
      CmdMode_DATA : cmdStream_payload_mode_string = "DATA       ";
      CmdMode_CS : cmdStream_payload_mode_string = "CS         ";
      CmdMode_DUMMYCYCLES : cmdStream_payload_mode_string = "DUMMYCYCLES";
      default : cmdStream_payload_mode_string = "???????????";
    endcase
  end
  always @(*) begin
    case(stateMachine_state)
      State_1_IDLE : stateMachine_state_string = "IDLE       ";
      State_1_ENABLESPI : stateMachine_state_string = "ENABLESPI  ";
      State_1_COMMAND : stateMachine_state_string = "COMMAND    ";
      State_1_ADDRESS : stateMachine_state_string = "ADDRESS    ";
      State_1_DUMMYCYCLES : stateMachine_state_string = "DUMMYCYCLES";
      State_1_DATA : stateMachine_state_string = "DATA       ";
      State_1_DISABLESPI : stateMachine_state_string = "DISABLESPI ";
      default : stateMachine_state_string = "???????????";
    endcase
  end
  always @(*) begin
    case(configureFlash_currentOp)
      OpType_WRITE_ENABLE : configureFlash_currentOp_string = "WRITE_ENABLE  ";
      OpType_WRITE_REGISTER : configureFlash_currentOp_string = "WRITE_REGISTER";
      OpType_READ_REGISTER : configureFlash_currentOp_string = "READ_REGISTER ";
      default : configureFlash_currentOp_string = "??????????????";
    endcase
  end
  always @(*) begin
    case(configureFlash_currentStep)
      OpStep_IDLE : configureFlash_currentStep_string = "IDLE      ";
      OpStep_ENABLESPI : configureFlash_currentStep_string = "ENABLESPI ";
      OpStep_COMMAND : configureFlash_currentStep_string = "COMMAND   ";
      OpStep_ADDRESS : configureFlash_currentStep_string = "ADDRESS   ";
      OpStep_DATA : configureFlash_currentStep_string = "DATA      ";
      OpStep_DISABLESPI : configureFlash_currentStep_string = "DISABLESPI";
      default : configureFlash_currentStep_string = "??????????";
    endcase
  end
  `endif

  always @(*) begin
    cmdStream_valid = 1'b0;
    case(stateMachine_state)
      State_1_IDLE : begin
      end
      State_1_ENABLESPI : begin
        cmdStream_valid = 1'b1;
      end
      State_1_COMMAND : begin
        cmdStream_valid = 1'b1;
      end
      State_1_ADDRESS : begin
        cmdStream_valid = 1'b1;
      end
      State_1_DUMMYCYCLES : begin
        cmdStream_valid = 1'b1;
      end
      State_1_DATA : begin
        cmdStream_valid = 1'b1;
      end
      default : begin
        cmdStream_valid = 1'b1;
      end
    endcase
    case(configureFlash_currentStep)
      OpStep_ENABLESPI : begin
        cmdStream_valid = 1'b1;
      end
      OpStep_COMMAND : begin
        cmdStream_valid = 1'b1;
      end
      OpStep_DATA : begin
        cmdStream_valid = 1'b1;
      end
      OpStep_DISABLESPI : begin
        cmdStream_valid = 1'b1;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    cmdStream_payload_mode = CmdMode_DATA;
    case(stateMachine_state)
      State_1_IDLE : begin
      end
      State_1_ENABLESPI : begin
        cmdStream_payload_mode = CmdMode_CS;
      end
      State_1_COMMAND : begin
        cmdStream_payload_mode = CmdMode_DATA;
      end
      State_1_ADDRESS : begin
        cmdStream_payload_mode = CmdMode_DATA;
      end
      State_1_DUMMYCYCLES : begin
        cmdStream_payload_mode = CmdMode_DUMMYCYCLES;
      end
      State_1_DATA : begin
        cmdStream_payload_mode = CmdMode_DATA;
      end
      default : begin
        cmdStream_payload_mode = CmdMode_CS;
      end
    endcase
    case(configureFlash_currentStep)
      OpStep_ENABLESPI : begin
        cmdStream_payload_mode = CmdMode_CS;
      end
      OpStep_COMMAND : begin
        cmdStream_payload_mode = CmdMode_DATA;
      end
      OpStep_DATA : begin
        cmdStream_payload_mode = CmdMode_DATA;
      end
      OpStep_DISABLESPI : begin
        cmdStream_payload_mode = CmdMode_CS;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    cmdStream_payload_args = 13'h0;
    case(stateMachine_state)
      State_1_IDLE : begin
      end
      State_1_ENABLESPI : begin
        cmdStream_payload_args = {12'd0, _zz_cmdStream_payload_args_1};
      end
      State_1_COMMAND : begin
        cmdStream_payload_args = {1'b0,{configuration_mode,configuration_cmd}};
      end
      State_1_ADDRESS : begin
        cmdStream_payload_args = {1'b0,{configuration_mode,burst_address[_zz_cmdStream_payload_args_2 +: 8]}};
      end
      State_1_DUMMYCYCLES : begin
        cmdStream_payload_args = {8'd0, _zz_cmdStream_payload_args_3};
      end
      State_1_DATA : begin
        cmdStream_payload_args = {1'b1,{configuration_mode,8'h0}};
      end
      default : begin
        cmdStream_payload_args = {12'd0, _zz_cmdStream_payload_args_4};
      end
    endcase
    case(configureFlash_currentStep)
      OpStep_ENABLESPI : begin
        cmdStream_payload_args = {12'd0, _zz_cmdStream_payload_args_5};
      end
      OpStep_COMMAND : begin
        cmdStream_payload_args = {1'b0,{4'b0000,_zz_cmdStream_payload_args}};
      end
      OpStep_DATA : begin
        cmdStream_payload_args = {1'b1,{4'b0000,io_config_evcr}};
      end
      OpStep_DISABLESPI : begin
        cmdStream_payload_args = {12'd0, _zz_cmdStream_payload_args_6};
      end
      default : begin
      end
    endcase
  end

  assign io_cmd_valid = cmdStream_valid;
  assign cmdStream_ready = io_cmd_ready;
  assign io_cmd_payload_mode = cmdStream_payload_mode;
  assign io_cmd_payload_args = cmdStream_payload_args;
  always @(*) begin
    case(configuration_mode)
      4'b0010 : begin
        configuration_cmd = 8'he7;
      end
      4'b0001 : begin
        configuration_cmd = 8'hbb;
      end
      default : begin
        configuration_cmd = 8'h03;
      end
    endcase
  end

  always @(*) begin
    io_busRsp_valid = 1'b0;
    if(rspHandler_push) begin
      io_busRsp_valid = 1'b1;
    end
  end

  always @(*) begin
    io_busRsp_payload_last = 1'b0;
    if(rspHandler_push) begin
      if(when_SpiXipControllerCtrl_l106) begin
        io_busRsp_payload_last = 1'b1;
      end
    end
  end

  always @(*) begin
    rspFifo_io_pop_ready = 1'b0;
    if(when_SpiXipControllerCtrl_l94) begin
      rspFifo_io_pop_ready = 1'b1;
    end
  end

  assign when_SpiXipControllerCtrl_l94 = (rspFifo_io_pop_valid && (! rspHandler_push));
  assign when_SpiXipControllerCtrl_l96 = (! cfgInProgress);
  assign when_SpiXipControllerCtrl_l100 = (rspHandler_counter == 2'b11);
  assign when_SpiXipControllerCtrl_l106 = (burst_countResponse == 8'h0);
  assign io_busRsp_fire = (io_busRsp_valid && io_busRsp_ready);
  assign io_busRsp_payload_data = rspHandler_data;
  always @(*) begin
    io_busCmd_ready = 1'b0;
    case(stateMachine_state)
      State_1_IDLE : begin
        if(when_SpiXipControllerCtrl_l129) begin
          io_busCmd_ready = 1'b1;
        end
      end
      State_1_ENABLESPI : begin
      end
      State_1_COMMAND : begin
      end
      State_1_ADDRESS : begin
      end
      State_1_DUMMYCYCLES : begin
      end
      State_1_DATA : begin
      end
      default : begin
      end
    endcase
  end

  assign when_SpiXipControllerCtrl_l129 = (io_busCmd_valid && (! cfgPending));
  assign when_SpiXipControllerCtrl_l177 = (stateMachine_counter_value == 2'b00);
  assign when_SpiXipControllerCtrl_l179 = (configuration_dummyCycles != 5'h0);
  assign when_SpiXipControllerCtrl_l212 = (stateMachine_counter_value == 2'b00);
  assign when_SpiXipControllerCtrl_l215 = (burst_count == 8'h0);
  assign when_SpiXipControllerCtrl_l251 = ((stateMachine_state == State_1_IDLE) && cfgPending);
  assign when_SpiXipControllerCtrl_l273 = (configureFlash_currentOp == OpType_WRITE_ENABLE);
  always @(*) begin
    if(when_SpiXipControllerCtrl_l273) begin
      _zz_cmdStream_payload_args = 8'h06;
    end else begin
      _zz_cmdStream_payload_args = 8'h61;
    end
  end

  assign when_SpiXipControllerCtrl_l284 = (configureFlash_currentOp == OpType_WRITE_ENABLE);
  assign when_SpiXipControllerCtrl_l315 = (configureFlash_currentOp == OpType_WRITE_ENABLE);
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      cfgPending <= 1'b0;
      cfgInProgress <= 1'b0;
      configuration_mode <= 4'b0000;
      configuration_dummyCycles <= 5'h0;
      rspHandler_counter <= 2'b00;
      rspHandler_push <= 1'b0;
      stateMachine_state <= State_1_IDLE;
      configureFlash_currentOp <= OpType_WRITE_ENABLE;
      configureFlash_currentStep <= OpStep_IDLE;
    end else begin
      if(io_config_configure) begin
        cfgPending <= 1'b1;
      end
      if(when_SpiXipControllerCtrl_l94) begin
        if(when_SpiXipControllerCtrl_l96) begin
          rspHandler_counter <= (rspHandler_counter + 2'b01);
        end
        if(when_SpiXipControllerCtrl_l100) begin
          rspHandler_push <= 1'b1;
        end
      end
      if(rspHandler_push) begin
        if(io_busRsp_fire) begin
          rspHandler_push <= 1'b0;
        end
      end
      case(stateMachine_state)
        State_1_IDLE : begin
          if(when_SpiXipControllerCtrl_l129) begin
            stateMachine_state <= State_1_ENABLESPI;
          end
        end
        State_1_ENABLESPI : begin
          if(cmdStream_ready) begin
            stateMachine_state <= State_1_COMMAND;
          end
        end
        State_1_COMMAND : begin
          if(cmdStream_ready) begin
            stateMachine_state <= State_1_ADDRESS;
          end
        end
        State_1_ADDRESS : begin
          if(cmdStream_ready) begin
            if(when_SpiXipControllerCtrl_l177) begin
              if(when_SpiXipControllerCtrl_l179) begin
                stateMachine_state <= State_1_DUMMYCYCLES;
              end else begin
                stateMachine_state <= State_1_DATA;
              end
            end
          end
        end
        State_1_DUMMYCYCLES : begin
          if(cmdStream_ready) begin
            stateMachine_state <= State_1_DATA;
          end
        end
        State_1_DATA : begin
          if(cmdStream_ready) begin
            if(when_SpiXipControllerCtrl_l212) begin
              if(when_SpiXipControllerCtrl_l215) begin
                stateMachine_state <= State_1_DISABLESPI;
              end
            end
          end
        end
        default : begin
          if(cmdStream_ready) begin
            stateMachine_state <= State_1_IDLE;
          end
        end
      endcase
      case(configureFlash_currentStep)
        OpStep_IDLE : begin
          if(when_SpiXipControllerCtrl_l251) begin
            cfgInProgress <= 1'b1;
            configureFlash_currentStep <= OpStep_ENABLESPI;
          end
        end
        OpStep_ENABLESPI : begin
          if(cmdStream_ready) begin
            configureFlash_currentStep <= OpStep_COMMAND;
          end
        end
        OpStep_COMMAND : begin
          if(cmdStream_ready) begin
            if(when_SpiXipControllerCtrl_l284) begin
              configureFlash_currentStep <= OpStep_DISABLESPI;
            end else begin
              configureFlash_currentStep <= OpStep_DATA;
            end
          end
        end
        OpStep_DATA : begin
          if(cmdStream_ready) begin
            configureFlash_currentStep <= OpStep_DISABLESPI;
          end
        end
        OpStep_DISABLESPI : begin
          if(cmdStream_ready) begin
            if(when_SpiXipControllerCtrl_l315) begin
              configureFlash_currentOp <= OpType_WRITE_REGISTER;
              configureFlash_currentStep <= OpStep_ENABLESPI;
            end else begin
              configureFlash_currentOp <= OpType_WRITE_ENABLE;
              cfgPending <= 1'b0;
              cfgInProgress <= 1'b0;
              configureFlash_currentStep <= OpStep_IDLE;
              configuration_mode <= io_config_mode;
              configuration_dummyCycles <= io_config_dummyCycles;
            end
          end
        end
        default : begin
        end
      endcase
    end
  end

  always @(posedge clk) begin
    if(when_SpiXipControllerCtrl_l94) begin
      rspHandler_data[_zz_rspHandler_data +: 8] <= rspFifo_io_pop_payload;
    end
    if(rspHandler_push) begin
      if(io_busRsp_fire) begin
        burst_countResponse <= (burst_countResponse - 8'h01);
      end
    end
    case(stateMachine_state)
      State_1_IDLE : begin
        if(when_SpiXipControllerCtrl_l129) begin
          burst_address <= io_busCmd_payload_addr;
          burst_count <= io_busCmd_payload_count;
          burst_countResponse <= io_busCmd_payload_count;
          burst_size <= 3'b000;
        end
      end
      State_1_ENABLESPI : begin
      end
      State_1_COMMAND : begin
        stateMachine_counter_value <= 2'b10;
      end
      State_1_ADDRESS : begin
        if(cmdStream_ready) begin
          if(when_SpiXipControllerCtrl_l177) begin
            stateMachine_counter_value <= 2'b11;
          end else begin
            stateMachine_counter_value <= (stateMachine_counter_value - 2'b01);
          end
        end
      end
      State_1_DUMMYCYCLES : begin
      end
      State_1_DATA : begin
        if(cmdStream_ready) begin
          if(when_SpiXipControllerCtrl_l212) begin
            stateMachine_counter_value <= 2'b11;
            burst_count <= (burst_count - 8'h01);
          end else begin
            stateMachine_counter_value <= (stateMachine_counter_value - 2'b01);
          end
        end
      end
      default : begin
      end
    endcase
  end


endmodule

module SpiControllerCtrl (
  input  wire [15:0]   io_config_clockDivider,
  input  wire [0:0]    io_config_cs_activeHigh,
  input  wire [15:0]   io_config_cs_setup,
  input  wire [15:0]   io_config_cs_hold,
  input  wire [15:0]   io_config_cs_disable,
  input  wire          io_modeConfig_cpol,
  input  wire          io_modeConfig_cpha,
  input  wire [1:0]    io_modeConfig_busWidth,
  output wire [0:0]    io_spi_cs,
  output wire          io_spi_sclk,
  input  wire [3:0]    io_spi_dq_read,
  output reg  [3:0]    io_spi_dq_write,
  output reg  [3:0]    io_spi_dq_writeEnable,
  output wire          io_interrupt,
  input  wire [1:0]    io_pendingInterrupts,
  input  wire          io_cmd_valid,
  output reg           io_cmd_ready,
  input  wire [1:0]    io_cmd_payload_mode,
  input  wire [12:0]   io_cmd_payload_args,
  output wire          io_rsp_valid,
  output wire [7:0]    io_rsp_payload,
  input  wire          clk,
  input  wire          resetn
);
  localparam SpiBusWidth_Single = 2'd0;
  localparam SpiBusWidth_Dual = 2'd1;
  localparam SpiBusWidth_Quad = 2'd2;
  localparam SpiBusWidth_Octa = 2'd3;
  localparam CmdMode_DATA = 2'd0;
  localparam CmdMode_CS = 2'd1;
  localparam CmdMode_DUMMYCYCLES = 2'd2;
  localparam State_Idle = 4'd0;
  localparam State_Cs = 4'd1;
  localparam State_CsSetup = 4'd2;
  localparam State_CsHold = 4'd3;
  localparam State_CsDisable = 4'd4;
  localparam State_DummyCycles = 4'd5;
  localparam State_DataSingle = 4'd6;
  localparam State_DataDual = 4'd7;
  localparam State_DataQuad = 4'd8;

  reg        [15:0]   ctrl_clockDivider_io_value;
  reg                 ctrl_clockDivider_io_reload;
  wire                ctrl_clockDivider_io_tick;
  wire       [3:0]    _zz_1;
  wire       [4:0]    _zz_when_SpiControllerCtrl_l193;
  wire       [8:0]    _zz_ctrl_stateMachine_buffer;
  wire       [9:0]    _zz_ctrl_stateMachine_buffer_1;
  wire       [11:0]   _zz_ctrl_stateMachine_buffer_2;
  wire       [7:0]    _zz__zz_io_spi_dq_write;
  wire       [2:0]    _zz__zz_io_spi_dq_write_1;
  wire       [2:0]    _zz__zz_io_spi_dq_write_2;
  wire       [2:0]    _zz__zz_io_spi_dq_write_1_1;
  wire       [3:0]    _zz__zz_io_spi_dq_write_1_2;
  wire       [2:0]    _zz__zz_io_spi_dq_write_1_3;
  wire       [7:0]    _zz__zz_io_spi_dq_write_2_1;
  wire       [2:0]    _zz__zz_io_spi_dq_write_2_2;
  wire       [7:0]    _zz__zz_io_spi_dq_write_3;
  wire       [2:0]    _zz__zz_io_spi_dq_write_3_1;
  wire       [2:0]    _zz__zz_io_spi_dq_write_4;
  wire       [4:0]    _zz__zz_io_spi_dq_write_4_1;
  wire       [2:0]    _zz__zz_io_spi_dq_write_4_2;
  wire       [7:0]    _zz__zz_io_spi_dq_write_5;
  wire       [2:0]    _zz__zz_io_spi_dq_write_5_1;
  wire       [7:0]    _zz__zz_io_spi_dq_write_6;
  wire       [2:0]    _zz__zz_io_spi_dq_write_6_1;
  wire       [7:0]    _zz__zz_io_spi_dq_write_7;
  wire       [2:0]    _zz__zz_io_spi_dq_write_7_1;
  wire       [7:0]    _zz__zz_io_spi_dq_write_8;
  wire       [2:0]    _zz__zz_io_spi_dq_write_8_1;
  reg                 ctrlEnable;
  wire                ctrl_newClockEnable;
  reg        [3:0]    ctrl_dataCounter_value;
  reg        [0:0]    ctrl_stateMachine_cs;
  reg        [7:0]    ctrl_stateMachine_buffer;
  reg        [3:0]    ctrl_stateMachine_state;
  wire                when_SpiControllerCtrl_l153;
  wire                when_SpiControllerCtrl_l157;
  wire                when_SpiControllerCtrl_l161;
  wire                when_SpiControllerCtrl_l176;
  wire                when_SpiControllerCtrl_l193;
  wire                when_SpiControllerCtrl_l202;
  wire                when_SpiControllerCtrl_l205;
  wire                when_SpiControllerCtrl_l214;
  wire                when_SpiControllerCtrl_l217;
  wire                when_SpiControllerCtrl_l226;
  wire                when_SpiControllerCtrl_l232;
  wire                when_SpiControllerCtrl_l257;
  wire                io_cmd_fire;
  reg                 _zz_io_rsp_valid;
  reg                 _zz_io_spi_sclk;
  wire                when_SpiControllerCtrl_l282;
  wire                when_SpiControllerCtrl_l288;
  reg                 _zz_io_spi_dq_write;
  wire                when_SpiControllerCtrl_l295;
  wire                when_SpiControllerCtrl_l296;
  wire       [2:0]    _zz_io_spi_dq_write_1;
  reg                 _zz_io_spi_dq_write_2;
  reg                 _zz_io_spi_dq_write_3;
  wire                when_SpiControllerCtrl_l310;
  wire                when_SpiControllerCtrl_l311;
  wire       [2:0]    _zz_io_spi_dq_write_4;
  reg                 _zz_io_spi_dq_write_5;
  reg                 _zz_io_spi_dq_write_6;
  reg                 _zz_io_spi_dq_write_7;
  reg                 _zz_io_spi_dq_write_8;
  `ifndef SYNTHESIS
  reg [47:0] io_modeConfig_busWidth_string;
  reg [87:0] io_cmd_payload_mode_string;
  reg [87:0] ctrl_stateMachine_state_string;
  `endif


  assign _zz_1 = io_cmd_payload_args[11 : 8];
  assign _zz_when_SpiControllerCtrl_l193 = {1'd0, ctrl_dataCounter_value};
  assign _zz_ctrl_stateMachine_buffer = {ctrl_stateMachine_buffer,io_spi_dq_read[1]};
  assign _zz_ctrl_stateMachine_buffer_1 = {{ctrl_stateMachine_buffer,io_spi_dq_read[1]},io_spi_dq_read[0]};
  assign _zz_ctrl_stateMachine_buffer_2 = {{{{ctrl_stateMachine_buffer,io_spi_dq_read[3]},io_spi_dq_read[2]},io_spi_dq_read[1]},io_spi_dq_read[0]};
  assign _zz__zz_io_spi_dq_write = io_cmd_payload_args[7 : 0];
  assign _zz__zz_io_spi_dq_write_1 = (3'b111 - _zz__zz_io_spi_dq_write_2);
  assign _zz__zz_io_spi_dq_write_2 = (ctrl_dataCounter_value >>> 1'd1);
  assign _zz__zz_io_spi_dq_write_1_2 = ({1'd0,_zz__zz_io_spi_dq_write_1_3} <<< 1'd1);
  assign _zz__zz_io_spi_dq_write_1_1 = _zz__zz_io_spi_dq_write_1_2[2:0];
  assign _zz__zz_io_spi_dq_write_1_3 = (ctrl_dataCounter_value >>> 1'd1);
  assign _zz__zz_io_spi_dq_write_2_1 = io_cmd_payload_args[7 : 0];
  assign _zz__zz_io_spi_dq_write_2_2 = (_zz_io_spi_dq_write_1 - 3'b001);
  assign _zz__zz_io_spi_dq_write_3 = io_cmd_payload_args[7 : 0];
  assign _zz__zz_io_spi_dq_write_3_1 = (_zz_io_spi_dq_write_1 - 3'b000);
  assign _zz__zz_io_spi_dq_write_4_1 = ({2'd0,_zz__zz_io_spi_dq_write_4_2} <<< 2'd2);
  assign _zz__zz_io_spi_dq_write_4 = _zz__zz_io_spi_dq_write_4_1[2:0];
  assign _zz__zz_io_spi_dq_write_4_2 = (ctrl_dataCounter_value >>> 1'd1);
  assign _zz__zz_io_spi_dq_write_5 = io_cmd_payload_args[7 : 0];
  assign _zz__zz_io_spi_dq_write_5_1 = (_zz_io_spi_dq_write_4 - 3'b011);
  assign _zz__zz_io_spi_dq_write_6 = io_cmd_payload_args[7 : 0];
  assign _zz__zz_io_spi_dq_write_6_1 = (_zz_io_spi_dq_write_4 - 3'b010);
  assign _zz__zz_io_spi_dq_write_7 = io_cmd_payload_args[7 : 0];
  assign _zz__zz_io_spi_dq_write_7_1 = (_zz_io_spi_dq_write_4 - 3'b001);
  assign _zz__zz_io_spi_dq_write_8 = io_cmd_payload_args[7 : 0];
  assign _zz__zz_io_spi_dq_write_8_1 = (_zz_io_spi_dq_write_4 - 3'b000);
  ClockDivider ctrl_clockDivider (
    .io_value            (ctrl_clockDivider_io_value[15:0]), //i
    .io_reload           (ctrl_clockDivider_io_reload     ), //i
    .io_tick             (ctrl_clockDivider_io_tick       ), //o
    .clk                 (clk                             ), //i
    .resetn              (resetn                          ), //i
    .ctrl_newClockEnable (ctrl_newClockEnable             )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_modeConfig_busWidth)
      SpiBusWidth_Single : io_modeConfig_busWidth_string = "Single";
      SpiBusWidth_Dual : io_modeConfig_busWidth_string = "Dual  ";
      SpiBusWidth_Quad : io_modeConfig_busWidth_string = "Quad  ";
      SpiBusWidth_Octa : io_modeConfig_busWidth_string = "Octa  ";
      default : io_modeConfig_busWidth_string = "??????";
    endcase
  end
  always @(*) begin
    case(io_cmd_payload_mode)
      CmdMode_DATA : io_cmd_payload_mode_string = "DATA       ";
      CmdMode_CS : io_cmd_payload_mode_string = "CS         ";
      CmdMode_DUMMYCYCLES : io_cmd_payload_mode_string = "DUMMYCYCLES";
      default : io_cmd_payload_mode_string = "???????????";
    endcase
  end
  always @(*) begin
    case(ctrl_stateMachine_state)
      State_Idle : ctrl_stateMachine_state_string = "Idle       ";
      State_Cs : ctrl_stateMachine_state_string = "Cs         ";
      State_CsSetup : ctrl_stateMachine_state_string = "CsSetup    ";
      State_CsHold : ctrl_stateMachine_state_string = "CsHold     ";
      State_CsDisable : ctrl_stateMachine_state_string = "CsDisable  ";
      State_DummyCycles : ctrl_stateMachine_state_string = "DummyCycles";
      State_DataSingle : ctrl_stateMachine_state_string = "DataSingle ";
      State_DataDual : ctrl_stateMachine_state_string = "DataDual   ";
      State_DataQuad : ctrl_stateMachine_state_string = "DataQuad   ";
      default : ctrl_stateMachine_state_string = "???????????";
    endcase
  end
  `endif

  assign ctrl_newClockEnable = (1'b1 && ctrlEnable);
  always @(*) begin
    ctrl_clockDivider_io_value = io_config_clockDivider;
    case(ctrl_stateMachine_state)
      State_Idle : begin
        if(io_cmd_valid) begin
          if(when_SpiControllerCtrl_l153) begin
            ctrl_clockDivider_io_value = io_config_cs_setup;
          end
          if(when_SpiControllerCtrl_l157) begin
            ctrl_clockDivider_io_value = io_config_cs_hold;
          end
          if(when_SpiControllerCtrl_l161) begin
            ctrl_clockDivider_io_value = io_config_clockDivider;
          end
          if(when_SpiControllerCtrl_l176) begin
            ctrl_clockDivider_io_value = io_config_clockDivider;
          end
        end
      end
      State_CsHold : begin
        if(ctrl_clockDivider_io_tick) begin
          ctrl_clockDivider_io_value = io_config_cs_disable;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    ctrl_clockDivider_io_reload = 1'b0;
    case(ctrl_stateMachine_state)
      State_Idle : begin
        if(io_cmd_valid) begin
          ctrl_clockDivider_io_reload = 1'b1;
        end
      end
      State_CsHold : begin
        if(ctrl_clockDivider_io_tick) begin
          ctrl_clockDivider_io_reload = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_cmd_ready = 1'b0;
    case(ctrl_stateMachine_state)
      State_CsSetup : begin
        if(ctrl_clockDivider_io_tick) begin
          io_cmd_ready = 1'b1;
        end
      end
      State_DummyCycles : begin
        if(ctrl_clockDivider_io_tick) begin
          if(when_SpiControllerCtrl_l193) begin
            io_cmd_ready = 1'b1;
          end
        end
      end
      State_DataSingle : begin
        if(ctrl_clockDivider_io_tick) begin
          if(when_SpiControllerCtrl_l205) begin
            io_cmd_ready = 1'b1;
          end
        end
      end
      State_DataDual : begin
        if(ctrl_clockDivider_io_tick) begin
          if(when_SpiControllerCtrl_l217) begin
            io_cmd_ready = 1'b1;
          end
        end
      end
      State_DataQuad : begin
        if(ctrl_clockDivider_io_tick) begin
          if(when_SpiControllerCtrl_l232) begin
            io_cmd_ready = 1'b1;
          end
        end
      end
      State_CsDisable : begin
        if(ctrl_clockDivider_io_tick) begin
          io_cmd_ready = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_SpiControllerCtrl_l153 = ((io_cmd_payload_mode == CmdMode_CS) && io_cmd_payload_args[0]);
  assign when_SpiControllerCtrl_l157 = ((io_cmd_payload_mode == CmdMode_CS) && (! io_cmd_payload_args[0]));
  assign when_SpiControllerCtrl_l161 = (io_cmd_payload_mode == CmdMode_DATA);
  assign when_SpiControllerCtrl_l176 = (io_cmd_payload_mode == CmdMode_DUMMYCYCLES);
  assign when_SpiControllerCtrl_l193 = (_zz_when_SpiControllerCtrl_l193 == io_cmd_payload_args[4 : 0]);
  assign when_SpiControllerCtrl_l202 = ctrl_dataCounter_value[0];
  assign when_SpiControllerCtrl_l205 = (ctrl_dataCounter_value == 4'b1111);
  assign when_SpiControllerCtrl_l214 = ctrl_dataCounter_value[0];
  assign when_SpiControllerCtrl_l217 = (ctrl_dataCounter_value == 4'b0111);
  assign when_SpiControllerCtrl_l226 = ctrl_dataCounter_value[0];
  assign when_SpiControllerCtrl_l232 = (ctrl_dataCounter_value == 4'b0011);
  assign when_SpiControllerCtrl_l257 = (io_cmd_valid || (! (ctrl_stateMachine_state == State_Idle)));
  assign io_cmd_fire = (io_cmd_valid && io_cmd_ready);
  assign io_rsp_valid = _zz_io_rsp_valid;
  assign io_rsp_payload = ctrl_stateMachine_buffer;
  assign io_spi_cs = (ctrl_stateMachine_cs ^ io_config_cs_activeHigh);
  assign io_spi_sclk = _zz_io_spi_sclk;
  always @(*) begin
    io_spi_dq_writeEnable[0] = 1'b0;
    io_spi_dq_writeEnable[1] = 1'b0;
    io_spi_dq_writeEnable[2] = 1'b0;
    io_spi_dq_writeEnable[3] = 1'b0;
    if(when_SpiControllerCtrl_l282) begin
      io_spi_dq_writeEnable[0] = 1'b1;
      io_spi_dq_writeEnable[1] = 1'b1;
      io_spi_dq_writeEnable[2] = 1'b1;
      io_spi_dq_writeEnable[3] = 1'b1;
    end
    if(when_SpiControllerCtrl_l288) begin
      io_spi_dq_writeEnable[0] = 1'b1;
    end
    if(when_SpiControllerCtrl_l295) begin
      if(when_SpiControllerCtrl_l296) begin
        io_spi_dq_writeEnable[0] = 1'b1;
        io_spi_dq_writeEnable[1] = 1'b1;
      end
    end
    if(when_SpiControllerCtrl_l310) begin
      if(when_SpiControllerCtrl_l311) begin
        io_spi_dq_writeEnable[0] = 1'b1;
        io_spi_dq_writeEnable[1] = 1'b1;
        io_spi_dq_writeEnable[2] = 1'b1;
        io_spi_dq_writeEnable[3] = 1'b1;
      end
    end
  end

  always @(*) begin
    io_spi_dq_write[0] = 1'b0;
    io_spi_dq_write[1] = 1'b0;
    io_spi_dq_write[2] = 1'b0;
    io_spi_dq_write[3] = 1'b0;
    if(when_SpiControllerCtrl_l282) begin
      io_spi_dq_write[0] = 1'b0;
      io_spi_dq_write[1] = 1'b0;
      io_spi_dq_write[2] = 1'b0;
      io_spi_dq_write[3] = 1'b0;
    end
    if(when_SpiControllerCtrl_l288) begin
      io_spi_dq_write[0] = _zz_io_spi_dq_write;
    end
    if(when_SpiControllerCtrl_l295) begin
      io_spi_dq_write[0] = _zz_io_spi_dq_write_2;
      io_spi_dq_write[1] = _zz_io_spi_dq_write_3;
    end
    if(when_SpiControllerCtrl_l310) begin
      io_spi_dq_write[0] = _zz_io_spi_dq_write_5;
      io_spi_dq_write[1] = _zz_io_spi_dq_write_6;
      io_spi_dq_write[2] = _zz_io_spi_dq_write_7;
      io_spi_dq_write[3] = _zz_io_spi_dq_write_8;
    end
  end

  assign when_SpiControllerCtrl_l282 = (ctrl_stateMachine_state == State_DummyCycles);
  assign when_SpiControllerCtrl_l288 = (ctrl_stateMachine_state == State_DataSingle);
  assign when_SpiControllerCtrl_l295 = (ctrl_stateMachine_state == State_DataDual);
  assign when_SpiControllerCtrl_l296 = ((io_cmd_payload_mode == CmdMode_DATA) && (! io_cmd_payload_args[12]));
  assign _zz_io_spi_dq_write_1 = (3'b111 - _zz__zz_io_spi_dq_write_1_1);
  assign when_SpiControllerCtrl_l310 = (ctrl_stateMachine_state == State_DataQuad);
  assign when_SpiControllerCtrl_l311 = ((io_cmd_payload_mode == CmdMode_DATA) && (! io_cmd_payload_args[12]));
  assign _zz_io_spi_dq_write_4 = (3'b111 - _zz__zz_io_spi_dq_write_4);
  assign io_interrupt = (|io_pendingInterrupts);
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      ctrlEnable <= 1'b1;
      _zz_io_rsp_valid <= 1'b0;
    end else begin
      if(when_SpiControllerCtrl_l257) begin
        ctrlEnable <= 1'b1;
      end else begin
        ctrlEnable <= 1'b0;
      end
      _zz_io_rsp_valid <= ((io_cmd_fire && (io_cmd_payload_mode == CmdMode_DATA)) && io_cmd_payload_args[12]);
    end
  end

  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      ctrl_dataCounter_value <= 4'b0000;
      ctrl_stateMachine_cs <= 1'b1;
      ctrl_stateMachine_state <= State_Idle;
    end else begin
      if(ctrl_newClockEnable) begin
        case(ctrl_stateMachine_state)
          State_Idle : begin
            if(io_cmd_valid) begin
              if(when_SpiControllerCtrl_l153) begin
                ctrl_stateMachine_state <= State_CsSetup;
              end
              if(when_SpiControllerCtrl_l157) begin
                ctrl_stateMachine_state <= State_CsHold;
              end
              if(when_SpiControllerCtrl_l161) begin
                ctrl_dataCounter_value <= 4'b0000;
                case(_zz_1)
                  4'b0010 : begin
                    ctrl_stateMachine_state <= State_DataQuad;
                  end
                  4'b0001 : begin
                    ctrl_stateMachine_state <= State_DataDual;
                  end
                  default : begin
                    ctrl_stateMachine_state <= State_DataSingle;
                  end
                endcase
              end
              if(when_SpiControllerCtrl_l176) begin
                ctrl_dataCounter_value <= 4'b0000;
                ctrl_stateMachine_state <= State_DummyCycles;
              end
            end
          end
          State_CsSetup : begin
            ctrl_stateMachine_cs[0] <= 1'b0;
            if(ctrl_clockDivider_io_tick) begin
              ctrl_stateMachine_state <= State_Idle;
            end
          end
          State_DummyCycles : begin
            if(ctrl_clockDivider_io_tick) begin
              ctrl_dataCounter_value <= (ctrl_dataCounter_value + 4'b0001);
              if(when_SpiControllerCtrl_l193) begin
                ctrl_stateMachine_state <= State_Idle;
              end
            end
          end
          State_DataSingle : begin
            if(ctrl_clockDivider_io_tick) begin
              ctrl_dataCounter_value <= (ctrl_dataCounter_value + 4'b0001);
              if(when_SpiControllerCtrl_l205) begin
                ctrl_stateMachine_state <= State_Idle;
              end
            end
          end
          State_DataDual : begin
            if(ctrl_clockDivider_io_tick) begin
              ctrl_dataCounter_value <= (ctrl_dataCounter_value + 4'b0001);
              if(when_SpiControllerCtrl_l217) begin
                ctrl_stateMachine_state <= State_Idle;
              end
            end
          end
          State_DataQuad : begin
            if(ctrl_clockDivider_io_tick) begin
              ctrl_dataCounter_value <= (ctrl_dataCounter_value + 4'b0001);
              if(when_SpiControllerCtrl_l232) begin
                ctrl_stateMachine_state <= State_Idle;
              end
            end
          end
          State_CsHold : begin
            if(ctrl_clockDivider_io_tick) begin
              ctrl_stateMachine_state <= State_CsDisable;
            end
          end
          State_CsDisable : begin
            ctrl_stateMachine_cs[0] <= 1'b1;
            if(ctrl_clockDivider_io_tick) begin
              ctrl_stateMachine_state <= State_Idle;
            end
          end
          default : begin
          end
        endcase
      end
    end
  end

  always @(posedge clk) begin
    if(ctrl_newClockEnable) begin
      case(ctrl_stateMachine_state)
        State_DataSingle : begin
          if(ctrl_clockDivider_io_tick) begin
            if(when_SpiControllerCtrl_l202) begin
              ctrl_stateMachine_buffer <= _zz_ctrl_stateMachine_buffer[7:0];
            end
          end
        end
        State_DataDual : begin
          if(ctrl_clockDivider_io_tick) begin
            if(when_SpiControllerCtrl_l214) begin
              ctrl_stateMachine_buffer <= _zz_ctrl_stateMachine_buffer_1[7:0];
            end
          end
        end
        State_DataQuad : begin
          if(ctrl_clockDivider_io_tick) begin
            if(when_SpiControllerCtrl_l226) begin
              ctrl_stateMachine_buffer <= _zz_ctrl_stateMachine_buffer_2[7:0];
            end
          end
        end
        default : begin
        end
      endcase
    end
  end

  always @(posedge clk) begin
    _zz_io_spi_sclk <= (((io_cmd_valid && ((io_cmd_payload_mode == CmdMode_DATA) || (io_cmd_payload_mode == CmdMode_DUMMYCYCLES))) && (ctrl_dataCounter_value[0] ^ io_modeConfig_cpha)) ^ io_modeConfig_cpol);
  end

  always @(posedge clk) begin
    _zz_io_spi_dq_write <= _zz__zz_io_spi_dq_write[_zz__zz_io_spi_dq_write_1];
  end

  always @(posedge clk) begin
    _zz_io_spi_dq_write_2 <= _zz__zz_io_spi_dq_write_2_1[_zz__zz_io_spi_dq_write_2_2];
    _zz_io_spi_dq_write_3 <= _zz__zz_io_spi_dq_write_3[_zz__zz_io_spi_dq_write_3_1];
  end

  always @(posedge clk) begin
    _zz_io_spi_dq_write_5 <= _zz__zz_io_spi_dq_write_5[_zz__zz_io_spi_dq_write_5_1];
    _zz_io_spi_dq_write_6 <= _zz__zz_io_spi_dq_write_6[_zz__zz_io_spi_dq_write_6_1];
    _zz_io_spi_dq_write_7 <= _zz__zz_io_spi_dq_write_7[_zz__zz_io_spi_dq_write_7_1];
    _zz_io_spi_dq_write_8 <= _zz__zz_io_spi_dq_write_8[_zz__zz_io_spi_dq_write_8_1];
  end


endmodule

module StreamFifo (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  input  wire [7:0]    io_push_payload,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire [7:0]    io_pop_payload,
  input  wire          io_flush,
  output wire [4:0]    io_occupancy,
  output wire [4:0]    io_availability,
  input  wire          clk,
  input  wire          resetn
);

  reg        [7:0]    logic_ram_spinal_port1;
  reg                 _zz_1;
  wire                logic_ptr_doPush;
  wire                logic_ptr_doPop;
  wire                logic_ptr_full;
  wire                logic_ptr_empty;
  reg        [4:0]    logic_ptr_push;
  reg        [4:0]    logic_ptr_pop;
  wire       [4:0]    logic_ptr_occupancy;
  wire       [4:0]    logic_ptr_popOnIo;
  wire                when_Stream_l1455;
  reg                 logic_ptr_wentUp;
  wire                io_push_fire;
  wire                logic_push_onRam_write_valid;
  wire       [3:0]    logic_push_onRam_write_payload_address;
  wire       [7:0]    logic_push_onRam_write_payload_data;
  wire                logic_pop_addressGen_valid;
  reg                 logic_pop_addressGen_ready;
  wire       [3:0]    logic_pop_addressGen_payload;
  wire                logic_pop_addressGen_fire;
  wire                logic_pop_sync_readArbitation_valid;
  wire                logic_pop_sync_readArbitation_ready;
  wire       [3:0]    logic_pop_sync_readArbitation_payload;
  reg                 logic_pop_addressGen_rValid;
  reg        [3:0]    logic_pop_addressGen_rData;
  wire                when_Stream_l477;
  wire                logic_pop_sync_readPort_cmd_valid;
  wire       [3:0]    logic_pop_sync_readPort_cmd_payload;
  wire       [7:0]    logic_pop_sync_readPort_rsp;
  wire                logic_pop_addressGen_toFlowFire_valid;
  wire       [3:0]    logic_pop_addressGen_toFlowFire_payload;
  wire                logic_pop_sync_readArbitation_translated_valid;
  wire                logic_pop_sync_readArbitation_translated_ready;
  wire       [7:0]    logic_pop_sync_readArbitation_translated_payload;
  wire                logic_pop_sync_readArbitation_fire;
  reg        [4:0]    logic_pop_sync_popReg;
  reg [7:0] logic_ram [0:15];

  always @(posedge clk) begin
    if(_zz_1) begin
      logic_ram[logic_push_onRam_write_payload_address] <= logic_push_onRam_write_payload_data;
    end
  end

  always @(posedge clk) begin
    if(logic_pop_sync_readPort_cmd_valid) begin
      logic_ram_spinal_port1 <= logic_ram[logic_pop_sync_readPort_cmd_payload];
    end
  end

  always @(*) begin
    _zz_1 = 1'b0;
    if(logic_push_onRam_write_valid) begin
      _zz_1 = 1'b1;
    end
  end

  assign when_Stream_l1455 = (logic_ptr_doPush != logic_ptr_doPop);
  assign logic_ptr_full = (((logic_ptr_push ^ logic_ptr_popOnIo) ^ 5'h10) == 5'h0);
  assign logic_ptr_empty = (logic_ptr_push == logic_ptr_pop);
  assign logic_ptr_occupancy = (logic_ptr_push - logic_ptr_popOnIo);
  assign io_push_ready = (! logic_ptr_full);
  assign io_push_fire = (io_push_valid && io_push_ready);
  assign logic_ptr_doPush = io_push_fire;
  assign logic_push_onRam_write_valid = io_push_fire;
  assign logic_push_onRam_write_payload_address = logic_ptr_push[3:0];
  assign logic_push_onRam_write_payload_data = io_push_payload;
  assign logic_pop_addressGen_valid = (! logic_ptr_empty);
  assign logic_pop_addressGen_payload = logic_ptr_pop[3:0];
  assign logic_pop_addressGen_fire = (logic_pop_addressGen_valid && logic_pop_addressGen_ready);
  assign logic_ptr_doPop = logic_pop_addressGen_fire;
  always @(*) begin
    logic_pop_addressGen_ready = logic_pop_sync_readArbitation_ready;
    if(when_Stream_l477) begin
      logic_pop_addressGen_ready = 1'b1;
    end
  end

  assign when_Stream_l477 = (! logic_pop_sync_readArbitation_valid);
  assign logic_pop_sync_readArbitation_valid = logic_pop_addressGen_rValid;
  assign logic_pop_sync_readArbitation_payload = logic_pop_addressGen_rData;
  assign logic_pop_sync_readPort_rsp = logic_ram_spinal_port1;
  assign logic_pop_addressGen_toFlowFire_valid = logic_pop_addressGen_fire;
  assign logic_pop_addressGen_toFlowFire_payload = logic_pop_addressGen_payload;
  assign logic_pop_sync_readPort_cmd_valid = logic_pop_addressGen_toFlowFire_valid;
  assign logic_pop_sync_readPort_cmd_payload = logic_pop_addressGen_toFlowFire_payload;
  assign logic_pop_sync_readArbitation_translated_valid = logic_pop_sync_readArbitation_valid;
  assign logic_pop_sync_readArbitation_ready = logic_pop_sync_readArbitation_translated_ready;
  assign logic_pop_sync_readArbitation_translated_payload = logic_pop_sync_readPort_rsp;
  assign io_pop_valid = logic_pop_sync_readArbitation_translated_valid;
  assign logic_pop_sync_readArbitation_translated_ready = io_pop_ready;
  assign io_pop_payload = logic_pop_sync_readArbitation_translated_payload;
  assign logic_pop_sync_readArbitation_fire = (logic_pop_sync_readArbitation_valid && logic_pop_sync_readArbitation_ready);
  assign logic_ptr_popOnIo = logic_pop_sync_popReg;
  assign io_occupancy = logic_ptr_occupancy;
  assign io_availability = (5'h10 - logic_ptr_occupancy);
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      logic_ptr_push <= 5'h0;
      logic_ptr_pop <= 5'h0;
      logic_ptr_wentUp <= 1'b0;
      logic_pop_addressGen_rValid <= 1'b0;
      logic_pop_sync_popReg <= 5'h0;
    end else begin
      if(when_Stream_l1455) begin
        logic_ptr_wentUp <= logic_ptr_doPush;
      end
      if(io_flush) begin
        logic_ptr_wentUp <= 1'b0;
      end
      if(logic_ptr_doPush) begin
        logic_ptr_push <= (logic_ptr_push + 5'h01);
      end
      if(logic_ptr_doPop) begin
        logic_ptr_pop <= (logic_ptr_pop + 5'h01);
      end
      if(io_flush) begin
        logic_ptr_push <= 5'h0;
        logic_ptr_pop <= 5'h0;
      end
      if(logic_pop_addressGen_ready) begin
        logic_pop_addressGen_rValid <= logic_pop_addressGen_valid;
      end
      if(io_flush) begin
        logic_pop_addressGen_rValid <= 1'b0;
      end
      if(logic_pop_sync_readArbitation_fire) begin
        logic_pop_sync_popReg <= logic_ptr_pop;
      end
      if(io_flush) begin
        logic_pop_sync_popReg <= 5'h0;
      end
    end
  end

  always @(posedge clk) begin
    if(logic_pop_addressGen_ready) begin
      logic_pop_addressGen_rData <= logic_pop_addressGen_payload;
    end
  end


endmodule

module ClockDivider (
  input  wire [15:0]   io_value,
  input  wire          io_reload,
  output wire          io_tick,
  input  wire          clk,
  input  wire          resetn,
  input  wire          ctrl_newClockEnable
);

  reg        [15:0]   counter;
  wire                tick;
  wire                when_ClockDivider_l26;

  assign tick = (counter == 16'h0);
  assign when_ClockDivider_l26 = (tick || io_reload);
  assign io_tick = tick;
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      counter <= 16'h0;
    end else begin
      if(ctrl_newClockEnable) begin
        counter <= (counter - 16'h0001);
        if(when_ClockDivider_l26) begin
          counter <= io_value;
        end
      end
    end
  end


endmodule
