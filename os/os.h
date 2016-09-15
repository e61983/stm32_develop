#pragma once
void system_call(void);
unsigned int *context_switch(unsigned int *stack);
unsigned int *createTaskStack( unsigned int *userStack, void (*func)(void) );
