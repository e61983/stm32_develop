#include <string.h>
#include "semi.h"

int main(void){
    const char *hello = "HELLO\n";

    write(1,hello,strlen(hello));

    int fp = open("log.txt", 4);
    write(fp,hello,strlen(hello));
    close(fp);

    while(1);
}
