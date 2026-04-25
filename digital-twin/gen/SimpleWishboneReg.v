// Generator : SpinalHDL v1.13.0    git head : d9d72474863badf47d8585d187f3e04ae4749c59
// Component : SimpleWishboneReg
// Git hash  : 58d827afb766b3e54c8e02d57b05f468cf844e91

`timescale 1ns/1ps

module SimpleWishboneReg (
  input  wire          io_bus_CYC,
  input  wire          io_bus_STB,
  output reg           io_bus_ACK,
  input  wire          io_bus_WE,
  input  wire [31:0]   io_bus_ADR,
  output reg  [31:0]   io_bus_DAT_MISO,
  input  wire [31:0]   io_bus_DAT_MOSI,
  output wire [7:0]    io_led,
  input  wire          clk,
  input  wire          resetn
);

  reg        [31:0]   _zz_io_bus_DAT_MISO;
  reg        [31:0]   regs_0;
  reg        [31:0]   regs_1;
  reg        [31:0]   regs_2;
  reg        [31:0]   regs_3;
  reg        [31:0]   regs_4;
  reg        [31:0]   regs_5;
  reg        [31:0]   regs_6;
  reg        [31:0]   regs_7;
  reg        [31:0]   regs_8;
  reg        [31:0]   regs_9;
  reg        [31:0]   regs_10;
  reg        [31:0]   regs_11;
  reg        [31:0]   regs_12;
  reg        [31:0]   regs_13;
  reg        [31:0]   regs_14;
  reg        [31:0]   regs_15;
  wire       [3:0]    regIndex;
  wire                when_SimpleWishboneReg_l34;
  wire       [15:0]   _zz_1;
  wire       [31:0]   _zz_regs_0;

  always @(*) begin
    case(regIndex)
      4'b0000 : _zz_io_bus_DAT_MISO = regs_0;
      4'b0001 : _zz_io_bus_DAT_MISO = regs_1;
      4'b0010 : _zz_io_bus_DAT_MISO = regs_2;
      4'b0011 : _zz_io_bus_DAT_MISO = regs_3;
      4'b0100 : _zz_io_bus_DAT_MISO = regs_4;
      4'b0101 : _zz_io_bus_DAT_MISO = regs_5;
      4'b0110 : _zz_io_bus_DAT_MISO = regs_6;
      4'b0111 : _zz_io_bus_DAT_MISO = regs_7;
      4'b1000 : _zz_io_bus_DAT_MISO = regs_8;
      4'b1001 : _zz_io_bus_DAT_MISO = regs_9;
      4'b1010 : _zz_io_bus_DAT_MISO = regs_10;
      4'b1011 : _zz_io_bus_DAT_MISO = regs_11;
      4'b1100 : _zz_io_bus_DAT_MISO = regs_12;
      4'b1101 : _zz_io_bus_DAT_MISO = regs_13;
      4'b1110 : _zz_io_bus_DAT_MISO = regs_14;
      default : _zz_io_bus_DAT_MISO = regs_15;
    endcase
  end

  assign regIndex = io_bus_ADR[3 : 0];
  always @(*) begin
    io_bus_ACK = 1'b0;
    if(when_SimpleWishboneReg_l34) begin
      io_bus_ACK = 1'b1;
    end
  end

  always @(*) begin
    io_bus_DAT_MISO = 32'h0;
    if(when_SimpleWishboneReg_l34) begin
      if(!io_bus_WE) begin
        io_bus_DAT_MISO = _zz_io_bus_DAT_MISO;
      end
    end
  end

  assign when_SimpleWishboneReg_l34 = (io_bus_CYC && io_bus_STB);
  assign _zz_1 = ({15'd0,1'b1} <<< regIndex);
  assign _zz_regs_0 = io_bus_DAT_MOSI;
  assign io_led = regs_0[7 : 0];
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      regs_0 <= 32'h0;
      regs_1 <= 32'h0;
      regs_2 <= 32'h0;
      regs_3 <= 32'h0;
      regs_4 <= 32'h0;
      regs_5 <= 32'h0;
      regs_6 <= 32'h0;
      regs_7 <= 32'h0;
      regs_8 <= 32'h0;
      regs_9 <= 32'h0;
      regs_10 <= 32'h0;
      regs_11 <= 32'h0;
      regs_12 <= 32'h0;
      regs_13 <= 32'h0;
      regs_14 <= 32'h0;
      regs_15 <= 32'h0;
    end else begin
      if(when_SimpleWishboneReg_l34) begin
        if(io_bus_WE) begin
          if(_zz_1[0]) begin
            regs_0 <= _zz_regs_0;
          end
          if(_zz_1[1]) begin
            regs_1 <= _zz_regs_0;
          end
          if(_zz_1[2]) begin
            regs_2 <= _zz_regs_0;
          end
          if(_zz_1[3]) begin
            regs_3 <= _zz_regs_0;
          end
          if(_zz_1[4]) begin
            regs_4 <= _zz_regs_0;
          end
          if(_zz_1[5]) begin
            regs_5 <= _zz_regs_0;
          end
          if(_zz_1[6]) begin
            regs_6 <= _zz_regs_0;
          end
          if(_zz_1[7]) begin
            regs_7 <= _zz_regs_0;
          end
          if(_zz_1[8]) begin
            regs_8 <= _zz_regs_0;
          end
          if(_zz_1[9]) begin
            regs_9 <= _zz_regs_0;
          end
          if(_zz_1[10]) begin
            regs_10 <= _zz_regs_0;
          end
          if(_zz_1[11]) begin
            regs_11 <= _zz_regs_0;
          end
          if(_zz_1[12]) begin
            regs_12 <= _zz_regs_0;
          end
          if(_zz_1[13]) begin
            regs_13 <= _zz_regs_0;
          end
          if(_zz_1[14]) begin
            regs_14 <= _zz_regs_0;
          end
          if(_zz_1[15]) begin
            regs_15 <= _zz_regs_0;
          end
        end
      end
    end
  end


endmodule
