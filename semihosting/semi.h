#pragma once
#include <stddef.h>
#include <stdint.h>

int open(const char *path, int mode);
int close(int fildese);
size_t read(int fildes, const void *buf, size_t nbyte);
size_t write(int fildes, const void *buf, size_t nbyte);
