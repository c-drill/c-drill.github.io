#include <unistd.h>

static void putnbr(int n)
{
    char c;
    if (n >= 10)
        putnbr(n / 10);
    c = n % 10 + 48;
    write(1, &c, 1);
}

int main(int ac, char **av)
{
    int counts[26];
    int order[26];
    int nord;
    int i;

    if (ac != 2)
    {
        write(1, "\n", 1);
        return (0);
    }
    i = 0;
    nord = 0;
    while (i < 26)
        counts[i++] = 0;
    i = 0;
    while (av[1][i])
    {
        char ch = av[1][i];
        int idx = -1;
        if (ch >= 'a' && ch <= 'z')
            idx = ch - 'a';
        else if (ch >= 'A' && ch <= 'Z')
            idx = ch - 'A';
        if (idx >= 0)
        {
            if (counts[idx] == 0)
                order[nord++] = idx;
            counts[idx]++;
        }
        i++;
    }
    i = 0;
    while (i < nord)
    {
        char letter = 'a' + order[i];
        putnbr(counts[order[i]]);
        write(1, &letter, 1);
        if (i < nord - 1)
            write(1, ", ", 2);
        i++;
    }
    write(1, "\n", 1);
    return (0);
}
