# LHZ_ZYNQ7020_keyEliminateJitter_PIN.xdc
# 代码压缩与烧写速度
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

# 时钟与复位 50MHz
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports fpga_clk]

# LED
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports led0]
set_property -dict {PACKAGE_PIN H18 IOSTANDARD LVCMOS33} [get_ports led1]

# KEY
set_property -dict {PACKAGE_PIN L20 IOSTANDARD LVCMOS33} [get_ports key_in_0]
set_property -dict {PACKAGE_PIN J20 IOSTANDARD LVCMOS33} [get_ports key_in_1]