#include <stdio.h>
int occ_z(char *str);
int main(int ac,char**av){if(ac<2)return 1;printf("%d\n",occ_z(av[1]));return 0;}
