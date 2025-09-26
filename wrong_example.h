#ifndef WRONG_EXAMPLE_H
#define WRONG_EXAMPLE_H

// 只声明extern变量，但没有对应的定义
extern const char* undefined_string;
extern int undefined_variable;

void print_undefined(void);

#endif // WRONG_EXAMPLE_H