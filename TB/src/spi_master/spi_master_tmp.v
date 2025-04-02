//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.9.03 Education (64-bit)
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9
//Device Version: C
//Created Time: Thu Dec  5 01:47:09 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	SPI_MASTER_Top your_instance_name(
		.I_CLK(I_CLK), //input I_CLK
		.I_RESETN(I_RESETN), //input I_RESETN
		.I_TX_EN(I_TX_EN), //input I_TX_EN
		.I_WADDR(I_WADDR), //input [2:0] I_WADDR
		.I_WDATA(I_WDATA), //input [7:0] I_WDATA
		.I_RX_EN(I_RX_EN), //input I_RX_EN
		.I_RADDR(I_RADDR), //input [2:0] I_RADDR
		.O_RDATA(O_RDATA), //output [7:0] O_RDATA
		.O_SPI_INT(O_SPI_INT), //output O_SPI_INT
		.MISO_MASTER(MISO_MASTER), //input MISO_MASTER
		.MOSI_MASTER(MOSI_MASTER), //output MOSI_MASTER
		.SS_N_MASTER(SS_N_MASTER), //output [0:0] SS_N_MASTER
		.SCLK_MASTER(SCLK_MASTER), //output SCLK_MASTER
		.MISO_SLAVE(MISO_SLAVE), //output MISO_SLAVE
		.MOSI_SLAVE(MOSI_SLAVE), //input MOSI_SLAVE
		.SS_N_SLAVE(SS_N_SLAVE), //input SS_N_SLAVE
		.SCLK_SLAVE(SCLK_SLAVE) //input SCLK_SLAVE
	);

//--------Copy end-------------------
