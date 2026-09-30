#include <unistd.h>
int main(int ac,char**av){ if(ac==2){ char*s=av[1]; int i=0; while(s[i]){ int n=1; if(s[i]>='a'&&s[i]<='z')n=s[i]-'a'+1; else if(s[i]>='A'&&s[i]<='Z')n=s[i]-'A'+1; while(n--)write(1,&s[i],1); i++; } } write(1,"\n",1); return 0; }
