#define _XOPEN_SOURCE       /* See feature_test_macros(7) */
#include <time.h>
#include <stdio.h>
#include <locale.h>

int main (void) {
  struct tm tm = {0}; // init with 0 is important

  printf("%d\n", LC_ALL);

  setlocale(LC_ALL, "de_DE.UTF-8");

  printf("%s\n", strptime("Friday, 28. Jun 2019", "%A, %d. %b %Y", &tm));
  time_t old_time = mktime(&tm);
  printf("%ld\n", old_time);

  time_t seconds;

  seconds = time(NULL);
  printf("%ld\n", seconds);

  return 0;
}
