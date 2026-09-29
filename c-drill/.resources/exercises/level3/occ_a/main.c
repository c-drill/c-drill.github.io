#include <stdio.h>
int occ_a(char *str);
int main(int ac,char**av){if(ac<2)return 1;printf("%d\n",occ_a(av[1]));return 0;}
