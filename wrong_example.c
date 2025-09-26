#include "wrong_example.h"
#include <stdio.h>

// 注意：这里没有定义undefined_string和undefined_variable
// 只定义了一个函数

void print_undefined(void) {
    // 尝试使用未定义的变量会导致链接错误
    printf("This function tries to use undefined variables\n");
    // printf("String: %s\n", undefined_string);  // 这会导致undefined symbol错误
    // printf("Variable: %d\n", undefined_variable);  // 这也会导致undefined symbol错误
}