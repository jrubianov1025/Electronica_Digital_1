module Control_Timer_WS2812 (
    input  wire       clk,
    input  wire       reset,
    input  wire       INIT_T,
    input  wire [1:0] SEL,
    input  wire       Z,

    output reg        DOUT,
    output reg        DONE_T,
    output reg        RST,
    output reg        INC,
    output reg  [1:0] SEL_TIM
);

    localparam START    = 3'd0;
    localparam SEND_0   = 3'd1;
    localparam SEND_1   = 3'd2;
    localparam SEND_RES = 3'd3;
    localparam WAIT_T   = 3'd4;
    localparam END_SEND = 3'd5;

    reg [2:0] state;
    reg [2:0] next_state;

    always @(posedge clk) begin
        if (reset) begin
            state <= START;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case (state)

            START: begin
                if (INIT_T) begin
                    case (SEL)
                        2'd0: next_state = SEND_0;
                        2'd1: next_state = SEND_1;
                        2'd2: next_state = SEND_RES;
                        default: next_state = SEND_RES;
                    endcase
                end else begin
                    next_state = START;
                end
            end

            SEND_0: begin
                if (Z)
                    next_state = WAIT_T;
                else
                    next_state = SEND_0;
            end

            SEND_1: begin
                if (Z)
                    next_state = WAIT_T;
                else
                    next_state = SEND_1;
            end

            WAIT_T: begin
                if (Z)
                    next_state = END_SEND;
                else
                    next_state = WAIT_T;
            end

            SEND_RES: begin
                if (Z)
                    next_state = END_SEND;
                else
                    next_state = SEND_RES;
            end

            END_SEND: begin
                if (!INIT_T)
                    next_state = START;
                else
                    next_state = END_SEND;
            end

            default: begin
                next_state = START;
            end

        endcase
    end

    always @(*) begin
        DOUT    = 1'b0;
        DONE_T  = 1'b0;
        RST     = 1'b0;
        INC     = 1'b0;
        SEL_TIM = 2'd0;

        case (state)

            START: begin
                DOUT    = 1'b0;
                DONE_T  = 1'b0;
                RST     = 1'b1;
                INC     = 1'b0;
                SEL_TIM = 2'd0;
            end

            SEND_0: begin
                DOUT    = 1'b1;
                DONE_T  = 1'b0;
                RST     = 1'b0;
                INC     = 1'b1;
                SEL_TIM = 2'd0;   // T0H
            end

            SEND_1: begin
                DOUT    = 1'b1;
                DONE_T  = 1'b0;
                RST     = 1'b0;
                INC     = 1'b1;
                SEL_TIM = 2'd1;   // T1H
            end

            WAIT_T: begin
                DOUT    = 1'b0;
                DONE_T  = 1'b0;
                RST     = 1'b0;
                INC     = 1'b1;
                SEL_TIM = 2'd3;   // PER
            end

            SEND_RES: begin
                DOUT    = 1'b0;
                DONE_T  = 1'b0;
                RST     = 1'b0;
                INC     = 1'b1;
                SEL_TIM = 2'd2;   // RES
            end

            END_SEND: begin
                DOUT    = 1'b0;
                DONE_T  = 1'b1;
                RST     = 1'b1;
                INC     = 1'b0;
                SEL_TIM = 2'd0;
            end

            default: begin
                DOUT    = 1'b0;
                DONE_T  = 1'b0;
                RST     = 1'b0;
                INC     = 1'b0;
                SEL_TIM = 2'd0;
            end

        endcase
    end

endmodule