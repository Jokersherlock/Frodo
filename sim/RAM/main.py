from generate import generate_matrix
from generate import save_matrix_to_file
from transform import generate_ram_file
from transform import read_matrix_from_file
import numpy as np

def generate_ram_data(rows,cols,bit_mode,name):
    filename = 'F:/project/Frodo/sim/RAM/data/' + name
    matrix = generate_matrix(rows,cols,bit_mode)
    save_matrix_to_file(matrix,filename+'.txt')
    print(f"矩阵{name}已保存到{filename}'.txt")
    if bit_mode == '16bit':
        mode = 1
    else:
        mode = 2
    matrix = read_matrix_from_file(filename+'.txt')
    generate_ram_file(matrix,mode,filename+'.hex')
    print(f"生成的RAM文件:{filename}.hex")
    
    return np.array(matrix)


# 左矩阵生成样例,16x8,16位

A = generate_ram_data(16,8,'16bit','A')

# 右矩阵生成样例,8x8,16位

B = generate_ram_data(8,8,'16bit','B')

# 加矩阵生成样例.,8x8,16位
C = generate_ram_data(8,8,'16bit','C')



