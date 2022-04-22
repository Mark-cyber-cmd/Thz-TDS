    module sys_control(
    input              sys_clk,
    input              sys_rst_n,
    
    output  reg        ram_wr_en,
    output  reg [14:0] ram_addr,
    output  reg [ 7:0] ram_wr_data,
    input       [ 7:0] ram_rd_data,
    
    input       [ 7:0] uart_rd_data,
    input              uart_rd_en,
    output  reg [ 7:0] uart_wr_data,
    output  reg        uart_wr_en,
    input              uart_wr_complete
);

//parameter define
parameter CYCLE = 10;


//wire_define
wire uart_rd_flag; 


//reg define
reg uart_rd_d0;
reg uart_rd_d1;

reg [ 2:0]  sys_status;
reg [14:0]  cycle_cnt;
reg [ 2:0]  cycle_flag;
reg         sys_output_complete;

//串口读取使能位上升沿检测
assign uart_rd_flag = ~uart_rd_d1 & uart_rd_d0;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
    begin
        uart_rd_d0 <= 1'd0;
        uart_rd_d1 <= 1'd0;        
    end
    else
    begin
        uart_rd_d0 <= uart_rd_en;
        uart_rd_d1 <= uart_rd_d0;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
    begin
        cycle_cnt <= 15'd0;
        cycle_flag <= 3'd0;
    end
    else
    begin
        if(uart_rd_flag)
        begin
            cycle_cnt <= cycle_cnt + 1;
        end
        
        if(cycle_cnt == CYCLE)
        begin
            cycle_cnt  <= 15'd0;
            cycle_flag <= cycle_flag + 1;
        end
        
        if(sys_output_complete)
        begin
            cycle_flag <= 3'd0;
        end
   end
end

//状态机 第一周期接受阶段------->叠加周期阶段------->数据返回阶段
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
    begin
        sys_status <= 3'd0;
    end
    else
    begin
        case(cycle_flag)
            3'd0 : begin
                   sys_status <= 3'd0;
                   sys_output_complete <= 1'b0;
                   end 
            3'd1 : sys_status <= 3'd1;
            3'd5 : sys_status <= 3'd2;
        endcase       
    end
end

//
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
    begin
        ram_wr_data   <= 8'd0;
        ram_addr      <= 15'd0;
        ram_wr_en     <= 1'd0;
        uart_wr_data  <= 8'd0;
        uart_wr_en    <= 1'd0;
    end
    else
    begin
        if(sys_status == 3'd0 && uart_rd_flag)
        begin
            ram_wr_data  <= uart_rd_data;
            ram_addr  <= cycle_cnt;
            ram_wr_en <= uart_rd_flag;
        end
        else
        begin
            ram_wr_en <= uart_rd_flag;
        end
        
        if(sys_status == 3'd1 && uart_rd_flag)
        begin
            ram_addr     <= cycle_cnt;
            ram_wr_data  <= uart_rd_data + ram_rd_data;
            ram_wr_en    <= uart_rd_flag;
        end
        else
        begin
            ram_wr_en <= uart_rd_flag;
        end
        
        if(sys_status == 3'd2 && !uart_wr_complete)
        begin
            ram_addr     <= cycle_cnt;
            uart_wr_data <= ram_rd_data;
            uart_wr_en   <= uart_wr_complete;
        end
        else
        begin
            uart_wr_en   <= uart_wr_complete;
        end
    end
end


endmodule
















