def read_matrix_from_file(file_path):
    """
    读取txt文件中的矩阵，每个元素为十进制有符号整数，返回矩阵数据。
    """
    matrix = []
    with open(file_path, 'r') as file:
        for line in file:
            # 每行的数字由空格分隔
            row = list(map(int, line.split()))
            matrix.append(row)
    return matrix

def sign_extend_16bit(val):
    """
    对16位有符号整数进行符号扩展为64位，但扩展的结果只保留16位有效数据，其他部分为零。
    """
    # 这里仍然使用补码符号扩展，但我们只将其保留在对应的16位内
    if val < 0:
        return (1 << 16) + val  # 使用补码方式扩展
    return val

def sign_extend_8bit(val):
    """
    对8位有符号整数进行符号扩展为64位，但扩展的结果只保留8位有效数据，其他部分为零。
    """
    # 这里仍然使用补码符号扩展，但我们只将其保留在对应的8位内
    if val < 0:
        return (1 << 8) + val  # 使用补码方式扩展
    return val

def generate_ram_file(matrix, mode, output_file):
    """
    根据给定模式将矩阵数据写入到RAM文件中。
    
    参数：
    - matrix: 读取的矩阵数据
    - mode: 模式 1 或 模式 2
    - output_file: 生成的输出文件路径
    """
    with open(output_file, 'w') as file:
        # 根据不同的模式处理矩阵
        if mode == 1:
            # 每个数字是16位，4个16位数字存储在一个64位地址中
            for row in matrix:
                for i in range(0, len(row), 4):
                    # 取4个16位数，拼接成64位数据
                    words = row[i:i+4]
                    # 确保有4个数字，不足时补零
                    words += [0] * (4 - len(words))
                    
                    # 将每个16位数字符号扩展并拼接成64位
                    value = 0
                    for j in range(4):
                        # 对每个16位数字进行符号扩展
                        extended_val = sign_extend_16bit(words[3 - j])  # 反转顺序
                        # 将符号扩展后的数字放到64位的对应位置
                        value |= extended_val << (48 - j * 16)

                    # 写入64位十六进制数据
                    file.write(f'{value:016x}\n')
        
        elif mode == 2:
            # 每个数字是8位，8个8位数字存储在一个64位地址中
            for row in matrix:
                for i in range(0, len(row), 8):
                    # 取8个8位数，拼接成64位数据
                    bytes_ = row[i:i+8]
                    # 确保有8个数字，不足时补零
                    bytes_ += [0] * (8 - len(bytes_))
                    
                    # 将每个8位数字符号扩展并拼接成64位
                    value = 0
                    for j in range(8):
                        # 对每个8位数字进行符号扩展
                        extended_val = sign_extend_8bit(bytes_[7 - j])  # 反转顺序
                        # 将符号扩展后的数字放到64位的对应位置
                        value |= extended_val << (56 - j * 8)
                    
                    # 写入64位十六进制数据
                    file.write(f'{value:016x}\n')

# 示例调用
# input_file = 'F:\project\Frodo\sim\RAM\data\A.txt'  # 输入txt文件路径
# output_file = 'F:\project\Frodo\sim\RAM\data\B.hex'  # 输出文件路径
# mode = 1  # 设置模式：1（每个数字16位，4个数字存一个64位地址）

# # 读取矩阵并生成RAM文件
# matrix = read_matrix_from_file(input_file)
# generate_ram_file(matrix, mode, output_file)

# print(f"生成的RAM文件: {output_file}")
