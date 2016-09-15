#include <string.h>
#include "semi.h"
#include "os.h"

static
void task1(void){
    static const char *task1_string = "TASK_1\n";
    static const char *task1_again_string = "TASK_1_again\n";
    write(1,task1_string,strlen(task1_string));
    system_call();
    write(1,task1_again_string,strlen(task1_again_string));
    system_call();
    while(1);
}

int main(void){
    unsigned int user_stack[256];
    unsigned int *user_stack_ptr;

    static const char *hello = "HELLO\n";
    write(1,hello,strlen(hello));

    user_stack_ptr = createTaskStack(user_stack, task1);
    context_switch(user_stack_ptr);

    static const char *os_string = "in os\n";
    write(1,os_string,strlen(os_string));

    context_switch(user_stack_ptr);

    write(1,os_string,strlen(os_string));
    while(1);
}
