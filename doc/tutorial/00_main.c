/* 00_main.c */
#include <smear/smear.h>
#include "00_pinball.h"
#include "00_pinball_ext.h"

int main(void)
{
    SRT_init();
    SRT_run();
    SRT_wait_for_idle();
    SRT_stop();
    return 0;
}
