#include <stdlib.h>
int *ft_rrange(int start,int end){ int len=(start<=end?end-start:start-end)+1; int *a=malloc(sizeof(int)*len); int i=0; if(start<=end){ int v=end; while(i<len){a[i]=v;v--;i++;} } else { int v=end; while(i<len){a[i]=v;v++;i++;} } return a; }
