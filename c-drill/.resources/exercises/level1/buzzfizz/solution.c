#include <unistd.h>
static void pn(int n){char c;if(n>=10)pn(n/10);c=n%10+48;write(1,&c,1);}
int main(void){int i=1;while(i<=100){if(i%15==0)write(1,"buzzfizz",8);else if(i%3==0)write(1,"buzz",4);else if(i%5==0)write(1,"fizz",4);else pn(i);write(1,"\n",1);i++;}return 0;}
