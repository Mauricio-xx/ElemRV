// Generator : SpinalHDL v1.13.0    git head : d9d72474863badf47d8585d187f3e04ae4749c59
// Component : WishboneMachineTimer

`timescale 1ns/1ps

module WishboneMachineTimer (
  input  wire          io_bus_CYC,
  input  wire          io_bus_STB,
  output wire          io_bus_ACK,
  input  wire          io_bus_WE,
  input  wire [9:0]    io_bus_ADR,
  output reg  [31:0]   io_bus_DAT_MISO,
  input  wire [31:0]   io_bus_DAT_MOSI,
  output wire          io_interrupt,
  input  wire          clk,
  input  wire          resetn
);

  wire                ctrl_io_clear;
  wire       [63:0]   ctrl_io_counter;
  wire                ctrl_io_interrupt;
  wire                _zz_1;
  reg                 _zz_io_bus_ACK;
  wire       [11:0]   _zz_when_WishboneSlaveFactory_l76;
  reg        [63:0]   mapper_cfg_compare;
  wire       [63:0]   _zz_io_bus_DAT_MISO;
  reg                 _zz_io_clear;
  reg                 _zz_io_clear_1;
  wire                when_WishboneSlaveFactory_l76;
  wire                when_WishboneSlaveFactory_l76_1;
  wire                when_WishboneSlaveFactory_l76_2;
  wire                when_WishboneSlaveFactory_l76_3;

  MachineTimerCtrl ctrl (
    .io_config_compare (mapper_cfg_compare[63:0]), //i
    .io_counter        (ctrl_io_counter[63:0]   ), //o
    .io_clear          (ctrl_io_clear           ), //i
    .io_interrupt      (ctrl_io_interrupt       ), //o
    .clk               (clk                     ), //i
    .resetn            (resetn                  )  //i
  );
  assign io_interrupt = ctrl_io_interrupt;
  always @(*) begin
    io_bus_DAT_MISO = 32'h0;
    if(when_WishboneSlaveFactory_l76) begin
      io_bus_DAT_MISO[31 : 0] = _zz_io_bus_DAT_MISO[31 : 0];
    end
    if(when_WishboneSlaveFactory_l76_1) begin
      io_bus_DAT_MISO[31 : 0] = _zz_io_bus_DAT_MISO[63 : 32];
    end
  end

  assign _zz_1 = (((io_bus_CYC && io_bus_STB) && ((io_bus_CYC && io_bus_ACK) && io_bus_STB)) && io_bus_WE);
  assign io_bus_ACK = (_zz_io_bus_ACK && io_bus_STB);
  assign _zz_when_WishboneSlaveFactory_l76 = ({2'd0,io_bus_ADR} <<< 2'd2);
  assign _zz_io_bus_DAT_MISO = ctrl_io_counter;
  always @(*) begin
    _zz_io_clear = 1'b0;
    case(_zz_when_WishboneSlaveFactory_l76)
      12'h008 : begin
        if(_zz_1) begin
          _zz_io_clear = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    _zz_io_clear_1 = 1'b0;
    case(_zz_when_WishboneSlaveFactory_l76)
      12'h00c : begin
        if(_zz_1) begin
          _zz_io_clear_1 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign ctrl_io_clear = (_zz_io_clear || _zz_io_clear_1);
  assign when_WishboneSlaveFactory_l76 = ((_zz_when_WishboneSlaveFactory_l76 & (~ 12'h003)) == 12'h0);
  assign when_WishboneSlaveFactory_l76_1 = ((_zz_when_WishboneSlaveFactory_l76 & (~ 12'h003)) == 12'h004);
  assign when_WishboneSlaveFactory_l76_2 = ((_zz_when_WishboneSlaveFactory_l76 & (~ 12'h003)) == 12'h008);
  assign when_WishboneSlaveFactory_l76_3 = ((_zz_when_WishboneSlaveFactory_l76 & (~ 12'h003)) == 12'h00c);
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      _zz_io_bus_ACK <= 1'b0;
      mapper_cfg_compare <= 64'h0;
    end else begin
      _zz_io_bus_ACK <= (io_bus_STB && io_bus_CYC);
      if(when_WishboneSlaveFactory_l76_2) begin
        if(_zz_1) begin
          mapper_cfg_compare[31 : 0] <= io_bus_DAT_MOSI[31 : 0];
        end
      end
      if(when_WishboneSlaveFactory_l76_3) begin
        if(_zz_1) begin
          mapper_cfg_compare[63 : 32] <= io_bus_DAT_MOSI[31 : 0];
        end
      end
    end
  end


endmodule

module MachineTimerCtrl (
  input  wire [63:0]   io_config_compare,
  output wire [63:0]   io_counter,
  input  wire          io_clear,
  output wire          io_interrupt,
  input  wire          clk,
  input  wire          resetn
);

  wire       [63:0]   _zz_when_MachineTimerCtrl_l53;
  reg        [63:0]   counter;
  reg                 hit;
  reg                 lock;
  wire                when_MachineTimerCtrl_l47;
  wire                when_MachineTimerCtrl_l51;
  wire                when_MachineTimerCtrl_l53;

  assign _zz_when_MachineTimerCtrl_l53 = (counter - io_config_compare);
  assign io_counter = counter;
  assign when_MachineTimerCtrl_l47 = (! lock);
  assign when_MachineTimerCtrl_l51 = (io_clear || lock);
  assign when_MachineTimerCtrl_l53 = (! _zz_when_MachineTimerCtrl_l53[63]);
  assign io_interrupt = hit;
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      counter <= 64'h0000000000000001;
      hit <= 1'b0;
      lock <= 1'b1;
    end else begin
      if(io_clear) begin
        lock <= 1'b0;
      end
      if(when_MachineTimerCtrl_l47) begin
        counter <= (counter + 64'h0000000000000001);
      end
      if(when_MachineTimerCtrl_l51) begin
        hit <= 1'b0;
      end else begin
        if(when_MachineTimerCtrl_l53) begin
          hit <= 1'b1;
        end
      end
    end
  end


endmodule
