#include <stdlib.h>
char *ft_itoa(int nbr){
    long n=nbr; int neg=(n<0); if(neg)n=-n;
    int len=1; long t=n; while(t>=10){ len++; t/=10; }
    if(neg)len++;
    char *s=malloc(len+1); s[len]=0; int i=len-1;
    if(n==0)s[i--]=48;
    while(n>0){ s[i--]=n%10+48; n/=10; }
    if(neg)s[0]=45;
    return s;
}
