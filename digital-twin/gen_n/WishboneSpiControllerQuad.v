// Generator : SpinalHDL v1.13.0    git head : d9d72474863badf47d8585d187f3e04ae4749c59
// Component : WishboneSpiControllerQuad
// Git hash  : 58d827afb766b3e54c8e02d57b05f468cf844e91

`timescale 1ns/1ps

module WishboneSpiControllerQuad (
  input  wire          io_bus_CYC,
  input  wire          io_bus_STB,
  output wire          io_bus_ACK,
  input  wire          io_bus_WE,
  input  wire [9:0]    io_bus_ADR,
  output reg  [31:0]   io_bus_DAT_MISO,
  input  wire [31:0]   io_bus_DAT_MOSI,
  output wire [0:0]    io_spi_cs,
  output wire          io_spi_sclk,
  input  wire [3:0]    io_spi_dq_read,
  output wire [3:0]    io_spi_dq_write,
  output wire [3:0]    io_spi_dq_writeEnable,
  output wire          io_interrupt,
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

  reg                 io_rsp_queueWithOccupancy_io_pop_ready;
  reg        [1:0]    interruptCtrl_1_io_inputs;
  reg        [1:0]    interruptCtrl_1_io_clears;
  wire       [0:0]    spiControllerCtrl_1_io_spi_cs;
  wire                spiControllerCtrl_1_io_spi_sclk;
  wire       [3:0]    spiControllerCtrl_1_io_spi_dq_write;
  wire       [3:0]    spiControllerCtrl_1_io_spi_dq_writeEnable;
  wire                spiControllerCtrl_1_io_interrupt;
  wire                spiControllerCtrl_1_io_cmd_ready;
  wire                spiControllerCtrl_1_io_rsp_valid;
  wire       [7:0]    spiControllerCtrl_1_io_rsp_payload;
  wire       [31:0]   ipIdentificationCtrl_1_io_header;
  wire       [31:0]   ipIdentificationCtrl_1_io_version;
  wire                streamFifo_2_io_push_ready;
  wire                streamFifo_2_io_pop_valid;
  wire       [1:0]    streamFifo_2_io_pop_payload_mode;
  wire       [12:0]   streamFifo_2_io_pop_payload_args;
  wire       [4:0]    streamFifo_2_io_occupancy;
  wire       [4:0]    streamFifo_2_io_availability;
  wire                io_rsp_queueWithOccupancy_io_push_ready;
  wire                io_rsp_queueWithOccupancy_io_pop_valid;
  wire       [7:0]    io_rsp_queueWithOccupancy_io_pop_payload;
  wire       [4:0]    io_rsp_queueWithOccupancy_io_occupancy;
  wire       [4:0]    io_rsp_queueWithOccupancy_io_availability;
  wire       [1:0]    interruptCtrl_1_io_pendings;
  wire       [0:0]    _zz__zz_io_push_payload_args;
  wire       [4:0]    _zz__zz_io_push_payload_args_1;
  wire                busFactory_readErrorFlag;
  wire                busFactory_writeErrorFlag;
  wire                busFactory_askWrite;
  wire                busFactory_askRead;
  wire                busFactory_doWrite;
  wire                busFactory_doRead;
  reg                 _zz_io_bus_ACK;
  wire       [11:0]   busFactory_byteAddress;
  reg        [15:0]   _zz_io_bus_DAT_MISO;
  reg        [0:0]    _zz_io_bus_DAT_MISO_1;
  reg        [15:0]   _zz_io_bus_DAT_MISO_2;
  reg        [15:0]   _zz_io_bus_DAT_MISO_3;
  reg        [15:0]   _zz_io_bus_DAT_MISO_4;
  reg                 _zz_io_bus_DAT_MISO_5;
  reg                 _zz_io_bus_DAT_MISO_6;
  wire       [1:0]    _zz_io_modeConfig_busWidth;
  wire       [1:0]    _zz_io_push_payload_mode;
  reg        [12:0]   _zz_io_push_payload_args;
  reg                 _zz_io_push_valid;
  wire                io_rsp_toStream_valid;
  wire                io_rsp_toStream_ready;
  wire       [7:0]    io_rsp_toStream_payload;
  reg        [1:0]    io_masks_driver;
  wire       [1:0]    _zz_io_push_payload_mode_1;
  `ifndef SYNTHESIS
  reg [47:0] _zz_io_modeConfig_busWidth_string;
  reg [87:0] _zz_io_push_payload_mode_string;
  reg [87:0] _zz_io_push_payload_mode_1_string;
  `endif


  assign _zz__zz_io_push_payload_args = io_bus_DAT_MOSI[24];
  assign _zz__zz_io_push_payload_args_1 = io_bus_DAT_MOSI[4 : 0];
  SpiControllerCtrl spiControllerCtrl_1 (
    .io_config_clockDivider  (_zz_io_bus_DAT_MISO[15:0]                     ), //i
    .io_config_cs_activeHigh (_zz_io_bus_DAT_MISO_1                         ), //i
    .io_config_cs_setup      (_zz_io_bus_DAT_MISO_2[15:0]                   ), //i
    .io_config_cs_hold       (_zz_io_bus_DAT_MISO_3[15:0]                   ), //i
    .io_config_cs_disable    (_zz_io_bus_DAT_MISO_4[15:0]                   ), //i
    .io_modeConfig_cpol      (_zz_io_bus_DAT_MISO_5                         ), //i
    .io_modeConfig_cpha      (_zz_io_bus_DAT_MISO_6                         ), //i
    .io_modeConfig_busWidth  (_zz_io_modeConfig_busWidth[1:0]               ), //i
    .io_spi_cs               (spiControllerCtrl_1_io_spi_cs                 ), //o
    .io_spi_sclk             (spiControllerCtrl_1_io_spi_sclk               ), //o
    .io_spi_dq_read          (io_spi_dq_read[3:0]                           ), //i
    .io_spi_dq_write         (spiControllerCtrl_1_io_spi_dq_write[3:0]      ), //o
    .io_spi_dq_writeEnable   (spiControllerCtrl_1_io_spi_dq_writeEnable[3:0]), //o
    .io_interrupt            (spiControllerCtrl_1_io_interrupt              ), //o
    .io_pendingInterrupts    (interruptCtrl_1_io_pendings[1:0]              ), //i
    .io_cmd_valid            (streamFifo_2_io_pop_valid                     ), //i
    .io_cmd_ready            (spiControllerCtrl_1_io_cmd_ready              ), //o
    .io_cmd_payload_mode     (streamFifo_2_io_pop_payload_mode[1:0]         ), //i
    .io_cmd_payload_args     (streamFifo_2_io_pop_payload_args[12:0]        ), //i
    .io_rsp_valid            (spiControllerCtrl_1_io_rsp_valid              ), //o
    .io_rsp_payload          (spiControllerCtrl_1_io_rsp_payload[7:0]       ), //o
    .clk                     (clk                                           ), //i
    .resetn                  (resetn                                        )  //i
  );
  IpIdentificationCtrl ipIdentificationCtrl_1 (
    .io_header  (ipIdentificationCtrl_1_io_header[31:0] ), //o
    .io_version (ipIdentificationCtrl_1_io_version[31:0]), //o
    .clk        (clk                                    ), //i
    .resetn     (resetn                                 )  //i
  );
  StreamFifo streamFifo_2 (
    .io_push_valid        (_zz_io_push_valid                     ), //i
    .io_push_ready        (streamFifo_2_io_push_ready            ), //o
    .io_push_payload_mode (_zz_io_push_payload_mode[1:0]         ), //i
    .io_push_payload_args (_zz_io_push_payload_args[12:0]        ), //i
    .io_pop_valid         (streamFifo_2_io_pop_valid             ), //o
    .io_pop_ready         (spiControllerCtrl_1_io_cmd_ready      ), //i
    .io_pop_payload_mode  (streamFifo_2_io_pop_payload_mode[1:0] ), //o
    .io_pop_payload_args  (streamFifo_2_io_pop_payload_args[12:0]), //o
    .io_flush             (1'b0                                  ), //i
    .io_occupancy         (streamFifo_2_io_occupancy[4:0]        ), //o
    .io_availability      (streamFifo_2_io_availability[4:0]     ), //o
    .clk                  (clk                                   ), //i
    .resetn               (resetn                                )  //i
  );
  StreamFifo_1 io_rsp_queueWithOccupancy (
    .io_push_valid   (io_rsp_toStream_valid                         ), //i
    .io_push_ready   (io_rsp_queueWithOccupancy_io_push_ready       ), //o
    .io_push_payload (io_rsp_toStream_payload[7:0]                  ), //i
    .io_pop_valid    (io_rsp_queueWithOccupancy_io_pop_valid        ), //o
    .io_pop_ready    (io_rsp_queueWithOccupancy_io_pop_ready        ), //i
    .io_pop_payload  (io_rsp_queueWithOccupancy_io_pop_payload[7:0] ), //o
    .io_flush        (1'b0                                          ), //i
    .io_occupancy    (io_rsp_queueWithOccupancy_io_occupancy[4:0]   ), //o
    .io_availability (io_rsp_queueWithOccupancy_io_availability[4:0]), //o
    .clk             (clk                                           ), //i
    .resetn          (resetn                                        )  //i
  );
  InterruptCtrl interruptCtrl_1 (
    .io_inputs   (interruptCtrl_1_io_inputs[1:0]  ), //i
    .io_clears   (interruptCtrl_1_io_clears[1:0]  ), //i
    .io_masks    (io_masks_driver[1:0]            ), //i
    .io_pendings (interruptCtrl_1_io_pendings[1:0]), //o
    .clk         (clk                             ), //i
    .resetn      (resetn                          )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(_zz_io_modeConfig_busWidth)
      SpiBusWidth_Single : _zz_io_modeConfig_busWidth_string = "Single";
      SpiBusWidth_Dual : _zz_io_modeConfig_busWidth_string = "Dual  ";
      SpiBusWidth_Quad : _zz_io_modeConfig_busWidth_string = "Quad  ";
      SpiBusWidth_Octa : _zz_io_modeConfig_busWidth_string = "Octa  ";
      default : _zz_io_modeConfig_busWidth_string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_io_push_payload_mode)
      CmdMode_DATA : _zz_io_push_payload_mode_string = "DATA       ";
      CmdMode_CS : _zz_io_push_payload_mode_string = "CS         ";
      CmdMode_DUMMYCYCLES : _zz_io_push_payload_mode_string = "DUMMYCYCLES";
      default : _zz_io_push_payload_mode_string = "???????????";
    endcase
  end
  always @(*) begin
    case(_zz_io_push_payload_mode_1)
      CmdMode_DATA : _zz_io_push_payload_mode_1_string = "DATA       ";
      CmdMode_CS : _zz_io_push_payload_mode_1_string = "CS         ";
      CmdMode_DUMMYCYCLES : _zz_io_push_payload_mode_1_string = "DUMMYCYCLES";
      default : _zz_io_push_payload_mode_1_string = "???????????";
    endcase
  end
  `endif

  assign io_spi_cs = spiControllerCtrl_1_io_spi_cs;
  assign io_spi_sclk = spiControllerCtrl_1_io_spi_sclk;
  assign io_spi_dq_write = spiControllerCtrl_1_io_spi_dq_write;
  assign io_spi_dq_writeEnable = spiControllerCtrl_1_io_spi_dq_writeEnable;
  assign io_interrupt = spiControllerCtrl_1_io_interrupt;
  assign busFactory_readErrorFlag = 1'b0;
  assign busFactory_writeErrorFlag = 1'b0;
  always @(*) begin
    io_bus_DAT_MISO = 32'h0;
    case(busFactory_byteAddress)
      12'h0 : begin
        io_bus_DAT_MISO[31 : 0] = ipIdentificationCtrl_1_io_header;
      end
      12'h004 : begin
        io_bus_DAT_MISO[31 : 0] = ipIdentificationCtrl_1_io_version;
      end
      12'h008 : begin
        io_bus_DAT_MISO[31 : 0] = {{8'h0,16'h0001},8'h04};
      end
      12'h00c : begin
        io_bus_DAT_MISO[31 : 0] = {24'h0,8'h10};
      end
      12'h010 : begin
        io_bus_DAT_MISO[31 : 0] = {{16'h0,8'h10},8'h10};
      end
      12'h014 : begin
        io_bus_DAT_MISO[31 : 0] = {30'h0,{1'b1,1'b1}};
      end
      12'h028 : begin
        io_bus_DAT_MISO[15 : 0] = _zz_io_bus_DAT_MISO;
      end
      12'h030 : begin
        io_bus_DAT_MISO[15 : 0] = _zz_io_bus_DAT_MISO_3;
      end
      12'h034 : begin
        io_bus_DAT_MISO[15 : 0] = _zz_io_bus_DAT_MISO_4;
      end
      12'h038 : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO_1;
      end
      12'h02c : begin
        io_bus_DAT_MISO[15 : 0] = _zz_io_bus_DAT_MISO_2;
      end
      12'h03c : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO_5;
      end
      12'h040 : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO_6;
      end
      12'h050 : begin
        io_bus_DAT_MISO[31 : 31] = (io_rsp_queueWithOccupancy_io_pop_valid ^ 1'b0);
        io_bus_DAT_MISO[7 : 0] = io_rsp_queueWithOccupancy_io_pop_payload;
      end
      12'h054 : begin
        io_bus_DAT_MISO[20 : 16] = streamFifo_2_io_availability;
        io_bus_DAT_MISO[4 : 0] = io_rsp_queueWithOccupancy_io_occupancy;
      end
      12'h058 : begin
        io_bus_DAT_MISO[1 : 0] = interruptCtrl_1_io_pendings;
      end
      12'h05c : begin
        io_bus_DAT_MISO[1 : 0] = io_masks_driver;
      end
      default : begin
      end
    endcase
  end

  assign busFactory_askWrite = ((io_bus_CYC && io_bus_STB) && io_bus_WE);
  assign busFactory_askRead = ((io_bus_CYC && io_bus_STB) && (! io_bus_WE));
  assign busFactory_doWrite = (((io_bus_CYC && io_bus_STB) && ((io_bus_CYC && io_bus_ACK) && io_bus_STB)) && io_bus_WE);
  assign busFactory_doRead = (((io_bus_CYC && io_bus_STB) && ((io_bus_CYC && io_bus_ACK) && io_bus_STB)) && (! io_bus_WE));
  assign io_bus_ACK = (_zz_io_bus_ACK && io_bus_STB);
  assign busFactory_byteAddress = ({2'd0,io_bus_ADR} <<< 2'd2);
  assign _zz_io_modeConfig_busWidth = SpiBusWidth_Single;
  always @(*) begin
    _zz_io_push_valid = 1'b0;
    case(busFactory_byteAddress)
      12'h050 : begin
        if(busFactory_doWrite) begin
          _zz_io_push_valid = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    case(_zz_io_push_payload_mode)
      CmdMode_DATA : begin
        _zz_io_push_payload_args = {io_bus_DAT_MOSI[24],{io_bus_DAT_MOSI[19 : 16],io_bus_DAT_MOSI[7 : 0]}};
      end
      CmdMode_CS : begin
        _zz_io_push_payload_args = {12'd0, _zz__zz_io_push_payload_args};
      end
      default : begin
        _zz_io_push_payload_args = {8'd0, _zz__zz_io_push_payload_args_1};
      end
    endcase
  end

  assign io_rsp_toStream_valid = spiControllerCtrl_1_io_rsp_valid;
  assign io_rsp_toStream_payload = spiControllerCtrl_1_io_rsp_payload;
  assign io_rsp_toStream_ready = io_rsp_queueWithOccupancy_io_push_ready;
  always @(*) begin
    io_rsp_queueWithOccupancy_io_pop_ready = 1'b0;
    case(busFactory_byteAddress)
      12'h050 : begin
        if(busFactory_doRead) begin
          io_rsp_queueWithOccupancy_io_pop_ready = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    interruptCtrl_1_io_clears = 2'b00;
    case(busFactory_byteAddress)
      12'h058 : begin
        if(busFactory_doWrite) begin
          interruptCtrl_1_io_clears = io_bus_DAT_MOSI[1 : 0];
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    interruptCtrl_1_io_inputs[0] = (! streamFifo_2_io_pop_valid);
    interruptCtrl_1_io_inputs[1] = io_rsp_queueWithOccupancy_io_pop_valid;
  end

  assign _zz_io_push_payload_mode_1 = io_bus_DAT_MOSI[29 : 28];
  assign _zz_io_push_payload_mode = _zz_io_push_payload_mode_1;
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      _zz_io_bus_ACK <= 1'b0;
      _zz_io_bus_DAT_MISO <= 16'h0003;
      _zz_io_bus_DAT_MISO_2 <= 16'h0003;
      _zz_io_bus_DAT_MISO_3 <= 16'h0003;
      _zz_io_bus_DAT_MISO_4 <= 16'h0003;
      _zz_io_bus_DAT_MISO_1 <= 1'b0;
      _zz_io_bus_DAT_MISO_5 <= 1'b0;
      _zz_io_bus_DAT_MISO_6 <= 1'b0;
      io_masks_driver <= 2'b00;
    end else begin
      _zz_io_bus_ACK <= (io_bus_STB && io_bus_CYC);
      case(busFactory_byteAddress)
        12'h028 : begin
          if(busFactory_doWrite) begin
            _zz_io_bus_DAT_MISO <= io_bus_DAT_MOSI[15 : 0];
          end
        end
        12'h030 : begin
          if(busFactory_doWrite) begin
            _zz_io_bus_DAT_MISO_2 <= io_bus_DAT_MOSI[15 : 0];
          end
        end
        12'h034 : begin
          if(busFactory_doWrite) begin
            _zz_io_bus_DAT_MISO_3 <= io_bus_DAT_MOSI[15 : 0];
          end
        end
        12'h038 : begin
          if(busFactory_doWrite) begin
            _zz_io_bus_DAT_MISO_4 <= io_bus_DAT_MOSI[15 : 0];
            _zz_io_bus_DAT_MISO_1 <= io_bus_DAT_MOSI[0 : 0];
          end
        end
        12'h03c : begin
          if(busFactory_doWrite) begin
            _zz_io_bus_DAT_MISO_5 <= io_bus_DAT_MOSI[0];
          end
        end
        12'h040 : begin
          if(busFactory_doWrite) begin
            _zz_io_bus_DAT_MISO_6 <= io_bus_DAT_MOSI[0];
          end
        end
        12'h05c : begin
          if(busFactory_doWrite) begin
            io_masks_driver <= io_bus_DAT_MOSI[1 : 0];
          end
        end
        default : begin
        end
      endcase
    end
  end


endmodule

module InterruptCtrl (
  input  wire [1:0]    io_inputs,
  input  wire [1:0]    io_clears,
  input  wire [1:0]    io_masks,
  output wire [1:0]    io_pendings,
  input  wire          clk,
  input  wire          resetn
);

  reg        [1:0]    pendings;

  assign io_pendings = (pendings & io_masks);
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      pendings <= 2'b00;
    end else begin
      pendings <= ((pendings & (~ io_clears)) | io_inputs);
    end
  end


endmodule

module StreamFifo_1 (
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

module StreamFifo (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  input  wire [1:0]    io_push_payload_mode,
  input  wire [12:0]   io_push_payload_args,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire [1:0]    io_pop_payload_mode,
  output wire [12:0]   io_pop_payload_args,
  input  wire          io_flush,
  output wire [4:0]    io_occupancy,
  output wire [4:0]    io_availability,
  input  wire          clk,
  input  wire          resetn
);
  localparam CmdMode_DATA = 2'd0;
  localparam CmdMode_CS = 2'd1;
  localparam CmdMode_DUMMYCYCLES = 2'd2;

  reg        [14:0]   logic_ram_spinal_port1;
  wire       [14:0]   _zz_logic_ram_port;
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
  wire       [1:0]    logic_push_onRam_write_payload_data_mode;
  wire       [12:0]   logic_push_onRam_write_payload_data_args;
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
  wire       [1:0]    logic_pop_sync_readPort_rsp_mode;
  wire       [12:0]   logic_pop_sync_readPort_rsp_args;
  wire       [1:0]    _zz_logic_pop_sync_readPort_rsp_mode;
  wire       [14:0]   _zz_logic_pop_sync_readPort_rsp_args;
  wire       [1:0]    _zz_logic_pop_sync_readPort_rsp_mode_1;
  wire                logic_pop_addressGen_toFlowFire_valid;
  wire       [3:0]    logic_pop_addressGen_toFlowFire_payload;
  wire                logic_pop_sync_readArbitation_translated_valid;
  wire                logic_pop_sync_readArbitation_translated_ready;
  wire       [1:0]    logic_pop_sync_readArbitation_translated_payload_mode;
  wire       [12:0]   logic_pop_sync_readArbitation_translated_payload_args;
  wire                logic_pop_sync_readArbitation_fire;
  reg        [4:0]    logic_pop_sync_popReg;
  `ifndef SYNTHESIS
  reg [87:0] io_push_payload_mode_string;
  reg [87:0] io_pop_payload_mode_string;
  reg [87:0] logic_push_onRam_write_payload_data_mode_string;
  reg [87:0] logic_pop_sync_readPort_rsp_mode_string;
  reg [87:0] _zz_logic_pop_sync_readPort_rsp_mode_string;
  reg [87:0] _zz_logic_pop_sync_readPort_rsp_mode_1_string;
  reg [87:0] logic_pop_sync_readArbitation_translated_payload_mode_string;
  `endif

  reg [14:0] logic_ram [0:15];

  assign _zz_logic_ram_port = {logic_push_onRam_write_payload_data_args,logic_push_onRam_write_payload_data_mode};
  always @(posedge clk) begin
    if(_zz_1) begin
      logic_ram[logic_push_onRam_write_payload_address] <= _zz_logic_ram_port;
    end
  end

  always @(posedge clk) begin
    if(logic_pop_sync_readPort_cmd_valid) begin
      logic_ram_spinal_port1 <= logic_ram[logic_pop_sync_readPort_cmd_payload];
    end
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(io_push_payload_mode)
      CmdMode_DATA : io_push_payload_mode_string = "DATA       ";
      CmdMode_CS : io_push_payload_mode_string = "CS         ";
      CmdMode_DUMMYCYCLES : io_push_payload_mode_string = "DUMMYCYCLES";
      default : io_push_payload_mode_string = "???????????";
    endcase
  end
  always @(*) begin
    case(io_pop_payload_mode)
      CmdMode_DATA : io_pop_payload_mode_string = "DATA       ";
      CmdMode_CS : io_pop_payload_mode_string = "CS         ";
      CmdMode_DUMMYCYCLES : io_pop_payload_mode_string = "DUMMYCYCLES";
      default : io_pop_payload_mode_string = "???????????";
    endcase
  end
  always @(*) begin
    case(logic_push_onRam_write_payload_data_mode)
      CmdMode_DATA : logic_push_onRam_write_payload_data_mode_string = "DATA       ";
      CmdMode_CS : logic_push_onRam_write_payload_data_mode_string = "CS         ";
      CmdMode_DUMMYCYCLES : logic_push_onRam_write_payload_data_mode_string = "DUMMYCYCLES";
      default : logic_push_onRam_write_payload_data_mode_string = "???????????";
    endcase
  end
  always @(*) begin
    case(logic_pop_sync_readPort_rsp_mode)
      CmdMode_DATA : logic_pop_sync_readPort_rsp_mode_string = "DATA       ";
      CmdMode_CS : logic_pop_sync_readPort_rsp_mode_string = "CS         ";
      CmdMode_DUMMYCYCLES : logic_pop_sync_readPort_rsp_mode_string = "DUMMYCYCLES";
      default : logic_pop_sync_readPort_rsp_mode_string = "???????????";
    endcase
  end
  always @(*) begin
    case(_zz_logic_pop_sync_readPort_rsp_mode)
      CmdMode_DATA : _zz_logic_pop_sync_readPort_rsp_mode_string = "DATA       ";
      CmdMode_CS : _zz_logic_pop_sync_readPort_rsp_mode_string = "CS         ";
      CmdMode_DUMMYCYCLES : _zz_logic_pop_sync_readPort_rsp_mode_string = "DUMMYCYCLES";
      default : _zz_logic_pop_sync_readPort_rsp_mode_string = "???????????";
    endcase
  end
  always @(*) begin
    case(_zz_logic_pop_sync_readPort_rsp_mode_1)
      CmdMode_DATA : _zz_logic_pop_sync_readPort_rsp_mode_1_string = "DATA       ";
      CmdMode_CS : _zz_logic_pop_sync_readPort_rsp_mode_1_string = "CS         ";
      CmdMode_DUMMYCYCLES : _zz_logic_pop_sync_readPort_rsp_mode_1_string = "DUMMYCYCLES";
      default : _zz_logic_pop_sync_readPort_rsp_mode_1_string = "???????????";
    endcase
  end
  always @(*) begin
    case(logic_pop_sync_readArbitation_translated_payload_mode)
      CmdMode_DATA : logic_pop_sync_readArbitation_translated_payload_mode_string = "DATA       ";
      CmdMode_CS : logic_pop_sync_readArbitation_translated_payload_mode_string = "CS         ";
      CmdMode_DUMMYCYCLES : logic_pop_sync_readArbitation_translated_payload_mode_string = "DUMMYCYCLES";
      default : logic_pop_sync_readArbitation_translated_payload_mode_string = "???????????";
    endcase
  end
  `endif

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
  assign logic_push_onRam_write_payload_data_mode = io_push_payload_mode;
  assign logic_push_onRam_write_payload_data_args = io_push_payload_args;
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
  assign _zz_logic_pop_sync_readPort_rsp_args = logic_ram_spinal_port1;
  assign _zz_logic_pop_sync_readPort_rsp_mode_1 = _zz_logic_pop_sync_readPort_rsp_args[1 : 0];
  assign _zz_logic_pop_sync_readPort_rsp_mode = _zz_logic_pop_sync_readPort_rsp_mode_1;
  assign logic_pop_sync_readPort_rsp_mode = _zz_logic_pop_sync_readPort_rsp_mode;
  assign logic_pop_sync_readPort_rsp_args = _zz_logic_pop_sync_readPort_rsp_args[14 : 2];
  assign logic_pop_addressGen_toFlowFire_valid = logic_pop_addressGen_fire;
  assign logic_pop_addressGen_toFlowFire_payload = logic_pop_addressGen_payload;
  assign logic_pop_sync_readPort_cmd_valid = logic_pop_addressGen_toFlowFire_valid;
  assign logic_pop_sync_readPort_cmd_payload = logic_pop_addressGen_toFlowFire_payload;
  assign logic_pop_sync_readArbitation_translated_valid = logic_pop_sync_readArbitation_valid;
  assign logic_pop_sync_readArbitation_ready = logic_pop_sync_readArbitation_translated_ready;
  assign logic_pop_sync_readArbitation_translated_payload_mode = logic_pop_sync_readPort_rsp_mode;
  assign logic_pop_sync_readArbitation_translated_payload_args = logic_pop_sync_readPort_rsp_args;
  assign io_pop_valid = logic_pop_sync_readArbitation_translated_valid;
  assign logic_pop_sync_readArbitation_translated_ready = io_pop_ready;
  assign io_pop_payload_mode = logic_pop_sync_readArbitation_translated_payload_mode;
  assign io_pop_payload_args = logic_pop_sync_readArbitation_translated_payload_args;
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
