#include <unistd.h>
int main(int ac,char**av){ if(ac==2){ char*s=av[1]; int i=0; while(s[i]){ char c=s[i]; if(c>=97&&c<=122)c=122-(c-97); else if(c>=65&&c<=90)c=90-(c-65); write(1,&c,1); i++; } } write(1,"\n",1); return 0; }
