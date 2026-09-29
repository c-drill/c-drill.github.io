int	ft_atoi(const char *str)
{
	long	r;
	int		sign;

	r = 0;
	sign = 1;
	while (*str == ' ' || (*str >= 9 && *str <= 13))
		str++;
	if (*str == '-' || *str == '+')
		if (*str++ == '-')
			sign = -1;
	while (*str >= '0' && *str <= '9')
		r = r * 10 + (*str++ - '0');
	return ((int)(r * sign));
}
