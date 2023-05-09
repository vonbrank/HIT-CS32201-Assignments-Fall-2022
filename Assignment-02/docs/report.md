## 一、实验目的

1. 掌握 Vivado 集成开发环境
2. 掌握 Verilog 语言
3. 掌握 FPGA 编程方法及硬件调试手段
4. 深刻理解处理器结构和计算机系统的整体工作原理

## 二、实验环境（实验设备、开发环境）

Vivado 集成开发环境和龙芯 Artix-7 实验平台

## 三、设计思想（实验预习）

### CPU接口信号定义

填写下表

| 信号名              | 位数 | 方向     | 来源/去向 | 意义               |
| ------------------- | ---- | -------- | --------- | ------------------ |
| `clk`               | `1`  | `in`     | 外部      | 时钟信号           |
| `rst`               | `1`  | `in`     | 外部      | 重置处理器         |
| `debug_wb_pc`       | `32` | `output` | 外部      | 当前 `PC`          |
| `debug_wb_rf_wen`   | `1`  | `output` | 外部      | 寄存器文件写使能   |
| `debug_wb_rf_addr`  | `5`  | `output` | 外部      | 寄存器文件写回编号 |
| `debug_wb_rf_wdata` | `32` | `output` | 外部      | 当前需要写回的数据 |

### 处理器设计方案

给出处理器的设计方案，设计方案要求包括：

1. 指令格式设计

   `rs`：source register

   `rd`：destination register

   `rt`：source register / target register

   + 运算指令

     + `ADD rd, rs, rt`

       | `31-26`  | `25-21` | `20-16` | `15-11` |     `10-0`     |
       | :------: | :-----: | :-----: | :-----: | :------------: |
       | `000000` |  `rs`   |  `rt`   |  `rd`   | `00000_100000` |
       |   `6`    |   `5`   |   `5`   |   `5`   |      `11`      |

       `[rd] <- [rs] + [rt]`

     + `SUB rd, rs, rt`

       | `31-26`  | `25-21` | `20-16` | `15-11` |     `10-0`     |
       | :------: | :-----: | :-----: | :-----: | :------------: |
       | `000000` |  `rs`   |  `rt`   |  `rd`   | `00000_100010` |
       |   `6`    |   `5`   |   `5`   |   `5`   |      `11`      |

       `[rd] <- [rs] - [rt]`

     + `AND rd, rs, rt`

       | `31-26`  | `25-21` | `20-16` | `15-11` |     `10-0`     |
       | :------: | :-----: | :-----: | :-----: | :------------: |
       | `000000` |  `rs`   |  `rt`   |  `rd`   | `00000_100100` |
       |   `6`    |   `5`   |   `5`   |   `5`   |      `11`      |

       `[rd] <- [rs] & [rt]`

     + `OR rd, rs, rt`

       | `31-26`  | `25-21` | `20-16` | `15-11` |     `10-0`     |
       | :------: | :-----: | :-----: | :-----: | :------------: |
       | `000000` |  `rs`   |  `rt`   |  `rd`   | `00000_100101` |
       |   `6`    |   `5`   |   `5`   |   `5`   |      `11`      |

       `[rd] <- [rs] | [rt]`

     + `XOR rd, rs, rt`

       | `31-26`  | `25-21` | `20-16` | `15-11` |     `10-0`     |
       | :------: | :-----: | :-----: | :-----: | :------------: |
       | `000000` |  `rs`   |  `rt`   |  `rd`   | `00000_100110` |
       |   `6`    |   `5`   |   `5`   |   `5`   |      `11`      |

       `[rd] <- [rs] ^ [rt]`

     + `SLT rd, rs, rt`

       | `31-26`  | `25-21` | `20-16` | `15-11` |     `10-0`     |
       | :------: | :-----: | :-----: | :-----: | :------------: |
       | `000000` |  `rs`   |  `rt`   |  `rd`   | `00000_101010` |
       |   `6`    |   `5`   |   `5`   |   `5`   |      `11`      |

       `[rd] <- [rs] < [rt] ? 1 : 0`

     + `MOVZ rd, rs, rt`

       | `31-26`  | `25-21` | `20-16` | `15-11` |     `10-0`     |
       | :------: | :-----: | :-----: | :-----: | :------------: |
       | `000000` |  `rs`   |  `rt`   |  `rd`   | `00000_001010` |
       |   `6`    |   `5`   |   `5`   |   `5`   |      `11`      |

       `if([rt] == 0) then [rd] <- [rs]`

   + 访存指令

     - `SW rt, offset(base)`

       | `31-26`  | `25-21` | `20-16` |  `15-0`  |
       | :------: | :-----: | :-----: | :------: |
       | `101011` | `base`  |  `rt`   | `offset` |
       |   `6`    |   `5`   |   `5`   |   `16`   |

       `Men[[base] + offset] <- [rt]`

     - `LW rt, offset(base)`

       | `31-26`  | `25-21` | `20-16` |  `15-0`  |
       | :------: | :-----: | :-----: | :------: |
       | `100011` | `base`  |  `rt`   | `offset` |
       |   `6`    |   `5`   |   `5`   |   `16`   |

       `[rt] <- Men[[base] + offset]`

   + 转移类指令

     - `BEQ rt, rt, offset`

       | `31-26`  | `25-21` | `20-16` |  `15-0`  |
       | :------: | :-----: | :-----: | :------: |
       | `000100` |  `rs`   |  `rt`   | `offset` |
       |   `6`    |   `5`   |   `5`   |   `16`   |

       `PC <- ([rs] == [rt]) ? [sign_extend(offset) << 2 + NPC] : NPC`

     - `J target`

       | `31-26`  |       `25-0`        |
       | :------: | :-----------------: |
       | `000010` | `instruction_index` |
       |   `6`    |        `26`         |

       `PC <- (NPC[31:28]) ## (instr_index << 2)`

     注：`NPC = PC + 4`

