#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

#define MAX_SEM 256
#define SEM_ERROR 0
#define SEM_SUCCESS 1

typedef struct 
{
    int value;
    struct spinlock lock;
}   semaphore;

semaphore sem_table[MAX_SEM];

//sem_init for the array. It's executed in main.c on the kernel at start.
void
sem_init(void)
{
    for (uint i = 0; i < MAX_SEM; i++) 
    {
        initlock(&sem_table[i].lock, "semaphore_lock");
        sem_table[i].value = -1;
    }
}

int
sem_open(int sem, int value)
{
    if (sem < 0 || sem >= MAX_SEM) return SEM_ERROR;
    int ret = SEM_ERROR;

    acquire(&sem_table[sem].lock);
    if (sem_table[sem].value == -1) //If not open yet, do it.
    {
        sem_table[sem].value = value;
        ret = SEM_SUCCESS;
    }
    release(&sem_table[sem].lock);

    return ret;
}

int
sem_close(int sem)
{
   if (sem < 0 || sem >= MAX_SEM) return SEM_ERROR;

    acquire(&sem_table[sem].lock);
    if (sem_table[sem].value > 0) 
    {
        sem_table[sem].value = -1;
    }
    release(&sem_table[sem].lock);

    return SEM_SUCCESS;
}

int
sem_up(int sem)
{
    acquire(&(sem_table[sem].lock));

    if (sem_table[sem].value == -1 ) {
        printf("ERROR: Ilegal increase of closed semaphore.\n");
        release(&(sem_table[sem].lock));
        return SEM_ERROR;
    }

    if (sem_table[sem].value == 0)
        wakeup(&(sem_table[sem]));

    (sem_table[sem].value) += 1;

    release(&(sem_table[sem].lock));

    return SEM_SUCCESS;
}

int
sem_down(int sem)
{
 acquire(&(sem_table[sem].lock));

    if (sem_table[sem].value == -1)
    {
        printf("ERROR: Ilegal decrease of closed semaphore.\n");
        release(&(sem_table[sem].lock));
        return SEM_ERROR;
    }

    while (sem_table[sem].value == 0)
    {
        sleep(&(sem_table[sem]), &(sem_table[sem].lock));
    }

    (sem_table[sem].value) -= 1;

    release(&(sem_table[sem].lock));

    return SEM_SUCCESS;
}

