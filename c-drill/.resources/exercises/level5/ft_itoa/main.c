#include <stdlib.h>
#include <stdio.h>
char *ft_itoa(int nbr);
int main(int ac,char**av){if(ac<2)return 1;printf("%s\n",ft_itoa(atoi(av[1])));return 0;}