2. 处理器结构设计框图及功能描述

   ![CPU-Design-Sequential-Diagram](report.assets\CPU-Design-Sequential-Diagram.jpg)

3. 各功能模块结构设计框图及功能描述

   - 取指模块

     ![Fetch](report.assets\Fetch.jpg)

     根据 PC 从存储器取出指令，将指令送入 `IR`；`PC + 4` 送入 `NPC`，作为下一条指令地址的备选值，即：

     - `IR <- Men[PC]`
     - `NPC <- PC + 4`

   - 译码模块

     ![Decode](report.assets\Decode.jpg)

     从 `IR` 中读出 `rs` `rt` `rd` 的值，并选择合适的值传入寄存器 `regA` `regB` 作为 ALU 的备选操作数。同时从低 `16` 位的值扩展至 `32` 位存入 `Imm` 寄存器：

     `A <- Regs[IR[25:21]]（即rs）`

     `B <- Regs[IR[20:16]]（即rt）`

     - 运算类

       `Imm <- IR[10:0]`

     - 访存类

       `Imm <- IR[15:0]符号位扩展至高位`

     - 转移类

       对于 `BEQ`：

       `Imm <- IR[15:0]符号位扩展至高位`

       对于 `J`：

       `Imm <- IR[26:0]`

   - 执行模块

     ![Execute](report.assets\Execute.jpg)

     根据指令选择对应操作数进行逻辑运算：

     - 运算类：

       `ALU Output <- A op B`

       对于 `SLT`：

       `Cond <- A < B ? 1 : 0`

       对于 `MOVZ`：

       `ALU Output <- A + 0`

       `Cond <- B == 0 ? 1 : 0` 

     - 访存类：

       `ALU Output <- A + Imm[15:0]`

     - `BEQ`：

       `ALU Output <- NPC + Imm[15:0]<<2`

       `Cond <- A == B ? 1 : 0`

     - `J`：

       `ALU Output <- {NPC[31:28], Imm[25:0] << 2}`

   - 访存模块

     ![MemoryAccess](report.assets\MemoryAccess.jpg)

     根据指令以及输入选择下一个 `PC` 的取值；对于访存指令，根据 ALU 得到的计算结果访存。

     + 运算指令：

       `PC <- NPC`

     + 访存指令：

       对于 `LW`

       `LMD <- Mem[ALU Output]`

       对于 `SW`

       `Men[ALU Output] <- B`

     + 转移指令：

       对于 `BEQ`

       `PC <- cond == 1 ? ALU Output : NPC`

       对于 `J`

       `PC <- ALU Output`

   - 写回模块

     ![WriteBack](report.assets\WriteBack.jpg)

     - 运算指令：

       `valWEN <- 1`

       `valW <- ALU Output`

       对于 `SLT`：

       `valW <- cond`

       对于 `MOVZ`：

       `valWEN <- cond`

       `valW <- ALU Output` 

     - 访存指令：
     
       对于 `LW`：
     
       `valWEN <- 1`
       
       `valW <- LMD`

