#include <stdlib.h>
#include <stdio.h>
void ft_add_n(int *ptr,int n);
int main(int ac,char**av){if(ac<3)return 1;int x=atoi(av[1]);ft_add_n(&x,atoi(av[2]));printf("%d\n",x);return 0;}
