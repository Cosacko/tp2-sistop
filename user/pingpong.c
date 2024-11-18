#include "../kernel/types.h"
#include "user.h"

#define EXIT_SUCCESS 0
#define EXIT_FAILURE -1
#define SEM_PING 1
#define SEM_PONG 2

int
main(int argc, char *argv[])
{
    if (argc != 2)
    {
        printf("ERROR: Must provide an argument\n");
        exit(EXIT_FAILURE);
    }
    uint pingpong_n = atoi(argv[1]);
    if (pingpong_n < 1)
    {
        printf("ERROR: The argument must be greater or equal than 1.\n");
        exit(EXIT_FAILURE);
    }

    sem_open(SEM_PING, 1);
    sem_open(SEM_PONG, 0);
    int pid;
    pid = fork();
    if (pid < 0)
    {
        printf("ERROR: fork() failed\n");
        exit(EXIT_FAILURE);
    }    
    else if (pid == 0)
    {
        for (int i = 0; i < pingpong_n; i++) 
        {
            sem_down(SEM_PONG); 
            printf("\tpong\n");
            sem_up(SEM_PING); 
        }
        exit(EXIT_SUCCESS);
    }
    else
    {

        for (int i = 0; i < pingpong_n; i++) 
        {
            sem_down(SEM_PING);
            printf("ping\n");
            sem_up(SEM_PONG);
        }

        wait(0);

        sem_close(SEM_PING);
        sem_close(SEM_PONG);
    }

    exit(EXIT_SUCCESS);
}
