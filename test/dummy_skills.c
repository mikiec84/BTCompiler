#include "dummy_skills.h"
#include <string.h>
#include <stdio.h>

#if defined(POSIX)
#include <unistd.h>
#elif defined(_WIN32)
#include <windows.h>
#endif

void PortableSleep(unsigned int MSec)
{
#if defined(POSIX)
usleep((useconds_t)MSec * 1000);
#elif defined(_WIN32)
Sleep((DWORD)MSec);
#else
//#error non-supported platform
#endif
}


int DoDummySkill(int status, int elapsed_time_milliseconds)
{
    //PortableSleep(elapsed_time_milliseconds);
    return status;
}


int ExecuteSkill(const char *name){

    printf ("Executing the skill: %s \n", name);

    // Uncomment (and implement the remaining code) when you want to introduce the HALT
    //    int is_tick = 1;

    //    if (is_tick == 1)
    //    {
    //        printf ("Ticking the skill: %s \n", name);
    //    }
    //    else
    //    {
    //        printf ("Halting the skill: %s \n", name);
    //    }

    if (strcmp(name,"Action1SecondSuccess"))
    {
        return DoDummySkill(SUCCESS, 1000);
    }
    else if (strcmp(name, "Action1SecondFailure")) {

        return DoDummySkill(SUCCESS, 1000);

    }
    else if (strcmp(name, "ConditionTrue")) {

        return DoDummySkill(SUCCESS, 0);

    }
    else if (strcmp(name, "ConditionFalse")) {

        return DoDummySkill(FAILURE, 0);
    }
    else
    {
        printf ("Node %s not known \n", name);
        return ERROR;
    }


    // Runn, Fail, Success, Error

}




