# AGU单元说明

本质上是一个控制循环的模块,内部主要有i,k_0,k_1,j,4个计数器,除待机状态外,有i_loop,k_0_loop,wait,k_1_loop,j_loop5个装态,wait状态在k_0循环和k_1循环之间,用于等待矩阵乘法时的shake

产生访问ram的地址,以及进行一些数据上的处理

共有4个工作模式,工作模式决定了在不同状态干的事,循环边界通过指令译码控制:

1. **mode0**: 进行矩阵乘法

地址上

```python
for i in range(1344):
    for k_0 in range(1344):
        for k_1 in range(4):
            A_bias = k_1
            for j in range(1344):
                Print()
                B_addr += 1
                C_addr += 1
            if k_0 != 1 & k_1 != 3:
                C_addr = temp_C_addr
        A_addr += 1
    temp_C_addr = C_addr
    B_addr = B_addr_start
```

2. **mode1**: 转置存储矩阵(S^T)

```python
temp_C_addr = C_addr_start
# k_1作为64位数据的偏置
for k_1 in range(8):
    for j in range(1344):
        C_addr += 1
    C_addr = temp_C_addr
```

由于S一行恰好8个,因此地址一轮循环后只需进行复位,然后进行读64位,填8位,写64位的过程

3. **mode2**:顺序存储S',E,E',E''

```python
for i in range(1344):
    for k_0 in range(8):
        for k_1 in range(8):
            bias = k_1
        C_addr += 1
```

与S相反,这些矩阵会先每个地址64位数据偏置的计数,再是地址的计数,内部设有一个buffer(或者移位寄存器),64位满了才会存储

4. **mode3** : encode和decode

循环上就是一个生成矩阵地址的过程

使用刚才的mode2的buffer进行操作



# 指令设计

挤压过程中的地址由AGU单元提供

## shake指令

1. **absorb**

0(1位) + func(2位) +addr(12位)+ round(10位) + 安全等级(1位)

2. **absorbload**

0(1位) + func(2位) + addr(12位) + datalength(10位) + 安全等级(1位) + 是否吸收(1位)

3. **squeeze**

0(1位) + func(2位) +mac_index(4位) + 是否转置(1位) + 是否更新AGU配置(1位)+ round(10位) + 安全等级(1位) + 是否采样(1位)

4. **squeezestore**

0(1位) + func(2位) + mac_index(4位) + 是否转置(1位) + 是否更新AGU配置(1位) + datalength(10位) + 安全等级 + 是否挤压(1位) + 是否采样(1位)

## MAC指令

1. **matmul**

1(1位) + func(2位) + mac_index0(4位) + mac_index1(4位) + mac_index2(4位)

2. **matadd**
3. **encode**
4. **decode**

![image-20241114164719277](C:\Users\Lenovo\AppData\Roaming\Typora\typora-user-images\image-20241114164719277.png)





# Key generation

![image-20241114162444006](C:\Users\Lenovo\AppData\Roaming\Typora\typora-user-images\image-20241114162444006.png)

1. 

```
absorbload z(地址) 数据长度2(一次吸收64bit) 安全等级 吸收 
squeezestore seedA(索引) 不转置 更新AGU 8(一次输出16bit) 安全等级 挤压 不采样
AGU:seedA译码为mode2 无j循环，k_1上限为4，k_0为2,i循环为1(0?)  // 共128bit
```

2. 

```
absorbload seedSE(地址) 数据长度8 安全等级 吸收
squeeze S^T 转置 更新AGU 159(轮数) 安全等级 采样
AGU: S译码为mode1 j上限1344,k_1上限为
```

```python
#生成S  
absorbload seed_SE 8 Level Ex=True  
squeeze S Trans=True Addr_update=True 159 安全等级 Sample=True  
squeezestore S Trans=True Addr_update=False 数据长度 安全等级 Sample=True Ex=True  
#生成E  
squeezestore E Trans=False Addr_update=True 数据长度 安全等级 Sample=True Ex=False  
squeeze E Trans=False Addr_update=False 159 安全等级 Sample=True  
squeezestore E Trans=False Addr_update=False 数据长度 安全等级 Sample=True Ex=True
```

