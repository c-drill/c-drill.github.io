#include <unistd.h>
int main(int ac,char**av){ if(ac!=3){write(1,"\n",1);return 0;} char seen[256]={0}; for(int a=1;a<=2;a++){ char*s=av[a];int i=0; while(s[i]){ if(!seen[(unsigned char)s[i]]){write(1,&s[i],1);seen[(unsigned char)s[i]]=1;} i++; } } write(1,"\n",1); return 0; }
