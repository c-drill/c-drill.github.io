#include <stdlib.h>
int	*ft_range(int start, int end)
{
	long	len;
	long	i;
	int		*r;

	len = (long)end - start;
	if (len < 0)
		len = -len;
	len++;
	r = malloc(sizeof(int) * len);
	if (!r)
		return (NULL);
	i = 0;
	while (i < len)
	{
		r[i] = (start <= end) ? (int)(start + i) : (int)(start - i);
		i++;
	}
	return (r);
}
