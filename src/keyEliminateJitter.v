/*
 * @Author       : Xu Dakang
 * @Email        : xudaKang_up@qq.com
 * @Date         : 2021-12-20 15:13:10
 * @LastEditors  : Xu Xiaokang
 * @LastEditTime : 2024-09-22 23:23:55
 * @Filename     :
 * @Description  :
*/

/*
! 模块功能: 消除按键抖动, 得到按键是否按下, 或是否抬起
* 思路:
  1.先检测按键初始的电平, 必须保证在FPGA上电后的50ms(可通过参数INTI_MS修改)内, 按键保持初始状态
  2.当按键电平为按下电平时, 开始一个40ms(可通过参数KEEP_MS修改)的计数器, 计数到最大值则认为按键按下
  3.当按键电平为抬起电平时, 开始一个40ms(可通过参数KEEP_MS修改)的计数器, 计数到最大值则认为按键抬起
~ 使用:
  1.key_down为1表示按键处于按下状态, key_down_one_time为1表示按键按下一次
  2.key_up为1表示按键处于抬起状态, key_up_one_time为1表示按键抬起一次
  3.key_down与key_up不能同时为1, 因为一个键无法同时按下/抬起,
    但此两信号可同时为0, 此时按键处于按下/抬起切换过程中
*/

`default_nettype none

module keyEliminateJitter
#(
  parameter CLK_FREQ_MHZ = 100, // 计时时钟频率, 注意修改
  parameter KEY_INIT_STATUS = "up", // 按键初始状态: "up"(默认) 或 "down"
  parameter INTI_MS = 50,  // 初始检测未按下电平, 需要持续多少MS才视为检测成功, 默认50ms, 通常无需修改
  parameter KEEP_MS = 40   // 检测到按键按下/抬起需要持续多少MS才视为有效, 默认40ms, 通常无需修改
)(
  output wire key_down,          // 按键按下
  output wire key_down_one_time, // 按键按下一次

  output wire key_up,           // 按键抬起
  output wire key_up_one_time,  // 按键抬起一次

  input  wire key_in,   // 按键输入

  input  wire clk
);


//++ 按键输入同步 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
reg key_in_r1;
reg key;
always @(posedge clk) begin
  key_in_r1 <= key_in;
  key <= key_in_r1;
end
//-- 按键输入同步 ------------------------------------------------------------


//++ 按键未按下时的电平检测 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
localparam CNT_50MS_MAX = CLK_FREQ_MHZ * 1000 * INTI_MS;
reg [$clog2(CNT_50MS_MAX+1)-1 : 0] cnt_50ms;

wire auto_detection_success = cnt_50ms == CNT_50MS_MAX; // 按键信号从FPGAs上电开始50ms内输入未发生变化

always @(posedge clk) begin
  if (auto_detection_success)
    cnt_50ms <= cnt_50ms;
  // 按键信号一改变就重新计数, 初始情况下这不应该发生, 只是为了应对电磁干扰或机械振动等极端条件
  else if (key != key_in_r1)
    cnt_50ms <= 'd0;
  else if (cnt_50ms < CNT_50MS_MAX)
    cnt_50ms <= cnt_50ms + 1'b1;
  else
    cnt_50ms <= 'd0;
end


reg auto_detection_success_r1;
always @(posedge clk) begin
  auto_detection_success_r1 <= auto_detection_success;
end

wire auto_detection_success_pedge = auto_detection_success && ~auto_detection_success_r1;


reg key_init_value; // 存储按键初始电平
always @(posedge clk) begin
  if (auto_detection_success_pedge)
    key_init_value <= key;
  else
    key_init_value <= key_init_value;
end

wire key_up_value; // 按键未按下的电平
generate
  if (KEY_INIT_STATUS == "up") begin
    assign key_up_value = key_init_value;
  end else begin
    assign key_up_value = ~key_init_value;
  end
endgenerate
//-- 按键未按下时的电平检测 ------------------------------------------------------------


//++ 检测按键按下 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// 自动检测完成后, 开始检测按键是否按下, 如果按下保持40ms, 则认为键正常按下
localparam CNT_40MS_MAX = CLK_FREQ_MHZ * 1000 * KEEP_MS;
reg [$clog2(CNT_40MS_MAX+1)-1 : 0] key_down_cnt_40ms;
always @(posedge clk) begin
  if (auto_detection_success && key == ~key_up_value) // 按键按下了
    if (key_down_cnt_40ms < CNT_40MS_MAX)
      key_down_cnt_40ms <= key_down_cnt_40ms + 1'b1;
    else
      key_down_cnt_40ms <= key_down_cnt_40ms;
  else
    key_down_cnt_40ms <= 'd0;
end

assign key_down = key_down_cnt_40ms == CNT_40MS_MAX; // 按下计数值保持最大值不变说明键处于按下的状态

reg key_down_r1;
always @(posedge clk) begin
  key_down_r1 <= key_down;
end

assign key_down_one_time = key_down && ~key_down_r1;
//-- 检测按键按下 ------------------------------------------------------------


//++ 检测按键抬起 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// 自动检测完成后, 开始检测按键是否抬起, 如果抬起保持40ms, 则认为键正常抬起
reg [$clog2(CNT_40MS_MAX+1)-1 : 0] key_up_cnt_40ms;
always @(posedge clk) begin
  if (auto_detection_success && key == key_up_value) // 按键抬起了
    if (key_up_cnt_40ms < CNT_40MS_MAX)
      key_up_cnt_40ms <= key_up_cnt_40ms + 1'b1;
    else
      key_up_cnt_40ms <= key_up_cnt_40ms;
  else
    key_up_cnt_40ms <= 'd0;
end

assign key_up = key_up_cnt_40ms == CNT_40MS_MAX; // 抬起计数值保持最大值不变说明键处于抬起的状态

reg key_up_r1;
always @(posedge clk) begin
  key_up_r1 <= key_up;
end

assign key_up_one_time = key_up && ~key_up_r1;
//-- 检测按键抬起 ------------------------------------------------------------


endmodule
`resetall