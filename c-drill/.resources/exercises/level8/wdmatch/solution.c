#include <unistd.h>
int main(int ac,char**av){ if(ac!=3){write(1,"\n",1);return 0;} char*a=av[1];char*b=av[2];int i=0,j=0; while(a[i]){ while(b[j]&&b[j]!=a[i])j++; if(!b[j]){write(1,"\n",1);return 0;} i++;j++; } int k=0; while(a[k]){write(1,&a[k],1);k++;} write(1,"\n",1); return 0; }
