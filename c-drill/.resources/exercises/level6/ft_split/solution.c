#include <stdlib.h>
static int is_sep(char c){ return c==32||c==9||c==10; }
char **ft_split(char *str){
    int i=0,n=0;
    while(str[i]){ while(str[i]&&is_sep(str[i]))i++; if(str[i])n++; while(str[i]&&!is_sep(str[i]))i++; }
    char **res=malloc(sizeof(char*)*(n+1));
    int w=0; i=0;
    while(str[i]){
        while(str[i]&&is_sep(str[i]))i++;
        int start=i;
        while(str[i]&&!is_sep(str[i]))i++;
        if(i>start){ int len=i-start; char *word=malloc(len+1); int k=0; while(k<len){word[k]=str[start+k];k++;} word[len]=0; res[w++]=word; }
    }
    res[w]=0;
    return res;
}
