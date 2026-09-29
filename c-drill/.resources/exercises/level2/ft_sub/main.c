#include <stdlib.h>
#include <stdio.h>
void ft_sub(int *ptr);
int main(int ac,char**av){if(ac<2)return 1;int x=atoi(av[1]);ft_sub(&x);printf("%d\n",x);return 0;}
