`timescale 1ns / 1ns

module tb();

//for master
reg clk;                     // Тактовый сигнал
reg button_send;             // Кнопка отправки
wire [5:0] led_m;     // Светодиоды

//for slave
wire [5:0] led_s;  // Светодиоды

//spi io
wire SCLK;             // Сигнал синхронизации
wire MISO;              // Сигнал от ведомого
wire MOSI;             // Данные от ведущего
wire SS;              // Выбор ведомого

// сопоставления входов и выходов master с переменными tb
master m(
.clk(clk),
.button_send(button_send),
.led(led_m),
.SCLK(SCLK),
.SS(SS),
.MOSI(MOSI),
.MISO(MISO)
);

// сопоставления входов и выходов slave с переменными tb
slave s(
.SCLK(SCLK),
.MOSI(MOSI),
.SS(SS),
.led(led_s),
.MISO(MISO)
);

initial
begin
    clk = 0;                     // Тактовый сигнал
    button_send = 1;             // Кнопка отправки 
end

initial 
begin
    forever 
    begin 
        #300;
        button_send = 0;
        #11;
        button_send = 1;
    end
end

initial forever #(5) clk = !clk;

initial #1000 $finish;

initial
begin
  $dumpfile("./spi_out.vcd");
  $dumpvars(0, tb);
end

endmodule