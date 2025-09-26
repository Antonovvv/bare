# C/C++ 静态库链接问题解决方案

## 问题描述
当头文件使用`extern`声明字符串变量，另一个文件引用并链接静态库时出现"undefined symbol"错误。

## 常见原因和解决方案

### 1. 头文件声明了extern变量，但源文件没有定义

**错误示例：**
```c
// wrong_example.h
extern const char* undefined_string;

// wrong_example.c - 没有定义undefined_string
void some_function() {
    // 使用undefined_string会导致链接错误
}
```

**正确做法：**
```c
// example.h
extern const char* my_string;

// example.c
const char* my_string = "Hello World";  // 必须定义
```

### 2. 静态库编译问题

确保静态库正确编译：
```bash
# 编译目标文件
gcc -c example.c -o example.o

# 创建静态库
ar rcs libexample.a example.o
```

### 3. 链接顺序问题

链接时静态库的顺序很重要：
```bash
# 正确：主程序在前，静态库在后
gcc main.o -L. -lexample -o main

# 错误：静态库在前
gcc -L. -lexample main.o -o main
```

### 4. 符号可见性问题

使用`nm`命令检查静态库中的符号：
```bash
nm libexample.a
```

## 演示项目

### 正确示例
- `example.h` - 头文件声明extern变量
- `example.c` - 源文件定义变量
- `main.c` - 主程序使用变量
- `Makefile` - 正确的编译和链接

### 错误示例
- `wrong_example.h` - 只声明不定义
- `wrong_example.c` - 缺少定义
- `wrong_main.c` - 尝试使用未定义变量

## 编译和运行

```bash
# 编译正确示例
make

# 运行程序
make run

# 查看静态库符号
make symbols

# 清理
make clean
```

## 调试技巧

1. **检查符号表：**
   ```bash
   nm libexample.a
   objdump -t libexample.a
   ```

2. **检查链接器输出：**
   ```bash
   gcc -v main.o -L. -lexample -o main
   ```

3. **使用ldd检查依赖：**
   ```bash
   ldd main
   ```

## 常见错误信息

- `undefined reference to 'symbol_name'` - 符号未定义
- `undefined symbol: symbol_name` - 符号未找到
- `multiple definition of 'symbol_name'` - 符号重复定义