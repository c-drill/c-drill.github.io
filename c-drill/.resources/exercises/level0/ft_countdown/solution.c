#include <unistd.h>
int main(void){ char c=57; while(c>=48){ write(1,&c,1); c--; } write(1,"\n",1); return 0; }
