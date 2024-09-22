/*
 * @Author       : Xu Xiaokang
 * @Email        : xuxiaokang_up@qq.com
 * @Date         : 2024-09-14 11:40:11
 * @LastEditors  : Xu Xiaokang
 * @LastEditTime : 2024-09-20 10:15:13
 * @Filename     :
 * @Description  :
*/

/*
! 模块功能: uartRTUseFIFO实例化参考
*/


keyEliminateJitter #(
  .CLK_FREQ_MHZ    (100 ),
  .KEY_INIT_STATUS ("up"), // 按键初始状态: "up" (默认)或 "down"
  .INTI_MS         (    ),
  .KEEP_MS         (    )
) keyEliminateJitter_u0 (
  .key_down          (key_down         ),
  .key_down_one_time (key_down_one_time),
  .key_up            (key_up           ),
  .key_up_one_time   (key_up_one_time  ),
  .key_in            (key_in           ),
  .clk               (clk              )
);