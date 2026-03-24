module decoder_2_4(
    input           A0  ,
    input           A1  ,
    input           E   ,
    output  [3:0]   Y               //输出端，共有四项输出
);

    not n1(nE, E), n2(nA0, A0), n3(nA1, A1); //分别对使能端和输入端
    nand nd1(Y[3], nE, A0, A1), nd2(Y[2], nE, nA0, A1), nd3(Y[1], nE, A0, nA1), nd4(Y[0], nE, nA0, nA1);
    
endmodule