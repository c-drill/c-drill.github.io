#include <stdlib.h>
#include <stdio.h>
void ft_swap(int *a,int *b);
int main(int ac,char**av){if(ac<3)return 1;int a=atoi(av[1]),b=atoi(av[2]);ft_swap(&a,&b);printf("%d %d\n",a,b);return 0;}
