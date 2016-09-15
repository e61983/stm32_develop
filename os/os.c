#include "os.h"
void system_call(void){
    asm volatile("svc 0");
    asm volatile("nop");
    asm volatile("bx lr");
}

unsigned int *context_switch(unsigned int *stack){
    asm volatile("mrs ip, psr");
    asm volatile("push {r4-r11,ip,lr}");

    asm volatile("msr psp, r0");
    asm volatile("mov r0, #3");
    asm volatile("msr control, r0");

    asm volatile("pop {r4-r11,lr}");
    asm volatile("bx lr");
}

unsigned int *createTaskStack( unsigned int *userStack, void (*func)(void) ){
    static unsigned char first = 1;
    userStack += 256 - 16;
    if(first){
        userStack[8] = (unsigned int) func;
        first = 0;
    }else{
        userStack[8] = 0xfffffffd;
        userStack[15] = (unsigned int) func;
        userStack[16] = 0x01000000;
    }
    return userStack;
}

__attribute__((naked))
void SVC_Handler(void) {
    asm volatile("mrs r0, psp");
    asm volatile("stmdb r0!, {r4-r11,lr}");

    asm volatile("pop {r4-r11,ip,lr}");
    asm volatile("msr psr, ip");
    asm volatile("bx lr");
}
