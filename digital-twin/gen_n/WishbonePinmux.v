// Generator : SpinalHDL v1.13.0    git head : d9d72474863badf47d8585d187f3e04ae4749c59
// Component : WishbonePinmux
// Git hash  : c46981392eb50d83a12c687a69933cc658cd2128

`timescale 1ns/1ps

module WishbonePinmux (
  input  wire          io_bus_CYC,
  input  wire          io_bus_STB,
  output wire          io_bus_ACK,
  input  wire          io_bus_WE,
  input  wire [9:0]    io_bus_ADR,
  output reg  [31:0]   io_bus_DAT_MISO,
  input  wire [31:0]   io_bus_DAT_MOSI,
  input  wire [19:0]   io_pins_pins_read,
  output wire [19:0]   io_pins_pins_write,
  output wire [19:0]   io_pins_pins_writeEnable,
  output wire [39:0]   io_inputs_read,
  input  wire [39:0]   io_inputs_write,
  input  wire [39:0]   io_inputs_writeEnable,
  input  wire          clk,
  input  wire          resetn
);

  wire       [19:0]   ctrl_io_pins_write;
  wire       [19:0]   ctrl_io_pins_writeEnable;
  wire       [39:0]   ctrl_io_inputs_read;
  wire       [11:0]   _zz_2;
  wire                _zz_1;
  reg                 _zz_io_bus_ACK;
  reg        [0:0]    _zz_io_bus_DAT_MISO;
  reg        [0:0]    _zz_io_bus_DAT_MISO_1;
  reg        [0:0]    _zz_io_bus_DAT_MISO_2;
  reg        [0:0]    _zz_io_bus_DAT_MISO_3;
  reg        [0:0]    _zz_io_bus_DAT_MISO_4;
  reg        [0:0]    _zz_io_bus_DAT_MISO_5;
  reg        [0:0]    _zz_io_bus_DAT_MISO_6;
  reg        [0:0]    _zz_io_bus_DAT_MISO_7;
  reg        [0:0]    _zz_io_bus_DAT_MISO_8;
  reg        [0:0]    _zz_io_bus_DAT_MISO_9;
  reg        [0:0]    _zz_io_bus_DAT_MISO_10;
  reg        [0:0]    _zz_io_bus_DAT_MISO_11;
  reg        [0:0]    _zz_io_bus_DAT_MISO_12;
  reg        [0:0]    _zz_io_bus_DAT_MISO_13;
  reg        [0:0]    _zz_io_bus_DAT_MISO_14;
  reg        [0:0]    _zz_io_bus_DAT_MISO_15;
  reg        [0:0]    _zz_io_bus_DAT_MISO_16;
  reg        [0:0]    _zz_io_bus_DAT_MISO_17;
  reg        [0:0]    _zz_io_bus_DAT_MISO_18;
  reg        [0:0]    _zz_io_bus_DAT_MISO_19;

  assign _zz_2 = ({2'd0,io_bus_ADR} <<< 2'd2);
  PinmuxCtrl ctrl (
    .io_pins_read          (io_pins_pins_read[19:0]       ), //i
    .io_pins_write         (ctrl_io_pins_write[19:0]      ), //o
    .io_pins_writeEnable   (ctrl_io_pins_writeEnable[19:0]), //o
    .io_inputs_read        (ctrl_io_inputs_read[39:0]     ), //o
    .io_inputs_write       (io_inputs_write[39:0]         ), //i
    .io_inputs_writeEnable (io_inputs_writeEnable[39:0]   ), //i
    .io_options_0          (_zz_io_bus_DAT_MISO           ), //i
    .io_options_1          (_zz_io_bus_DAT_MISO_1         ), //i
    .io_options_2          (_zz_io_bus_DAT_MISO_2         ), //i
    .io_options_3          (_zz_io_bus_DAT_MISO_3         ), //i
    .io_options_4          (_zz_io_bus_DAT_MISO_4         ), //i
    .io_options_5          (_zz_io_bus_DAT_MISO_5         ), //i
    .io_options_6          (_zz_io_bus_DAT_MISO_6         ), //i
    .io_options_7          (_zz_io_bus_DAT_MISO_7         ), //i
    .io_options_8          (_zz_io_bus_DAT_MISO_8         ), //i
    .io_options_9          (_zz_io_bus_DAT_MISO_9         ), //i
    .io_options_10         (_zz_io_bus_DAT_MISO_10        ), //i
    .io_options_11         (_zz_io_bus_DAT_MISO_11        ), //i
    .io_options_12         (_zz_io_bus_DAT_MISO_12        ), //i
    .io_options_13         (_zz_io_bus_DAT_MISO_13        ), //i
    .io_options_14         (_zz_io_bus_DAT_MISO_14        ), //i
    .io_options_15         (_zz_io_bus_DAT_MISO_15        ), //i
    .io_options_16         (_zz_io_bus_DAT_MISO_16        ), //i
    .io_options_17         (_zz_io_bus_DAT_MISO_17        ), //i
    .io_options_18         (_zz_io_bus_DAT_MISO_18        ), //i
    .io_options_19         (_zz_io_bus_DAT_MISO_19        )  //i
  );
  assign io_pins_pins_write = ctrl_io_pins_write;
  assign io_pins_pins_writeEnable = ctrl_io_pins_writeEnable;
  assign io_inputs_read = ctrl_io_inputs_read;
  always @(*) begin
    io_bus_DAT_MISO = 32'h0;
    case(_zz_2)
      12'h0 : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO;
      end
      12'h004 : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO_1;
      end
      12'h008 : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO_2;
      end
      12'h00c : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO_3;
      end
      12'h010 : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO_4;
      end
      12'h014 : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO_5;
      end
      12'h018 : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO_6;
      end
      12'h01c : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO_7;
      end
      12'h020 : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO_8;
      end
      12'h024 : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO_9;
      end
      12'h028 : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO_10;
      end
      12'h02c : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO_11;
      end
      12'h030 : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO_12;
      end
      12'h034 : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO_13;
      end
      12'h038 : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO_14;
      end
      12'h03c : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO_15;
      end
      12'h040 : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO_16;
      end
      12'h044 : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO_17;
      end
      12'h048 : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO_18;
      end
      12'h04c : begin
        io_bus_DAT_MISO[0 : 0] = _zz_io_bus_DAT_MISO_19;
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
      _zz_io_bus_DAT_MISO <= 1'b0;
      _zz_io_bus_DAT_MISO_1 <= 1'b0;
      _zz_io_bus_DAT_MISO_2 <= 1'b0;
      _zz_io_bus_DAT_MISO_3 <= 1'b0;
      _zz_io_bus_DAT_MISO_4 <= 1'b0;
      _zz_io_bus_DAT_MISO_5 <= 1'b0;
      _zz_io_bus_DAT_MISO_6 <= 1'b0;
      _zz_io_bus_DAT_MISO_7 <= 1'b0;
      _zz_io_bus_DAT_MISO_8 <= 1'b0;
      _zz_io_bus_DAT_MISO_9 <= 1'b0;
      _zz_io_bus_DAT_MISO_10 <= 1'b0;
      _zz_io_bus_DAT_MISO_11 <= 1'b0;
      _zz_io_bus_DAT_MISO_12 <= 1'b0;
      _zz_io_bus_DAT_MISO_13 <= 1'b0;
      _zz_io_bus_DAT_MISO_14 <= 1'b0;
      _zz_io_bus_DAT_MISO_15 <= 1'b0;
      _zz_io_bus_DAT_MISO_16 <= 1'b0;
      _zz_io_bus_DAT_MISO_17 <= 1'b0;
      _zz_io_bus_DAT_MISO_18 <= 1'b0;
      _zz_io_bus_DAT_MISO_19 <= 1'b0;
    end else begin
      _zz_io_bus_ACK <= (io_bus_STB && io_bus_CYC);
      case(_zz_2)
        12'h0 : begin
          if(_zz_1) begin
            _zz_io_bus_DAT_MISO <= io_bus_DAT_MOSI[0 : 0];
          end
        end
        12'h004 : begin
          if(_zz_1) begin
            _zz_io_bus_DAT_MISO_1 <= io_bus_DAT_MOSI[0 : 0];
          end
        end
        12'h008 : begin
          if(_zz_1) begin
            _zz_io_bus_DAT_MISO_2 <= io_bus_DAT_MOSI[0 : 0];
          end
        end
        12'h00c : begin
          if(_zz_1) begin
            _zz_io_bus_DAT_MISO_3 <= io_bus_DAT_MOSI[0 : 0];
          end
        end
        12'h010 : begin
          if(_zz_1) begin
            _zz_io_bus_DAT_MISO_4 <= io_bus_DAT_MOSI[0 : 0];
          end
        end
        12'h014 : begin
          if(_zz_1) begin
            _zz_io_bus_DAT_MISO_5 <= io_bus_DAT_MOSI[0 : 0];
          end
        end
        12'h018 : begin
          if(_zz_1) begin
            _zz_io_bus_DAT_MISO_6 <= io_bus_DAT_MOSI[0 : 0];
          end
        end
        12'h01c : begin
          if(_zz_1) begin
            _zz_io_bus_DAT_MISO_7 <= io_bus_DAT_MOSI[0 : 0];
          end
        end
        12'h020 : begin
          if(_zz_1) begin
            _zz_io_bus_DAT_MISO_8 <= io_bus_DAT_MOSI[0 : 0];
          end
        end
        12'h024 : begin
          if(_zz_1) begin
            _zz_io_bus_DAT_MISO_9 <= io_bus_DAT_MOSI[0 : 0];
          end
        end
        12'h028 : begin
          if(_zz_1) begin
            _zz_io_bus_DAT_MISO_10 <= io_bus_DAT_MOSI[0 : 0];
          end
        end
        12'h02c : begin
          if(_zz_1) begin
            _zz_io_bus_DAT_MISO_11 <= io_bus_DAT_MOSI[0 : 0];
          end
        end
        12'h030 : begin
          if(_zz_1) begin
            _zz_io_bus_DAT_MISO_12 <= io_bus_DAT_MOSI[0 : 0];
          end
        end
        12'h034 : begin
          if(_zz_1) begin
            _zz_io_bus_DAT_MISO_13 <= io_bus_DAT_MOSI[0 : 0];
          end
        end
        12'h038 : begin
          if(_zz_1) begin
            _zz_io_bus_DAT_MISO_14 <= io_bus_DAT_MOSI[0 : 0];
          end
        end
        12'h03c : begin
          if(_zz_1) begin
            _zz_io_bus_DAT_MISO_15 <= io_bus_DAT_MOSI[0 : 0];
          end
        end
        12'h040 : begin
          if(_zz_1) begin
            _zz_io_bus_DAT_MISO_16 <= io_bus_DAT_MOSI[0 : 0];
          end
        end
        12'h044 : begin
          if(_zz_1) begin
            _zz_io_bus_DAT_MISO_17 <= io_bus_DAT_MOSI[0 : 0];
          end
        end
        12'h048 : begin
          if(_zz_1) begin
            _zz_io_bus_DAT_MISO_18 <= io_bus_DAT_MOSI[0 : 0];
          end
        end
        12'h04c : begin
          if(_zz_1) begin
            _zz_io_bus_DAT_MISO_19 <= io_bus_DAT_MOSI[0 : 0];
          end
        end
        default : begin
        end
      endcase
    end
  end


endmodule

module PinmuxCtrl (
  input  wire [19:0]   io_pins_read,
  output reg  [19:0]   io_pins_write,
  output reg  [19:0]   io_pins_writeEnable,
  output reg  [39:0]   io_inputs_read,
  input  wire [39:0]   io_inputs_write,
  input  wire [39:0]   io_inputs_writeEnable,
  input  wire [0:0]    io_options_0,
  input  wire [0:0]    io_options_1,
  input  wire [0:0]    io_options_2,
  input  wire [0:0]    io_options_3,
  input  wire [0:0]    io_options_4,
  input  wire [0:0]    io_options_5,
  input  wire [0:0]    io_options_6,
  input  wire [0:0]    io_options_7,
  input  wire [0:0]    io_options_8,
  input  wire [0:0]    io_options_9,
  input  wire [0:0]    io_options_10,
  input  wire [0:0]    io_options_11,
  input  wire [0:0]    io_options_12,
  input  wire [0:0]    io_options_13,
  input  wire [0:0]    io_options_14,
  input  wire [0:0]    io_options_15,
  input  wire [0:0]    io_options_16,
  input  wire [0:0]    io_options_17,
  input  wire [0:0]    io_options_18,
  input  wire [0:0]    io_options_19
);

  reg                 _zz_io_pins_write;
  reg                 _zz_io_pins_writeEnable;
  wire                when_PinmuxCtrl_l44;
  wire                when_PinmuxCtrl_l44_1;
  reg                 _zz_io_pins_write_1;
  reg                 _zz_io_pins_writeEnable_1;
  wire                when_PinmuxCtrl_l44_2;
  wire                when_PinmuxCtrl_l44_3;
  reg                 _zz_io_pins_write_2;
  reg                 _zz_io_pins_writeEnable_2;
  wire                when_PinmuxCtrl_l44_4;
  wire                when_PinmuxCtrl_l44_5;
  reg                 _zz_io_pins_write_3;
  reg                 _zz_io_pins_writeEnable_3;
  wire                when_PinmuxCtrl_l44_6;
  wire                when_PinmuxCtrl_l44_7;
  reg                 _zz_io_pins_write_4;
  reg                 _zz_io_pins_writeEnable_4;
  wire                when_PinmuxCtrl_l44_8;
  wire                when_PinmuxCtrl_l44_9;
  reg                 _zz_io_pins_write_5;
  reg                 _zz_io_pins_writeEnable_5;
  wire                when_PinmuxCtrl_l44_10;
  wire                when_PinmuxCtrl_l44_11;
  reg                 _zz_io_pins_write_6;
  reg                 _zz_io_pins_writeEnable_6;
  wire                when_PinmuxCtrl_l44_12;
  wire                when_PinmuxCtrl_l44_13;
  reg                 _zz_io_pins_write_7;
  reg                 _zz_io_pins_writeEnable_7;
  wire                when_PinmuxCtrl_l44_14;
  wire                when_PinmuxCtrl_l44_15;
  reg                 _zz_io_pins_write_8;
  reg                 _zz_io_pins_writeEnable_8;
  wire                when_PinmuxCtrl_l44_16;
  wire                when_PinmuxCtrl_l44_17;
  reg                 _zz_io_pins_write_9;
  reg                 _zz_io_pins_writeEnable_9;
  wire                when_PinmuxCtrl_l44_18;
  wire                when_PinmuxCtrl_l44_19;
  reg                 _zz_io_pins_write_10;
  reg                 _zz_io_pins_writeEnable_10;
  wire                when_PinmuxCtrl_l44_20;
  wire                when_PinmuxCtrl_l44_21;
  reg                 _zz_io_pins_write_11;
  reg                 _zz_io_pins_writeEnable_11;
  wire                when_PinmuxCtrl_l44_22;
  wire                when_PinmuxCtrl_l44_23;
  reg                 _zz_io_pins_write_12;
  reg                 _zz_io_pins_writeEnable_12;
  wire                when_PinmuxCtrl_l44_24;
  wire                when_PinmuxCtrl_l44_25;
  reg                 _zz_io_pins_write_13;
  reg                 _zz_io_pins_writeEnable_13;
  wire                when_PinmuxCtrl_l44_26;
  wire                when_PinmuxCtrl_l44_27;
  reg                 _zz_io_pins_write_14;
  reg                 _zz_io_pins_writeEnable_14;
  wire                when_PinmuxCtrl_l44_28;
  wire                when_PinmuxCtrl_l44_29;
  reg                 _zz_io_pins_write_15;
  reg                 _zz_io_pins_writeEnable_15;
  wire                when_PinmuxCtrl_l44_30;
  wire                when_PinmuxCtrl_l44_31;
  reg                 _zz_io_pins_write_16;
  reg                 _zz_io_pins_writeEnable_16;
  wire                when_PinmuxCtrl_l44_32;
  wire                when_PinmuxCtrl_l44_33;
  reg                 _zz_io_pins_write_17;
  reg                 _zz_io_pins_writeEnable_17;
  wire                when_PinmuxCtrl_l44_34;
  wire                when_PinmuxCtrl_l44_35;
  reg                 _zz_io_pins_write_18;
  reg                 _zz_io_pins_writeEnable_18;
  wire                when_PinmuxCtrl_l44_36;
  wire                when_PinmuxCtrl_l44_37;
  reg                 _zz_io_pins_write_19;
  reg                 _zz_io_pins_writeEnable_19;
  wire                when_PinmuxCtrl_l44_38;
  wire                when_PinmuxCtrl_l44_39;

  always @(*) begin
    io_inputs_read[0] = 1'b0;
    io_inputs_read[1] = 1'b0;
    io_inputs_read[2] = 1'b0;
    io_inputs_read[3] = 1'b0;
    io_inputs_read[4] = 1'b0;
    io_inputs_read[5] = 1'b0;
    io_inputs_read[6] = 1'b0;
    io_inputs_read[7] = 1'b0;
    io_inputs_read[8] = 1'b0;
    io_inputs_read[9] = 1'b0;
    io_inputs_read[10] = 1'b0;
    io_inputs_read[11] = 1'b0;
    io_inputs_read[12] = 1'b0;
    io_inputs_read[13] = 1'b0;
    io_inputs_read[14] = 1'b0;
    io_inputs_read[15] = 1'b0;
    io_inputs_read[16] = 1'b0;
    io_inputs_read[17] = 1'b0;
    io_inputs_read[18] = 1'b0;
    io_inputs_read[19] = 1'b0;
    io_inputs_read[20] = 1'b0;
    io_inputs_read[21] = 1'b0;
    io_inputs_read[22] = 1'b0;
    io_inputs_read[23] = 1'b0;
    io_inputs_read[24] = 1'b0;
    io_inputs_read[25] = 1'b0;
    io_inputs_read[26] = 1'b0;
    io_inputs_read[27] = 1'b0;
    io_inputs_read[28] = 1'b0;
    io_inputs_read[29] = 1'b0;
    io_inputs_read[30] = 1'b0;
    io_inputs_read[31] = 1'b0;
    io_inputs_read[32] = 1'b0;
    io_inputs_read[33] = 1'b0;
    io_inputs_read[34] = 1'b0;
    io_inputs_read[35] = 1'b0;
    io_inputs_read[36] = 1'b0;
    io_inputs_read[37] = 1'b0;
    io_inputs_read[38] = 1'b0;
    io_inputs_read[39] = 1'b0;
    if(when_PinmuxCtrl_l44) begin
      io_inputs_read[0] = io_pins_read[0];
    end
    if(when_PinmuxCtrl_l44_1) begin
      io_inputs_read[1] = io_pins_read[0];
    end
    if(when_PinmuxCtrl_l44_2) begin
      io_inputs_read[2] = io_pins_read[1];
    end
    if(when_PinmuxCtrl_l44_3) begin
      io_inputs_read[3] = io_pins_read[1];
    end
    if(when_PinmuxCtrl_l44_4) begin
      io_inputs_read[4] = io_pins_read[2];
    end
    if(when_PinmuxCtrl_l44_5) begin
      io_inputs_read[5] = io_pins_read[2];
    end
    if(when_PinmuxCtrl_l44_6) begin
      io_inputs_read[6] = io_pins_read[3];
    end
    if(when_PinmuxCtrl_l44_7) begin
      io_inputs_read[7] = io_pins_read[3];
    end
    if(when_PinmuxCtrl_l44_8) begin
      io_inputs_read[8] = io_pins_read[4];
    end
    if(when_PinmuxCtrl_l44_9) begin
      io_inputs_read[9] = io_pins_read[4];
    end
    if(when_PinmuxCtrl_l44_10) begin
      io_inputs_read[10] = io_pins_read[5];
    end
    if(when_PinmuxCtrl_l44_11) begin
      io_inputs_read[11] = io_pins_read[5];
    end
    if(when_PinmuxCtrl_l44_12) begin
      io_inputs_read[12] = io_pins_read[6];
    end
    if(when_PinmuxCtrl_l44_13) begin
      io_inputs_read[13] = io_pins_read[6];
    end
    if(when_PinmuxCtrl_l44_14) begin
      io_inputs_read[14] = io_pins_read[7];
    end
    if(when_PinmuxCtrl_l44_15) begin
      io_inputs_read[15] = io_pins_read[7];
    end
    if(when_PinmuxCtrl_l44_16) begin
      io_inputs_read[16] = io_pins_read[8];
    end
    if(when_PinmuxCtrl_l44_17) begin
      io_inputs_read[17] = io_pins_read[8];
    end
    if(when_PinmuxCtrl_l44_18) begin
      io_inputs_read[18] = io_pins_read[9];
    end
    if(when_PinmuxCtrl_l44_19) begin
      io_inputs_read[19] = io_pins_read[9];
    end
    if(when_PinmuxCtrl_l44_20) begin
      io_inputs_read[20] = io_pins_read[10];
    end
    if(when_PinmuxCtrl_l44_21) begin
      io_inputs_read[21] = io_pins_read[10];
    end
    if(when_PinmuxCtrl_l44_22) begin
      io_inputs_read[22] = io_pins_read[11];
    end
    if(when_PinmuxCtrl_l44_23) begin
      io_inputs_read[23] = io_pins_read[11];
    end
    if(when_PinmuxCtrl_l44_24) begin
      io_inputs_read[24] = io_pins_read[12];
    end
    if(when_PinmuxCtrl_l44_25) begin
      io_inputs_read[25] = io_pins_read[12];
    end
    if(when_PinmuxCtrl_l44_26) begin
      io_inputs_read[26] = io_pins_read[13];
    end
    if(when_PinmuxCtrl_l44_27) begin
      io_inputs_read[27] = io_pins_read[13];
    end
    if(when_PinmuxCtrl_l44_28) begin
      io_inputs_read[28] = io_pins_read[14];
    end
    if(when_PinmuxCtrl_l44_29) begin
      io_inputs_read[29] = io_pins_read[14];
    end
    if(when_PinmuxCtrl_l44_30) begin
      io_inputs_read[30] = io_pins_read[15];
    end
    if(when_PinmuxCtrl_l44_31) begin
      io_inputs_read[31] = io_pins_read[15];
    end
    if(when_PinmuxCtrl_l44_32) begin
      io_inputs_read[32] = io_pins_read[16];
    end
    if(when_PinmuxCtrl_l44_33) begin
      io_inputs_read[33] = io_pins_read[16];
    end
    if(when_PinmuxCtrl_l44_34) begin
      io_inputs_read[34] = io_pins_read[17];
    end
    if(when_PinmuxCtrl_l44_35) begin
      io_inputs_read[35] = io_pins_read[17];
    end
    if(when_PinmuxCtrl_l44_36) begin
      io_inputs_read[36] = io_pins_read[18];
    end
    if(when_PinmuxCtrl_l44_37) begin
      io_inputs_read[37] = io_pins_read[18];
    end
    if(when_PinmuxCtrl_l44_38) begin
      io_inputs_read[38] = io_pins_read[19];
    end
    if(when_PinmuxCtrl_l44_39) begin
      io_inputs_read[39] = io_pins_read[19];
    end
  end

  always @(*) begin
    case(io_options_0)
      1'b0 : begin
        _zz_io_pins_write = io_inputs_write[0];
      end
      default : begin
        _zz_io_pins_write = io_inputs_write[1];
      end
    endcase
  end

  always @(*) begin
    case(io_options_0)
      1'b0 : begin
        _zz_io_pins_writeEnable = io_inputs_writeEnable[0];
      end
      default : begin
        _zz_io_pins_writeEnable = io_inputs_writeEnable[1];
      end
    endcase
  end

  always @(*) begin
    io_pins_write[0] = _zz_io_pins_write;
    io_pins_write[1] = _zz_io_pins_write_1;
    io_pins_write[2] = _zz_io_pins_write_2;
    io_pins_write[3] = _zz_io_pins_write_3;
    io_pins_write[4] = _zz_io_pins_write_4;
    io_pins_write[5] = _zz_io_pins_write_5;
    io_pins_write[6] = _zz_io_pins_write_6;
    io_pins_write[7] = _zz_io_pins_write_7;
    io_pins_write[8] = _zz_io_pins_write_8;
    io_pins_write[9] = _zz_io_pins_write_9;
    io_pins_write[10] = _zz_io_pins_write_10;
    io_pins_write[11] = _zz_io_pins_write_11;
    io_pins_write[12] = _zz_io_pins_write_12;
    io_pins_write[13] = _zz_io_pins_write_13;
    io_pins_write[14] = _zz_io_pins_write_14;
    io_pins_write[15] = _zz_io_pins_write_15;
    io_pins_write[16] = _zz_io_pins_write_16;
    io_pins_write[17] = _zz_io_pins_write_17;
    io_pins_write[18] = _zz_io_pins_write_18;
    io_pins_write[19] = _zz_io_pins_write_19;
  end

  always @(*) begin
    io_pins_writeEnable[0] = _zz_io_pins_writeEnable;
    io_pins_writeEnable[1] = _zz_io_pins_writeEnable_1;
    io_pins_writeEnable[2] = _zz_io_pins_writeEnable_2;
    io_pins_writeEnable[3] = _zz_io_pins_writeEnable_3;
    io_pins_writeEnable[4] = _zz_io_pins_writeEnable_4;
    io_pins_writeEnable[5] = _zz_io_pins_writeEnable_5;
    io_pins_writeEnable[6] = _zz_io_pins_writeEnable_6;
    io_pins_writeEnable[7] = _zz_io_pins_writeEnable_7;
    io_pins_writeEnable[8] = _zz_io_pins_writeEnable_8;
    io_pins_writeEnable[9] = _zz_io_pins_writeEnable_9;
    io_pins_writeEnable[10] = _zz_io_pins_writeEnable_10;
    io_pins_writeEnable[11] = _zz_io_pins_writeEnable_11;
    io_pins_writeEnable[12] = _zz_io_pins_writeEnable_12;
    io_pins_writeEnable[13] = _zz_io_pins_writeEnable_13;
    io_pins_writeEnable[14] = _zz_io_pins_writeEnable_14;
    io_pins_writeEnable[15] = _zz_io_pins_writeEnable_15;
    io_pins_writeEnable[16] = _zz_io_pins_writeEnable_16;
    io_pins_writeEnable[17] = _zz_io_pins_writeEnable_17;
    io_pins_writeEnable[18] = _zz_io_pins_writeEnable_18;
    io_pins_writeEnable[19] = _zz_io_pins_writeEnable_19;
  end

  assign when_PinmuxCtrl_l44 = (io_options_0 == 1'b0);
  assign when_PinmuxCtrl_l44_1 = (io_options_0 == 1'b1);
  always @(*) begin
    case(io_options_1)
      1'b0 : begin
        _zz_io_pins_write_1 = io_inputs_write[2];
      end
      default : begin
        _zz_io_pins_write_1 = io_inputs_write[3];
      end
    endcase
  end

  always @(*) begin
    case(io_options_1)
      1'b0 : begin
        _zz_io_pins_writeEnable_1 = io_inputs_writeEnable[2];
      end
      default : begin
        _zz_io_pins_writeEnable_1 = io_inputs_writeEnable[3];
      end
    endcase
  end

  assign when_PinmuxCtrl_l44_2 = (io_options_1 == 1'b0);
  assign when_PinmuxCtrl_l44_3 = (io_options_1 == 1'b1);
  always @(*) begin
    case(io_options_2)
      1'b0 : begin
        _zz_io_pins_write_2 = io_inputs_write[4];
      end
      default : begin
        _zz_io_pins_write_2 = io_inputs_write[5];
      end
    endcase
  end

  always @(*) begin
    case(io_options_2)
      1'b0 : begin
        _zz_io_pins_writeEnable_2 = io_inputs_writeEnable[4];
      end
      default : begin
        _zz_io_pins_writeEnable_2 = io_inputs_writeEnable[5];
      end
    endcase
  end

  assign when_PinmuxCtrl_l44_4 = (io_options_2 == 1'b0);
  assign when_PinmuxCtrl_l44_5 = (io_options_2 == 1'b1);
  always @(*) begin
    case(io_options_3)
      1'b0 : begin
        _zz_io_pins_write_3 = io_inputs_write[6];
      end
      default : begin
        _zz_io_pins_write_3 = io_inputs_write[7];
      end
    endcase
  end

  always @(*) begin
    case(io_options_3)
      1'b0 : begin
        _zz_io_pins_writeEnable_3 = io_inputs_writeEnable[6];
      end
      default : begin
        _zz_io_pins_writeEnable_3 = io_inputs_writeEnable[7];
      end
    endcase
  end

  assign when_PinmuxCtrl_l44_6 = (io_options_3 == 1'b0);
  assign when_PinmuxCtrl_l44_7 = (io_options_3 == 1'b1);
  always @(*) begin
    case(io_options_4)
      1'b0 : begin
        _zz_io_pins_write_4 = io_inputs_write[8];
      end
      default : begin
        _zz_io_pins_write_4 = io_inputs_write[9];
      end
    endcase
  end

  always @(*) begin
    case(io_options_4)
      1'b0 : begin
        _zz_io_pins_writeEnable_4 = io_inputs_writeEnable[8];
      end
      default : begin
        _zz_io_pins_writeEnable_4 = io_inputs_writeEnable[9];
      end
    endcase
  end

  assign when_PinmuxCtrl_l44_8 = (io_options_4 == 1'b0);
  assign when_PinmuxCtrl_l44_9 = (io_options_4 == 1'b1);
  always @(*) begin
    case(io_options_5)
      1'b0 : begin
        _zz_io_pins_write_5 = io_inputs_write[10];
      end
      default : begin
        _zz_io_pins_write_5 = io_inputs_write[11];
      end
    endcase
  end

  always @(*) begin
    case(io_options_5)
      1'b0 : begin
        _zz_io_pins_writeEnable_5 = io_inputs_writeEnable[10];
      end
      default : begin
        _zz_io_pins_writeEnable_5 = io_inputs_writeEnable[11];
      end
    endcase
  end

  assign when_PinmuxCtrl_l44_10 = (io_options_5 == 1'b0);
  assign when_PinmuxCtrl_l44_11 = (io_options_5 == 1'b1);
  always @(*) begin
    case(io_options_6)
      1'b0 : begin
        _zz_io_pins_write_6 = io_inputs_write[12];
      end
      default : begin
        _zz_io_pins_write_6 = io_inputs_write[13];
      end
    endcase
  end

  always @(*) begin
    case(io_options_6)
      1'b0 : begin
        _zz_io_pins_writeEnable_6 = io_inputs_writeEnable[12];
      end
      default : begin
        _zz_io_pins_writeEnable_6 = io_inputs_writeEnable[13];
      end
    endcase
  end

  assign when_PinmuxCtrl_l44_12 = (io_options_6 == 1'b0);
  assign when_PinmuxCtrl_l44_13 = (io_options_6 == 1'b1);
  always @(*) begin
    case(io_options_7)
      1'b0 : begin
        _zz_io_pins_write_7 = io_inputs_write[14];
      end
      default : begin
        _zz_io_pins_write_7 = io_inputs_write[15];
      end
    endcase
  end

  always @(*) begin
    case(io_options_7)
      1'b0 : begin
        _zz_io_pins_writeEnable_7 = io_inputs_writeEnable[14];
      end
      default : begin
        _zz_io_pins_writeEnable_7 = io_inputs_writeEnable[15];
      end
    endcase
  end

  assign when_PinmuxCtrl_l44_14 = (io_options_7 == 1'b0);
  assign when_PinmuxCtrl_l44_15 = (io_options_7 == 1'b1);
  always @(*) begin
    case(io_options_8)
      1'b0 : begin
        _zz_io_pins_write_8 = io_inputs_write[16];
      end
      default : begin
        _zz_io_pins_write_8 = io_inputs_write[17];
      end
    endcase
  end

  always @(*) begin
    case(io_options_8)
      1'b0 : begin
        _zz_io_pins_writeEnable_8 = io_inputs_writeEnable[16];
      end
      default : begin
        _zz_io_pins_writeEnable_8 = io_inputs_writeEnable[17];
      end
    endcase
  end

  assign when_PinmuxCtrl_l44_16 = (io_options_8 == 1'b0);
  assign when_PinmuxCtrl_l44_17 = (io_options_8 == 1'b1);
  always @(*) begin
    case(io_options_9)
      1'b0 : begin
        _zz_io_pins_write_9 = io_inputs_write[18];
      end
      default : begin
        _zz_io_pins_write_9 = io_inputs_write[19];
      end
    endcase
  end

  always @(*) begin
    case(io_options_9)
      1'b0 : begin
        _zz_io_pins_writeEnable_9 = io_inputs_writeEnable[18];
      end
      default : begin
        _zz_io_pins_writeEnable_9 = io_inputs_writeEnable[19];
      end
    endcase
  end

  assign when_PinmuxCtrl_l44_18 = (io_options_9 == 1'b0);
  assign when_PinmuxCtrl_l44_19 = (io_options_9 == 1'b1);
  always @(*) begin
    case(io_options_10)
      1'b0 : begin
        _zz_io_pins_write_10 = io_inputs_write[20];
      end
      default : begin
        _zz_io_pins_write_10 = io_inputs_write[21];
      end
    endcase
  end

  always @(*) begin
    case(io_options_10)
      1'b0 : begin
        _zz_io_pins_writeEnable_10 = io_inputs_writeEnable[20];
      end
      default : begin
        _zz_io_pins_writeEnable_10 = io_inputs_writeEnable[21];
      end
    endcase
  end

  assign when_PinmuxCtrl_l44_20 = (io_options_10 == 1'b0);
  assign when_PinmuxCtrl_l44_21 = (io_options_10 == 1'b1);
  always @(*) begin
    case(io_options_11)
      1'b0 : begin
        _zz_io_pins_write_11 = io_inputs_write[22];
      end
      default : begin
        _zz_io_pins_write_11 = io_inputs_write[23];
      end
    endcase
  end

  always @(*) begin
    case(io_options_11)
      1'b0 : begin
        _zz_io_pins_writeEnable_11 = io_inputs_writeEnable[22];
      end
      default : begin
        _zz_io_pins_writeEnable_11 = io_inputs_writeEnable[23];
      end
    endcase
  end

  assign when_PinmuxCtrl_l44_22 = (io_options_11 == 1'b0);
  assign when_PinmuxCtrl_l44_23 = (io_options_11 == 1'b1);
  always @(*) begin
    case(io_options_12)
      1'b0 : begin
        _zz_io_pins_write_12 = io_inputs_write[24];
      end
      default : begin
        _zz_io_pins_write_12 = io_inputs_write[25];
      end
    endcase
  end

  always @(*) begin
    case(io_options_12)
      1'b0 : begin
        _zz_io_pins_writeEnable_12 = io_inputs_writeEnable[24];
      end
      default : begin
        _zz_io_pins_writeEnable_12 = io_inputs_writeEnable[25];
      end
    endcase
  end

  assign when_PinmuxCtrl_l44_24 = (io_options_12 == 1'b0);
  assign when_PinmuxCtrl_l44_25 = (io_options_12 == 1'b1);
  always @(*) begin
    case(io_options_13)
      1'b0 : begin
        _zz_io_pins_write_13 = io_inputs_write[26];
      end
      default : begin
        _zz_io_pins_write_13 = io_inputs_write[27];
      end
    endcase
  end

  always @(*) begin
    case(io_options_13)
      1'b0 : begin
        _zz_io_pins_writeEnable_13 = io_inputs_writeEnable[26];
      end
      default : begin
        _zz_io_pins_writeEnable_13 = io_inputs_writeEnable[27];
      end
    endcase
  end

  assign when_PinmuxCtrl_l44_26 = (io_options_13 == 1'b0);
  assign when_PinmuxCtrl_l44_27 = (io_options_13 == 1'b1);
  always @(*) begin
    case(io_options_14)
      1'b0 : begin
        _zz_io_pins_write_14 = io_inputs_write[28];
      end
      default : begin
        _zz_io_pins_write_14 = io_inputs_write[29];
      end
    endcase
  end

  always @(*) begin
    case(io_options_14)
      1'b0 : begin
        _zz_io_pins_writeEnable_14 = io_inputs_writeEnable[28];
      end
      default : begin
        _zz_io_pins_writeEnable_14 = io_inputs_writeEnable[29];
      end
    endcase
  end

  assign when_PinmuxCtrl_l44_28 = (io_options_14 == 1'b0);
  assign when_PinmuxCtrl_l44_29 = (io_options_14 == 1'b1);
  always @(*) begin
    case(io_options_15)
      1'b0 : begin
        _zz_io_pins_write_15 = io_inputs_write[30];
      end
      default : begin
        _zz_io_pins_write_15 = io_inputs_write[31];
      end
    endcase
  end

  always @(*) begin
    case(io_options_15)
      1'b0 : begin
        _zz_io_pins_writeEnable_15 = io_inputs_writeEnable[30];
      end
      default : begin
        _zz_io_pins_writeEnable_15 = io_inputs_writeEnable[31];
      end
    endcase
  end

  assign when_PinmuxCtrl_l44_30 = (io_options_15 == 1'b0);
  assign when_PinmuxCtrl_l44_31 = (io_options_15 == 1'b1);
  always @(*) begin
    case(io_options_16)
      1'b0 : begin
        _zz_io_pins_write_16 = io_inputs_write[32];
      end
      default : begin
        _zz_io_pins_write_16 = io_inputs_write[33];
      end
    endcase
  end

  always @(*) begin
    case(io_options_16)
      1'b0 : begin
        _zz_io_pins_writeEnable_16 = io_inputs_writeEnable[32];
      end
      default : begin
        _zz_io_pins_writeEnable_16 = io_inputs_writeEnable[33];
      end
    endcase
  end

  assign when_PinmuxCtrl_l44_32 = (io_options_16 == 1'b0);
  assign when_PinmuxCtrl_l44_33 = (io_options_16 == 1'b1);
  always @(*) begin
    case(io_options_17)
      1'b0 : begin
        _zz_io_pins_write_17 = io_inputs_write[34];
      end
      default : begin
        _zz_io_pins_write_17 = io_inputs_write[35];
      end
    endcase
  end

  always @(*) begin
    case(io_options_17)
      1'b0 : begin
        _zz_io_pins_writeEnable_17 = io_inputs_writeEnable[34];
      end
      default : begin
        _zz_io_pins_writeEnable_17 = io_inputs_writeEnable[35];
      end
    endcase
  end

  assign when_PinmuxCtrl_l44_34 = (io_options_17 == 1'b0);
  assign when_PinmuxCtrl_l44_35 = (io_options_17 == 1'b1);
  always @(*) begin
    case(io_options_18)
      1'b0 : begin
        _zz_io_pins_write_18 = io_inputs_write[36];
      end
      default : begin
        _zz_io_pins_write_18 = io_inputs_write[37];
      end
    endcase
  end

  always @(*) begin
    case(io_options_18)
      1'b0 : begin
        _zz_io_pins_writeEnable_18 = io_inputs_writeEnable[36];
      end
      default : begin
        _zz_io_pins_writeEnable_18 = io_inputs_writeEnable[37];
      end
    endcase
  end

  assign when_PinmuxCtrl_l44_36 = (io_options_18 == 1'b0);
  assign when_PinmuxCtrl_l44_37 = (io_options_18 == 1'b1);
  always @(*) begin
    case(io_options_19)
      1'b0 : begin
        _zz_io_pins_write_19 = io_inputs_write[38];
      end
      default : begin
        _zz_io_pins_write_19 = io_inputs_write[39];
      end
    endcase
  end

  always @(*) begin
    case(io_options_19)
      1'b0 : begin
        _zz_io_pins_writeEnable_19 = io_inputs_writeEnable[38];
      end
      default : begin
        _zz_io_pins_writeEnable_19 = io_inputs_writeEnable[39];
      end
    endcase
  end

  assign when_PinmuxCtrl_l44_38 = (io_options_19 == 1'b0);
  assign when_PinmuxCtrl_l44_39 = (io_options_19 == 1'b1);

endmodule
