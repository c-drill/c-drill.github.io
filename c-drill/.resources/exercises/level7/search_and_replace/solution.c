#include <unistd.h>
int slen(char*s){int i=0;while(s[i])i++;return i;}
int main(int ac,char**av){ if(ac!=4||slen(av[2])!=1||slen(av[3])!=1){write(1,"\n",1);return 0;} char*s=av[1];char f=av[2][0],r=av[3][0];int i=0; while(s[i]){ char c=(s[i]==f)?r:s[i]; write(1,&c,1); i++; } write(1,"\n",1); return 0; }
