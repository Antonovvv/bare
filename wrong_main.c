#include "wrong_example.h"
#include <stdio.h>

int main() {
    printf("=== 错误示例：undefined symbol ===\n");
    
    // 尝试使用未定义的变量会导致链接错误
    printf("String: %s\n", undefined_string);  // undefined symbol错误
    printf("Variable: %d\n", undefined_variable);  // undefined symbol错误
    
    return 0;
}