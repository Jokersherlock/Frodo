import random

def generate_matrix(rows, cols, bit_mode):
    """
    生成一个随机矩阵
    :param rows: 矩阵的行数
    :param cols: 矩阵的列数
    :param bit_mode: 数字范围模式 ('8bit' 或 '16bit')
    :return: 生成的矩阵（二维列表）
    """
    # 根据bit_mode选择整数范围
    if bit_mode == '8bit':
        min_val, max_val = -128, 127  # 8位有符号整数范围
    elif bit_mode == '16bit':
        min_val, max_val = -32768, 32767  # 16位有符号整数范围
    else:
        raise ValueError("Invalid bit_mode. Choose '8bit' or '16bit'.")
    
    # 生成随机矩阵
    matrix = [[random.randint(min_val, max_val) for _ in range(cols)] for _ in range(rows)]
    return matrix

def save_matrix_to_file(matrix, filename):
    """
    将矩阵保存到文件
    :param matrix: 生成的矩阵（二维列表）
    :param filename: 文件名
    """
    with open(filename, 'w') as f:
        for row in matrix:
            f.write(" ".join(map(str, row)) + "\n")

def main():
    # 输入矩阵的大小和位模式
    rows = int(input("请输入矩阵的行数："))
    cols = int(input("请输入矩阵的列数："))
    bit_mode = input("请选择数字范围模式 ('8bit' 或 '16bit'): ")

    # 生成矩阵
    matrix = generate_matrix(rows, cols, bit_mode)

    # 保存矩阵到文件
    filename = 'matrix.txt'
    save_matrix_to_file(matrix, filename)

    print(f"矩阵已保存到 {filename}")

# if __name__ == '__main__':
#     main()