4. 各模块输入输出接口信号定义

   【以表格形式给出，表格内容包括信号名称、位数、方向、来源/去向和信号意义】

   除取指模块外，所有模块都有 `[5: 0] icode` 和 `[10: 0] ifun` 作为输入，表明当前指令的操作码和功能。

   + 取指模块
   
     | 信号名   | 位数 | 方向  | 来源/去向         | 意义                           |
     | -------- | ---- | ----- | ----------------- | ------------------------------ |
     | `nextPC` | `8`  | `in`  | 访存模块          | 下一条指令地址                 |
     | `NPC`    | `8`  | `out` | 执行模块/访存模块 | 非转移指令的<br>下一条指令地址 |
     | `IR`     | `32` | `out` | 译码模块          | 当前 `PC` <br>对应指令的值     |
     
   + 译码模块
   
     | 信号名 | 位数 | 方向  | 来源/去向         | 意义                                  |
     | ------ | ---- | ----- | ----------------- | ------------------------------------- |
     | `IR`   | `32` | `in`  | 取指模块          | 当前指令的值                          |
     | `RegA` | `32` | `out` | 执行模块          | 执行模块备选操作数                    |
     | `RegB` | `32` | `out` | 执行模块/访存模块 | 执行模块备选操作数/<br>访存阶段操作数 |
     | `Imm`  | `32` | `out` | 执行模块          | 执行模块备选操作数                    |
     
   + 执行模块

        | 信号名       | 位数 | 方向  | 来源/去向 | 意义                       |
     | ------------ | ---- | ----- | --------- | -------------------------- |
     | `NPC`        | `8`  | `in`  | 取指模块  | 用于计算下一条指令地址     |
     | `RegA`       | `32` | `in`  | 译码模块  | ALU 备选操作数             |
     | `RegB`       | `32` | `in`  | 译码模块  | ALU 备选操作数             |
     | `Imm`        | `32` | `in`  | 译码模块  | ALU 备选操作数             |
     | `ALU Output` | `32` | `out` | 访存模块  | ALU 的运算结果             |
     | `cond`       | `1`  | `out` | 访存模块  | 某些带条件指令的访存依赖项 |
     
   + 访存模块

        | 信号名       | 位数 | 方向  | 来源/去向 | 意义                         |
     | ------------ | ---- | ----- | --------- | ---------------------------- |
     | `ALU Output` | `32` | `in`  | 执行模块  | 访存地址/下一条指令地址      |
     | `RegB`       | `32` | `in`  | 译码模块  | 写入存储器的值               |
     | `cond`       | `1`  | `in`  | 执行模块  | 选择下一条指令地址的判断条件 |
     | `nextPC`     | `32` | `out` | 取指模块  | 下一条指令的地址             |
     | `LMD`        | `32` | `out` | 写回模块  | 访存结果                     |
     
   + 写回模块
   
        | 信号名       | 位数 | 方向  | 来源/去向 | 意义                 |
        | ------------ | ---- | ----- | --------- | -------------------- |
        | `ALU Output` | `32` | `in`  | 执行模块  | 写回寄存器的备选值   |
        | `LMD`        | `32` | `in`  | 访存模块  | 写回寄存器的备选值   |
        | `cond`       | `1`  | `in`  | 执行模块  | 写回寄存器的判断条件 |
        | `valWEN`     | `1`  | `out` | 译码模块  | 是否写寄存器文件     |
        | `valW`       | `32` | `out` | 译码模块  | 写回寄存器文件的值   |
       
   + 其他辅助模块
   
       - 寄存器文件

         | 信号名   | 位数 | 方向  | 来源/去向 | 意义                   |
         | -------- | ---- | ----- | --------- | ---------------------- |
         | `srcA`   | `5`  | `in`  | 访存模块  | 读取 `valA` 的寄存器号 |
         | `valA`   | `32` | `out` | 访存模块  | 读到的 `valA` 值       |
         | `srcB`   | `5`  | `in`  | 访存模块  | 读取 `valB` 的寄存器号 |
         | `valB`   | `32` | `out` | 访存模块  | 读到的 `valB` 值       |
         | `srcC`   | `5`  | `in`  | 访存模块  | 写入 `valC` 的寄存器号 |
         | `valC`   | `32` | `in`  | 访存模块  | 写入的 `valC` 值       |
         | `valCEN` | `1`  | `in`  | 访存模块  | 写入信号               |
         
       - 指令、数据缓存
       
         | 信号名         | 位数 | 方向  | 来源/去向     | 意义        |
         | -------------- | ---- | ----- | ------------- | ----------- |
         | `CacheRead`    | `1`  | `in`  | 取指/访存模块 | 读使能      |
         | `CacheWrite`   | `1`  | `in`  | 访存模块      | 写使能      |
         | `CacheAddress` | `8`  | `in`  | 取指/访存模块 | 读/写的地址 |
         | `CacheDataIn`  | `32` | `in`  | 访存模块      | 写入的值    |
         | `CacheDataOut` | `32` | `out` | 取指/访存模块 | 读取的值    |

