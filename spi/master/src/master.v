module master
#(
    localparam LEN_DATA = 8,
    localparam LEN_CD = 21, // 5 - для tb , 21 - для запуска на ПЛИС
    localparam LEN_SCLK = 3
)
(
    input clk,
    input btn_send,
    input MISO, 
    output reg MOSI,
    output SS,
    output SCLK
);

    wire cooldown;

    reg [2:0] counter = 3'b0;
    reg [LEN_CD - 1:0] cd;
    reg [LEN_DATA - 1:0] data = ~(8'b0);
    reg sending_cd; //костыль чтобы объеденить 2 always 
    reg sending_ck; //костыль чтобы объеденить 2 always
    reg flag_send; // 0 - не передано ; 1 - передано
    reg [LEN_SCLK - 1:0] sclk; //если будет тупить то первым делом увеличеваем размер данного регистра

    //создание замедленные тактирующих сигналов
    assign SCLK = (sclk == 0? 1: 0);
    assign cooldown = (cd == 0? 0: 1);

    //активация slave 
    assign SS = (sending_ck? 0: 1);
    
    //как маштабировать? (передавать несколько пакетов по 8 бит)

    // блок создающий другие такты для работы с кнопками(cooldown) и для работы с spi (SCLK)
    always @ (negedge clk)
    begin
        cd <= cd + 1;
        sclk <= sclk + 3'b1;
    end

    // опрос кнопок примерно 14 раз в секунду
    always @ (negedge cooldown)
    begin
        //если передано и передача в блоке spi выполнена выключаем передачу блока кнопок
        //костыль чтобы объеденить 2 always
        if (!sending_ck)
        begin
            sending_cd <= 0;
        end
        //если ничего не передается то проверяем кнопку и запускаем передачу в случае ее нажанития
        else if (!sending_cd)
        begin
            if (!btn_send)
            begin 
                sending_cd <= 1;
            end
        end
    end

    //блок spi
    always @ (negedge SCLK)
    begin
            //если включена передача с кнопки
            if(sending_cd)
            begin
                // если включена передача в spi
                if (sending_ck)
                begin
                    if (counter < LEN_DATA)
                    begin
                        counter = counter + 3'b1;
                        MOSI = data[LEN_DATA - 1];
                        data = data << 1;
                        data[0] = MISO;
                    end
                    else
                    begin
                        flag_send = 1;
                        sending_ck = 0;
                    end
                end
                // если НЕ включена передача в spi
                // и передача не выполнена
                else if (!flag_send)
                begin
                    sending_ck = 1; // включаем передачу в блоке spi
                end
                // если НЕ включена передача в spi
                // и передача выполнена
                else 
                begin
                    flag_send = 0; // сбрасываем флаг передачи
                end
            end
            //если передачи не происходит выключаем SS и сбрасываем все регистры блока spi
            else 
            begin
                sending_ck = 0;
                counter = 0;
                flag_send = 0;
            end
    end

endmodule