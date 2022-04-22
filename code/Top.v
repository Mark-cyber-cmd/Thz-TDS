module Top(
    input sys_clk,
    input sys_rst_n,
    
    input  uart_rxd,          //UART接收端口
    output uart_txd,          //UART发送端口
    
    output clk_test
);

//reg define
reg ram_address;

//wire define
wire [7:0]  uart_data_w;
wire        uart_en_w;         //发送请求信号
wire        uart_tx_flag;      //发送完成信号
wire [7:0]  uart_data_r;       
wire        uart_en_r;          //接收完成信号

wire        ram_wr_en;
wire [14:0] ram_addr;
wire [ 7:0] ram_wr_data;
wire [ 7:0] ram_rd_data;


PLL u_PLL(
	.inclk0 (sys_clk),
	.c0     (clk_test)
);
    
uart_top u_uart_top(
    .sys_clk        (sys_clk),           //外部50M时钟
    .sys_rst_n      (sys_rst_n),         //外部复位信号，低有效

    .uart_rxd       (uart_rxd),          //UART接收端口
    .uart_txd       (uart_txd),          //UART发送端口
    

    .uart_data_w    (uart_data_w),
    .uart_en_w      (uart_en_w),         //发送请求信号
    .uart_tx_flag   (uart_tx_flag),      //发送完成信号
    .uart_data_r    (uart_data_r),       
    .uart_en_r      (uart_en_r)          //接收完成信号
    );

sys_control u_sys_control(
    .sys_clk         (sys_clk),
    .sys_rst_n       (sys_rst_n),
    
    .ram_wr_en       (ram_wr_en),
    .ram_addr        (ram_addr),
    .ram_wr_data     (ram_wr_data),
    .ram_rd_data     (ram_rd_data),
    
    .uart_rd_data    (uart_data_r),
    .uart_rd_en      (uart_en_r),
    .uart_wr_data    (uart_data_w),
    .uart_wr_en      (uart_en_w),
    .uart_wr_complete(uart_tx_flag)
);

ram u_ram(
	.address        (ram_addr),
	.clock          (sys_clk),
	.data           (ram_wr_data),
	.wren           (ram_wr_en),
	.q              (ram_rd_data)
);

endmodule
