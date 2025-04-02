  
`timescale 1ns/1ps

`define DATA_WIDTH 8
   
module m_spi_control
(
	 I_CLK,
     I_RESETN,
	 start,
     I_TX_EN,
     I_WADDR,
     I_WDATA,
     I_RX_EN,
     I_RADDR,
     O_RDATA,
	 wr_index,

     i_data,
     o_data,
     is_sending
);

  input                       I_CLK;
  input                       I_RESETN;
  input                       start;  
  output                      I_TX_EN;
  output [2:0]                I_WADDR;
  output [`DATA_WIDTH-1:0]    I_WDATA;   
  output                      I_RX_EN;  
  output [2:0]                I_RADDR;
  input  [`DATA_WIDTH-1:0]    O_RDATA;
  output reg [3:0]            wr_index;  

  output reg [7:0]            i_data;
  input [7:0]                 o_data;
  output reg                  is_sending;

//////////////////////////////////////////////////////////////////////////
// Internal Wires/Registers

 reg                      I_TX_EN;
 reg [2:0]                I_WADDR;
 reg [`DATA_WIDTH-1:0]    I_WDATA;
 reg                      I_RX_EN; 
 reg [2:0]                I_RADDR;

 wire [2:0]               REG_RXDATA  = 3'd0;
 wire [2:0]               REG_TXDATA  = 3'd1;
 wire [2:0]               REG_STATUS  = 3'd2;
 wire [2:0]               REG_CONTROL = 3'd3;
 wire [2:0]               REG_SSMASK  = 3'd4;

 reg [0:0]				  wr_cntl;
 reg [0:0]				  wr_reg;
 reg [1:0]				  rd_reg;
 reg [`DATA_WIDTH-1:0]    rd_status;
 
 reg                      start_dl;

///////////////////////////////////////////////////////////////////////////
// Module management

always @(negedge I_RESETN or posedge I_CLK)
    if(~I_RESETN)
       start_dl <= 1'b0;	 
    else
       start_dl <= start; 

