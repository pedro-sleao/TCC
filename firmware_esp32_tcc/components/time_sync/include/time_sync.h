#pragma once

#include <sys/time.h>

void obtain_time(void);
void time_sync_set_timezone(const char *tz_string);
void time_sync_get_localtime(time_t *now, struct tm *timeinfo);
