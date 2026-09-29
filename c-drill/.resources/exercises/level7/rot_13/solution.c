#include <unistd.h>
int main(int ac,char**av){ if(ac!=2){write(1,"\n",1);return 0;} char *s=av[1]; int i=0; while(s[i]){ char c=s[i]; if(c>=65&&c<=90)c=(c-65+13)%26+65; else if(c>=97&&c<=122)c=(c-97+13)%26+97; write(1,&c,1); i++; } write(1,"\n",1); return 0; }
