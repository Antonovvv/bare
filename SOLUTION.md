# 解决 "undefined symbol" 问题的完整方案

## 问题分析

你遇到的"undefined symbol"错误是C/C++静态库链接中的常见问题。从演示中可以看到：

### 错误信息示例：
```
/usr/bin/ld: wrong_main.o: in function `main':
wrong_main.c:(.text+0x1a): undefined reference to `undefined_string'
/usr/bin/ld: wrong_main.c:(.text+0x37): undefined reference to `undefined_variable'
```

## 根本原因

**头文件声明了`extern`变量，但对应的源文件没有定义这些变量。**

## 解决方案

### 1. 确保变量定义存在

**头文件 (example.h):**
```c
extern const char* my_string;
extern const char* another_string;
```

**源文件 (example.c) - 必须定义：**
```c
const char* my_string = "Hello from static library!";
const char* another_string = "This is another string";
```

### 2. 正确的编译流程

```bash
# 1. 编译源文件为目标文件
gcc -c example.c -o example.o

# 2. 创建静态库
ar rcs libexample.a example.o

# 3. 编译主程序
gcc -c main.c -o main.o

# 4. 链接（注意顺序：主程序在前，静态库在后）
gcc main.o -L. -lexample -o main
```

### 3. 验证符号存在

使用`nm`命令检查静态库中的符号：
```bash
nm libexample.a
```

输出应该显示你的变量：
```
example.o:
0000000000000008 D another_string
0000000000000000 D my_string
```

## 常见错误和解决方法

### 错误1：只声明不定义
```c
// 错误：只有声明
extern const char* my_string;  // 在头文件中

// 正确：必须有定义
const char* my_string = "Hello";  // 在源文件中
```

### 错误2：链接顺序错误
```bash
# 错误
gcc -L. -lexample main.o -o main

# 正确
gcc main.o -L. -lexample -o main
```

### 错误3：静态库没有正确编译
确保使用`ar`命令创建静态库，而不是直接链接`.o`文件。

## 调试技巧

1. **检查符号表：**
   ```bash
   nm libexample.a
   objdump -t libexample.a
   ```

2. **详细链接信息：**
   ```bash
   gcc -v main.o -L. -lexample -o main
   ```

3. **检查目标文件：**
   ```bash
   nm main.o
   ```

## 完整的工作示例

项目结构：
```
workspace/
├── example.h          # 头文件声明extern变量
├── example.c          # 源文件定义变量
├── main.c             # 主程序
├── Makefile           # 编译脚本
└── README.md          # 说明文档
```

编译和运行：
```bash
make clean && make && make run
```

## 总结

"undefined symbol"错误的根本原因是**声明了extern变量但没有定义**。解决方法是确保在源文件中提供变量的实际定义，并正确编译和链接静态库。