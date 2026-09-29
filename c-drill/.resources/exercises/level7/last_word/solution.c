#include <unistd.h>
int main(int ac,char**av){ if(ac==2){ char*s=av[1]; int i=0,st=-1,len=0; while(s[i]){ if(s[i]!=32&&s[i]!=9&&(i==0||s[i-1]==32||s[i-1]==9))st=i; i++; } if(st>=0){ while(s[st+len]&&s[st+len]!=32&&s[st+len]!=9)len++; write(1,s+st,len); } } write(1,"\n",1); return 0; }
