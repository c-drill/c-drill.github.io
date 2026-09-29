int ft_atoi(const char *str){
    int i=0,sign=1; long res=0;
    while(str[i]==32||(str[i]>=9&&str[i]<=13)) i++;
    if(str[i]==43||str[i]==45){ if(str[i]==45)sign=-1; i++; }
    while(str[i]>=48&&str[i]<=57){ res=res*10+(str[i]-48); i++; }
    return (int)(res*sign);
}