## 四、实验设计及测试

用Verilog语言实现处理器设计。要求采用结构化设计方法，用Verilog语言实现处理器的设计。设计包括：

1. 各模块的详细设计（包括各模块功能详述，设计方法，Verilog语言实现等）

   按照上述设计在 Verilog 中设计各个模块。

   本设计中，每条指令执行需要5个周期，每个模块按顺序激活（`EN`）变量，得到每个模块的设计：

   + Fetcth：

     ```verilog
     module Fetch(
             input clk,
             input rst,
             input EN,
     
             input [31: 0] predictPC,
             output reg [31: 0] NPC,
             output [31: 0] IR,
             output [31: 0] PC
         );
     
         reg [31: 0] currentPC;
     
         always @(posedge clk) begin
             if(!rst) currentPC <= 0;
             else if(EN) currentPC <= predictPC;
         end    
     
         assign NPC = currentPC + 4;
         assign PC = currentPC;
     
         InstrucionCache instructionCache(
             .readAddress(currentPC), 
             .readData(IR)
         );
     
     endmodule
     ```

   + Decode：

     ```verilog
     module Decode(
             input clk,
             input rst,
             input EN,
     
             input [31: 0] IR,
             input writeEN,
             input [31: 0] writeVal,
     
             output [31: 0] RegA,
             output [31: 0] RegB,
             output reg [31: 0] Imm,
             output [4: 0] debug_wb_rf_addr
         );
     
         reg [4: 0] RegCAddress;
     
         always @(posedge clk) begin
             if(!rst) begin
                 Imm <= {32{1'b0}};
             end
             else if(EN) begin
                 case (IR[31: 26])
                     `ALU_OP_CODE: begin
                         Imm <= {21'b0, IR[10: 0]};   // 运算类
                         RegCAddress <= IR[15: 11];
                     end 
                     `SW_OP_CODE, `LW_OP_CODE, `BEQ_OP_CODE: begin
                         Imm <= {{16{IR[15]}}, IR[15: 0]}; // 访存类， BEQ
                         RegCAddress <= IR[20: 16];
                     end 
                     `J_OP_CODE: Imm <= {5'b0, IR[26: 0]};
                     default: Imm <= {5'b0, IR[26: 0]}; // J
                 endcase
             end
         end
     
         RegisterFile registerFile(
             .clk (clk),
             .rst (rst),
             .readAddressA (IR[25: 21]),
             .readValA (RegA),
             .readAddressB (IR[20: 16]),
             .readValB (RegB),
             .writeEN (writeEN),
             .writeAddress (RegCAddress),
             .writeVal (writeVal)
         );
     
         assign debug_wb_rf_addr = RegCAddress;
     
     endmodule
     ```

   + Execute：

     ```verilog
     module Execute(
             input clk,
             input rst,
             input EN,
     
             input [31: 0] NPC,
             input [31: 0] RegA,
             input [31: 0] RegB,
             input [31: 0] Imm,
             input [31: 0] IR,
     
             output reg [31: 0] ALU_Output,
             output reg cond
         );
     
     
         always @(posedge clk) begin
             if(!rst) begin
                 ALU_Output <= {32{1'b0}};
                 cond <= 0;
             end
             else if(EN) begin
                 case (IR[31: 26]) // iCode
                     `ALU_OP_CODE: begin
                         case(IR[10: 0]) // iFun
                             `ADD_FUN_CODE: ALU_Output <= RegA + RegB;
                             `SUB_FUN_CODE: ALU_Output <= RegA - RegB;
                             `AND_FUN_CODE: ALU_Output <= RegA & RegB;
                             `OR_FUN_CODE: ALU_Output <= RegA | RegB;
                             `XOR_FUN_CODE: ALU_Output <= RegA ^ RegB;
                             `SLT_FUN_CODE: cond <= RegA < RegB ? 1'b1 : 1'b0;
                             `MOVZ_FUN_CODE: begin
                                 ALU_Output <= RegA;
                                 cond <= RegB == 32'b0 ? 1 : 0;
                             end
                             default: begin
                                 ALU_Output <= RegA + RegB;;
                                 cond <= 0;
                             end
                         endcase
                     end
                     `SW_OP_CODE, `LW_OP_CODE: ALU_Output <= RegA + Imm[15: 0];
                     `BEQ_OP_CODE: begin
                         ALU_Output <= NPC + (Imm[15: 0] << 2);
                         cond <= RegA == RegB ? 1'b1 : 1'b0;
                     end
                     `J_OP_CODE: ALU_Output <= {NPC[31: 28], Imm[25: 0] << 2};
                     default: ALU_Output <= RegA + RegB;
                 endcase  
             end
         end
     
     endmodule
     ```

   + Memory Access：

     ```verilog
     module MemoryAccess(
             input clk,
             input rst,
             input EN,
     
             input [31: 0] ALU_Output,
             input [31: 0] RegB,
             input cond,
             input [31: 0] nextPC,
             input [31: 0] IR,
     
             output reg [31: 0] predictPC,
             output reg [31: 0] LMD
         );
     
         wire [5: 0] iCode = IR[31: 26];
         wire [10: 0] iFun = IR[10: 0];
         
         reg writeEN;
         wire [31: 0] readData;
     
         always @(posedge clk) begin
             if(!rst) begin
                 predictPC <= 0;
                 LMD <= 0;
             end 
             else if(EN) begin
                 case (iCode)
                     `BEQ_OP_CODE: predictPC <= cond == 1'b1 ? ALU_Output : nextPC;
                     `J_OP_CODE: predictPC <= ALU_Output;
                     
                     default: begin
                         predictPC <= nextPC;
                     end 
                 endcase
     
                 if(iCode == `SW_OP_CODE) writeEN <= 1'b1;
                 else writeEN <= 1'b0;
                 LMD <= readData;
             end
             else writeEN <= 1'b0;
         end
     
         DataCache dataCache(
             .clk (clk),
             .rst (rst),
             .readAddress (ALU_Output),
             .readData (readData),
             .writeEN (writeEN),
             .writeAddress (ALU_Output),
             .writeData (RegB)
         );
     
     endmodule
     ```

   + Write Back

     ```verilog
     module WriteBack(
             input clk,
             input rst,
             input EN,
     
             input [31: 0] ALU_Output,
             input [31: 0] LMD,
             input cond,
             input [31: 0] IR,
     
             output valWriteEN,
             output reg [31: 0] valWrite
         );
     
         wire [5: 0] iCode = IR[31: 26];
         wire [10: 0] iFun = IR[10: 0];
         reg valWriteENPre;
         reg bCurrentStage;
     
         always @(posedge clk) begin
             if(!rst) begin
                 valWriteENPre <= 1'b0;
                 valWrite <= 0;
                 bCurrentStage <= 0;
             end
             else if(EN) begin
                 bCurrentStage <= 1;
                 case (iCode)
                     `ALU_OP_CODE: begin
                         case(iFun)
                             `SLT_FUN_CODE: begin
                                 valWriteENPre <= 1'b1;
                                 valWrite <= {{31{1'b0}}, cond};
                             end 
                             `MOVZ_FUN_CODE: begin
                                 valWriteENPre <= cond ? 1'b1 : 1'b0;
                                 valWrite <= ALU_Output;
                             end
                             default: begin
                                 valWriteENPre <= 1'b1;
                                 valWrite <= ALU_Output;
                             end
                         endcase
                     end
                     `LW_OP_CODE: begin
                         valWriteENPre <= 1'b1;
                         valWrite <= LMD;
                     end
                     default: valWriteENPre <= 1'b0;
                 endcase
             end
             else begin
                 bCurrentStage <= 0;
             end
         end
     
     
         assign valWriteEN = valWriteENPre & bCurrentStage;
     
     endmodule
     ```

     

2. 各模块的功能测试（每个模块作为一个部分，包括测试方案、测试过程和测试波形等）

   各模块连接之后进行测试，通过仿真波形查看各模块内的 Reg/Wire 值来判断是否正常运行。

   选用代码框架中使用的测试用例进行测试：

   ```asm
   0x0000:  8C 01 00 04    LW   $1,  4($0)
   0x0004:  8C 02 00 08    LW   $2,  8($0)
   0x0008:  00 22 18 20    ADD  $3,  $1,  $2
   0x000c:  00 22 20 22    SUB  $4,  $1,  $2
   0x0010:  00 22 28 24    AND  $5,  $1,  $2
   0x0014:  00 22 30 25    OR   $6,  $1,  $2
   0x0018:  00 22 38 26    XOR  $7,  $1,  $2
   0x001c:  00 22 40 2A    SLT  $8,  $1,  $2
   0x0020:  AC 01 00 08    SW   $1,  8($0)
   0x0024:  AC 02 00 04    SW   $2,  4($0)
   0x0028:  10 05 00 02    BEQ  $0,  $5,  0x2  // taken to 0x34
   0x002c:  AC 01 00 00    SW   $1,  0($0)
   0x0030:  08 00 00 00    J    0              // back to start
   0x0034:  08 00 00 0F    J    0x15           // jumps to 0x3c
   0x0038:  AC 01 00 00    SW   $1,  0($0)
   0x003c:  8C 00 00 00    LW   $0,  0($0)
   0x0040:  00 00 00 00    NOP
   0x0044:  08 00 00 00    J    0              // back to start
   ```

3. 系统的详细设计（包括系统功能详述，设计方法，Verilog语言实现等）

   对整个系统来说，上文提到，每个模块每个周期按顺序更新，由 `StageController` 控制每个模块的 `EN` ，其实现如下：

   ```verilog
   module StageController(
           input clk ,
           input rst ,
   
           output reg bFetchStage,
           output reg bDecodeStage,
           output reg bExecuteStage,
           output reg bMemoryStage,
           output reg bWriteBackStage
       );
   
       (*mark_debug = "true"*) reg [2: 0] counter;
   
       // counter 在 rst 为 0 时 = 0，否则按 1 2 3 4 5 循环
   
       always @(posedge clk) begin
           if(!rst) counter <= {3{1'b0}};
           else begin 
               if(counter == 5) counter <= 1;
               else counter = counter + 1;
           end
       end
   
       always @(negedge clk) begin
           bFetchStage <= counter == 1;
           bDecodeStage <= counter == 2;
           bExecuteStage <= counter == 3;
           bMemoryStage <= counter == 4;
           bWriteBackStage <= counter == 5;
       end
   
   
   endmodule
   ```

4. 系统的功能测试（包括系统整体功能的测试方案、测试过程和测试波形等）

   对整体进行系统测试，选用代码框架中的 `cpu_top.sv` 和 `cpu_tb.v` 进行，代码具体实现分别为：

   + `cpu_tb.v`：

     ```verilog
     module cpu_tb(
     
         );
     
         //-----Clock and reset signal simulation-----
         //signals
         reg clk;
         reg resetn;
         //simulation
         initial begin
             clk    = 1'b0;
             resetn = 1'b0;
             #2000;
             resetn = 1'b1;
             #700;
             resetn = 1'b0;
             #3000;
             resetn = 1'b1;
     
         end
     
         always #5 clk = ~clk;
     
         cpu_top U_cpu_top(
                 .clk     (clk     ),
                 .reset   (resetn  )
             );
     
         //-----monitor test-----
         initial
         begin
             $timeformat(-9,0," ns",10);
             while(!resetn) #5;
             $display("==============================================================");
             $display("Test begin!");
             #10000;
         end
     
     endmodule
     ```

   + `cpu_top.sv`

     ```verilog
     module cpu_top(
         (*mark_debug = "true"*) input         clk     ,
         (*mark_debug = "true"*) input         reset   ,
         (*mark_debug = "true"*) output [15 :0] leds
     );
     
         // Initialize trace file registers
         reg [71:0] trace_data [`TEST_COUNT - 1 :0];
     
         initial begin
             $readmemh(`TRACE_FILE_PATH , trace_data);
         end
     
         // Instantiate the cpu
         (*mark_debug = "true"*) wire [31:0] debug_wb_pc;
         (*mark_debug = "true"*) wire        debug_wb_rf_wen;
         (*mark_debug = "true"*) wire [4 :0] debug_wb_rf_addr;
         (*mark_debug = "true"*) wire [31:0] debug_wb_rf_wdata;
     
         CPU U_cpu(
             .clk               (clk               ),
             .resetn            (reset             ),
             .debug_wb_pc       (debug_wb_pc       ),
             .debug_wb_rf_wen   (debug_wb_rf_wen   ),
             .debug_wb_rf_addr  (debug_wb_rf_addr  ),
             .debug_wb_rf_wdata (debug_wb_rf_wdata )
         );
     
         // Compare the cpu data to the reference data
         (*mark_debug = "true"*) reg         test_err;
         (*mark_debug = "true"*) reg         test_pass;
         (*mark_debug = "true"*) reg [31:0] test_counter;
         (*mark_debug = "true"*) reg [15 :0] leds_reg;
     
         (*mark_debug = "true"*) wire [31:0] ref_wb_pc       = trace_data[test_counter][71:40];
         (*mark_debug = "true"*) wire [4 :0] ref_wb_rf_addr  = trace_data[test_counter][36:32];
         (*mark_debug = "true"*) wire [31:0] ref_wb_rf_wdata = trace_data[test_counter][31: 0];
         
         assign leds = leds_reg;
     
         always @ (posedge clk) begin
             if (!reset) begin
                 leds_reg     <= 16'hffff;
                 test_err     <= 1'b0;
                 test_pass    <= 1'b0;
                 test_counter <= 0;
             end
             else if (debug_wb_pc == 32'h00000040 && !test_err) begin
                     $display("    ----PASS!!!");
                     $display("Test end!");
                     $display("==============================================================");
                     test_pass <= 1'b1;
                     leds_reg  <= 16'h0000;
                     #5;
                     $finish;
             end
             else if (debug_wb_rf_wen && |debug_wb_rf_addr && !test_pass) begin
                 if (debug_wb_pc != ref_wb_pc || debug_wb_rf_addr != ref_wb_rf_addr || debug_wb_rf_wdata != ref_wb_rf_wdata) begin
                 $display("--------------------------------------------------------------");
                     $display("Error!!!");
                     $display("    test_counter : %2d", test_counter);
                     $display("    Reference : PC = 0x%8h, write back reg number = %2d, write back data = 0x%8h", ref_wb_pc, ref_wb_rf_addr, ref_wb_rf_wdata);
                     $display("    Error     : PC = 0x%8h, write back reg number = %2d, write back data = 0x%8h", debug_wb_pc, debug_wb_rf_addr, debug_wb_rf_wdata);
                     $display("--------------------------------------------------------------");
                     $display("==============================================================");
                     test_err     <= 1'b1;
                     #5;
                     $finish;
                 end
                 else begin
                     $display("--------------------------------------------------------------");
                     $display("Pass test_counter %2d !!!", test_counter);
                     $display("    Reference : PC = 0x%8h, write back reg number = %2d, write back data = 0x%8h", ref_wb_pc, ref_wb_rf_addr, ref_wb_rf_wdata);
                     $display("    Value     : PC = 0x%8h, write back reg number = %2d, write back data = 0x%8h", debug_wb_pc, debug_wb_rf_addr, debug_wb_rf_wdata);
                     $display("--------------------------------------------------------------");
                     $display("==============================================================");
                     test_counter <= test_counter + 1;
                 end
             end
         end
     
     endmodule
     ```

   为了测试方便，此处在代码框架的基础上增加输出已通过的指令数，即输出 `test_counter` 的值，便于测试和 debug 的进行。

## 五、测试结果及实验分析

1. 处理器仿真测试波形（整体）

2. FPGA编程下载
   - 编写处理器功能测试程序，包括助记符和二进制代码。
   - 上板波形记录与解释

## 六、实验总结

本次实验通过设计并实现一个支持 MIPS 指令集子集的处理器，深入了解了非流水处理器设计与实现的过程，体会处理器设计是精妙和现代 EDA 的强大之处。对理解计算机底层设计与架构有很大帮助。

## 附录

【备用表格】

以上表格不够可加页。

模块名称及功能：

| 信号名 | 位数 | 方向 | 来源/去向 | 意义 |
| ------ | ---- | ---- | --------- | ---- |
|        |      |      |           |      |
|        |      |      |           |      |
|        |      |      |           |      |
|        |      |      |           |      |
|        |      |      |           |      |
|        |      |      |           |      |
|        |      |      |           |      |
|        |      |      |           |      |
|        |      |      |           |      |
|        |      |      |           |      |
|        |      |      |           |      |
|        |      |      |           |      |
