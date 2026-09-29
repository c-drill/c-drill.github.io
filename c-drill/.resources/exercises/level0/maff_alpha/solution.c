#include <unistd.h>
int main(void){ int i=0; while(i<26){ char x=((i+1)%2==0)?(char)(97+i-32):(char)(97+i); write(1,&x,1); i++; } write(1,"\n",1); return 0; }
