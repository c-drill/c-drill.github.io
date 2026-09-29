#include <stdio.h>
#include <stdlib.h>
int *ft_range(int start,int end);
int main(int ac,char**av){ if(ac<3)return 1; int s=atoi(av[1]),e=atoi(av[2]); int *r=ft_range(s,e); int len=(s<=e?e-s:s-e)+1; for(int i=0;i<len;i++)printf("%d\n",r[i]); return 0; }
