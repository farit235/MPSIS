module RAM_RiscV
#(
  parameter SIZE      = 256, // bytes
  parameter INIT_FILE = ""
)
(
  // clock, reset
  input clk,
  input reset,

  // instruction memory interface
  output logic  [31:0]  instr_data,
  input         [31:0]  instr_address,

  // data memory interface
  output logic  [31: 0]  data_read,
  input                  data_require,
  input                  data_write_enable,
  input         [3:  0]  data_byte_enable_map,
  input         [31: 0]  data_address,
  input         [31: 0]  data_write
);

 reg [31: 0] memory [0: SIZE / 4 - 1]; //64 байта строк по 4 байта
  //Init  RAM
  integer ram_index;

  initial begin
    if(INIT_FILE != "") begin
      $readmemh(INIT_FILE, memory); //проверка на существования файла
    end else
      for (ram_index = 0; ram_index < SIZE / 4 - 1; ram_index = ram_index + 1)
        memory[ram_index] = {32{1'b0}}; //еслии нет то занулим 
  end
  
  assign instr_data = memory[(instr_address >> 2) % SIZE]; //скидываем инструкцию (сдвигаем адрес на 2 тк есть флаги) 
  
  reg[2: 0] work_stage = 3'd1;
  always @(posedge clk)
    if(!reset)
      data_read  <= 32'b0; //если резет то занулям записываемую инф-ю в 0
    else
      if(data_require)    
        if(!data_write_enable) //если записи не разрешена, то в чтение 
          data_read <= memory[(data_address >> 2) % SIZE];
        else begin
          if(data_byte_enable_map[0])      //если запись разрешена то по мепам выбираем часть слова куда будем записывать информацию 
            memory[data_address[31:2]][7:0]  <= data_write[7:0];
	  
          if(data_byte_enable_map[1])
	    memory[data_address[31:2]][15:8] <= data_write[15:8];

	  if(data_byte_enable_map[2])
	    memory[data_address[31:2]][23:16] <= data_write[23:16];

	  if(data_byte_enable_map[3])
	    memory[data_address[31:2]][31:24] <= data_write[31:24];
        end
endmodule