module Control_WS2812_Led_Array(
    input clk,
    input reset,

    input INIT_M,
    input DONE_LED,
    input Z,

    output reg INIT_LED,
    output reg RST,
    output reg INC,
    output reg DONE_M
);

parameter START      = 3'b000;
parameter START_SEND = 3'b001;
parameter SEND_LED   = 3'b010;
parameter WAIT_TX    = 3'b011;
parameter INC_ADDR   = 3'b100;
parameter CHECK_END  = 3'b101;
parameter END_SEND   = 3'b110;

reg [2:0] state;
reg [2:0] next_state;

// Registro de estado
always @(posedge clk) begin
    if (reset) begin
        state <= START;
    end
    else begin
        state <= next_state;
    end
end

// Lógica de próximo estado
always @(*) begin
    case (state)

        START: begin
            if (INIT_M)
                next_state = START_SEND;
            else
                next_state = START;
        end

        START_SEND: begin
            next_state = SEND_LED;
        end

        SEND_LED: begin
            next_state = WAIT_TX;
        end

        WAIT_TX: begin
            if (DONE_LED)
                next_state = INC_ADDR;
            else
                next_state = WAIT_TX;
        end

        INC_ADDR: begin
            next_state = CHECK_END;
        end

        CHECK_END: begin
            if (Z)
                next_state = END_SEND;
            else
                next_state = START_SEND;
        end

        END_SEND: begin
            next_state = START;
        end

        default: begin
            next_state = START;
        end

    endcase
end

// Salidas de control
always @(*) begin
    INIT_LED = 0;
    RST      = 0;
    INC      = 0;
    DONE_M   = 0;

    case (state)

        START: begin
            INIT_LED = 0;
            RST      = 1;
            INC      = 0;
            DONE_M   = 0;
        end

        START_SEND: begin
            INIT_LED = 1;
            RST      = 0;
            INC      = 0;
            DONE_M   = 0;
        end

        SEND_LED: begin
            INIT_LED = 0;
            RST      = 0;
            INC      = 0;
            DONE_M   = 0;
        end

        WAIT_TX: begin
            INIT_LED = 0;
            RST      = 0;
            INC      = 0;
            DONE_M   = 0;
        end

        INC_ADDR: begin
            INIT_LED = 0;
            RST      = 0;
            INC      = 1;
            DONE_M   = 0;
        end

        CHECK_END: begin
            INIT_LED = 0;
            RST      = 0;
            INC      = 0;
            DONE_M   = 0;
        end

        END_SEND: begin
            INIT_LED = 0;
            RST      = 0;
            INC      = 0;
            DONE_M   = 1;
        end

        default: begin
            INIT_LED = 0;
            RST      = 0;
            INC      = 0;
            DONE_M   = 0;
        end

    endcase
end

endmodule