always @(negedge I_RESETN or posedge I_CLK)
begin
	if(~I_RESETN)
	begin
	    I_TX_EN <= 1'b0;
		I_WADDR <= 2'b00;
		I_WDATA <= {`DATA_WIDTH{1'b0}};
	    I_RX_EN <= 1'b0;		
		I_RADDR <= 2'b00;
		
		wr_index <= 0;
		wr_cntl <= 0;
		wr_reg <= 0;
		rd_reg <= 0;
		rd_status <= 0;
        i_data <= 0;
        is_sending <= 0;
	end
	else
	begin
		if(wr_index==0)begin    //write ssmask
		    case(wr_cntl)
		                0:
						   if((start_dl == 1'b0) && (start == 1'b1)) 
						    begin
		                        I_TX_EN <= 1'b1;
		                        I_WADDR <= REG_SSMASK; //0x04
		                        I_WDATA <= 8'h01;	 //Slave Select
		
		                        wr_cntl <=1;
                                is_sending <= 0;
		                    end
						   else
						    begin
		                        I_TX_EN <= 1'b0;

			                    wr_index <= 0;	
                                wr_cntl <= 0;
                            end								
		                1:
		                    begin 
		                        I_TX_EN <= 1'b0;

			                    wr_index <= 1;	
                                wr_cntl <= 0;								
		                    end
						default:
						    begin
		                        I_TX_EN <= 1'b0;

			                    wr_index <= 0;	
                                wr_cntl <= 0;
                            end						
		    endcase 
		end //if(wr_index==0)
		
        else if(wr_index==1)begin   //write control reg
		        case(wr_reg)
		                0:
		                    begin
		                        I_TX_EN <= 1'b1;
		                        I_WADDR <= REG_CONTROL; //0x03
		                        I_WDATA <= 8'h8B; //10001011
		
		                        wr_reg <=1;
		                    end
		                1:
		                    begin 
		                        I_TX_EN <= 1'b0;
								
			                    wr_index <= 2;
			                    wr_reg <= 0;
		                    end
						default:
						    begin
		                        I_TX_EN <= 1'b0;
								I_WADDR <= 0;
								I_WDATA <= 0;

			                    wr_index <= 0;	
                                wr_reg <= 0;
                            end								
		        endcase 
		end//if(wr_index==1)
		
        else if(wr_index==2)begin       //read status reg
			    case(rd_reg)
			            0:
			                begin
		                        I_RX_EN <= 1'b1;
				                I_RADDR <= REG_STATUS; //0x02
				
				                rd_reg <= 1;
			                end
			            1:
			                begin
		                        I_RX_EN <= 1'b0;
								
					            rd_reg <= 2;
			                end
			            2:
			                begin
				                rd_status <= O_RDATA;
					
					            rd_reg <= 3;					
			                end	
			            3:
			                begin
					            if(rd_status[5]&&rd_status[4])begin //if tx ready
						            wr_index <= 3;
						            rd_reg <= 0;
					            end
					            else
						            rd_reg <= 0;
				            end
						default:
						    begin
		                        I_RX_EN <= 1'b0;
								I_RADDR <= 0;

								rd_status <= 0;
			                    wr_index <= 0;	
                                rd_reg <= 0;
                            end								
			        endcase
			end	//if(wr_index==2)
			
		else if(wr_index==3)begin   //write data
		        case(wr_reg)
		                0:
		                    begin
		                        I_TX_EN <= 1'b1;
		                        I_WADDR <= REG_TXDATA; //0x01
                                I_WDATA <= o_data;
		
		                        wr_reg <=1;
		                    end
		                1:
		                    begin 
		                        I_TX_EN <= 1'b0;

			                    wr_index <= 4;
			                    wr_reg <= 0;								
		                    end
						default:
						    begin
		                        I_TX_EN <= 1'b0;
								I_WADDR <= 0;
								I_WDATA <= 0;

			                    wr_index <= 0;	
                                wr_reg <= 0;
                            end							
		        endcase 
		end//if(wr_index==3)

		else if(wr_index==4)begin       //read status reg
			    case(rd_reg)
			            0:
			                begin
		                        I_RX_EN <= 1'b1;
				                I_RADDR <= REG_STATUS; //0x02
				
				                rd_reg <= 1;
			                end
			            1:
			                begin
		                        I_RX_EN <= 1'b0;
								
					            rd_reg <= 2;
			                end
			            2:
			                begin
				                rd_status <= O_RDATA;
					
					            rd_reg <= 3;					
			                end	
						3:
                            begin						
							   if(rd_status[6] == 1'b1) begin
					              rd_reg <= 0;
                                  wr_index <= 5;
                               end
                               else begin
					              rd_reg <= 0;
                                  wr_index <= 4;
							   end
			                end
						default:
						    begin
		                        I_RX_EN <= 1'b0;
								I_RADDR <= 0;

								rd_status <= 0;
			                    wr_index <= 0;	
                                rd_reg <= 0;
                            end							
			    endcase
		end	//if(wr_index==4)
		
		else if(wr_index==5)begin       //read data
			    case(rd_reg)
			            0:
			                begin
		                        I_RX_EN <= 1'b1;
				                I_RADDR <= REG_RXDATA; //0x00
				
				                rd_reg <= 1;
			                end
			            1:
			                begin
		                        I_RX_EN <= 1'b0;
								
					            rd_reg <= 2;
			                end
			            2:
			                begin
                                i_data <= O_RDATA;
								
					            rd_reg <= 3;
			                end
			            3:
			                begin	
					            rd_reg <= 0;   
                                wr_index <= 6;              
			                end	
						default:
						    begin
		                        I_RX_EN <= 1'b0;
								I_RADDR <= 0;

			                    wr_index <= 0;	
                                rd_reg <= 0;							
                            end							
			    endcase
		end	//if(wr_index==5)
			
        else if(wr_index==6)begin   //write control reg
		        case(wr_reg)
		                0:
		                    begin
		                        I_TX_EN <= 1'b1;
		                        I_WADDR <= REG_CONTROL;
		                        I_WDATA <= 8'h00;
		
		                        wr_reg <=1;
		                    end
		                1:
		                    begin						
		                        I_TX_EN <= 1'b0;	

			                    wr_index <= 0;
			                    wr_reg <= 0;
                                is_sending <= 1;
		                    end
						default:
						    begin
		                        I_TX_EN <= 1'b0;

			                    wr_index <= 0;	
                                wr_reg <= 0;
                                is_sending <= 0;
                            end							
		        endcase 
		end//if(wr_index==6)
	end 
end 

endmodule
