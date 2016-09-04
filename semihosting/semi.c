#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include "semi.h"

enum SEMIHOSTING_SYS{
    SYS_OPEN = 0x01,
    SYS_CLOSE = 0x02,
    SYS_WRITE = 0x05,
    SYS_READ = 0x06,
};

static
int host_call(int serviceNumber, void *opaque){
    register int r0 asm("r0") = serviceNumber;
    register void *r1 asm("r1") = opaque;
    register int result asm("r0");
    asm volatile ("bkpt 0xab" : "=r"(result) : "r"(r0), "r"(r1));
    return result;
}

size_t write(int fildes, const void *buf, size_t nbyte){
    uint32_t parameter[] = {fildes, (uint32_t)buf, nbyte};
    return host_call(SYS_WRITE,(void *) parameter);
}

size_t read(int fildes, const void *buf, size_t nbyte){
    uint32_t parameter[] = {fildes, (uint32_t)buf, nbyte};
    return host_call(SYS_READ,(void *) parameter);
}

int open(const char *path, int mode){
    uint32_t parameter[] = {(uint32_t)path, mode, strlen(path)};
    return host_call(SYS_OPEN,(void *) parameter);
}

int close(int fildese){
    uint32_t parameter[] = {fildese};
    return host_call(SYS_CLOSE,(void *) parameter);
}
