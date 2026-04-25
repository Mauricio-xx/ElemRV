// Generator : SpinalHDL v1.13.0    git head : d9d72474863badf47d8585d187f3e04ae4749c59
// Component : WishboneI2cController
// Git hash  : 58d827afb766b3e54c8e02d57b05f468cf844e91

`timescale 1ns/1ps

module WishboneI2cController (
  input  wire          io_bus_CYC,
  input  wire          io_bus_STB,
  output wire          io_bus_ACK,
  input  wire          io_bus_WE,
  input  wire [9:0]    io_bus_ADR,
  output reg  [31:0]   io_bus_DAT_MISO,
  input  wire [31:0]   io_bus_DAT_MOSI,
  output wire          io_i2c_scl_write,
  input  wire          io_i2c_scl_read,
  output wire          io_i2c_sda_write,
  input  wire          io_i2c_sda_read,
  output wire          io_interrupt,
  input  wire          clk,
  input  wire          resetn
);

  reg                 io_rsp_queueWithOccupancy_io_pop_ready;
  reg        [1:0]    mapper_interruptCtrl_irqCtrl_io_inputs;
  reg        [1:0]    mapper_interruptCtrl_irqCtrl_io_clears;
  wire                i2cControllerCtrl_1_io_i2c_scl_write;
  wire                i2cControllerCtrl_1_io_i2c_sda_write;
  wire                i2cControllerCtrl_1_io_interrupt;
  wire                i2cControllerCtrl_1_io_cmd_ready;
  wire                i2cControllerCtrl_1_io_rsp_valid;
  wire       [7:0]    i2cControllerCtrl_1_io_rsp_payload_data;
  wire                i2cControllerCtrl_1_io_rsp_payload_error;
  wire       [31:0]   mapper_idCtrl_io_header;
  wire       [31:0]   mapper_idCtrl_io_version;
  wire                mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_push_ready;
  wire                mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_pop_valid;
  wire       [7:0]    mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_pop_payload_data;
  wire                mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_pop_payload_read;
  wire                mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_pop_payload_start;
  wire                mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_pop_payload_stop;
  wire                mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_pop_payload_ack;
  wire       [2:0]    mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_occupancy;
  wire       [2:0]    mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_availability;
  wire                io_rsp_queueWithOccupancy_io_push_ready;
  wire                io_rsp_queueWithOccupancy_io_pop_valid;
  wire       [7:0]    io_rsp_queueWithOccupancy_io_pop_payload_data;
  wire                io_rsp_queueWithOccupancy_io_pop_payload_error;
  wire       [2:0]    io_rsp_queueWithOccupancy_io_occupancy;
  wire       [2:0]    io_rsp_queueWithOccupancy_io_availability;
  wire       [1:0]    mapper_interruptCtrl_irqCtrl_io_pendings;
  wire       [2:0]    _zz_mapper_interruptCtrl_cmdTrigger;
  wire       [11:0]   _zz_3;
  wire                _zz_1;
  wire                _zz_2;
  reg                 _zz_io_bus_ACK;
  wire                mapper_permissionBits;
  wire                mapper_cmdLogic_streamUnbuffered_valid;
  wire                mapper_cmdLogic_streamUnbuffered_ready;
  wire       [7:0]    mapper_cmdLogic_streamUnbuffered_payload_data;
  wire                mapper_cmdLogic_streamUnbuffered_payload_read;
  wire                mapper_cmdLogic_streamUnbuffered_payload_start;
  wire                mapper_cmdLogic_streamUnbuffered_payload_stop;
  wire                mapper_cmdLogic_streamUnbuffered_payload_ack;
  reg                 _zz_mapper_cmdLogic_streamUnbuffered_valid;
  wire       [2:0]    mapper_cmdLogic_fifoVacancy;
  reg        [30:0]   mapper_config_cfg_config;
  reg        [15:0]   mapper_config_cfg_clockDivider;
  reg                 mapper_config_cfg_clockDividerReload;
  reg        [2:0]    mapper_interruptCtrl_cmdOccupancyTrigger;
  reg        [2:0]    mapper_interruptCtrl_cmdPreviousOccupancy;
  wire                mapper_interruptCtrl_cmdTrigger;
  reg        [1:0]    io_masks_driver;

  assign _zz_3 = ({2'd0,io_bus_ADR} <<< 2'd2);
  assign _zz_mapper_interruptCtrl_cmdTrigger = (mapper_interruptCtrl_cmdOccupancyTrigger + 3'b001);
  I2cControllerCtrl i2cControllerCtrl_1 (
    .io_config_config             (mapper_config_cfg_config[30:0]                                              ), //i
    .io_config_clockDivider       (mapper_config_cfg_clockDivider[15:0]                                        ), //i
    .io_config_clockDividerReload (mapper_config_cfg_clockDividerReload                                        ), //i
    .io_i2c_scl_write             (i2cControllerCtrl_1_io_i2c_scl_write                                        ), //o
    .io_i2c_scl_read              (io_i2c_scl_read                                                             ), //i
    .io_i2c_sda_write             (i2cControllerCtrl_1_io_i2c_sda_write                                        ), //o
    .io_i2c_sda_read              (io_i2c_sda_read                                                             ), //i
    .io_interrupt                 (i2cControllerCtrl_1_io_interrupt                                            ), //o
    .io_pendingInterrupts         (mapper_interruptCtrl_irqCtrl_io_pendings[1:0]                               ), //i
    .io_cmd_valid                 (mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_pop_valid            ), //i
    .io_cmd_ready                 (i2cControllerCtrl_1_io_cmd_ready                                            ), //o
    .io_cmd_payload_data          (mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_pop_payload_data[7:0]), //i
    .io_cmd_payload_read          (mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_pop_payload_read     ), //i
    .io_cmd_payload_start         (mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_pop_payload_start    ), //i
    .io_cmd_payload_stop          (mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_pop_payload_stop     ), //i
    .io_cmd_payload_ack           (mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_pop_payload_ack      ), //i
    .io_rsp_valid                 (i2cControllerCtrl_1_io_rsp_valid                                            ), //o
    .io_rsp_ready                 (io_rsp_queueWithOccupancy_io_push_ready                                     ), //i
    .io_rsp_payload_data          (i2cControllerCtrl_1_io_rsp_payload_data[7:0]                                ), //o
    .io_rsp_payload_error         (i2cControllerCtrl_1_io_rsp_payload_error                                    ), //o
    .clk                          (clk                                                                         ), //i
    .resetn                       (resetn                                                                      )  //i
  );
  IpIdentificationCtrl mapper_idCtrl (
    .io_header  (mapper_idCtrl_io_header[31:0] ), //o
    .io_version (mapper_idCtrl_io_version[31:0]), //o
    .clk        (clk                           ), //i
    .resetn     (resetn                        )  //i
  );
  StreamFifo mapper_cmdLogic_streamUnbuffered_queueWithOccupancy (
    .io_push_valid         (mapper_cmdLogic_streamUnbuffered_valid                                      ), //i
    .io_push_ready         (mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_push_ready           ), //o
    .io_push_payload_data  (mapper_cmdLogic_streamUnbuffered_payload_data[7:0]                          ), //i
    .io_push_payload_read  (mapper_cmdLogic_streamUnbuffered_payload_read                               ), //i
    .io_push_payload_start (mapper_cmdLogic_streamUnbuffered_payload_start                              ), //i
    .io_push_payload_stop  (mapper_cmdLogic_streamUnbuffered_payload_stop                               ), //i
    .io_push_payload_ack   (mapper_cmdLogic_streamUnbuffered_payload_ack                                ), //i
    .io_pop_valid          (mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_pop_valid            ), //o
    .io_pop_ready          (i2cControllerCtrl_1_io_cmd_ready                                            ), //i
    .io_pop_payload_data   (mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_pop_payload_data[7:0]), //o
    .io_pop_payload_read   (mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_pop_payload_read     ), //o
    .io_pop_payload_start  (mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_pop_payload_start    ), //o
    .io_pop_payload_stop   (mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_pop_payload_stop     ), //o
    .io_pop_payload_ack    (mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_pop_payload_ack      ), //o
    .io_flush              (1'b0                                                                        ), //i
    .io_occupancy          (mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_occupancy[2:0]       ), //o
    .io_availability       (mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_availability[2:0]    ), //o
    .clk                   (clk                                                                         ), //i
    .resetn                (resetn                                                                      )  //i
  );
  StreamFifo_1 io_rsp_queueWithOccupancy (
    .io_push_valid         (i2cControllerCtrl_1_io_rsp_valid                  ), //i
    .io_push_ready         (io_rsp_queueWithOccupancy_io_push_ready           ), //o
    .io_push_payload_data  (i2cControllerCtrl_1_io_rsp_payload_data[7:0]      ), //i
    .io_push_payload_error (i2cControllerCtrl_1_io_rsp_payload_error          ), //i
    .io_pop_valid          (io_rsp_queueWithOccupancy_io_pop_valid            ), //o
    .io_pop_ready          (io_rsp_queueWithOccupancy_io_pop_ready            ), //i
    .io_pop_payload_data   (io_rsp_queueWithOccupancy_io_pop_payload_data[7:0]), //o
    .io_pop_payload_error  (io_rsp_queueWithOccupancy_io_pop_payload_error    ), //o
    .io_flush              (1'b0                                              ), //i
    .io_occupancy          (io_rsp_queueWithOccupancy_io_occupancy[2:0]       ), //o
    .io_availability       (io_rsp_queueWithOccupancy_io_availability[2:0]    ), //o
    .clk                   (clk                                               ), //i
    .resetn                (resetn                                            )  //i
  );
  InterruptCtrl mapper_interruptCtrl_irqCtrl (
    .io_inputs   (mapper_interruptCtrl_irqCtrl_io_inputs[1:0]  ), //i
    .io_clears   (mapper_interruptCtrl_irqCtrl_io_clears[1:0]  ), //i
    .io_masks    (io_masks_driver[1:0]                         ), //i
    .io_pendings (mapper_interruptCtrl_irqCtrl_io_pendings[1:0]), //o
    .clk         (clk                                          ), //i
    .resetn      (resetn                                       )  //i
  );
  assign io_i2c_scl_write = i2cControllerCtrl_1_io_i2c_scl_write;
  assign io_i2c_sda_write = i2cControllerCtrl_1_io_i2c_sda_write;
  assign io_interrupt = i2cControllerCtrl_1_io_interrupt;
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
        io_bus_DAT_MISO[31 : 0] = {24'h0,8'h10};
      end
      12'h00c : begin
        io_bus_DAT_MISO[31 : 0] = {{16'h0,8'h04},8'h04};
      end
      12'h010 : begin
        io_bus_DAT_MISO[31 : 0] = {31'h0,mapper_permissionBits};
      end
      12'h014 : begin
        io_bus_DAT_MISO[31 : 31] = (io_rsp_queueWithOccupancy_io_pop_valid ^ 1'b0);
        io_bus_DAT_MISO[8 : 0] = {io_rsp_queueWithOccupancy_io_pop_payload_error,io_rsp_queueWithOccupancy_io_pop_payload_data};
      end
      12'h018 : begin
        io_bus_DAT_MISO[18 : 16] = mapper_cmdLogic_fifoVacancy;
        io_bus_DAT_MISO[2 : 0] = io_rsp_queueWithOccupancy_io_occupancy;
      end
      12'h01c : begin
        io_bus_DAT_MISO[15 : 0] = mapper_config_cfg_clockDivider;
      end
      12'h024 : begin
        io_bus_DAT_MISO[2 : 0] = mapper_interruptCtrl_cmdOccupancyTrigger;
      end
      12'h028 : begin
        io_bus_DAT_MISO[1 : 0] = mapper_interruptCtrl_irqCtrl_io_pendings;
      end
      12'h02c : begin
        io_bus_DAT_MISO[1 : 0] = io_masks_driver;
      end
      default : begin
      end
    endcase
  end

  assign _zz_1 = (((io_bus_CYC && io_bus_STB) && ((io_bus_CYC && io_bus_ACK) && io_bus_STB)) && io_bus_WE);
  assign _zz_2 = (((io_bus_CYC && io_bus_STB) && ((io_bus_CYC && io_bus_ACK) && io_bus_STB)) && (! io_bus_WE));
  assign io_bus_ACK = (_zz_io_bus_ACK && io_bus_STB);
  assign mapper_permissionBits = 1'b1;
  always @(*) begin
    _zz_mapper_cmdLogic_streamUnbuffered_valid = 1'b0;
    case(_zz_3)
      12'h014 : begin
        if(_zz_1) begin
          _zz_mapper_cmdLogic_streamUnbuffered_valid = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign mapper_cmdLogic_streamUnbuffered_valid = _zz_mapper_cmdLogic_streamUnbuffered_valid;
  assign mapper_cmdLogic_streamUnbuffered_ready = mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_push_ready;
  assign mapper_cmdLogic_fifoVacancy = (3'b100 - mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_occupancy);
  always @(*) begin
    io_rsp_queueWithOccupancy_io_pop_ready = 1'b0;
    case(_zz_3)
      12'h014 : begin
        if(_zz_2) begin
          io_rsp_queueWithOccupancy_io_pop_ready = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign mapper_interruptCtrl_cmdTrigger = ((mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_occupancy == mapper_interruptCtrl_cmdOccupancyTrigger) && (mapper_interruptCtrl_cmdPreviousOccupancy == _zz_mapper_interruptCtrl_cmdTrigger));
  always @(*) begin
    mapper_interruptCtrl_irqCtrl_io_clears = 2'b00;
    case(_zz_3)
      12'h028 : begin
        if(_zz_1) begin
          mapper_interruptCtrl_irqCtrl_io_clears = io_bus_DAT_MOSI[1 : 0];
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    mapper_interruptCtrl_irqCtrl_io_inputs[0] = mapper_interruptCtrl_cmdTrigger;
    mapper_interruptCtrl_irqCtrl_io_inputs[1] = io_rsp_queueWithOccupancy_io_pop_valid;
  end

  assign mapper_cmdLogic_streamUnbuffered_payload_data = io_bus_DAT_MOSI[7 : 0];
  assign mapper_cmdLogic_streamUnbuffered_payload_start = io_bus_DAT_MOSI[8];
  assign mapper_cmdLogic_streamUnbuffered_payload_stop = io_bus_DAT_MOSI[9];
  assign mapper_cmdLogic_streamUnbuffered_payload_read = io_bus_DAT_MOSI[10];
  assign mapper_cmdLogic_streamUnbuffered_payload_ack = io_bus_DAT_MOSI[11];
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      _zz_io_bus_ACK <= 1'b0;
      io_masks_driver <= 2'b00;
    end else begin
      _zz_io_bus_ACK <= (io_bus_STB && io_bus_CYC);
      case(_zz_3)
        12'h02c : begin
          if(_zz_1) begin
            io_masks_driver <= io_bus_DAT_MOSI[1 : 0];
          end
        end
        default : begin
        end
      endcase
    end
  end

  always @(posedge clk) begin
    mapper_config_cfg_clockDividerReload <= 1'b0;
    mapper_interruptCtrl_cmdPreviousOccupancy <= mapper_cmdLogic_streamUnbuffered_queueWithOccupancy_io_occupancy;
    case(_zz_3)
      12'h01c : begin
        if(_zz_1) begin
          mapper_config_cfg_clockDivider <= io_bus_DAT_MOSI[15 : 0];
          mapper_config_cfg_clockDividerReload <= 1'b1;
        end
      end
      12'h024 : begin
        if(_zz_1) begin
          mapper_interruptCtrl_cmdOccupancyTrigger <= io_bus_DAT_MOSI[2 : 0];
        end
      end
      default : begin
      end
    endcase
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
  input  wire [7:0]    io_push_payload_data,
  input  wire          io_push_payload_error,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire [7:0]    io_pop_payload_data,
  output wire          io_pop_payload_error,
  input  wire          io_flush,
  output wire [2:0]    io_occupancy,
  output wire [2:0]    io_availability,
  input  wire          clk,
  input  wire          resetn
);

  reg        [8:0]    logic_ram_spinal_port1;
  wire       [8:0]    _zz_logic_ram_port;
  reg                 _zz_1;
  wire                logic_ptr_doPush;
  wire                logic_ptr_doPop;
  wire                logic_ptr_full;
  wire                logic_ptr_empty;
  reg        [2:0]    logic_ptr_push;
  reg        [2:0]    logic_ptr_pop;
  wire       [2:0]    logic_ptr_occupancy;
  wire       [2:0]    logic_ptr_popOnIo;
  wire                when_Stream_l1455;
  reg                 logic_ptr_wentUp;
  wire                io_push_fire;
  wire                logic_push_onRam_write_valid;
  wire       [1:0]    logic_push_onRam_write_payload_address;
  wire       [7:0]    logic_push_onRam_write_payload_data_data;
  wire                logic_push_onRam_write_payload_data_error;
  wire                logic_pop_addressGen_valid;
  reg                 logic_pop_addressGen_ready;
  wire       [1:0]    logic_pop_addressGen_payload;
  wire                logic_pop_addressGen_fire;
  wire                logic_pop_sync_readArbitation_valid;
  wire                logic_pop_sync_readArbitation_ready;
  wire       [1:0]    logic_pop_sync_readArbitation_payload;
  reg                 logic_pop_addressGen_rValid;
  reg        [1:0]    logic_pop_addressGen_rData;
  wire                when_Stream_l477;
  wire                logic_pop_sync_readPort_cmd_valid;
  wire       [1:0]    logic_pop_sync_readPort_cmd_payload;
  wire       [7:0]    logic_pop_sync_readPort_rsp_data;
  wire                logic_pop_sync_readPort_rsp_error;
  wire       [8:0]    _zz_logic_pop_sync_readPort_rsp_data;
  wire                logic_pop_addressGen_toFlowFire_valid;
  wire       [1:0]    logic_pop_addressGen_toFlowFire_payload;
  wire                logic_pop_sync_readArbitation_translated_valid;
  wire                logic_pop_sync_readArbitation_translated_ready;
  wire       [7:0]    logic_pop_sync_readArbitation_translated_payload_data;
  wire                logic_pop_sync_readArbitation_translated_payload_error;
  wire                logic_pop_sync_readArbitation_fire;
  reg        [2:0]    logic_pop_sync_popReg;
  reg [8:0] logic_ram [0:3];

  assign _zz_logic_ram_port = {logic_push_onRam_write_payload_data_error,logic_push_onRam_write_payload_data_data};
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

  always @(*) begin
    _zz_1 = 1'b0;
    if(logic_push_onRam_write_valid) begin
      _zz_1 = 1'b1;
    end
  end

  assign when_Stream_l1455 = (logic_ptr_doPush != logic_ptr_doPop);
  assign logic_ptr_full = (((logic_ptr_push ^ logic_ptr_popOnIo) ^ 3'b100) == 3'b000);
  assign logic_ptr_empty = (logic_ptr_push == logic_ptr_pop);
  assign logic_ptr_occupancy = (logic_ptr_push - logic_ptr_popOnIo);
  assign io_push_ready = (! logic_ptr_full);
  assign io_push_fire = (io_push_valid && io_push_ready);
  assign logic_ptr_doPush = io_push_fire;
  assign logic_push_onRam_write_valid = io_push_fire;
  assign logic_push_onRam_write_payload_address = logic_ptr_push[1:0];
  assign logic_push_onRam_write_payload_data_data = io_push_payload_data;
  assign logic_push_onRam_write_payload_data_error = io_push_payload_error;
  assign logic_pop_addressGen_valid = (! logic_ptr_empty);
  assign logic_pop_addressGen_payload = logic_ptr_pop[1:0];
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
  assign _zz_logic_pop_sync_readPort_rsp_data = logic_ram_spinal_port1;
  assign logic_pop_sync_readPort_rsp_data = _zz_logic_pop_sync_readPort_rsp_data[7 : 0];
  assign logic_pop_sync_readPort_rsp_error = _zz_logic_pop_sync_readPort_rsp_data[8];
  assign logic_pop_addressGen_toFlowFire_valid = logic_pop_addressGen_fire;
  assign logic_pop_addressGen_toFlowFire_payload = logic_pop_addressGen_payload;
  assign logic_pop_sync_readPort_cmd_valid = logic_pop_addressGen_toFlowFire_valid;
  assign logic_pop_sync_readPort_cmd_payload = logic_pop_addressGen_toFlowFire_payload;
  assign logic_pop_sync_readArbitation_translated_valid = logic_pop_sync_readArbitation_valid;
  assign logic_pop_sync_readArbitation_ready = logic_pop_sync_readArbitation_translated_ready;
  assign logic_pop_sync_readArbitation_translated_payload_data = logic_pop_sync_readPort_rsp_data;
  assign logic_pop_sync_readArbitation_translated_payload_error = logic_pop_sync_readPort_rsp_error;
  assign io_pop_valid = logic_pop_sync_readArbitation_translated_valid;
  assign logic_pop_sync_readArbitation_translated_ready = io_pop_ready;
  assign io_pop_payload_data = logic_pop_sync_readArbitation_translated_payload_data;
  assign io_pop_payload_error = logic_pop_sync_readArbitation_translated_payload_error;
  assign logic_pop_sync_readArbitation_fire = (logic_pop_sync_readArbitation_valid && logic_pop_sync_readArbitation_ready);
  assign logic_ptr_popOnIo = logic_pop_sync_popReg;
  assign io_occupancy = logic_ptr_occupancy;
  assign io_availability = (3'b100 - logic_ptr_occupancy);
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      logic_ptr_push <= 3'b000;
      logic_ptr_pop <= 3'b000;
      logic_ptr_wentUp <= 1'b0;
      logic_pop_addressGen_rValid <= 1'b0;
      logic_pop_sync_popReg <= 3'b000;
    end else begin
      if(when_Stream_l1455) begin
        logic_ptr_wentUp <= logic_ptr_doPush;
      end
      if(io_flush) begin
        logic_ptr_wentUp <= 1'b0;
      end
      if(logic_ptr_doPush) begin
        logic_ptr_push <= (logic_ptr_push + 3'b001);
      end
      if(logic_ptr_doPop) begin
        logic_ptr_pop <= (logic_ptr_pop + 3'b001);
      end
      if(io_flush) begin
        logic_ptr_push <= 3'b000;
        logic_ptr_pop <= 3'b000;
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
        logic_pop_sync_popReg <= 3'b000;
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
  input  wire [7:0]    io_push_payload_data,
  input  wire          io_push_payload_read,
  input  wire          io_push_payload_start,
  input  wire          io_push_payload_stop,
  input  wire          io_push_payload_ack,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire [7:0]    io_pop_payload_data,
  output wire          io_pop_payload_read,
  output wire          io_pop_payload_start,
  output wire          io_pop_payload_stop,
  output wire          io_pop_payload_ack,
  input  wire          io_flush,
  output wire [2:0]    io_occupancy,
  output wire [2:0]    io_availability,
  input  wire          clk,
  input  wire          resetn
);

  reg        [11:0]   logic_ram_spinal_port1;
  wire       [11:0]   _zz_logic_ram_port;
  reg                 _zz_1;
  wire                logic_ptr_doPush;
  wire                logic_ptr_doPop;
  wire                logic_ptr_full;
  wire                logic_ptr_empty;
  reg        [2:0]    logic_ptr_push;
  reg        [2:0]    logic_ptr_pop;
  wire       [2:0]    logic_ptr_occupancy;
  wire       [2:0]    logic_ptr_popOnIo;
  wire                when_Stream_l1455;
  reg                 logic_ptr_wentUp;
  wire                io_push_fire;
  wire                logic_push_onRam_write_valid;
  wire       [1:0]    logic_push_onRam_write_payload_address;
  wire       [7:0]    logic_push_onRam_write_payload_data_data;
  wire                logic_push_onRam_write_payload_data_read;
  wire                logic_push_onRam_write_payload_data_start;
  wire                logic_push_onRam_write_payload_data_stop;
  wire                logic_push_onRam_write_payload_data_ack;
  wire                logic_pop_addressGen_valid;
  reg                 logic_pop_addressGen_ready;
  wire       [1:0]    logic_pop_addressGen_payload;
  wire                logic_pop_addressGen_fire;
  wire                logic_pop_sync_readArbitation_valid;
  wire                logic_pop_sync_readArbitation_ready;
  wire       [1:0]    logic_pop_sync_readArbitation_payload;
  reg                 logic_pop_addressGen_rValid;
  reg        [1:0]    logic_pop_addressGen_rData;
  wire                when_Stream_l477;
  wire                logic_pop_sync_readPort_cmd_valid;
  wire       [1:0]    logic_pop_sync_readPort_cmd_payload;
  wire       [7:0]    logic_pop_sync_readPort_rsp_data;
  wire                logic_pop_sync_readPort_rsp_read;
  wire                logic_pop_sync_readPort_rsp_start;
  wire                logic_pop_sync_readPort_rsp_stop;
  wire                logic_pop_sync_readPort_rsp_ack;
  wire       [11:0]   _zz_logic_pop_sync_readPort_rsp_data;
  wire                logic_pop_addressGen_toFlowFire_valid;
  wire       [1:0]    logic_pop_addressGen_toFlowFire_payload;
  wire                logic_pop_sync_readArbitation_translated_valid;
  wire                logic_pop_sync_readArbitation_translated_ready;
  wire       [7:0]    logic_pop_sync_readArbitation_translated_payload_data;
  wire                logic_pop_sync_readArbitation_translated_payload_read;
  wire                logic_pop_sync_readArbitation_translated_payload_start;
  wire                logic_pop_sync_readArbitation_translated_payload_stop;
  wire                logic_pop_sync_readArbitation_translated_payload_ack;
  wire                logic_pop_sync_readArbitation_fire;
  reg        [2:0]    logic_pop_sync_popReg;
  reg [11:0] logic_ram [0:3];

  assign _zz_logic_ram_port = {logic_push_onRam_write_payload_data_ack,{logic_push_onRam_write_payload_data_stop,{logic_push_onRam_write_payload_data_start,{logic_push_onRam_write_payload_data_read,logic_push_onRam_write_payload_data_data}}}};
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

  always @(*) begin
    _zz_1 = 1'b0;
    if(logic_push_onRam_write_valid) begin
      _zz_1 = 1'b1;
    end
  end

  assign when_Stream_l1455 = (logic_ptr_doPush != logic_ptr_doPop);
  assign logic_ptr_full = (((logic_ptr_push ^ logic_ptr_popOnIo) ^ 3'b100) == 3'b000);
  assign logic_ptr_empty = (logic_ptr_push == logic_ptr_pop);
  assign logic_ptr_occupancy = (logic_ptr_push - logic_ptr_popOnIo);
  assign io_push_ready = (! logic_ptr_full);
  assign io_push_fire = (io_push_valid && io_push_ready);
  assign logic_ptr_doPush = io_push_fire;
  assign logic_push_onRam_write_valid = io_push_fire;
  assign logic_push_onRam_write_payload_address = logic_ptr_push[1:0];
  assign logic_push_onRam_write_payload_data_data = io_push_payload_data;
  assign logic_push_onRam_write_payload_data_read = io_push_payload_read;
  assign logic_push_onRam_write_payload_data_start = io_push_payload_start;
  assign logic_push_onRam_write_payload_data_stop = io_push_payload_stop;
  assign logic_push_onRam_write_payload_data_ack = io_push_payload_ack;
  assign logic_pop_addressGen_valid = (! logic_ptr_empty);
  assign logic_pop_addressGen_payload = logic_ptr_pop[1:0];
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
  assign _zz_logic_pop_sync_readPort_rsp_data = logic_ram_spinal_port1;
  assign logic_pop_sync_readPort_rsp_data = _zz_logic_pop_sync_readPort_rsp_data[7 : 0];
  assign logic_pop_sync_readPort_rsp_read = _zz_logic_pop_sync_readPort_rsp_data[8];
  assign logic_pop_sync_readPort_rsp_start = _zz_logic_pop_sync_readPort_rsp_data[9];
  assign logic_pop_sync_readPort_rsp_stop = _zz_logic_pop_sync_readPort_rsp_data[10];
  assign logic_pop_sync_readPort_rsp_ack = _zz_logic_pop_sync_readPort_rsp_data[11];
  assign logic_pop_addressGen_toFlowFire_valid = logic_pop_addressGen_fire;
  assign logic_pop_addressGen_toFlowFire_payload = logic_pop_addressGen_payload;
  assign logic_pop_sync_readPort_cmd_valid = logic_pop_addressGen_toFlowFire_valid;
  assign logic_pop_sync_readPort_cmd_payload = logic_pop_addressGen_toFlowFire_payload;
  assign logic_pop_sync_readArbitation_translated_valid = logic_pop_sync_readArbitation_valid;
  assign logic_pop_sync_readArbitation_ready = logic_pop_sync_readArbitation_translated_ready;
  assign logic_pop_sync_readArbitation_translated_payload_data = logic_pop_sync_readPort_rsp_data;
  assign logic_pop_sync_readArbitation_translated_payload_read = logic_pop_sync_readPort_rsp_read;
  assign logic_pop_sync_readArbitation_translated_payload_start = logic_pop_sync_readPort_rsp_start;
  assign logic_pop_sync_readArbitation_translated_payload_stop = logic_pop_sync_readPort_rsp_stop;
  assign logic_pop_sync_readArbitation_translated_payload_ack = logic_pop_sync_readPort_rsp_ack;
  assign io_pop_valid = logic_pop_sync_readArbitation_translated_valid;
  assign logic_pop_sync_readArbitation_translated_ready = io_pop_ready;
  assign io_pop_payload_data = logic_pop_sync_readArbitation_translated_payload_data;
  assign io_pop_payload_read = logic_pop_sync_readArbitation_translated_payload_read;
  assign io_pop_payload_start = logic_pop_sync_readArbitation_translated_payload_start;
  assign io_pop_payload_stop = logic_pop_sync_readArbitation_translated_payload_stop;
  assign io_pop_payload_ack = logic_pop_sync_readArbitation_translated_payload_ack;
  assign logic_pop_sync_readArbitation_fire = (logic_pop_sync_readArbitation_valid && logic_pop_sync_readArbitation_ready);
  assign logic_ptr_popOnIo = logic_pop_sync_popReg;
  assign io_occupancy = logic_ptr_occupancy;
  assign io_availability = (3'b100 - logic_ptr_occupancy);
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      logic_ptr_push <= 3'b000;
      logic_ptr_pop <= 3'b000;
      logic_ptr_wentUp <= 1'b0;
      logic_pop_addressGen_rValid <= 1'b0;
      logic_pop_sync_popReg <= 3'b000;
    end else begin
      if(when_Stream_l1455) begin
        logic_ptr_wentUp <= logic_ptr_doPush;
      end
      if(io_flush) begin
        logic_ptr_wentUp <= 1'b0;
      end
      if(logic_ptr_doPush) begin
        logic_ptr_push <= (logic_ptr_push + 3'b001);
      end
      if(logic_ptr_doPop) begin
        logic_ptr_pop <= (logic_ptr_pop + 3'b001);
      end
      if(io_flush) begin
        logic_ptr_push <= 3'b000;
        logic_ptr_pop <= 3'b000;
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
        logic_pop_sync_popReg <= 3'b000;
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

  assign _zz_header_1 = Ids_I2cController;
  assign _zz_header = {12'd0, _zz_header_1};
  assign header = {{8'h0,8'h08},_zz_header};
  assign version = {{8'h01,8'h0},16'h0};
  assign io_header = header;
  assign io_version = version;

endmodule

module I2cControllerCtrl (
  input  wire [30:0]   io_config_config,
  input  wire [15:0]   io_config_clockDivider,
  input  wire          io_config_clockDividerReload,
  output wire          io_i2c_scl_write,
  input  wire          io_i2c_scl_read,
  output wire          io_i2c_sda_write,
  input  wire          io_i2c_sda_read,
  output wire          io_interrupt,
  input  wire [1:0]    io_pendingInterrupts,
  input  wire          io_cmd_valid,
  output reg           io_cmd_ready,
  input  wire [7:0]    io_cmd_payload_data,
  input  wire          io_cmd_payload_read,
  input  wire          io_cmd_payload_start,
  input  wire          io_cmd_payload_stop,
  input  wire          io_cmd_payload_ack,
  output wire          io_rsp_valid,
  input  wire          io_rsp_ready,
  output wire [7:0]    io_rsp_payload_data,
  output wire          io_rsp_payload_error,
  input  wire          clk,
  input  wire          resetn
);
  localparam State_IDLE = 3'd0;
  localparam State_START = 3'd1;
  localparam State_SENDDATA = 3'd2;
  localparam State_SENDACK = 3'd3;
  localparam State_RECVDATA = 3'd4;
  localparam State_RECVACK = 3'd5;
  localparam State_STOP = 3'd6;
  localparam Samples_FIRST = 2'd0;
  localparam Samples_SECOND = 2'd1;
  localparam Samples_THIRD = 2'd2;
  localparam Samples_FOURTH = 2'd3;

  wire                ctrl_clockDivider_io_tick;
  reg                 ctrlEnable;
  wire                ctrl_newClockEnable;
  reg        [1:0]    ctrl_tickCounter_value;
  reg        [2:0]    ctrl_dataCounter_value;
  reg        [2:0]    ctrl_stateMachine_state;
  wire       [1:0]    ctrl_stateMachine_samples;
  reg                 ctrl_stateMachine_sclWrite;
  reg                 ctrl_stateMachine_sdaWrite;
  wire                ctrl_stateMachine_ack;
  reg                 ctrl_stateMachine_hasStop;
  reg                 ctrl_stateMachine_rspValid;
  reg                 ctrl_stateMachine_error;
  reg        [7:0]    ctrl_stateMachine_data;
  wire                when_I2cControllerCtrl_l153;
  wire                when_I2cControllerCtrl_l161;
  wire                when_I2cControllerCtrl_l164;
  wire                when_I2cControllerCtrl_l167;
  wire                when_I2cControllerCtrl_l175;
  wire                when_I2cControllerCtrl_l179;
  wire                when_I2cControllerCtrl_l182;
  wire                when_I2cControllerCtrl_l186;
  wire                when_I2cControllerCtrl_l188;
  wire                when_I2cControllerCtrl_l198;
  wire                when_I2cControllerCtrl_l202;
  wire                when_I2cControllerCtrl_l206;
  wire                when_I2cControllerCtrl_l218;
  wire                when_I2cControllerCtrl_l222;
  wire                when_I2cControllerCtrl_l226;
  wire                when_I2cControllerCtrl_l228;
  wire                when_I2cControllerCtrl_l237;
  wire                when_I2cControllerCtrl_l240;
  wire                when_I2cControllerCtrl_l243;
  wire                when_I2cControllerCtrl_l248;
  wire                when_I2cControllerCtrl_l260;
  wire                when_I2cControllerCtrl_l263;
  wire                when_I2cControllerCtrl_l266;
  wire                when_I2cControllerCtrl_l269;
  wire                when_I2cControllerCtrl_l277;
  `ifndef SYNTHESIS
  reg [63:0] ctrl_stateMachine_state_string;
  reg [47:0] ctrl_stateMachine_samples_string;
  `endif


  ClockDivider ctrl_clockDivider (
    .io_value            (io_config_clockDivider[15:0]), //i
    .io_reload           (io_config_clockDividerReload), //i
    .io_tick             (ctrl_clockDivider_io_tick   ), //o
    .clk                 (clk                         ), //i
    .resetn              (resetn                      ), //i
    .ctrl_newClockEnable (ctrl_newClockEnable         )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(ctrl_stateMachine_state)
      State_IDLE : ctrl_stateMachine_state_string = "IDLE    ";
      State_START : ctrl_stateMachine_state_string = "START   ";
      State_SENDDATA : ctrl_stateMachine_state_string = "SENDDATA";
      State_SENDACK : ctrl_stateMachine_state_string = "SENDACK ";
      State_RECVDATA : ctrl_stateMachine_state_string = "RECVDATA";
      State_RECVACK : ctrl_stateMachine_state_string = "RECVACK ";
      State_STOP : ctrl_stateMachine_state_string = "STOP    ";
      default : ctrl_stateMachine_state_string = "????????";
    endcase
  end
  always @(*) begin
    case(ctrl_stateMachine_samples)
      Samples_FIRST : ctrl_stateMachine_samples_string = "FIRST ";
      Samples_SECOND : ctrl_stateMachine_samples_string = "SECOND";
      Samples_THIRD : ctrl_stateMachine_samples_string = "THIRD ";
      Samples_FOURTH : ctrl_stateMachine_samples_string = "FOURTH";
      default : ctrl_stateMachine_samples_string = "??????";
    endcase
  end
  `endif

  assign ctrl_newClockEnable = (1'b1 && ctrlEnable);
  assign ctrl_stateMachine_samples = Samples_FIRST;
  assign ctrl_stateMachine_ack = 1'b0;
  always @(*) begin
    io_cmd_ready = 1'b0;
    case(ctrl_stateMachine_state)
      State_IDLE : begin
      end
      State_START : begin
      end
      State_RECVDATA : begin
      end
      State_RECVACK : begin
        if(ctrl_clockDivider_io_tick) begin
          if(when_I2cControllerCtrl_l202) begin
            io_cmd_ready = 1'b1;
          end
        end
      end
      State_SENDDATA : begin
        if(ctrl_clockDivider_io_tick) begin
          if(when_I2cControllerCtrl_l226) begin
            if(when_I2cControllerCtrl_l228) begin
              io_cmd_ready = 1'b1;
            end
          end
        end
      end
      State_SENDACK : begin
      end
      default : begin
      end
    endcase
  end

  assign when_I2cControllerCtrl_l153 = (io_cmd_valid && ctrl_clockDivider_io_tick);
  assign when_I2cControllerCtrl_l161 = (ctrl_tickCounter_value == 2'b01);
  assign when_I2cControllerCtrl_l164 = (ctrl_tickCounter_value == 2'b10);
  assign when_I2cControllerCtrl_l167 = (ctrl_tickCounter_value == 2'b11);
  assign when_I2cControllerCtrl_l175 = (ctrl_tickCounter_value == 2'b00);
  assign when_I2cControllerCtrl_l179 = (ctrl_tickCounter_value == 2'b01);
  assign when_I2cControllerCtrl_l182 = (ctrl_tickCounter_value == 2'b10);
  assign when_I2cControllerCtrl_l186 = (ctrl_tickCounter_value == 2'b11);
  assign when_I2cControllerCtrl_l188 = (ctrl_dataCounter_value == 3'b111);
  assign when_I2cControllerCtrl_l198 = (ctrl_tickCounter_value == 2'b00);
  assign when_I2cControllerCtrl_l202 = (ctrl_tickCounter_value == 2'b01);
  assign when_I2cControllerCtrl_l206 = (ctrl_tickCounter_value == 2'b11);
  assign when_I2cControllerCtrl_l218 = (ctrl_tickCounter_value == 2'b00);
  assign when_I2cControllerCtrl_l222 = (ctrl_tickCounter_value == 2'b01);
  assign when_I2cControllerCtrl_l226 = (ctrl_tickCounter_value == 2'b11);
  assign when_I2cControllerCtrl_l228 = (ctrl_dataCounter_value == 3'b111);
  assign when_I2cControllerCtrl_l237 = (ctrl_tickCounter_value == 2'b00);
  assign when_I2cControllerCtrl_l240 = (ctrl_tickCounter_value == 2'b01);
  assign when_I2cControllerCtrl_l243 = (ctrl_tickCounter_value == 2'b10);
  assign when_I2cControllerCtrl_l248 = (ctrl_tickCounter_value == 2'b11);
  assign when_I2cControllerCtrl_l260 = (ctrl_tickCounter_value == 2'b00);
  assign when_I2cControllerCtrl_l263 = (ctrl_tickCounter_value == 2'b01);
  assign when_I2cControllerCtrl_l266 = (ctrl_tickCounter_value == 2'b10);
  assign when_I2cControllerCtrl_l269 = (ctrl_tickCounter_value == 2'b11);
  assign when_I2cControllerCtrl_l277 = (io_cmd_valid || (! (ctrl_stateMachine_state == State_IDLE)));
  assign io_rsp_valid = ctrl_stateMachine_rspValid;
  assign io_rsp_payload_data = ctrl_stateMachine_data;
  assign io_rsp_payload_error = ctrl_stateMachine_error;
  assign io_i2c_scl_write = ctrl_stateMachine_sclWrite;
  assign io_i2c_sda_write = ctrl_stateMachine_sdaWrite;
  assign io_interrupt = (|io_pendingInterrupts);
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      ctrlEnable <= 1'b1;
    end else begin
      if(when_I2cControllerCtrl_l277) begin
        ctrlEnable <= 1'b1;
      end else begin
        ctrlEnable <= 1'b0;
      end
    end
  end

  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      ctrl_tickCounter_value <= 2'b00;
      ctrl_dataCounter_value <= 3'b111;
      ctrl_stateMachine_state <= State_IDLE;
      ctrl_stateMachine_sclWrite <= 1'b0;
      ctrl_stateMachine_sdaWrite <= 1'b0;
      ctrl_stateMachine_hasStop <= 1'b0;
      ctrl_stateMachine_rspValid <= 1'b0;
    end else begin
      if(ctrl_newClockEnable) begin
        if(ctrl_clockDivider_io_tick) begin
          ctrl_tickCounter_value <= (ctrl_tickCounter_value + 2'b01);
        end
        ctrl_stateMachine_rspValid <= 1'b0;
        case(ctrl_stateMachine_state)
          State_IDLE : begin
            if(when_I2cControllerCtrl_l153) begin
              ctrl_tickCounter_value <= 2'b00;
              ctrl_dataCounter_value <= 3'b111;
              if(io_cmd_payload_start) begin
                ctrl_stateMachine_state <= State_START;
              end else begin
                if(io_cmd_payload_read) begin
                  ctrl_stateMachine_state <= State_RECVDATA;
                end else begin
                  ctrl_stateMachine_state <= State_SENDDATA;
                end
              end
            end
          end
          State_START : begin
            if(ctrl_clockDivider_io_tick) begin
              if(when_I2cControllerCtrl_l161) begin
                ctrl_stateMachine_sclWrite <= 1'b0;
              end
              if(when_I2cControllerCtrl_l164) begin
                ctrl_stateMachine_sdaWrite <= 1'b1;
              end
              if(when_I2cControllerCtrl_l167) begin
                ctrl_stateMachine_sclWrite <= 1'b1;
                ctrl_stateMachine_state <= State_SENDDATA;
              end
            end
          end
          State_RECVDATA : begin
            if(ctrl_clockDivider_io_tick) begin
              if(when_I2cControllerCtrl_l175) begin
                ctrl_stateMachine_sdaWrite <= 1'b0;
                ctrl_stateMachine_hasStop <= io_cmd_payload_stop;
              end
              if(when_I2cControllerCtrl_l179) begin
                ctrl_stateMachine_sclWrite <= 1'b0;
              end
              if(when_I2cControllerCtrl_l182) begin
                ctrl_dataCounter_value <= (ctrl_dataCounter_value - 3'b001);
              end
              if(when_I2cControllerCtrl_l186) begin
                ctrl_stateMachine_sclWrite <= 1'b1;
                if(when_I2cControllerCtrl_l188) begin
                  ctrl_stateMachine_state <= State_RECVACK;
                  ctrl_stateMachine_rspValid <= 1'b1;
                end
              end
            end
          end
          State_RECVACK : begin
            if(ctrl_clockDivider_io_tick) begin
              if(when_I2cControllerCtrl_l198) begin
                ctrl_stateMachine_sdaWrite <= (io_cmd_payload_ack && io_rsp_ready);
              end
              if(when_I2cControllerCtrl_l202) begin
                ctrl_stateMachine_sclWrite <= 1'b0;
              end
              if(when_I2cControllerCtrl_l206) begin
                ctrl_stateMachine_sclWrite <= 1'b1;
                if(ctrl_stateMachine_hasStop) begin
                  ctrl_stateMachine_state <= State_STOP;
                end else begin
                  if(io_cmd_valid) begin
                    if(io_cmd_payload_start) begin
                      ctrl_stateMachine_state <= State_START;
                    end else begin
                      if(io_cmd_payload_read) begin
                        ctrl_stateMachine_state <= State_RECVDATA;
                      end else begin
                        ctrl_stateMachine_state <= State_SENDDATA;
                      end
                    end
                  end else begin
                    ctrl_stateMachine_state <= State_IDLE;
                  end
                end
              end
            end
          end
          State_SENDDATA : begin
            if(ctrl_clockDivider_io_tick) begin
              if(when_I2cControllerCtrl_l218) begin
                ctrl_stateMachine_hasStop <= io_cmd_payload_stop;
                ctrl_stateMachine_sdaWrite <= (! io_cmd_payload_data[ctrl_dataCounter_value]);
              end
              if(when_I2cControllerCtrl_l222) begin
                ctrl_stateMachine_sclWrite <= 1'b0;
                ctrl_dataCounter_value <= (ctrl_dataCounter_value - 3'b001);
              end
              if(when_I2cControllerCtrl_l226) begin
                ctrl_stateMachine_sclWrite <= 1'b1;
                if(when_I2cControllerCtrl_l228) begin
                  ctrl_stateMachine_state <= State_SENDACK;
                end
              end
            end
          end
          State_SENDACK : begin
            if(ctrl_clockDivider_io_tick) begin
              if(when_I2cControllerCtrl_l237) begin
                ctrl_stateMachine_sdaWrite <= 1'b0;
              end
              if(when_I2cControllerCtrl_l240) begin
                ctrl_stateMachine_sclWrite <= 1'b0;
              end
              if(when_I2cControllerCtrl_l243) begin
                ctrl_stateMachine_rspValid <= 1'b1;
              end
              if(when_I2cControllerCtrl_l248) begin
                ctrl_stateMachine_sclWrite <= 1'b1;
                if(ctrl_stateMachine_hasStop) begin
                  ctrl_stateMachine_state <= State_STOP;
                end else begin
                  if(io_cmd_valid) begin
                    if(io_cmd_payload_start) begin
                      ctrl_stateMachine_state <= State_START;
                    end else begin
                      if(io_cmd_payload_read) begin
                        ctrl_stateMachine_state <= State_RECVDATA;
                      end else begin
                        ctrl_stateMachine_state <= State_SENDDATA;
                      end
                    end
                  end else begin
                    ctrl_stateMachine_state <= State_IDLE;
                  end
                end
              end
            end
          end
          default : begin
            if(ctrl_clockDivider_io_tick) begin
              if(when_I2cControllerCtrl_l260) begin
                ctrl_stateMachine_sdaWrite <= 1'b1;
              end
              if(when_I2cControllerCtrl_l263) begin
                ctrl_stateMachine_sclWrite <= 1'b0;
              end
              if(when_I2cControllerCtrl_l266) begin
                ctrl_stateMachine_sdaWrite <= 1'b0;
              end
              if(when_I2cControllerCtrl_l269) begin
                if(io_cmd_valid) begin
                  if(io_cmd_payload_start) begin
                    ctrl_stateMachine_state <= State_START;
                  end else begin
                    if(io_cmd_payload_read) begin
                      ctrl_stateMachine_state <= State_RECVDATA;
                    end else begin
                      ctrl_stateMachine_state <= State_SENDDATA;
                    end
                  end
                end else begin
                  ctrl_stateMachine_state <= State_IDLE;
                end
              end
            end
          end
        endcase
      end
    end
  end

  always @(posedge clk) begin
    if(ctrl_newClockEnable) begin
      case(ctrl_stateMachine_state)
        State_IDLE : begin
        end
        State_START : begin
        end
        State_RECVDATA : begin
          if(ctrl_clockDivider_io_tick) begin
            if(when_I2cControllerCtrl_l182) begin
              ctrl_stateMachine_data[ctrl_dataCounter_value] <= io_i2c_sda_read;
            end
            if(when_I2cControllerCtrl_l186) begin
              if(when_I2cControllerCtrl_l188) begin
                ctrl_stateMachine_error <= 1'b0;
              end
            end
          end
        end
        State_RECVACK : begin
        end
        State_SENDDATA : begin
        end
        State_SENDACK : begin
          if(ctrl_clockDivider_io_tick) begin
            if(when_I2cControllerCtrl_l243) begin
              ctrl_stateMachine_error <= io_i2c_sda_read;
              ctrl_stateMachine_data <= 8'h0;
            end
          end
        end
        default : begin
        end
      endcase
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
