#include "example.h"
#include <stdio.h>

// 定义extern字符串变量
const char* my_string = "Hello from static library!";
const char* another_string = "This is another string";

// 实现函数
void print_strings(void) {
    printf("String 1: %s\n", my_string);
    printf("String 2: %s\n", another_string);
}