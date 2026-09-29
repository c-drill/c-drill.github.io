#include <unistd.h>
int main(int ac,char**av){ if(ac==2){ char*s=av[1]; int i=0; while(s[i]==32||s[i]==9)i++; while(s[i]&&s[i]!=32&&s[i]!=9){write(1,&s[i],1);i++;} } write(1,"\n",1); return 0; }
