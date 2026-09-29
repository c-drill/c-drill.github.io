#include <unistd.h>
int main(int ac,char**av){ if(ac!=2){write(1,"\n",1);return 0;} char *s=av[1]; int i=0; while(s[i]){ int p=i+1; char o; if(p%3==0)o=53; else if(p%5==0)o=51; else o=s[i]; write(1,&o,1); i++; } write(1,"\n",1); return 0; }
