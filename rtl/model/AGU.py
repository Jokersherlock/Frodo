A_addr_start = 0
B_addr_start = 0
C_addr_start = 0 

A_addr = A_addr_start
A_bias = 0
B_addr = B_addr_start       
C_addr = C_addr_start
temp_C_addr = C_addr_start
Cycle = 0


def Print():
    global Cycle
    print(f"cycle: {Cycle}, A_addr: {A_addr}, A_bias: {A_bias}, B_addr: {B_addr}, C_addr: {C_addr}")
    Cycle += 1

# 矩阵乘法
for i in range(8):
    for k_0 in range(2):
        for k_1 in range(4):
            import pdb; pdb.set_trace()
            A_bias = k_1
            for j in range(8):
                Print()
                B_addr += 1
                C_addr += 1
            if k_0 != 1 & k_1 != 3:
                C_addr = temp_C_addr
        A_addr += 1
    temp_C_addr = C_addr
    B_addr = B_addr_start


# S^T存储
temp_C_addr = C_addr_start
# k_1作为64位数据的偏置
for k_1 in range(8):
    for j in range(1344):
        C_addr += 1
    C_addr = temp_C_addr

# S',E,E',E''存储

for i in range(1344):
    for k_0 in range(8):
        for k_1 in range(8):
            bias = k_1
        C_addr += 1
