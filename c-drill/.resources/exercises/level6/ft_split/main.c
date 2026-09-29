#include <stdio.h>
char **ft_split(char *str);
int main(int ac,char**av){ if(ac<2)return 1; char **r=ft_split(av[1]); int i=0; while(r&&r[i]){ printf("%s\n",r[i]); i++; } return 0; }
