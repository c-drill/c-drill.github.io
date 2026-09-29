#include <unistd.h>
void ft_print_numbers(void){ char c=48; while(c<=57){ write(1,&c,1); c++; } }
