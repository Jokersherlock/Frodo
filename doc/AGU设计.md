# 矩阵乘法

```C
int A_addr_start,B_addr_start,C_addr_start;//输入
int A,B[4],C[4]; //矩阵乘法的输入
int A_addr=A_addr_start,B_addr=B_addr_start,C_addr=C_addr_start;
int temp_C_addr = C_addr_start;
for(int i=0;i<n;i++){
    for(int k_0;k_0<l/4;k_0++){
        for(int k_1=0;k_1<4;k++){
            for(int j=0;j<m/4;j++){
                A = mem[A_addr][k_1];
                B = mem[B_addr];
                C = mem[C_addr];
                B_addr = B_addr + 1;
                C_addr = C_addr + 1;
            }
            C_addr = tem
        }
    }
}
```

mode0 矩阵乘法

mode1 S^T

mode2 E,E',E'',S'

mode3 decode/e
