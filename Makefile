# Makefile for static library example

CC = gcc
CFLAGS = -Wall -Wextra -std=c99
AR = ar
ARFLAGS = rcs

# 目标文件
OBJS = example.o
LIBRARY = libexample.a
MAIN_TARGET = main

# 默认目标
all: $(MAIN_TARGET)

# 编译静态库
$(LIBRARY): $(OBJS)
	$(AR) $(ARFLAGS) $@ $^

# 编译目标文件
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# 编译主程序
$(MAIN_TARGET): main.o $(LIBRARY)
	$(CC) main.o -L. -lexample -o $@

# 清理
clean:
	rm -f *.o $(LIBRARY) $(MAIN_TARGET)

# 运行程序
run: $(MAIN_TARGET)
	./$(MAIN_TARGET)

# 显示符号表（用于调试）
symbols: $(LIBRARY)
	nm $(LIBRARY)

.PHONY: all clean run symbols