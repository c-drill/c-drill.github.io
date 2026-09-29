#include <unistd.h>
int in(char*s,char c){int i=0;while(s[i]){if(s[i]==c)return 1;i++;}return 0;}
int main(int ac,char**av){ if(ac!=3){write(1,"\n",1);return 0;} char*a=av[1];char seen[256]={0};int i=0; while(a[i]){ if(in(av[2],a[i])&&!seen[(unsigned char)a[i]]){write(1,&a[i],1);seen[(unsigned char)a[i]]=1;} i++; } write(1,"\n",1); return 0; }
