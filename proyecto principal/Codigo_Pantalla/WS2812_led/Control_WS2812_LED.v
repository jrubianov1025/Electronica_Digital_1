module Control_WS2812_LED (
    input        clk,
    input        reset,
    input        INIT,
    input        DONE_T,
    input        Z,
    input        RGB_MSB,
    input        RST_CMD,

    output reg        SH,
    output reg        INIT_T,
    output reg        DEC,
    output reg        LD,
    output reg        DONE,
    output reg [1:0]  SEL
);

parameter START     = 3'b000;
parameter CHK_SEL   = 3'b001;
parameter SEND_BIT  = 3'b010;
parameter WAIT_TX   = 3'b011;
parameter SHIFT     = 3'b100;
parameter CHECK_END = 3'b101;
parameter END_SEND  = 3'b110;

reg [2:0] state;
reg       send_reset;

always @(posedge clk) begin
    if (reset) begin
        state      <= START;
        send_reset <= 1'b0;
    end
    else begin
        case (state)

            START: begin
                send_reset <= 1'b0;

                if (INIT)
                    state <= CHK_SEL;
                else
                    state <= START;
            end

            CHK_SEL: begin
                send_reset <= RST_CMD;
                state      <= SEND_BIT;
            end

            SEND_BIT: begin
                state <= WAIT_TX;
            end

            WAIT_TX: begin
                if (DONE_T) begin
                    if (send_reset)
                        state <= END_SEND;
                    else
                        state <= SHIFT;
                end
                else begin
                    state <= WAIT_TX;
                end
            end

            SHIFT: begin
                state <= CHECK_END;
            end

            CHECK_END: begin
                if (Z)
                    state <= END_SEND;
                else
                    state <= CHK_SEL;
            end

            END_SEND: begin
                state <= START;
            end

            default: begin
                state <= START;
            end

        endcase
    end
end

always @(*) begin
    SH     = 1'b0;
    INIT_T = 1'b0;
    DEC    = 1'b0;
    LD     = 1'b0;
    DONE   = 1'b0;
    SEL    = 2'b00;

    case (state)

        START: begin
            SH     = 1'b0;
            INIT_T = 1'b0;
            DEC    = 1'b0;
            LD     = 1'b1;
            DONE   = 1'b0;
            SEL    = 2'b00;
        end

        CHK_SEL: begin
            SH     = 1'b0;
            INIT_T = 1'b0;
            DEC    = 1'b0;
            LD     = 1'b0;
            DONE   = 1'b0;

            if (RST_CMD)
                SEL = 2'b10;       // RES
            else if (RGB_MSB)
                SEL = 2'b01;       // bit 1
            else
                SEL = 2'b00;       // bit 0
        end

        SEND_BIT: begin
            SH     = 1'b0;
            INIT_T = 1'b1;
            DEC    = 1'b0;
            LD     = 1'b0;
            DONE   = 1'b0;

            if (send_reset)
                SEL = 2'b10;
            else if (RGB_MSB)
                SEL = 2'b01;
            else
                SEL = 2'b00;
        end

        WAIT_TX: begin
            SH     = 1'b0;
            INIT_T = 1'b0;
            DEC    = 1'b0;
            LD     = 1'b0;
            DONE   = 1'b0;

            if (send_reset)
                SEL = 2'b10;
            else if (RGB_MSB)
                SEL = 2'b01;
            else
                SEL = 2'b00;
        end

        SHIFT: begin
            SH     = 1'b1;
            INIT_T = 1'b0;
            DEC    = 1'b1;
            LD     = 1'b0;
            DONE   = 1'b0;
            SEL    = 2'b00;
        end

        CHECK_END: begin
            SH     = 1'b0;
            INIT_T = 1'b0;
            DEC    = 1'b0;
            LD     = 1'b0;
            DONE   = 1'b0;
            SEL    = 2'b00;
        end

        END_SEND: begin
            SH     = 1'b0;
            INIT_T = 1'b0;
            DEC    = 1'b0;
            LD     = 1'b0;
            DONE   = 1'b1;
            SEL    = 2'b00;
        end

        default: begin
            SH     = 1'b0;
            INIT_T = 1'b0;
            DEC    = 1'b0;
            LD     = 1'b0;
            DONE   = 1'b0;
            SEL    = 2'b00;
        end

    endcase
end

endmodule
