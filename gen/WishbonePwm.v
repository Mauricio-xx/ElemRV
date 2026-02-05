// Generator : SpinalHDL v1.13.0    git head : d9d72474863badf47d8585d187f3e04ae4749c59
// Component : WishbonePwm

`timescale 1ns/1ps

module WishbonePwm (
  input  wire          io_bus_CYC,
  input  wire          io_bus_STB,
  output wire          io_bus_ACK,
  input  wire          io_bus_WE,
  input  wire [9:0]    io_bus_ADR,
  output reg  [31:0]   io_bus_DAT_MISO,
  input  wire [31:0]   io_bus_DAT_MOSI,
  output wire [1:0]    io_pwm_output,
  input  wire          clk,
  input  wire          resetn
);

  wire       [1:0]    ctrl_io_pwm_output;
  wire       [31:0]   mapper_idCtrl_io_header;
  wire       [31:0]   mapper_idCtrl_io_version;
  wire       [11:0]   _zz_2;
  wire                _zz_1;
  reg                 _zz_io_bus_ACK;
  reg        [19:0]   mapper_config_cfg_clockDivider;
  reg                 mapper_channelCfg_0_enable;
  reg                 mapper_channelCfg_0_invert;
  reg        [19:0]   mapper_channelCfg_0_period;
  reg        [19:0]   mapper_channelCfg_0_pulse;
  reg                 mapper_channelCfg_1_enable;
  reg                 mapper_channelCfg_1_invert;
  reg        [19:0]   mapper_channelCfg_1_period;
  reg        [19:0]   mapper_channelCfg_1_pulse;

  assign _zz_2 = ({2'd0,io_bus_ADR} <<< 2'd2);
  PwmCtrl ctrl (
    .io_pwm_output          (ctrl_io_pwm_output[1:0]             ), //o
    .io_config_clockDivider (mapper_config_cfg_clockDivider[19:0]), //i
    .io_channels_0_enable   (mapper_channelCfg_0_enable          ), //i
    .io_channels_0_invert   (mapper_channelCfg_0_invert          ), //i
    .io_channels_0_period   (mapper_channelCfg_0_period[19:0]    ), //i
    .io_channels_0_pulse    (mapper_channelCfg_0_pulse[19:0]     ), //i
    .io_channels_1_enable   (mapper_channelCfg_1_enable          ), //i
    .io_channels_1_invert   (mapper_channelCfg_1_invert          ), //i
    .io_channels_1_period   (mapper_channelCfg_1_period[19:0]    ), //i
    .io_channels_1_pulse    (mapper_channelCfg_1_pulse[19:0]     ), //i
    .clk                    (clk                                 ), //i
    .resetn                 (resetn                              )  //i
  );
  IpIdentificationCtrl mapper_idCtrl (
    .io_header  (mapper_idCtrl_io_header[31:0] ), //o
    .io_version (mapper_idCtrl_io_version[31:0]), //o
    .clk        (clk                           ), //i
    .resetn     (resetn                        )  //i
  );
  assign io_pwm_output = ctrl_io_pwm_output;
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
        io_bus_DAT_MISO[31 : 0] = {{{8'h14,8'h14},8'h14},8'h02};
      end
      12'h00c : begin
        io_bus_DAT_MISO[31 : 0] = {31'h0,1'b1};
      end
      12'h010 : begin
        io_bus_DAT_MISO[19 : 0] = mapper_config_cfg_clockDivider;
      end
      12'h014 : begin
        io_bus_DAT_MISO[0 : 0] = mapper_channelCfg_0_enable;
        io_bus_DAT_MISO[1 : 1] = mapper_channelCfg_0_invert;
      end
      12'h018 : begin
        io_bus_DAT_MISO[19 : 0] = mapper_channelCfg_0_period;
      end
      12'h01c : begin
        io_bus_DAT_MISO[19 : 0] = mapper_channelCfg_0_pulse;
      end
      12'h020 : begin
        io_bus_DAT_MISO[0 : 0] = mapper_channelCfg_1_enable;
        io_bus_DAT_MISO[1 : 1] = mapper_channelCfg_1_invert;
      end
      12'h024 : begin
        io_bus_DAT_MISO[19 : 0] = mapper_channelCfg_1_period;
      end
      12'h028 : begin
        io_bus_DAT_MISO[19 : 0] = mapper_channelCfg_1_pulse;
      end
      default : begin
      end
    endcase
  end

  assign _zz_1 = (((io_bus_CYC && io_bus_STB) && ((io_bus_CYC && io_bus_ACK) && io_bus_STB)) && io_bus_WE);
  assign io_bus_ACK = (_zz_io_bus_ACK && io_bus_STB);
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      _zz_io_bus_ACK <= 1'b0;
      mapper_config_cfg_clockDivider <= 20'h0;
      mapper_channelCfg_0_enable <= 1'b0;
      mapper_channelCfg_0_invert <= 1'b0;
      mapper_channelCfg_0_period <= 20'h0;
      mapper_channelCfg_0_pulse <= 20'h0;
      mapper_channelCfg_1_enable <= 1'b0;
      mapper_channelCfg_1_invert <= 1'b0;
      mapper_channelCfg_1_period <= 20'h0;
      mapper_channelCfg_1_pulse <= 20'h0;
    end else begin
      _zz_io_bus_ACK <= (io_bus_STB && io_bus_CYC);
      case(_zz_2)
        12'h010 : begin
          if(_zz_1) begin
            mapper_config_cfg_clockDivider <= io_bus_DAT_MOSI[19 : 0];
          end
        end
        12'h014 : begin
          if(_zz_1) begin
            mapper_channelCfg_0_enable <= io_bus_DAT_MOSI[0];
            mapper_channelCfg_0_invert <= io_bus_DAT_MOSI[1];
          end
        end
        12'h018 : begin
          if(_zz_1) begin
            mapper_channelCfg_0_period <= io_bus_DAT_MOSI[19 : 0];
          end
        end
        12'h01c : begin
          if(_zz_1) begin
            mapper_channelCfg_0_pulse <= io_bus_DAT_MOSI[19 : 0];
          end
        end
        12'h020 : begin
          if(_zz_1) begin
            mapper_channelCfg_1_enable <= io_bus_DAT_MOSI[0];
            mapper_channelCfg_1_invert <= io_bus_DAT_MOSI[1];
          end
        end
        12'h024 : begin
          if(_zz_1) begin
            mapper_channelCfg_1_period <= io_bus_DAT_MOSI[19 : 0];
          end
        end
        12'h028 : begin
          if(_zz_1) begin
            mapper_channelCfg_1_pulse <= io_bus_DAT_MOSI[19 : 0];
          end
        end
        default : begin
        end
      endcase
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

  assign _zz_header_1 = Ids_Pwm;
  assign _zz_header = {12'd0, _zz_header_1};
  assign header = {{8'h0,8'h08},_zz_header};
  assign version = {{8'h01,8'h0},16'h0};
  assign io_header = header;
  assign io_version = version;

endmodule

module PwmCtrl (
  output reg  [1:0]    io_pwm_output,
  input  wire [19:0]   io_config_clockDivider,
  input  wire          io_channels_0_enable,
  input  wire          io_channels_0_invert,
  input  wire [19:0]   io_channels_0_period,
  input  wire [19:0]   io_channels_0_pulse,
  input  wire          io_channels_1_enable,
  input  wire          io_channels_1_invert,
  input  wire [19:0]   io_channels_1_period,
  input  wire [19:0]   io_channels_1_pulse,
  input  wire          clk,
  input  wire          resetn
);

  wire                clockDivider_1_io_tick;
  reg        [19:0]   _zz_when_PwmCtrl_l71;
  reg        [19:0]   _zz_when_PwmCtrl_l77;
  wire                when_PwmCtrl_l71;
  wire                when_PwmCtrl_l77;
  wire                when_PwmCtrl_l81;
  reg        [19:0]   _zz_when_PwmCtrl_l71_1;
  reg        [19:0]   _zz_when_PwmCtrl_l77_1;
  wire                when_PwmCtrl_l71_1;
  wire                when_PwmCtrl_l77_1;
  wire                when_PwmCtrl_l81_1;

  ClockDivider clockDivider_1 (
    .io_value  (io_config_clockDivider[19:0]), //i
    .io_reload (1'b0                        ), //i
    .io_tick   (clockDivider_1_io_tick      ), //o
    .clk       (clk                         ), //i
    .resetn    (resetn                      )  //i
  );
  always @(*) begin
    io_pwm_output[0] = io_channels_0_invert;
    if(io_channels_0_enable) begin
      if(when_PwmCtrl_l81) begin
        io_pwm_output[0] = (! io_channels_0_invert);
      end
    end
    io_pwm_output[1] = io_channels_1_invert;
    if(io_channels_1_enable) begin
      if(when_PwmCtrl_l81_1) begin
        io_pwm_output[1] = (! io_channels_1_invert);
      end
    end
  end

  assign when_PwmCtrl_l71 = (_zz_when_PwmCtrl_l71 == 20'h0);
  assign when_PwmCtrl_l77 = (_zz_when_PwmCtrl_l77 != 20'h0);
  assign when_PwmCtrl_l81 = (_zz_when_PwmCtrl_l77 != 20'h0);
  assign when_PwmCtrl_l71_1 = (_zz_when_PwmCtrl_l71_1 == 20'h0);
  assign when_PwmCtrl_l77_1 = (_zz_when_PwmCtrl_l77_1 != 20'h0);
  assign when_PwmCtrl_l81_1 = (_zz_when_PwmCtrl_l77_1 != 20'h0);
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      _zz_when_PwmCtrl_l71 <= 20'h0;
      _zz_when_PwmCtrl_l77 <= 20'h0;
      _zz_when_PwmCtrl_l71_1 <= 20'h0;
      _zz_when_PwmCtrl_l77_1 <= 20'h0;
    end else begin
      if(io_channels_0_enable) begin
        if(when_PwmCtrl_l71) begin
          _zz_when_PwmCtrl_l71 <= io_channels_0_period;
          _zz_when_PwmCtrl_l77 <= io_channels_0_pulse;
        end
        if(clockDivider_1_io_tick) begin
          _zz_when_PwmCtrl_l71 <= (_zz_when_PwmCtrl_l71 - 20'h00001);
          if(when_PwmCtrl_l77) begin
            _zz_when_PwmCtrl_l77 <= (_zz_when_PwmCtrl_l77 - 20'h00001);
          end
        end
      end else begin
        _zz_when_PwmCtrl_l71 <= io_channels_0_period;
        _zz_when_PwmCtrl_l77 <= io_channels_0_pulse;
      end
      if(io_channels_1_enable) begin
        if(when_PwmCtrl_l71_1) begin
          _zz_when_PwmCtrl_l71_1 <= io_channels_1_period;
          _zz_when_PwmCtrl_l77_1 <= io_channels_1_pulse;
        end
        if(clockDivider_1_io_tick) begin
          _zz_when_PwmCtrl_l71_1 <= (_zz_when_PwmCtrl_l71_1 - 20'h00001);
          if(when_PwmCtrl_l77_1) begin
            _zz_when_PwmCtrl_l77_1 <= (_zz_when_PwmCtrl_l77_1 - 20'h00001);
          end
        end
      end else begin
        _zz_when_PwmCtrl_l71_1 <= io_channels_1_period;
        _zz_when_PwmCtrl_l77_1 <= io_channels_1_pulse;
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
