#include <unistd.h>
static int myatoi(char*s){int i=0,sg=1;long r=0;while(s[i]==32||(s[i]>=9&&s[i]<=13))i++;if(s[i]==43||s[i]==45){if(s[i]==45)sg=-1;i++;}while(s[i]>=48&&s[i]<=57){r=r*10+(s[i]-48);i++;}return (int)(r*sg);}
static void pn(int n){char c;if(n==-2147483648){write(1,"-2147483648",11);return;}if(n<0){write(1,"-",1);n=-n;}if(n>=10)pn(n/10);c=n%10+48;write(1,&c,1);}
int main(int ac,char**av){ for(int i=1;i<ac;i++){ int n=myatoi(av[i]); if(n%2!=0){ pn(n); write(1,"\n",1); } } return 0; }
