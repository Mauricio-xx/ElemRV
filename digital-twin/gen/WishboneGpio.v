// Generator : SpinalHDL v1.13.0    git head : d9d72474863badf47d8585d187f3e04ae4749c59
// Component : WishboneGpio
// Git hash  : c46981392eb50d83a12c687a69933cc658cd2128

`timescale 1ns/1ps

module WishboneGpio (
  input  wire          io_bus_CYC,
  input  wire          io_bus_STB,
  output wire          io_bus_ACK,
  input  wire          io_bus_WE,
  input  wire [9:0]    io_bus_ADR,
  output reg  [31:0]   io_bus_DAT_MISO,
  input  wire [31:0]   io_bus_DAT_MOSI,
  input  wire [11:0]   io_gpio_pins_read,
  output wire [11:0]   io_gpio_pins_write,
  output wire [11:0]   io_gpio_pins_writeEnable,
  output wire          io_interrupt,
  input  wire          clk,
  input  wire          resetn
);

  reg        [11:0]   ctrl_io_config_write;
  reg        [11:0]   ctrl_io_config_direction;
  reg        [11:0]   ctrl_io_irqHigh_pending;
  reg        [11:0]   ctrl_io_irqLow_pending;
  reg        [11:0]   ctrl_io_irqRise_pending;
  reg        [11:0]   ctrl_io_irqFall_pending;
  reg        [11:0]   interruptCtrl_4_io_inputs;
  reg        [11:0]   interruptCtrl_4_io_clears;
  reg        [11:0]   interruptCtrl_5_io_inputs;
  reg        [11:0]   interruptCtrl_5_io_clears;
  reg        [11:0]   interruptCtrl_6_io_inputs;
  reg        [11:0]   interruptCtrl_6_io_clears;
  reg        [11:0]   interruptCtrl_7_io_inputs;
  reg        [11:0]   interruptCtrl_7_io_clears;
  wire       [11:0]   ctrl_io_gpio_pins_write;
  wire       [11:0]   ctrl_io_gpio_pins_writeEnable;
  wire       [11:0]   ctrl_io_value;
  wire                ctrl_io_interrupt;
  wire       [11:0]   ctrl_io_irqHigh_valid;
  wire       [11:0]   ctrl_io_irqLow_valid;
  wire       [11:0]   ctrl_io_irqRise_valid;
  wire       [11:0]   ctrl_io_irqFall_valid;
  wire       [31:0]   mapper_idCtrl_io_header;
  wire       [31:0]   mapper_idCtrl_io_version;
  wire       [11:0]   interruptCtrl_4_io_pendings;
  wire       [11:0]   interruptCtrl_5_io_pendings;
  wire       [11:0]   interruptCtrl_6_io_pendings;
  wire       [11:0]   interruptCtrl_7_io_pendings;
  wire       [11:0]   _zz_2;
  wire                _zz_1;
  reg                 _zz_io_bus_ACK;
  reg        [11:0]   io_masks_driver;
  reg        [11:0]   io_masks_driver_1;
  reg        [11:0]   io_masks_driver_2;
  reg        [11:0]   io_masks_driver_3;
  reg                 _zz_io_bus_DAT_MISO;
  wire                _zz_io_bus_DAT_MISO_1;
  reg                 _zz_io_bus_DAT_MISO_2;
  wire                _zz_io_bus_DAT_MISO_3;
  reg                 _zz_io_bus_DAT_MISO_4;
  wire                _zz_io_bus_DAT_MISO_5;
  reg                 _zz_io_bus_DAT_MISO_6;
  wire                _zz_io_bus_DAT_MISO_7;
  reg                 _zz_io_bus_DAT_MISO_8;
  wire                _zz_io_bus_DAT_MISO_9;
  reg                 _zz_io_bus_DAT_MISO_10;
  wire                _zz_io_bus_DAT_MISO_11;
  reg                 _zz_io_bus_DAT_MISO_12;
  wire                _zz_io_bus_DAT_MISO_13;
  reg                 _zz_io_bus_DAT_MISO_14;
  wire                _zz_io_bus_DAT_MISO_15;
  reg                 _zz_io_bus_DAT_MISO_16;
  wire                _zz_io_bus_DAT_MISO_17;
  reg                 _zz_io_bus_DAT_MISO_18;
  wire                _zz_io_bus_DAT_MISO_19;
  reg                 _zz_io_bus_DAT_MISO_20;
  wire                _zz_io_bus_DAT_MISO_21;
  reg                 _zz_io_bus_DAT_MISO_22;
  wire                _zz_io_bus_DAT_MISO_23;

  assign _zz_2 = ({2'd0,io_bus_ADR} <<< 2'd2);
  GpioCtrl ctrl (
    .io_gpio_pins_read        (io_gpio_pins_read[11:0]            ), //i
    .io_gpio_pins_write       (ctrl_io_gpio_pins_write[11:0]      ), //o
    .io_gpio_pins_writeEnable (ctrl_io_gpio_pins_writeEnable[11:0]), //o
    .io_config_write          (ctrl_io_config_write[11:0]         ), //i
    .io_config_direction      (ctrl_io_config_direction[11:0]     ), //i
    .io_value                 (ctrl_io_value[11:0]                ), //o
    .io_interrupt             (ctrl_io_interrupt                  ), //o
    .io_irqHigh_valid         (ctrl_io_irqHigh_valid[11:0]        ), //o
    .io_irqHigh_pending       (ctrl_io_irqHigh_pending[11:0]      ), //i
    .io_irqLow_valid          (ctrl_io_irqLow_valid[11:0]         ), //o
    .io_irqLow_pending        (ctrl_io_irqLow_pending[11:0]       ), //i
    .io_irqRise_valid         (ctrl_io_irqRise_valid[11:0]        ), //o
    .io_irqRise_pending       (ctrl_io_irqRise_pending[11:0]      ), //i
    .io_irqFall_valid         (ctrl_io_irqFall_valid[11:0]        ), //o
    .io_irqFall_pending       (ctrl_io_irqFall_pending[11:0]      ), //i
    .clk                      (clk                                ), //i
    .resetn                   (resetn                             )  //i
  );
  IpIdentificationCtrl mapper_idCtrl (
    .io_header  (mapper_idCtrl_io_header[31:0] ), //o
    .io_version (mapper_idCtrl_io_version[31:0]), //o
    .clk        (clk                           ), //i
    .resetn     (resetn                        )  //i
  );
  InterruptCtrl interruptCtrl_4 (
    .io_inputs   (interruptCtrl_4_io_inputs[11:0]  ), //i
    .io_clears   (interruptCtrl_4_io_clears[11:0]  ), //i
    .io_masks    (io_masks_driver[11:0]            ), //i
    .io_pendings (interruptCtrl_4_io_pendings[11:0]), //o
    .clk         (clk                              ), //i
    .resetn      (resetn                           )  //i
  );
  InterruptCtrl interruptCtrl_5 (
    .io_inputs   (interruptCtrl_5_io_inputs[11:0]  ), //i
    .io_clears   (interruptCtrl_5_io_clears[11:0]  ), //i
    .io_masks    (io_masks_driver_1[11:0]          ), //i
    .io_pendings (interruptCtrl_5_io_pendings[11:0]), //o
    .clk         (clk                              ), //i
    .resetn      (resetn                           )  //i
  );
  InterruptCtrl interruptCtrl_6 (
    .io_inputs   (interruptCtrl_6_io_inputs[11:0]  ), //i
    .io_clears   (interruptCtrl_6_io_clears[11:0]  ), //i
    .io_masks    (io_masks_driver_2[11:0]          ), //i
    .io_pendings (interruptCtrl_6_io_pendings[11:0]), //o
    .clk         (clk                              ), //i
    .resetn      (resetn                           )  //i
  );
  InterruptCtrl interruptCtrl_7 (
    .io_inputs   (interruptCtrl_7_io_inputs[11:0]  ), //i
    .io_clears   (interruptCtrl_7_io_clears[11:0]  ), //i
    .io_masks    (io_masks_driver_3[11:0]          ), //i
    .io_pendings (interruptCtrl_7_io_pendings[11:0]), //o
    .clk         (clk                              ), //i
    .resetn      (resetn                           )  //i
  );
  assign io_gpio_pins_write = ctrl_io_gpio_pins_write;
  assign io_gpio_pins_writeEnable = ctrl_io_gpio_pins_writeEnable;
  assign io_interrupt = ctrl_io_interrupt;
  always @(*) begin
    io_bus_DAT_MISO = 32'h0;
    case(_zz_2)
      12'h0 : begin
        io_bus_DAT_MISO[31 : 0] = mapper_idCtrl_io_header;
      end
      12'h004 : begin
        io_bus_DAT_MISO[31 : 0] = mapper_idCtrl_io_version;
      end
      12'h008 : begin
        io_bus_DAT_MISO[31 : 0] = {16'h0001,16'h000c};
      end
      12'h018 : begin
        io_bus_DAT_MISO[11 : 0] = interruptCtrl_4_io_pendings;
      end
      12'h01c : begin
        io_bus_DAT_MISO[11 : 0] = io_masks_driver;
      end
      12'h020 : begin
        io_bus_DAT_MISO[11 : 0] = interruptCtrl_5_io_pendings;
      end
      12'h024 : begin
        io_bus_DAT_MISO[11 : 0] = io_masks_driver_1;
      end
      12'h028 : begin
        io_bus_DAT_MISO[11 : 0] = interruptCtrl_6_io_pendings;
      end
      12'h02c : begin
        io_bus_DAT_MISO[11 : 0] = io_masks_driver_2;
      end
      12'h030 : begin
        io_bus_DAT_MISO[11 : 0] = interruptCtrl_7_io_pendings;
      end
      12'h034 : begin
        io_bus_DAT_MISO[11 : 0] = io_masks_driver_3;
      end
      12'h00c : begin
        io_bus_DAT_MISO[0 : 0] = ctrl_io_value[0];
        io_bus_DAT_MISO[1 : 1] = ctrl_io_value[1];
        io_bus_DAT_MISO[2 : 2] = ctrl_io_value[2];
        io_bus_DAT_MISO[3 : 3] = ctrl_io_value[3];
        io_bus_DAT_MISO[4 : 4] = ctrl_io_value[4];
        io_bus_DAT_MISO[5 : 5] = ctrl_io_value[5];
        io_bus_DAT_MISO[6 : 6] = ctrl_io_value[6];
        io_bus_DAT_MISO[7 : 7] = ctrl_io_value[7];
        io_bus_DAT_MISO[8 : 8] = ctrl_io_value[8];
        io_bus_DAT_MISO[9 : 9] = ctrl_io_value[9];
        io_bus_DAT_MISO[10 : 10] = ctrl_io_value[10];
        io_bus_DAT_MISO[11 : 11] = ctrl_io_value[11];
      end
      12'h010 : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO;
        io_bus_DAT_MISO[1 : 1] = _zz_io_bus_DAT_MISO_2;
        io_bus_DAT_MISO[2 : 2] = _zz_io_bus_DAT_MISO_4;
        io_bus_DAT_MISO[3 : 3] = _zz_io_bus_DAT_MISO_6;
        io_bus_DAT_MISO[4 : 4] = _zz_io_bus_DAT_MISO_8;
        io_bus_DAT_MISO[5 : 5] = _zz_io_bus_DAT_MISO_10;
        io_bus_DAT_MISO[6 : 6] = _zz_io_bus_DAT_MISO_12;
        io_bus_DAT_MISO[7 : 7] = _zz_io_bus_DAT_MISO_14;
        io_bus_DAT_MISO[8 : 8] = _zz_io_bus_DAT_MISO_16;
        io_bus_DAT_MISO[9 : 9] = _zz_io_bus_DAT_MISO_18;
        io_bus_DAT_MISO[10 : 10] = _zz_io_bus_DAT_MISO_20;
        io_bus_DAT_MISO[11 : 11] = _zz_io_bus_DAT_MISO_22;
      end
      12'h014 : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO_1;
        io_bus_DAT_MISO[1 : 1] = _zz_io_bus_DAT_MISO_3;
        io_bus_DAT_MISO[2 : 2] = _zz_io_bus_DAT_MISO_5;
        io_bus_DAT_MISO[3 : 3] = _zz_io_bus_DAT_MISO_7;
        io_bus_DAT_MISO[4 : 4] = _zz_io_bus_DAT_MISO_9;
        io_bus_DAT_MISO[5 : 5] = _zz_io_bus_DAT_MISO_11;
        io_bus_DAT_MISO[6 : 6] = _zz_io_bus_DAT_MISO_13;
        io_bus_DAT_MISO[7 : 7] = _zz_io_bus_DAT_MISO_15;
        io_bus_DAT_MISO[8 : 8] = _zz_io_bus_DAT_MISO_17;
        io_bus_DAT_MISO[9 : 9] = _zz_io_bus_DAT_MISO_19;
        io_bus_DAT_MISO[10 : 10] = _zz_io_bus_DAT_MISO_21;
        io_bus_DAT_MISO[11 : 11] = _zz_io_bus_DAT_MISO_23;
      end
      default : begin
      end
    endcase
  end

  assign _zz_1 = (((io_bus_CYC && io_bus_STB) && ((io_bus_CYC && io_bus_ACK) && io_bus_STB)) && io_bus_WE);
  assign io_bus_ACK = (_zz_io_bus_ACK && io_bus_STB);
  always @(*) begin
    interruptCtrl_4_io_clears = 12'h0;
    case(_zz_2)
      12'h018 : begin
        if(_zz_1) begin
          interruptCtrl_4_io_clears = io_bus_DAT_MOSI[11 : 0];
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    interruptCtrl_5_io_clears = 12'h0;
    case(_zz_2)
      12'h020 : begin
        if(_zz_1) begin
          interruptCtrl_5_io_clears = io_bus_DAT_MOSI[11 : 0];
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    interruptCtrl_6_io_clears = 12'h0;
    case(_zz_2)
      12'h028 : begin
        if(_zz_1) begin
          interruptCtrl_6_io_clears = io_bus_DAT_MOSI[11 : 0];
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    interruptCtrl_7_io_clears = 12'h0;
    case(_zz_2)
      12'h030 : begin
        if(_zz_1) begin
          interruptCtrl_7_io_clears = io_bus_DAT_MOSI[11 : 0];
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    ctrl_io_config_write[0] = _zz_io_bus_DAT_MISO;
    ctrl_io_config_write[1] = _zz_io_bus_DAT_MISO_2;
    ctrl_io_config_write[2] = _zz_io_bus_DAT_MISO_4;
    ctrl_io_config_write[3] = _zz_io_bus_DAT_MISO_6;
    ctrl_io_config_write[4] = _zz_io_bus_DAT_MISO_8;
    ctrl_io_config_write[5] = _zz_io_bus_DAT_MISO_10;
    ctrl_io_config_write[6] = _zz_io_bus_DAT_MISO_12;
    ctrl_io_config_write[7] = _zz_io_bus_DAT_MISO_14;
    ctrl_io_config_write[8] = _zz_io_bus_DAT_MISO_16;
    ctrl_io_config_write[9] = _zz_io_bus_DAT_MISO_18;
    ctrl_io_config_write[10] = _zz_io_bus_DAT_MISO_20;
    ctrl_io_config_write[11] = _zz_io_bus_DAT_MISO_22;
  end

  assign _zz_io_bus_DAT_MISO_1 = 1'b1;
  always @(*) begin
    ctrl_io_config_direction[0] = _zz_io_bus_DAT_MISO_1;
    ctrl_io_config_direction[1] = _zz_io_bus_DAT_MISO_3;
    ctrl_io_config_direction[2] = _zz_io_bus_DAT_MISO_5;
    ctrl_io_config_direction[3] = _zz_io_bus_DAT_MISO_7;
    ctrl_io_config_direction[4] = _zz_io_bus_DAT_MISO_9;
    ctrl_io_config_direction[5] = _zz_io_bus_DAT_MISO_11;
    ctrl_io_config_direction[6] = _zz_io_bus_DAT_MISO_13;
    ctrl_io_config_direction[7] = _zz_io_bus_DAT_MISO_15;
    ctrl_io_config_direction[8] = _zz_io_bus_DAT_MISO_17;
    ctrl_io_config_direction[9] = _zz_io_bus_DAT_MISO_19;
    ctrl_io_config_direction[10] = _zz_io_bus_DAT_MISO_21;
    ctrl_io_config_direction[11] = _zz_io_bus_DAT_MISO_23;
  end

  always @(*) begin
    interruptCtrl_4_io_inputs[0] = ctrl_io_irqHigh_valid[0];
    interruptCtrl_4_io_inputs[1] = ctrl_io_irqHigh_valid[1];
    interruptCtrl_4_io_inputs[2] = ctrl_io_irqHigh_valid[2];
    interruptCtrl_4_io_inputs[3] = ctrl_io_irqHigh_valid[3];
    interruptCtrl_4_io_inputs[4] = ctrl_io_irqHigh_valid[4];
    interruptCtrl_4_io_inputs[5] = ctrl_io_irqHigh_valid[5];
    interruptCtrl_4_io_inputs[6] = ctrl_io_irqHigh_valid[6];
    interruptCtrl_4_io_inputs[7] = ctrl_io_irqHigh_valid[7];
    interruptCtrl_4_io_inputs[8] = ctrl_io_irqHigh_valid[8];
    interruptCtrl_4_io_inputs[9] = ctrl_io_irqHigh_valid[9];
    interruptCtrl_4_io_inputs[10] = ctrl_io_irqHigh_valid[10];
    interruptCtrl_4_io_inputs[11] = ctrl_io_irqHigh_valid[11];
  end

  always @(*) begin
    interruptCtrl_5_io_inputs[0] = ctrl_io_irqLow_valid[0];
    interruptCtrl_5_io_inputs[1] = ctrl_io_irqLow_valid[1];
    interruptCtrl_5_io_inputs[2] = ctrl_io_irqLow_valid[2];
    interruptCtrl_5_io_inputs[3] = ctrl_io_irqLow_valid[3];
    interruptCtrl_5_io_inputs[4] = ctrl_io_irqLow_valid[4];
    interruptCtrl_5_io_inputs[5] = ctrl_io_irqLow_valid[5];
    interruptCtrl_5_io_inputs[6] = ctrl_io_irqLow_valid[6];
    interruptCtrl_5_io_inputs[7] = ctrl_io_irqLow_valid[7];
    interruptCtrl_5_io_inputs[8] = ctrl_io_irqLow_valid[8];
    interruptCtrl_5_io_inputs[9] = ctrl_io_irqLow_valid[9];
    interruptCtrl_5_io_inputs[10] = ctrl_io_irqLow_valid[10];
    interruptCtrl_5_io_inputs[11] = ctrl_io_irqLow_valid[11];
  end

  always @(*) begin
    interruptCtrl_6_io_inputs[0] = ctrl_io_irqRise_valid[0];
    interruptCtrl_6_io_inputs[1] = ctrl_io_irqRise_valid[1];
    interruptCtrl_6_io_inputs[2] = ctrl_io_irqRise_valid[2];
    interruptCtrl_6_io_inputs[3] = ctrl_io_irqRise_valid[3];
    interruptCtrl_6_io_inputs[4] = ctrl_io_irqRise_valid[4];
    interruptCtrl_6_io_inputs[5] = ctrl_io_irqRise_valid[5];
    interruptCtrl_6_io_inputs[6] = ctrl_io_irqRise_valid[6];
    interruptCtrl_6_io_inputs[7] = ctrl_io_irqRise_valid[7];
    interruptCtrl_6_io_inputs[8] = ctrl_io_irqRise_valid[8];
    interruptCtrl_6_io_inputs[9] = ctrl_io_irqRise_valid[9];
    interruptCtrl_6_io_inputs[10] = ctrl_io_irqRise_valid[10];
    interruptCtrl_6_io_inputs[11] = ctrl_io_irqRise_valid[11];
  end

  always @(*) begin
    interruptCtrl_7_io_inputs[0] = ctrl_io_irqFall_valid[0];
    interruptCtrl_7_io_inputs[1] = ctrl_io_irqFall_valid[1];
    interruptCtrl_7_io_inputs[2] = ctrl_io_irqFall_valid[2];
    interruptCtrl_7_io_inputs[3] = ctrl_io_irqFall_valid[3];
    interruptCtrl_7_io_inputs[4] = ctrl_io_irqFall_valid[4];
    interruptCtrl_7_io_inputs[5] = ctrl_io_irqFall_valid[5];
    interruptCtrl_7_io_inputs[6] = ctrl_io_irqFall_valid[6];
    interruptCtrl_7_io_inputs[7] = ctrl_io_irqFall_valid[7];
    interruptCtrl_7_io_inputs[8] = ctrl_io_irqFall_valid[8];
    interruptCtrl_7_io_inputs[9] = ctrl_io_irqFall_valid[9];
    interruptCtrl_7_io_inputs[10] = ctrl_io_irqFall_valid[10];
    interruptCtrl_7_io_inputs[11] = ctrl_io_irqFall_valid[11];
  end

  always @(*) begin
    ctrl_io_irqHigh_pending[0] = interruptCtrl_4_io_pendings[0];
    ctrl_io_irqHigh_pending[1] = interruptCtrl_4_io_pendings[1];
    ctrl_io_irqHigh_pending[2] = interruptCtrl_4_io_pendings[2];
    ctrl_io_irqHigh_pending[3] = interruptCtrl_4_io_pendings[3];
    ctrl_io_irqHigh_pending[4] = interruptCtrl_4_io_pendings[4];
    ctrl_io_irqHigh_pending[5] = interruptCtrl_4_io_pendings[5];
    ctrl_io_irqHigh_pending[6] = interruptCtrl_4_io_pendings[6];
    ctrl_io_irqHigh_pending[7] = interruptCtrl_4_io_pendings[7];
    ctrl_io_irqHigh_pending[8] = interruptCtrl_4_io_pendings[8];
    ctrl_io_irqHigh_pending[9] = interruptCtrl_4_io_pendings[9];
    ctrl_io_irqHigh_pending[10] = interruptCtrl_4_io_pendings[10];
    ctrl_io_irqHigh_pending[11] = interruptCtrl_4_io_pendings[11];
  end

  always @(*) begin
    ctrl_io_irqLow_pending[0] = interruptCtrl_5_io_pendings[0];
    ctrl_io_irqLow_pending[1] = interruptCtrl_5_io_pendings[1];
    ctrl_io_irqLow_pending[2] = interruptCtrl_5_io_pendings[2];
    ctrl_io_irqLow_pending[3] = interruptCtrl_5_io_pendings[3];
    ctrl_io_irqLow_pending[4] = interruptCtrl_5_io_pendings[4];
    ctrl_io_irqLow_pending[5] = interruptCtrl_5_io_pendings[5];
    ctrl_io_irqLow_pending[6] = interruptCtrl_5_io_pendings[6];
    ctrl_io_irqLow_pending[7] = interruptCtrl_5_io_pendings[7];
    ctrl_io_irqLow_pending[8] = interruptCtrl_5_io_pendings[8];
    ctrl_io_irqLow_pending[9] = interruptCtrl_5_io_pendings[9];
    ctrl_io_irqLow_pending[10] = interruptCtrl_5_io_pendings[10];
    ctrl_io_irqLow_pending[11] = interruptCtrl_5_io_pendings[11];
  end

  always @(*) begin
    ctrl_io_irqRise_pending[0] = interruptCtrl_6_io_pendings[0];
    ctrl_io_irqRise_pending[1] = interruptCtrl_6_io_pendings[1];
    ctrl_io_irqRise_pending[2] = interruptCtrl_6_io_pendings[2];
    ctrl_io_irqRise_pending[3] = interruptCtrl_6_io_pendings[3];
    ctrl_io_irqRise_pending[4] = interruptCtrl_6_io_pendings[4];
    ctrl_io_irqRise_pending[5] = interruptCtrl_6_io_pendings[5];
    ctrl_io_irqRise_pending[6] = interruptCtrl_6_io_pendings[6];
    ctrl_io_irqRise_pending[7] = interruptCtrl_6_io_pendings[7];
    ctrl_io_irqRise_pending[8] = interruptCtrl_6_io_pendings[8];
    ctrl_io_irqRise_pending[9] = interruptCtrl_6_io_pendings[9];
    ctrl_io_irqRise_pending[10] = interruptCtrl_6_io_pendings[10];
    ctrl_io_irqRise_pending[11] = interruptCtrl_6_io_pendings[11];
  end

  always @(*) begin
    ctrl_io_irqFall_pending[0] = interruptCtrl_7_io_pendings[0];
    ctrl_io_irqFall_pending[1] = interruptCtrl_7_io_pendings[1];
    ctrl_io_irqFall_pending[2] = interruptCtrl_7_io_pendings[2];
    ctrl_io_irqFall_pending[3] = interruptCtrl_7_io_pendings[3];
    ctrl_io_irqFall_pending[4] = interruptCtrl_7_io_pendings[4];
    ctrl_io_irqFall_pending[5] = interruptCtrl_7_io_pendings[5];
    ctrl_io_irqFall_pending[6] = interruptCtrl_7_io_pendings[6];
    ctrl_io_irqFall_pending[7] = interruptCtrl_7_io_pendings[7];
    ctrl_io_irqFall_pending[8] = interruptCtrl_7_io_pendings[8];
    ctrl_io_irqFall_pending[9] = interruptCtrl_7_io_pendings[9];
    ctrl_io_irqFall_pending[10] = interruptCtrl_7_io_pendings[10];
    ctrl_io_irqFall_pending[11] = interruptCtrl_7_io_pendings[11];
  end

  assign _zz_io_bus_DAT_MISO_3 = 1'b1;
  assign _zz_io_bus_DAT_MISO_5 = 1'b1;
  assign _zz_io_bus_DAT_MISO_7 = 1'b1;
  assign _zz_io_bus_DAT_MISO_9 = 1'b1;
  assign _zz_io_bus_DAT_MISO_11 = 1'b1;
  assign _zz_io_bus_DAT_MISO_13 = 1'b1;
  assign _zz_io_bus_DAT_MISO_15 = 1'b1;
  assign _zz_io_bus_DAT_MISO_17 = 1'b1;
  assign _zz_io_bus_DAT_MISO_19 = 1'b1;
  assign _zz_io_bus_DAT_MISO_21 = 1'b1;
  assign _zz_io_bus_DAT_MISO_23 = 1'b1;
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      _zz_io_bus_ACK <= 1'b0;
      io_masks_driver <= 12'h0;
      io_masks_driver_1 <= 12'h0;
      io_masks_driver_2 <= 12'h0;
      io_masks_driver_3 <= 12'h0;
      _zz_io_bus_DAT_MISO <= 1'b0;
      _zz_io_bus_DAT_MISO_2 <= 1'b0;
      _zz_io_bus_DAT_MISO_4 <= 1'b0;
      _zz_io_bus_DAT_MISO_6 <= 1'b0;
      _zz_io_bus_DAT_MISO_8 <= 1'b0;
      _zz_io_bus_DAT_MISO_10 <= 1'b0;
      _zz_io_bus_DAT_MISO_12 <= 1'b0;
      _zz_io_bus_DAT_MISO_14 <= 1'b0;
      _zz_io_bus_DAT_MISO_16 <= 1'b0;
      _zz_io_bus_DAT_MISO_18 <= 1'b0;
      _zz_io_bus_DAT_MISO_20 <= 1'b0;
      _zz_io_bus_DAT_MISO_22 <= 1'b0;
    end else begin
      _zz_io_bus_ACK <= (io_bus_STB && io_bus_CYC);
      case(_zz_2)
        12'h01c : begin
          if(_zz_1) begin
            io_masks_driver <= io_bus_DAT_MOSI[11 : 0];
          end
        end
        12'h024 : begin
          if(_zz_1) begin
            io_masks_driver_1 <= io_bus_DAT_MOSI[11 : 0];
          end
        end
        12'h02c : begin
          if(_zz_1) begin
            io_masks_driver_2 <= io_bus_DAT_MOSI[11 : 0];
          end
        end
        12'h034 : begin
          if(_zz_1) begin
            io_masks_driver_3 <= io_bus_DAT_MOSI[11 : 0];
          end
        end
        12'h010 : begin
          if(_zz_1) begin
            _zz_io_bus_DAT_MISO <= io_bus_DAT_MOSI[0];
            _zz_io_bus_DAT_MISO_2 <= io_bus_DAT_MOSI[1];
            _zz_io_bus_DAT_MISO_4 <= io_bus_DAT_MOSI[2];
            _zz_io_bus_DAT_MISO_6 <= io_bus_DAT_MOSI[3];
            _zz_io_bus_DAT_MISO_8 <= io_bus_DAT_MOSI[4];
            _zz_io_bus_DAT_MISO_10 <= io_bus_DAT_MOSI[5];
            _zz_io_bus_DAT_MISO_12 <= io_bus_DAT_MOSI[6];
            _zz_io_bus_DAT_MISO_14 <= io_bus_DAT_MOSI[7];
            _zz_io_bus_DAT_MISO_16 <= io_bus_DAT_MOSI[8];
            _zz_io_bus_DAT_MISO_18 <= io_bus_DAT_MOSI[9];
            _zz_io_bus_DAT_MISO_20 <= io_bus_DAT_MOSI[10];
            _zz_io_bus_DAT_MISO_22 <= io_bus_DAT_MOSI[11];
          end
        end
        default : begin
        end
      endcase
    end
  end


endmodule

//InterruptCtrl_3 replaced by InterruptCtrl

//InterruptCtrl_2 replaced by InterruptCtrl

//InterruptCtrl_1 replaced by InterruptCtrl

module InterruptCtrl (
  input  wire [11:0]   io_inputs,
  input  wire [11:0]   io_clears,
  input  wire [11:0]   io_masks,
  output wire [11:0]   io_pendings,
  input  wire          clk,
  input  wire          resetn
);

  reg        [11:0]   pendings;

  assign io_pendings = (pendings & io_masks);
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      pendings <= 12'h0;
    end else begin
      pendings <= ((pendings & (~ io_clears)) | io_inputs);
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

  assign _zz_header_1 = Ids_Gpio;
  assign _zz_header = {12'd0, _zz_header_1};
  assign header = {{8'h0,8'h08},_zz_header};
  assign version = {{8'h01,8'h0},16'h0};
  assign io_header = header;
  assign io_version = version;

endmodule

module GpioCtrl (
  input  wire [11:0]   io_gpio_pins_read,
  output wire [11:0]   io_gpio_pins_write,
  output wire [11:0]   io_gpio_pins_writeEnable,
  input  wire [11:0]   io_config_write,
  input  wire [11:0]   io_config_direction,
  output wire [11:0]   io_value,
  output wire          io_interrupt,
  output wire [11:0]   io_irqHigh_valid,
  input  wire [11:0]   io_irqHigh_pending,
  output wire [11:0]   io_irqLow_valid,
  input  wire [11:0]   io_irqLow_pending,
  output wire [11:0]   io_irqRise_valid,
  input  wire [11:0]   io_irqRise_pending,
  output wire [11:0]   io_irqFall_valid,
  input  wire [11:0]   io_irqFall_pending,
  input  wire          clk,
  input  wire          resetn
);

  wire       [11:0]   io_gpio_pins_read_buffercc_io_dataOut;
  wire       [11:0]   synchronized;
  reg        [11:0]   last;

  (* keep_hierarchy = "TRUE" *) BufferCC io_gpio_pins_read_buffercc (
    .io_dataIn  (io_gpio_pins_read[11:0]                    ), //i
    .io_dataOut (io_gpio_pins_read_buffercc_io_dataOut[11:0]), //o
    .clk        (clk                                        ), //i
    .resetn     (resetn                                     )  //i
  );
  assign io_value = io_gpio_pins_read_buffercc_io_dataOut;
  assign synchronized = io_value;
  assign io_gpio_pins_write = io_config_write;
  assign io_gpio_pins_writeEnable = io_config_direction;
  assign io_irqHigh_valid = synchronized;
  assign io_irqLow_valid = (~ synchronized);
  assign io_irqRise_valid = (synchronized & (~ last));
  assign io_irqFall_valid = ((~ synchronized) & last);
  assign io_interrupt = (|(((io_irqHigh_pending | io_irqLow_pending) | io_irqRise_pending) | io_irqFall_pending));
  always @(posedge clk) begin
    last <= synchronized;
  end


endmodule

module BufferCC (
  input  wire [11:0]   io_dataIn,
  output wire [11:0]   io_dataOut,
  input  wire          clk,
  input  wire          resetn
);

  (* async_reg = "true" *) reg        [11:0]   buffers_0;
  (* async_reg = "true" *) reg        [11:0]   buffers_1;
  (* async_reg = "true" *) reg        [11:0]   buffers_2;

  assign io_dataOut = buffers_2;
  always @(posedge clk) begin
    buffers_0 <= io_dataIn;
    buffers_1 <= buffers_0;
    buffers_2 <= buffers_1;
  end


endmodule
