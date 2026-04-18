// Generator : SpinalHDL v1.13.0    git head : d9d72474863badf47d8585d187f3e04ae4749c59
// Component : WishbonePio

`timescale 1ns/1ps

module WishbonePio (
  input  wire          io_bus_CYC,
  input  wire          io_bus_STB,
  output wire          io_bus_ACK,
  input  wire          io_bus_WE,
  input  wire [9:0]    io_bus_ADR,
  output reg  [31:0]   io_bus_DAT_MISO,
  input  wire [31:0]   io_bus_DAT_MOSI,
  input  wire [2:0]    io_pio_pins_read,
  output wire [2:0]    io_pio_pins_write,
  output wire [2:0]    io_pio_pins_writeEnable,
  input  wire          clk,
  input  wire          resetn
);
  localparam CommandType_HIGH = 2'd0;
  localparam CommandType_LOW = 2'd1;
  localparam CommandType_WAIT_1 = 2'd2;
  localparam CommandType_READ = 2'd3;

  wire                ctrl_io_readIsFull;
  reg                 io_read_queueWithOccupancy_io_pop_ready;
  wire       [2:0]    ctrl_io_pio_pins_write;
  wire       [2:0]    ctrl_io_pio_pins_writeEnable;
  wire                ctrl_io_commands_ready;
  wire                ctrl_io_read_valid;
  wire       [0:0]    ctrl_io_read_payload_result;
  wire       [31:0]   mapper_idCtrl_io_header;
  wire       [31:0]   mapper_idCtrl_io_version;
  wire                mapper_tx_streamUnbuffered_queueWithOccupancy_io_push_ready;
  wire                mapper_tx_streamUnbuffered_queueWithOccupancy_io_pop_valid;
  wire       [1:0]    mapper_tx_streamUnbuffered_queueWithOccupancy_io_pop_payload_command;
  wire       [1:0]    mapper_tx_streamUnbuffered_queueWithOccupancy_io_pop_payload_pin;
  wire       [23:0]   mapper_tx_streamUnbuffered_queueWithOccupancy_io_pop_payload_data;
  wire       [4:0]    mapper_tx_streamUnbuffered_queueWithOccupancy_io_occupancy;
  wire       [4:0]    mapper_tx_streamUnbuffered_queueWithOccupancy_io_availability;
  wire                io_read_queueWithOccupancy_io_push_ready;
  wire                io_read_queueWithOccupancy_io_pop_valid;
  wire       [0:0]    io_read_queueWithOccupancy_io_pop_payload_result;
  wire       [3:0]    io_read_queueWithOccupancy_io_occupancy;
  wire       [3:0]    io_read_queueWithOccupancy_io_availability;
  wire       [11:0]   _zz_3;
  wire                _zz_1;
  wire                _zz_2;
  reg                 _zz_io_bus_ACK;
  wire       [1:0]    mapper_tx_cmdContainer_command;
  wire       [1:0]    mapper_tx_cmdContainer_pin;
  wire       [23:0]   mapper_tx_cmdContainer_data;
  reg                 _zz_mapper_tx_streamUnbuffered_valid;
  wire       [1:0]    _zz_mapper_tx_streamUnbuffered_payload_command;
  wire                mapper_tx_streamUnbuffered_valid;
  wire                mapper_tx_streamUnbuffered_ready;
  wire       [1:0]    mapper_tx_streamUnbuffered_payload_command;
  wire       [1:0]    mapper_tx_streamUnbuffered_payload_pin;
  wire       [23:0]   mapper_tx_streamUnbuffered_payload_data;
  wire       [4:0]    mapper_tx_fifoVacancy;
  reg        [19:0]   mapper_clockDivider;
  reg        [7:0]    mapper_readDelay;
  wire       [27:0]   _zz_mapper_tx_streamUnbuffered_payload_pin;
  wire       [1:0]    _zz_mapper_tx_streamUnbuffered_payload_command_1;
  `ifndef SYNTHESIS
  reg [47:0] mapper_tx_cmdContainer_command_string;
  reg [47:0] _zz_mapper_tx_streamUnbuffered_payload_command_string;
  reg [47:0] mapper_tx_streamUnbuffered_payload_command_string;
  reg [47:0] _zz_mapper_tx_streamUnbuffered_payload_command_1_string;
  `endif


  assign _zz_3 = ({2'd0,io_bus_ADR} <<< 2'd2);
  PioCtrl ctrl (
    .io_pio_pins_read            (io_pio_pins_read[2:0]                                                    ), //i
    .io_pio_pins_write           (ctrl_io_pio_pins_write[2:0]                                              ), //o
    .io_pio_pins_writeEnable     (ctrl_io_pio_pins_writeEnable[2:0]                                        ), //o
    .io_config_clockDivider      (mapper_clockDivider[19:0]                                                ), //i
    .io_config_readDelay         (mapper_readDelay[7:0]                                                    ), //i
    .io_commands_valid           (mapper_tx_streamUnbuffered_queueWithOccupancy_io_pop_valid               ), //i
    .io_commands_ready           (ctrl_io_commands_ready                                                   ), //o
    .io_commands_payload_command (mapper_tx_streamUnbuffered_queueWithOccupancy_io_pop_payload_command[1:0]), //i
    .io_commands_payload_pin     (mapper_tx_streamUnbuffered_queueWithOccupancy_io_pop_payload_pin[1:0]    ), //i
    .io_commands_payload_data    (mapper_tx_streamUnbuffered_queueWithOccupancy_io_pop_payload_data[23:0]  ), //i
    .io_read_valid               (ctrl_io_read_valid                                                       ), //o
    .io_read_ready               (io_read_queueWithOccupancy_io_push_ready                                 ), //i
    .io_read_payload_result      (ctrl_io_read_payload_result                                              ), //o
    .io_readIsFull               (ctrl_io_readIsFull                                                       ), //i
    .clk                         (clk                                                                      ), //i
    .resetn                      (resetn                                                                   )  //i
  );
  IpIdentificationCtrl mapper_idCtrl (
    .io_header  (mapper_idCtrl_io_header[31:0] ), //o
    .io_version (mapper_idCtrl_io_version[31:0]), //o
    .clk        (clk                           ), //i
    .resetn     (resetn                        )  //i
  );
  StreamFifo mapper_tx_streamUnbuffered_queueWithOccupancy (
    .io_push_valid           (mapper_tx_streamUnbuffered_valid                                         ), //i
    .io_push_ready           (mapper_tx_streamUnbuffered_queueWithOccupancy_io_push_ready              ), //o
    .io_push_payload_command (mapper_tx_streamUnbuffered_payload_command[1:0]                          ), //i
    .io_push_payload_pin     (mapper_tx_streamUnbuffered_payload_pin[1:0]                              ), //i
    .io_push_payload_data    (mapper_tx_streamUnbuffered_payload_data[23:0]                            ), //i
    .io_pop_valid            (mapper_tx_streamUnbuffered_queueWithOccupancy_io_pop_valid               ), //o
    .io_pop_ready            (ctrl_io_commands_ready                                                   ), //i
    .io_pop_payload_command  (mapper_tx_streamUnbuffered_queueWithOccupancy_io_pop_payload_command[1:0]), //o
    .io_pop_payload_pin      (mapper_tx_streamUnbuffered_queueWithOccupancy_io_pop_payload_pin[1:0]    ), //o
    .io_pop_payload_data     (mapper_tx_streamUnbuffered_queueWithOccupancy_io_pop_payload_data[23:0]  ), //o
    .io_flush                (1'b0                                                                     ), //i
    .io_occupancy            (mapper_tx_streamUnbuffered_queueWithOccupancy_io_occupancy[4:0]          ), //o
    .io_availability         (mapper_tx_streamUnbuffered_queueWithOccupancy_io_availability[4:0]       ), //o
    .clk                     (clk                                                                      ), //i
    .resetn                  (resetn                                                                   )  //i
  );
  StreamFifo_1 io_read_queueWithOccupancy (
    .io_push_valid          (ctrl_io_read_valid                              ), //i
    .io_push_ready          (io_read_queueWithOccupancy_io_push_ready        ), //o
    .io_push_payload_result (ctrl_io_read_payload_result                     ), //i
    .io_pop_valid           (io_read_queueWithOccupancy_io_pop_valid         ), //o
    .io_pop_ready           (io_read_queueWithOccupancy_io_pop_ready         ), //i
    .io_pop_payload_result  (io_read_queueWithOccupancy_io_pop_payload_result), //o
    .io_flush               (1'b0                                            ), //i
    .io_occupancy           (io_read_queueWithOccupancy_io_occupancy[3:0]    ), //o
    .io_availability        (io_read_queueWithOccupancy_io_availability[3:0] ), //o
    .clk                    (clk                                             ), //i
    .resetn                 (resetn                                          )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(mapper_tx_cmdContainer_command)
      CommandType_HIGH : mapper_tx_cmdContainer_command_string = "HIGH  ";
      CommandType_LOW : mapper_tx_cmdContainer_command_string = "LOW   ";
      CommandType_WAIT_1 : mapper_tx_cmdContainer_command_string = "WAIT_1";
      CommandType_READ : mapper_tx_cmdContainer_command_string = "READ  ";
      default : mapper_tx_cmdContainer_command_string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_mapper_tx_streamUnbuffered_payload_command)
      CommandType_HIGH : _zz_mapper_tx_streamUnbuffered_payload_command_string = "HIGH  ";
      CommandType_LOW : _zz_mapper_tx_streamUnbuffered_payload_command_string = "LOW   ";
      CommandType_WAIT_1 : _zz_mapper_tx_streamUnbuffered_payload_command_string = "WAIT_1";
      CommandType_READ : _zz_mapper_tx_streamUnbuffered_payload_command_string = "READ  ";
      default : _zz_mapper_tx_streamUnbuffered_payload_command_string = "??????";
    endcase
  end
  always @(*) begin
    case(mapper_tx_streamUnbuffered_payload_command)
      CommandType_HIGH : mapper_tx_streamUnbuffered_payload_command_string = "HIGH  ";
      CommandType_LOW : mapper_tx_streamUnbuffered_payload_command_string = "LOW   ";
      CommandType_WAIT_1 : mapper_tx_streamUnbuffered_payload_command_string = "WAIT_1";
      CommandType_READ : mapper_tx_streamUnbuffered_payload_command_string = "READ  ";
      default : mapper_tx_streamUnbuffered_payload_command_string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_mapper_tx_streamUnbuffered_payload_command_1)
      CommandType_HIGH : _zz_mapper_tx_streamUnbuffered_payload_command_1_string = "HIGH  ";
      CommandType_LOW : _zz_mapper_tx_streamUnbuffered_payload_command_1_string = "LOW   ";
      CommandType_WAIT_1 : _zz_mapper_tx_streamUnbuffered_payload_command_1_string = "WAIT_1";
      CommandType_READ : _zz_mapper_tx_streamUnbuffered_payload_command_1_string = "READ  ";
      default : _zz_mapper_tx_streamUnbuffered_payload_command_1_string = "??????";
    endcase
  end
  `endif

  assign io_pio_pins_write = ctrl_io_pio_pins_write;
  assign io_pio_pins_writeEnable = ctrl_io_pio_pins_writeEnable;
  always @(*) begin
    io_bus_DAT_MISO = 32'h0;
    case(_zz_3)
      12'h0 : begin
        io_bus_DAT_MISO[31 : 0] = mapper_idCtrl_io_header;
      end
      12'h004 : begin
        io_bus_DAT_MISO[31 : 0] = mapper_idCtrl_io_version;
      end
      12'h008 : begin
        io_bus_DAT_MISO[31 : 0] = {{{8'h02,8'h14},8'h18},8'h03};
      end
      12'h00c : begin
        io_bus_DAT_MISO[31 : 0] = {{16'h0,8'h08},8'h10};
      end
      12'h010 : begin
        io_bus_DAT_MISO[31 : 0] = {31'h0,1'b1};
      end
      12'h014 : begin
        io_bus_DAT_MISO[16 : 16] = (io_read_queueWithOccupancy_io_pop_valid ^ 1'b0);
        io_bus_DAT_MISO[0 : 0] = io_read_queueWithOccupancy_io_pop_payload_result;
      end
      12'h018 : begin
        io_bus_DAT_MISO[20 : 16] = mapper_tx_fifoVacancy;
        io_bus_DAT_MISO[27 : 24] = io_read_queueWithOccupancy_io_occupancy;
      end
      12'h01c : begin
        io_bus_DAT_MISO[19 : 0] = mapper_clockDivider;
      end
      12'h020 : begin
        io_bus_DAT_MISO[7 : 0] = mapper_readDelay;
      end
      default : begin
      end
    endcase
  end

  assign _zz_1 = (((io_bus_CYC && io_bus_STB) && ((io_bus_CYC && io_bus_ACK) && io_bus_STB)) && io_bus_WE);
  assign _zz_2 = (((io_bus_CYC && io_bus_STB) && ((io_bus_CYC && io_bus_ACK) && io_bus_STB)) && (! io_bus_WE));
  assign io_bus_ACK = (_zz_io_bus_ACK && io_bus_STB);
  always @(*) begin
    _zz_mapper_tx_streamUnbuffered_valid = 1'b0;
    case(_zz_3)
      12'h014 : begin
        if(_zz_1) begin
          _zz_mapper_tx_streamUnbuffered_valid = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign mapper_tx_streamUnbuffered_valid = _zz_mapper_tx_streamUnbuffered_valid;
  assign mapper_tx_streamUnbuffered_payload_command = _zz_mapper_tx_streamUnbuffered_payload_command;
  assign mapper_tx_streamUnbuffered_payload_pin = _zz_mapper_tx_streamUnbuffered_payload_pin[3 : 2];
  assign mapper_tx_streamUnbuffered_payload_data = _zz_mapper_tx_streamUnbuffered_payload_pin[27 : 4];
  assign mapper_tx_streamUnbuffered_ready = mapper_tx_streamUnbuffered_queueWithOccupancy_io_push_ready;
  assign mapper_tx_fifoVacancy = (5'h10 - mapper_tx_streamUnbuffered_queueWithOccupancy_io_occupancy);
  assign ctrl_io_readIsFull = (4'b0111 <= io_read_queueWithOccupancy_io_occupancy);
  always @(*) begin
    io_read_queueWithOccupancy_io_pop_ready = 1'b0;
    case(_zz_3)
      12'h014 : begin
        if(_zz_2) begin
          io_read_queueWithOccupancy_io_pop_ready = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign _zz_mapper_tx_streamUnbuffered_payload_pin = io_bus_DAT_MOSI[27 : 0];
  assign _zz_mapper_tx_streamUnbuffered_payload_command_1 = _zz_mapper_tx_streamUnbuffered_payload_pin[1 : 0];
  assign _zz_mapper_tx_streamUnbuffered_payload_command = _zz_mapper_tx_streamUnbuffered_payload_command_1;
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      _zz_io_bus_ACK <= 1'b0;
    end else begin
      _zz_io_bus_ACK <= (io_bus_STB && io_bus_CYC);
    end
  end

  always @(posedge clk) begin
    case(_zz_3)
      12'h01c : begin
        if(_zz_1) begin
          mapper_clockDivider <= io_bus_DAT_MOSI[19 : 0];
        end
      end
      12'h020 : begin
        if(_zz_1) begin
          mapper_readDelay <= io_bus_DAT_MOSI[7 : 0];
        end
      end
      default : begin
      end
    endcase
  end


endmodule

module StreamFifo_1 (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  input  wire [0:0]    io_push_payload_result,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire [0:0]    io_pop_payload_result,
  input  wire          io_flush,
  output wire [3:0]    io_occupancy,
  output wire [3:0]    io_availability,
  input  wire          clk,
  input  wire          resetn
);

  reg        [0:0]    logic_ram_spinal_port1;
  reg                 _zz_1;
  wire                logic_ptr_doPush;
  wire                logic_ptr_doPop;
  wire                logic_ptr_full;
  wire                logic_ptr_empty;
  reg        [3:0]    logic_ptr_push;
  reg        [3:0]    logic_ptr_pop;
  wire       [3:0]    logic_ptr_occupancy;
  wire       [3:0]    logic_ptr_popOnIo;
  wire                when_Stream_l1455;
  reg                 logic_ptr_wentUp;
  wire                io_push_fire;
  wire                logic_push_onRam_write_valid;
  wire       [2:0]    logic_push_onRam_write_payload_address;
  wire       [0:0]    logic_push_onRam_write_payload_data_result;
  wire                logic_pop_addressGen_valid;
  reg                 logic_pop_addressGen_ready;
  wire       [2:0]    logic_pop_addressGen_payload;
  wire                logic_pop_addressGen_fire;
  wire                logic_pop_sync_readArbitation_valid;
  wire                logic_pop_sync_readArbitation_ready;
  wire       [2:0]    logic_pop_sync_readArbitation_payload;
  reg                 logic_pop_addressGen_rValid;
  reg        [2:0]    logic_pop_addressGen_rData;
  wire                when_Stream_l477;
  wire                logic_pop_sync_readPort_cmd_valid;
  wire       [2:0]    logic_pop_sync_readPort_cmd_payload;
  wire       [0:0]    logic_pop_sync_readPort_rsp_result;
  wire                logic_pop_addressGen_toFlowFire_valid;
  wire       [2:0]    logic_pop_addressGen_toFlowFire_payload;
  wire                logic_pop_sync_readArbitation_translated_valid;
  wire                logic_pop_sync_readArbitation_translated_ready;
  wire       [0:0]    logic_pop_sync_readArbitation_translated_payload_result;
  wire                logic_pop_sync_readArbitation_fire;
  reg        [3:0]    logic_pop_sync_popReg;
  reg [0:0] logic_ram [0:7];

  always @(posedge clk) begin
    if(_zz_1) begin
      logic_ram[logic_push_onRam_write_payload_address] <= logic_push_onRam_write_payload_data_result;
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
  assign logic_ptr_full = (((logic_ptr_push ^ logic_ptr_popOnIo) ^ 4'b1000) == 4'b0000);
  assign logic_ptr_empty = (logic_ptr_push == logic_ptr_pop);
  assign logic_ptr_occupancy = (logic_ptr_push - logic_ptr_popOnIo);
  assign io_push_ready = (! logic_ptr_full);
  assign io_push_fire = (io_push_valid && io_push_ready);
  assign logic_ptr_doPush = io_push_fire;
  assign logic_push_onRam_write_valid = io_push_fire;
  assign logic_push_onRam_write_payload_address = logic_ptr_push[2:0];
  assign logic_push_onRam_write_payload_data_result = io_push_payload_result;
  assign logic_pop_addressGen_valid = (! logic_ptr_empty);
  assign logic_pop_addressGen_payload = logic_ptr_pop[2:0];
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
  assign logic_pop_sync_readPort_rsp_result = logic_ram_spinal_port1[0 : 0];
  assign logic_pop_addressGen_toFlowFire_valid = logic_pop_addressGen_fire;
  assign logic_pop_addressGen_toFlowFire_payload = logic_pop_addressGen_payload;
  assign logic_pop_sync_readPort_cmd_valid = logic_pop_addressGen_toFlowFire_valid;
  assign logic_pop_sync_readPort_cmd_payload = logic_pop_addressGen_toFlowFire_payload;
  assign logic_pop_sync_readArbitation_translated_valid = logic_pop_sync_readArbitation_valid;
  assign logic_pop_sync_readArbitation_ready = logic_pop_sync_readArbitation_translated_ready;
  assign logic_pop_sync_readArbitation_translated_payload_result = logic_pop_sync_readPort_rsp_result;
  assign io_pop_valid = logic_pop_sync_readArbitation_translated_valid;
  assign logic_pop_sync_readArbitation_translated_ready = io_pop_ready;
  assign io_pop_payload_result = logic_pop_sync_readArbitation_translated_payload_result;
  assign logic_pop_sync_readArbitation_fire = (logic_pop_sync_readArbitation_valid && logic_pop_sync_readArbitation_ready);
  assign logic_ptr_popOnIo = logic_pop_sync_popReg;
  assign io_occupancy = logic_ptr_occupancy;
  assign io_availability = (4'b1000 - logic_ptr_occupancy);
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      logic_ptr_push <= 4'b0000;
      logic_ptr_pop <= 4'b0000;
      logic_ptr_wentUp <= 1'b0;
      logic_pop_addressGen_rValid <= 1'b0;
      logic_pop_sync_popReg <= 4'b0000;
    end else begin
      if(when_Stream_l1455) begin
        logic_ptr_wentUp <= logic_ptr_doPush;
      end
      if(io_flush) begin
        logic_ptr_wentUp <= 1'b0;
      end
      if(logic_ptr_doPush) begin
        logic_ptr_push <= (logic_ptr_push + 4'b0001);
      end
      if(logic_ptr_doPop) begin
        logic_ptr_pop <= (logic_ptr_pop + 4'b0001);
      end
      if(io_flush) begin
        logic_ptr_push <= 4'b0000;
        logic_ptr_pop <= 4'b0000;
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
        logic_pop_sync_popReg <= 4'b0000;
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
  input  wire [1:0]    io_push_payload_command,
  input  wire [1:0]    io_push_payload_pin,
  input  wire [23:0]   io_push_payload_data,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire [1:0]    io_pop_payload_command,
  output wire [1:0]    io_pop_payload_pin,
  output wire [23:0]   io_pop_payload_data,
  input  wire          io_flush,
  output wire [4:0]    io_occupancy,
  output wire [4:0]    io_availability,
  input  wire          clk,
  input  wire          resetn
);
  localparam CommandType_HIGH = 2'd0;
  localparam CommandType_LOW = 2'd1;
  localparam CommandType_WAIT_1 = 2'd2;
  localparam CommandType_READ = 2'd3;

  reg        [27:0]   logic_ram_spinal_port1;
  wire       [27:0]   _zz_logic_ram_port;
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
  wire       [1:0]    logic_push_onRam_write_payload_data_command;
  wire       [1:0]    logic_push_onRam_write_payload_data_pin;
  wire       [23:0]   logic_push_onRam_write_payload_data_data;
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
  wire       [1:0]    logic_pop_sync_readPort_rsp_command;
  wire       [1:0]    logic_pop_sync_readPort_rsp_pin;
  wire       [23:0]   logic_pop_sync_readPort_rsp_data;
  wire       [1:0]    _zz_logic_pop_sync_readPort_rsp_command;
  wire       [27:0]   _zz_logic_pop_sync_readPort_rsp_pin;
  wire       [1:0]    _zz_logic_pop_sync_readPort_rsp_command_1;
  wire                logic_pop_addressGen_toFlowFire_valid;
  wire       [3:0]    logic_pop_addressGen_toFlowFire_payload;
  wire                logic_pop_sync_readArbitation_translated_valid;
  wire                logic_pop_sync_readArbitation_translated_ready;
  wire       [1:0]    logic_pop_sync_readArbitation_translated_payload_command;
  wire       [1:0]    logic_pop_sync_readArbitation_translated_payload_pin;
  wire       [23:0]   logic_pop_sync_readArbitation_translated_payload_data;
  wire                logic_pop_sync_readArbitation_fire;
  reg        [4:0]    logic_pop_sync_popReg;
  `ifndef SYNTHESIS
  reg [47:0] io_push_payload_command_string;
  reg [47:0] io_pop_payload_command_string;
  reg [47:0] logic_push_onRam_write_payload_data_command_string;
  reg [47:0] logic_pop_sync_readPort_rsp_command_string;
  reg [47:0] _zz_logic_pop_sync_readPort_rsp_command_string;
  reg [47:0] _zz_logic_pop_sync_readPort_rsp_command_1_string;
  reg [47:0] logic_pop_sync_readArbitation_translated_payload_command_string;
  `endif

  reg [27:0] logic_ram [0:15];

  assign _zz_logic_ram_port = {logic_push_onRam_write_payload_data_data,{logic_push_onRam_write_payload_data_pin,logic_push_onRam_write_payload_data_command}};
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
    case(io_push_payload_command)
      CommandType_HIGH : io_push_payload_command_string = "HIGH  ";
      CommandType_LOW : io_push_payload_command_string = "LOW   ";
      CommandType_WAIT_1 : io_push_payload_command_string = "WAIT_1";
      CommandType_READ : io_push_payload_command_string = "READ  ";
      default : io_push_payload_command_string = "??????";
    endcase
  end
  always @(*) begin
    case(io_pop_payload_command)
      CommandType_HIGH : io_pop_payload_command_string = "HIGH  ";
      CommandType_LOW : io_pop_payload_command_string = "LOW   ";
      CommandType_WAIT_1 : io_pop_payload_command_string = "WAIT_1";
      CommandType_READ : io_pop_payload_command_string = "READ  ";
      default : io_pop_payload_command_string = "??????";
    endcase
  end
  always @(*) begin
    case(logic_push_onRam_write_payload_data_command)
      CommandType_HIGH : logic_push_onRam_write_payload_data_command_string = "HIGH  ";
      CommandType_LOW : logic_push_onRam_write_payload_data_command_string = "LOW   ";
      CommandType_WAIT_1 : logic_push_onRam_write_payload_data_command_string = "WAIT_1";
      CommandType_READ : logic_push_onRam_write_payload_data_command_string = "READ  ";
      default : logic_push_onRam_write_payload_data_command_string = "??????";
    endcase
  end
  always @(*) begin
    case(logic_pop_sync_readPort_rsp_command)
      CommandType_HIGH : logic_pop_sync_readPort_rsp_command_string = "HIGH  ";
      CommandType_LOW : logic_pop_sync_readPort_rsp_command_string = "LOW   ";
      CommandType_WAIT_1 : logic_pop_sync_readPort_rsp_command_string = "WAIT_1";
      CommandType_READ : logic_pop_sync_readPort_rsp_command_string = "READ  ";
      default : logic_pop_sync_readPort_rsp_command_string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_logic_pop_sync_readPort_rsp_command)
      CommandType_HIGH : _zz_logic_pop_sync_readPort_rsp_command_string = "HIGH  ";
      CommandType_LOW : _zz_logic_pop_sync_readPort_rsp_command_string = "LOW   ";
      CommandType_WAIT_1 : _zz_logic_pop_sync_readPort_rsp_command_string = "WAIT_1";
      CommandType_READ : _zz_logic_pop_sync_readPort_rsp_command_string = "READ  ";
      default : _zz_logic_pop_sync_readPort_rsp_command_string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_logic_pop_sync_readPort_rsp_command_1)
      CommandType_HIGH : _zz_logic_pop_sync_readPort_rsp_command_1_string = "HIGH  ";
      CommandType_LOW : _zz_logic_pop_sync_readPort_rsp_command_1_string = "LOW   ";
      CommandType_WAIT_1 : _zz_logic_pop_sync_readPort_rsp_command_1_string = "WAIT_1";
      CommandType_READ : _zz_logic_pop_sync_readPort_rsp_command_1_string = "READ  ";
      default : _zz_logic_pop_sync_readPort_rsp_command_1_string = "??????";
    endcase
  end
  always @(*) begin
    case(logic_pop_sync_readArbitation_translated_payload_command)
      CommandType_HIGH : logic_pop_sync_readArbitation_translated_payload_command_string = "HIGH  ";
      CommandType_LOW : logic_pop_sync_readArbitation_translated_payload_command_string = "LOW   ";
      CommandType_WAIT_1 : logic_pop_sync_readArbitation_translated_payload_command_string = "WAIT_1";
      CommandType_READ : logic_pop_sync_readArbitation_translated_payload_command_string = "READ  ";
      default : logic_pop_sync_readArbitation_translated_payload_command_string = "??????";
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
  assign logic_push_onRam_write_payload_data_command = io_push_payload_command;
  assign logic_push_onRam_write_payload_data_pin = io_push_payload_pin;
  assign logic_push_onRam_write_payload_data_data = io_push_payload_data;
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
  assign _zz_logic_pop_sync_readPort_rsp_pin = logic_ram_spinal_port1;
  assign _zz_logic_pop_sync_readPort_rsp_command_1 = _zz_logic_pop_sync_readPort_rsp_pin[1 : 0];
  assign _zz_logic_pop_sync_readPort_rsp_command = _zz_logic_pop_sync_readPort_rsp_command_1;
  assign logic_pop_sync_readPort_rsp_command = _zz_logic_pop_sync_readPort_rsp_command;
  assign logic_pop_sync_readPort_rsp_pin = _zz_logic_pop_sync_readPort_rsp_pin[3 : 2];
  assign logic_pop_sync_readPort_rsp_data = _zz_logic_pop_sync_readPort_rsp_pin[27 : 4];
  assign logic_pop_addressGen_toFlowFire_valid = logic_pop_addressGen_fire;
  assign logic_pop_addressGen_toFlowFire_payload = logic_pop_addressGen_payload;
  assign logic_pop_sync_readPort_cmd_valid = logic_pop_addressGen_toFlowFire_valid;
  assign logic_pop_sync_readPort_cmd_payload = logic_pop_addressGen_toFlowFire_payload;
  assign logic_pop_sync_readArbitation_translated_valid = logic_pop_sync_readArbitation_valid;
  assign logic_pop_sync_readArbitation_ready = logic_pop_sync_readArbitation_translated_ready;
  assign logic_pop_sync_readArbitation_translated_payload_command = logic_pop_sync_readPort_rsp_command;
  assign logic_pop_sync_readArbitation_translated_payload_pin = logic_pop_sync_readPort_rsp_pin;
  assign logic_pop_sync_readArbitation_translated_payload_data = logic_pop_sync_readPort_rsp_data;
  assign io_pop_valid = logic_pop_sync_readArbitation_translated_valid;
  assign logic_pop_sync_readArbitation_translated_ready = io_pop_ready;
  assign io_pop_payload_command = logic_pop_sync_readArbitation_translated_payload_command;
  assign io_pop_payload_pin = logic_pop_sync_readArbitation_translated_payload_pin;
  assign io_pop_payload_data = logic_pop_sync_readArbitation_translated_payload_data;
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

  assign _zz_header_1 = Ids_Pio;
  assign _zz_header = {12'd0, _zz_header_1};
  assign header = {{8'h0,8'h08},_zz_header};
  assign version = {{8'h01,8'h0},16'h0};
  assign io_header = header;
  assign io_version = version;

endmodule

module PioCtrl (
  input  wire [2:0]    io_pio_pins_read,
  output wire [2:0]    io_pio_pins_write,
  output wire [2:0]    io_pio_pins_writeEnable,
  input  wire [19:0]   io_config_clockDivider,
  input  wire [7:0]    io_config_readDelay,
  input  wire          io_commands_valid,
  output reg           io_commands_ready,
  input  wire [1:0]    io_commands_payload_command,
  input  wire [1:0]    io_commands_payload_pin,
  input  wire [23:0]   io_commands_payload_data,
  output reg           io_read_valid,
  input  wire          io_read_ready,
  output wire [0:0]    io_read_payload_result,
  input  wire          io_readIsFull,
  input  wire          clk,
  input  wire          resetn
);
  localparam CommandType_HIGH = 2'd0;
  localparam CommandType_LOW = 2'd1;
  localparam CommandType_WAIT_1 = 2'd2;
  localparam CommandType_READ = 2'd3;
  localparam fsm_BOOT = 3'd0;
  localparam fsm_stateIdle = 3'd1;
  localparam fsm_stateHigh = 3'd2;
  localparam fsm_stateLow = 3'd3;
  localparam fsm_stateWait = 3'd4;
  localparam fsm_stateRead = 3'd5;

  reg                 clockDivider_1_io_reload;
  wire       [2:0]    io_pio_pins_read_buffercc_io_dataOut;
  wire                clockDivider_1_io_tick;
  wire       [23:0]   _zz_when_PioCtrl_l183;
  wire       [7:0]    _zz_when_PioCtrl_l183_1;
  wire       [2:0]    value;
  wire                fsm_wantExit;
  reg                 fsm_wantStart;
  wire                fsm_wantKill;
  reg        [23:0]   fsm_counter;
  reg        [2:0]    fsm_write;
  reg        [2:0]    fsm_direction;
  wire       [1:0]    fsm_pinNumber;
  wire       [0:0]    fsm_readContainer_result;
  reg        [2:0]    fsm_stateReg;
  reg        [2:0]    fsm_stateNext;
  wire                when_PioCtrl_l169;
  wire                when_PioCtrl_l183;
  wire                fsm_onExit_BOOT;
  wire                fsm_onExit_stateIdle;
  wire                fsm_onExit_stateHigh;
  wire                fsm_onExit_stateLow;
  wire                fsm_onExit_stateWait;
  wire                fsm_onExit_stateRead;
  wire                fsm_onEntry_BOOT;
  wire                fsm_onEntry_stateIdle;
  wire                fsm_onEntry_stateHigh;
  wire                fsm_onEntry_stateLow;
  wire                fsm_onEntry_stateWait;
  wire                fsm_onEntry_stateRead;
  `ifndef SYNTHESIS
  reg [47:0] io_commands_payload_command_string;
  reg [71:0] fsm_stateReg_string;
  reg [71:0] fsm_stateNext_string;
  `endif


  assign _zz_when_PioCtrl_l183_1 = io_config_readDelay;
  assign _zz_when_PioCtrl_l183 = {16'd0, _zz_when_PioCtrl_l183_1};
  (* keep_hierarchy = "TRUE" *) BufferCC io_pio_pins_read_buffercc (
    .io_dataIn  (io_pio_pins_read[2:0]                    ), //i
    .io_dataOut (io_pio_pins_read_buffercc_io_dataOut[2:0]), //o
    .clk        (clk                                      ), //i
    .resetn     (resetn                                   )  //i
  );
  ClockDivider clockDivider_1 (
    .io_value  (io_config_clockDivider[19:0]), //i
    .io_reload (clockDivider_1_io_reload    ), //i
    .io_tick   (clockDivider_1_io_tick      ), //o
    .clk       (clk                         ), //i
    .resetn    (resetn                      )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_commands_payload_command)
      CommandType_HIGH : io_commands_payload_command_string = "HIGH  ";
      CommandType_LOW : io_commands_payload_command_string = "LOW   ";
      CommandType_WAIT_1 : io_commands_payload_command_string = "WAIT_1";
      CommandType_READ : io_commands_payload_command_string = "READ  ";
      default : io_commands_payload_command_string = "??????";
    endcase
  end
  always @(*) begin
    case(fsm_stateReg)
      fsm_BOOT : fsm_stateReg_string = "BOOT     ";
      fsm_stateIdle : fsm_stateReg_string = "stateIdle";
      fsm_stateHigh : fsm_stateReg_string = "stateHigh";
      fsm_stateLow : fsm_stateReg_string = "stateLow ";
      fsm_stateWait : fsm_stateReg_string = "stateWait";
      fsm_stateRead : fsm_stateReg_string = "stateRead";
      default : fsm_stateReg_string = "?????????";
    endcase
  end
  always @(*) begin
    case(fsm_stateNext)
      fsm_BOOT : fsm_stateNext_string = "BOOT     ";
      fsm_stateIdle : fsm_stateNext_string = "stateIdle";
      fsm_stateHigh : fsm_stateNext_string = "stateHigh";
      fsm_stateLow : fsm_stateNext_string = "stateLow ";
      fsm_stateWait : fsm_stateNext_string = "stateWait";
      fsm_stateRead : fsm_stateNext_string = "stateRead";
      default : fsm_stateNext_string = "?????????";
    endcase
  end
  `endif

  assign value = io_pio_pins_read_buffercc_io_dataOut;
  always @(*) begin
    clockDivider_1_io_reload = 1'b0;
    if(fsm_onEntry_stateWait) begin
      clockDivider_1_io_reload = 1'b1;
    end
    if(fsm_onEntry_stateRead) begin
      clockDivider_1_io_reload = 1'b1;
    end
  end

  assign fsm_wantExit = 1'b0;
  always @(*) begin
    fsm_wantStart = 1'b0;
    case(fsm_stateReg)
      fsm_stateIdle : begin
      end
      fsm_stateHigh : begin
      end
      fsm_stateLow : begin
      end
      fsm_stateWait : begin
      end
      fsm_stateRead : begin
      end
      default : begin
        fsm_wantStart = 1'b1;
      end
    endcase
  end

  assign fsm_wantKill = 1'b0;
  always @(*) begin
    io_commands_ready = 1'b0;
    if(fsm_onExit_stateHigh) begin
      io_commands_ready = 1'b1;
    end
    if(fsm_onExit_stateLow) begin
      io_commands_ready = 1'b1;
    end
    if(fsm_onExit_stateWait) begin
      io_commands_ready = 1'b1;
    end
    if(fsm_onExit_stateRead) begin
      io_commands_ready = 1'b1;
    end
  end

  always @(*) begin
    io_read_valid = 1'b0;
    case(fsm_stateReg)
      fsm_stateIdle : begin
      end
      fsm_stateHigh : begin
      end
      fsm_stateLow : begin
      end
      fsm_stateWait : begin
      end
      fsm_stateRead : begin
        if(when_PioCtrl_l183) begin
          io_read_valid = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign fsm_pinNumber = io_commands_payload_pin;
  assign fsm_readContainer_result = value[fsm_pinNumber];
  assign io_read_payload_result = fsm_readContainer_result;
  assign io_pio_pins_write = fsm_write;
  assign io_pio_pins_writeEnable = fsm_direction;
  always @(*) begin
    fsm_stateNext = fsm_stateReg;
    case(fsm_stateReg)
      fsm_stateIdle : begin
        if(io_commands_valid) begin
          case(io_commands_payload_command)
            CommandType_HIGH : begin
              fsm_stateNext = fsm_stateHigh;
            end
            CommandType_LOW : begin
              fsm_stateNext = fsm_stateLow;
            end
            CommandType_WAIT_1 : begin
              fsm_stateNext = fsm_stateWait;
            end
            default : begin
              fsm_stateNext = fsm_stateRead;
            end
          endcase
        end
      end
      fsm_stateHigh : begin
        fsm_stateNext = fsm_stateIdle;
      end
      fsm_stateLow : begin
        fsm_stateNext = fsm_stateIdle;
      end
      fsm_stateWait : begin
        if(when_PioCtrl_l169) begin
          fsm_stateNext = fsm_stateIdle;
        end
      end
      fsm_stateRead : begin
        if(when_PioCtrl_l183) begin
          fsm_stateNext = fsm_stateIdle;
        end
      end
      default : begin
      end
    endcase
    if(fsm_wantStart) begin
      fsm_stateNext = fsm_stateIdle;
    end
    if(fsm_wantKill) begin
      fsm_stateNext = fsm_BOOT;
    end
  end

  assign when_PioCtrl_l169 = (fsm_counter == io_commands_payload_data);
  assign when_PioCtrl_l183 = (fsm_counter == _zz_when_PioCtrl_l183);
  assign fsm_onExit_BOOT = ((fsm_stateNext != fsm_BOOT) && (fsm_stateReg == fsm_BOOT));
  assign fsm_onExit_stateIdle = ((fsm_stateNext != fsm_stateIdle) && (fsm_stateReg == fsm_stateIdle));
  assign fsm_onExit_stateHigh = ((fsm_stateNext != fsm_stateHigh) && (fsm_stateReg == fsm_stateHigh));
  assign fsm_onExit_stateLow = ((fsm_stateNext != fsm_stateLow) && (fsm_stateReg == fsm_stateLow));
  assign fsm_onExit_stateWait = ((fsm_stateNext != fsm_stateWait) && (fsm_stateReg == fsm_stateWait));
  assign fsm_onExit_stateRead = ((fsm_stateNext != fsm_stateRead) && (fsm_stateReg == fsm_stateRead));
  assign fsm_onEntry_BOOT = ((fsm_stateNext == fsm_BOOT) && (fsm_stateReg != fsm_BOOT));
  assign fsm_onEntry_stateIdle = ((fsm_stateNext == fsm_stateIdle) && (fsm_stateReg != fsm_stateIdle));
  assign fsm_onEntry_stateHigh = ((fsm_stateNext == fsm_stateHigh) && (fsm_stateReg != fsm_stateHigh));
  assign fsm_onEntry_stateLow = ((fsm_stateNext == fsm_stateLow) && (fsm_stateReg != fsm_stateLow));
  assign fsm_onEntry_stateWait = ((fsm_stateNext == fsm_stateWait) && (fsm_stateReg != fsm_stateWait));
  assign fsm_onEntry_stateRead = ((fsm_stateNext == fsm_stateRead) && (fsm_stateReg != fsm_stateRead));
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      fsm_counter <= 24'h0;
      fsm_write <= 3'b000;
      fsm_direction <= 3'b000;
      fsm_stateReg <= fsm_BOOT;
    end else begin
      fsm_stateReg <= fsm_stateNext;
      case(fsm_stateReg)
        fsm_stateIdle : begin
        end
        fsm_stateHigh : begin
          fsm_direction[fsm_pinNumber] <= 1'b1;
          fsm_write[fsm_pinNumber] <= 1'b1;
        end
        fsm_stateLow : begin
          fsm_direction[fsm_pinNumber] <= 1'b1;
          fsm_write[fsm_pinNumber] <= 1'b0;
        end
        fsm_stateWait : begin
          if(clockDivider_1_io_tick) begin
            fsm_counter <= (fsm_counter + 24'h000001);
          end
        end
        fsm_stateRead : begin
          fsm_direction[fsm_pinNumber] <= 1'b0;
          fsm_counter <= (fsm_counter + 24'h000001);
        end
        default : begin
        end
      endcase
      if(fsm_onEntry_stateWait) begin
        fsm_counter <= 24'h0;
      end
      if(fsm_onEntry_stateRead) begin
        fsm_counter <= 24'h0;
      end
    end
  end


endmodule

module ClockDivider (
  input  wire [19:0]   io_value,
  input  wire          io_reload,
  output wire          io_tick,
  input  wire          clk,
  input  wire          resetn
);

  reg        [19:0]   counter;
  wire                tick;
  wire                when_ClockDivider_l26;

  assign tick = (counter == 20'h0);
  assign when_ClockDivider_l26 = (tick || io_reload);
  assign io_tick = tick;
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      counter <= 20'h0;
    end else begin
      counter <= (counter - 20'h00001);
      if(when_ClockDivider_l26) begin
        counter <= io_value;
      end
    end
  end


endmodule

module BufferCC (
  input  wire [2:0]    io_dataIn,
  output wire [2:0]    io_dataOut,
  input  wire          clk,
  input  wire          resetn
);

  (* async_reg = "true" *) reg        [2:0]    buffers_0;
  (* async_reg = "true" *) reg        [2:0]    buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge clk) begin
    buffers_0 <= io_dataIn;
    buffers_1 <= buffers_0;
  end


endmodule
