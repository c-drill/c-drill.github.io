/* c-drill (web version only): WebVM cannot interrupt a busy loop (no timeout,
 * no kill), so the student's program is built with
 * -fsanitize-coverage=trace-pc and stops itself after 5 s (exit 124 = Timeout). */
#include <time.h>
#include <unistd.h>

static time_t g_start;
static unsigned long g_count;

__attribute__((constructor)) static void wd_init(void)
{
	struct timespec t;

	clock_gettime(CLOCK_MONOTONIC, &t);
	g_start = t.tv_sec;
}

void __sanitizer_cov_trace_pc(void)
{
	struct timespec t;

	if ((++g_count & 0xFFFF) != 0)
		return ;
	clock_gettime(CLOCK_MONOTONIC, &t);
	if (t.tv_sec - g_start >= 5)
		_exit(124);
}
