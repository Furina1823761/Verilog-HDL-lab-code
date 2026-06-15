`ifndef AI_parameters
`define AI_parameters

// 共享参数
`define DATA_WIDTH  8       //数据位宽
`define SUM_WIDTH   18      //累加位宽，需根据输入矩阵大小进行调整，确保结果不发生溢出

// 脉动阵列参数
`define PE_ROWS     5       //输出矩阵的行数（矩阵A的行数）     
`define PE_COLS     5       //输出矩阵的列数（矩阵B的列数），同时也是输入矩阵A的列数和输入矩阵B的行数
`define ARRAY_SIZE  5       //矩阵AB的内维度，移位寄存器的最大深度

// 广播架构参数 GPU Broadcast
`define BC_PE_ROWS     5    //输出矩阵行数 矩阵A的行数）
`define BC_PE_COLS     5    //输出矩阵列数 矩阵B的列数）
`define BC_INNER_DIM   5    //内维度

`endif