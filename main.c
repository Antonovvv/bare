#include "example.h"
#include <stdio.h>

int main() {
    printf("=== 正确使用静态库的示例 ===\n");
    
    // 使用extern字符串变量
    printf("直接访问字符串: %s\n", my_string);
    printf("另一个字符串: %s\n", another_string);
    
    // 调用库函数
    print_strings();
    
    return 0;
}