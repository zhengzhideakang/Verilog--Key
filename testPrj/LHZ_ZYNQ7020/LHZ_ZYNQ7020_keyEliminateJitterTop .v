/*
 * @Author       : Xu Dakang
 * @Email        : XudaKang_up@qq.com
 * @Date         : 2022-04-20 09:34:40
 * @LastEditors  : Xu Xiaokang
 * @LastEditTime : 2024-09-22 23:47:18
 * @Filename     :
 * @Description  :
*/

/*
! 模块功能: 按键消抖模块测试
! Vivado工程，使用的测试板卡为ZDYZ LHZ_ZYNQ7020_V1, 片上FPGA型号ZYNQ7020
* 思路:
  1.
*/

`default_nettype none

module LHZ_ZYNQ7020_keyEliminateJitterTop
(
  output wire led0,
  output wire led1,

  input  wire key_in_0,
  input  wire key_in_1,

  input wire fpga_clk // 50MHz
);


//++ 时钟与复位 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
wire clk;
wire locked;
localparam CLK_FREQ_MHZ = 100;
clk_wiz_0  clk_wiz_0_u0 (
  .clk_in1  (fpga_clk),
  .locked   (locked  ),
  .clk_out1 (clk     )
);
//-- 时钟与复位 ------------------------------------------------------------


//++ 实例化按键消抖模块 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
wire key_down_0;
wire key_down_one_time_0;
wire key_up_0;
wire key_up_one_time_0;
keyEliminateJitter #(
  .CLK_FREQ_MHZ    (CLK_FREQ_MHZ),
  .KEY_INIT_STATUS ("up"), // 按键初始状态: "up" (默认)或 "down"
  .INTI_MS         (    ),
  .KEEP_MS         (    )
) keyEliminateJitter_u0 (
  .key_down          (key_down_0         ),
  .key_down_one_time (key_down_one_time_0),
  .key_up            (key_up_0           ),
  .key_up_one_time   (key_up_one_time_0  ),
  .key_in            (key_in_0           ),
  .clk               (clk                )
);


wire key_down_1;
wire key_down_one_time_1;
wire key_up_1;
wire key_up_one_time_1;
keyEliminateJitter #(
  .CLK_FREQ_MHZ    (CLK_FREQ_MHZ),
  .KEY_INIT_STATUS ("up"), // 按键初始状态: "up" (默认)或 "down"
  .INTI_MS         (    ),
  .KEEP_MS         (    )
) keyEliminateJitter_u1 (
  .key_down          (key_down_1         ),
  .key_down_one_time (key_down_one_time_1),
  .key_up            (key_up_1           ),
  .key_up_one_time   (key_up_one_time_1  ),
  .key_in            (key_in_1           ),
  .clk               (clk                )
);
//-- 实例化按键消抖模块 ------------------------------------------------------------


//++ 按键控制LED ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
assign led0 = key_down_0;
assign led1 = key_up_1;
//-- 按键控制LED ------------------------------------------------------------


endmodule
`resetall