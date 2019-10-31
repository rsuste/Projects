// IOS proj2
// xsuste11: Radim Sustek(FIT)
// 1.5.2018

#include <stdio.h>
#include <stdlib.h>
#include <semaphore.h>
#include <sys/mman.h>
#include <unistd.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/shm.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <time.h>
#include <string.h>

//file
FILE *f = NULL;
//semafory pro funkcialitu
sem_t *BUS_SEM;
sem_t *board_sem;
sem_t *RIDER_SEM;
sem_t *RIDER_GENT_SEM;
//semafory pro zapis a upravy hodnot
sem_t *zapis_sem;
sem_t *uprav_sem;

//sdilene promene
int *OP_COUNTER = NULL; // iterace akci
int *zastavka = NULL; // pocet cekajicich cekajicich na zastavce
int *board = NULL; // pocet lidi na palube autobusu
int *RID_ALL = NULL; // pocet cestujicich
int *bus_ready = NULL; // zda je autobus na zastavce 1->je 0->neni
int *waiting = NULL; // pocet lidi cekajicich pred zastavkou

//ukazatele na sdilene promene
int OP_COUNTER_id = 0;
int zastavka_id = 0;
int board_id = 0;
int RID_ALL_id = 0;
int bus_ready_id = 0;
int waiting_id =0;


int inicialization(){
    //inicializace souboru
    f = fopen("proj2.out","w+r+");
    if (f == NULL)
    {
        fprintf(stderr,"CHYBA: Nepovedlo se otevrit soubor");
        return -1;
    }
    //semafory
    BUS_SEM = mmap(NULL, sizeof(sem_t), PROT_READ | PROT_WRITE,
                    MAP_SHARED | MAP_ANONYMOUS, -1, 0);

    RIDER_SEM = mmap(NULL, sizeof(sem_t), PROT_READ | PROT_WRITE,
                    MAP_SHARED | MAP_ANONYMOUS, -1, 0);

    RIDER_GENT_SEM = mmap(NULL, sizeof(sem_t), PROT_READ | PROT_WRITE,
                 MAP_SHARED | MAP_ANONYMOUS, -1, 0);

    zapis_sem = mmap(NULL, sizeof(sem_t), PROT_READ | PROT_WRITE,
                     MAP_SHARED | MAP_ANONYMOUS, -1, 0);

    uprav_sem = mmap(NULL, sizeof(sem_t), PROT_READ | PROT_WRITE,
                     MAP_SHARED | MAP_ANONYMOUS, -1, 0);

    board_sem = mmap(NULL, sizeof(sem_t), PROT_READ | PROT_WRITE,
                     MAP_SHARED | MAP_ANONYMOUS, -1, 0);


    //id
    OP_COUNTER_id = shmget(IPC_PRIVATE, sizeof(int),IPC_CREAT | IPC_EXCL | 0666);
    zastavka_id = shmget(IPC_PRIVATE, sizeof(int),IPC_CREAT | IPC_EXCL | 0666);
    board_id = shmget(IPC_PRIVATE, sizeof(int),IPC_CREAT | IPC_EXCL | 0666);
    RID_ALL_id =shmget(IPC_PRIVATE, sizeof(int),IPC_CREAT | IPC_EXCL | 0666);
    bus_ready_id = shmget(IPC_PRIVATE, sizeof(int),IPC_CREAT | IPC_EXCL | 0666);
    waiting_id = shmget(IPC_PRIVATE, sizeof(int), IPC_CREAT | IPC_EXCL | 0666);


    if(OP_COUNTER_id == -1 || zastavka_id == -1 || board_id == -1 || RID_ALL_id == -1 || bus_ready_id == -1 || waiting_id == -1)
        return -1;
    //sdilena pamet
    OP_COUNTER = (int*) shmat(OP_COUNTER_id,NULL,0);
    zastavka = (int*) shmat(zastavka_id,NULL,0);
    board = (int*) shmat(board_id,NULL,0);
    RID_ALL =(int*) shmat(RID_ALL_id,NULL,0);
    bus_ready=(int*) shmat(bus_ready_id,NULL,0);
    waiting = (int*) shmat(waiting_id,NULL,0);

    if (OP_COUNTER == NULL || zastavka == NULL || board == NULL || RID_ALL == NULL|| waiting == NULL)
        return -1;


    //semafor
    BUS_SEM = sem_open("xsuste11_ios_bus.semafor", O_CREAT | O_EXCL, 0666, 1);
    RIDER_SEM = sem_open("xsuste11_ios_rider.semafor", O_CREAT | O_EXCL, 0666, 1);
    RIDER_GENT_SEM = sem_open("xsuste11_ios_gen.semafor", O_CREAT | O_EXCL, 0666, 1);
    zapis_sem = sem_open("xsuste11_ios_zap.semafor",O_CREAT | O_EXCL, 0666,1);
    uprav_sem = sem_open("xsuste11_ios_upr.semafor",O_CREAT | O_EXCL, 0666,1 );
    board_sem = sem_open("xsuste11_ios_board.semafor",O_CREAT | O_EXCL, 0666,1);

    if (BUS_SEM == SEM_FAILED || RIDER_SEM== SEM_FAILED || RIDER_GENT_SEM == SEM_FAILED || zapis_sem == SEM_FAILED || uprav_sem == SEM_FAILED || board_sem == SEM_FAILED)
        return -1;


    return 0;
    


}
void delay_time(unsigned int wait){
    int rozsah = 0;
    if (wait != 0)
        rozsah = rand() % (wait+1);
    else
        rozsah = 0;

    usleep(rozsah*1000);
}
int check_parametr(int pocet, char *pole[]) {
    //pocet argumentu
    if (pocet != 5)
    {
        fprintf(stderr,"CHYBA: Nespravny pocet parametru");
        return -1;
    }
    //pocet riders
    if (strtol(pole[2],NULL,10) <=0)
    {
        fprintf(stderr,"CHYBA: Spatny pocet riders");
        return -1;
    }

    //kapacita busu
    if (strtol(pole[2],NULL,10) <=0)
    {
        fprintf(stderr,"CHYBA: Prilis mala kapacita busu");
        return -1;
    }

    //ART
    if (strtol(pole[3],NULL,10) < 0)
    {
        fprintf(stderr,"CHYBA: Prilis maly ART");
        return -1;
    }
    if (strtol(pole[3],NULL,10) > 1000)
    {
        fprintf(stderr,"CHYBA: Prilis velke ART");
        return -1;
    }
    //ABT
    if (strtol(pole[4],NULL,10) < 0)
    {
        fprintf(stderr,"CHYBA: Prilis maly ABT");
        return -1;
    }
    if (strtol(pole[4],NULL,10) > 1000)
    {
        fprintf(stderr,"CHYBA: Prilis velke ABT");
        return -1;
    }
    return 0;

}
void clean_all() {
    //zruseni sdilene promene
    munmap(BUS_SEM, sizeof(sem_t));
    munmap(RIDER_GENT_SEM, sizeof(sem_t));
    munmap(RIDER_SEM,sizeof(sem_t));
    munmap(zapis_sem, sizeof(sem_t));
    munmap(uprav_sem, sizeof(sem_t));
    munmap(board_sem, sizeof(sem_t));

    shmctl(OP_COUNTER_id,IPC_RMID,NULL);
    shmctl(zastavka_id,IPC_RMID,NULL);
    shmctl(board_id,IPC_RMID,NULL);
    shmctl(RID_ALL_id,IPC_RMID,NULL);
    shmctl(bus_ready_id,IPC_RMID,NULL);
    shmctl(waiting_id,IPC_RMID,NULL);


    //ukonceni semaforu
    sem_unlink("xsuste11_ios_bus.semafor");
    sem_unlink("xsuste11_ios_rider.semafor");
    sem_unlink("xsuste11_ios_gen.semafor");
    sem_unlink("xsuste11_ios_zap.semafor");
    sem_unlink("xsuste11_ios_upr.semafor");
    sem_unlink("xsuste11_ios_board.semafor");

    sem_close(BUS_SEM);
    sem_close(RIDER_SEM);
    sem_close(RIDER_GENT_SEM);
    sem_close(zapis_sem);
    sem_close(uprav_sem);
    sem_close(board_sem);
}
void BUS(int capacity,unsigned int delay) {
    while (*RID_ALL != 0)
    {
        //sem_post(RIDER_SEM);
        //printf(" %d\n",capacity);

        delay_time(delay); // zpozdeni

        sem_wait(zapis_sem);
        fprintf(f,"%d: BUS: start\n",(*OP_COUNTER)++);
        sem_post(zapis_sem);
        fflush(f);



        sem_wait(zapis_sem);
        fprintf(f,"%d: BUS: arrival\n",(*OP_COUNTER)++);
        sem_post(zapis_sem);
        fflush(f);

        //zastavit vsechny ridery

        sem_wait(uprav_sem);
        *bus_ready = 1;
        sem_post(uprav_sem);

        // povol vsechny RIDERY

        if (*zastavka != 0) {

            sem_wait(zapis_sem);
            fprintf(f,"%d: BUS: start boarding: %d\n", (*OP_COUNTER)++, *zastavka);
            sem_post(zapis_sem);
            fflush(f);


            //sem_post(RIDER_SEM);

            //printf(" test %d\n",*zastavka);
            if (*zastavka != 0)

                while (*zastavka != 0) {
                    if (*board == capacity)
                        break;
                    sem_post(board_sem);
                }


            sem_wait(zapis_sem);
            fprintf(f,"%d: BUS: end boarding: %d\n", (*OP_COUNTER)++, *zastavka);
            sem_post(zapis_sem);
            fflush(f);
        }
        //sem_wait(RIDER_SEM); // zastavit ridery




        sem_wait(zapis_sem);
        fprintf(f,"%d: BUS: depart\n",(*OP_COUNTER)++);
        sem_post(zapis_sem);
        fflush(f);


        sem_wait(uprav_sem);
        *bus_ready=0;
        sem_post(uprav_sem);

        while (*waiting != 0) {
            sem_post(RIDER_GENT_SEM);

            sem_wait(uprav_sem);
            (*waiting)--;
            sem_post(uprav_sem);
        }


        //sem_post(RIDER_GENT_SEM);

        sem_wait(zapis_sem);
        fprintf(f,"%d: BUS: end\n",(*OP_COUNTER)++);
        sem_post(zapis_sem);
        fflush(f);

        //sem_post(BUS_SEM);

        while(*board != 0) {

            sem_post(BUS_SEM);

            sem_wait(uprav_sem);
            (*board)--;
            sem_post(uprav_sem);
        }


    }
    sem_wait(zapis_sem);
    fprintf(f,"%d: BUS: finish\n",(*OP_COUNTER)++);
    sem_post(zapis_sem);
    fflush(f);

    exit(0);
}
void RIDER(int ID)
{
    //printf("test\n");
    //sem_post(RIDER_GENT_SEM);
    //sem_wait(RIDER_SEM);
    //sem_wait(BUS_SEM);
    //sem_wait(board_sem);
    //sem_wait(RIDER_SEM);


    sem_wait(zapis_sem);
    fprintf(f,"%d: RID %d: start\n",(*OP_COUNTER)++,ID);
    sem_post(zapis_sem);


    if (*bus_ready ==1)
    {
        sem_wait(RIDER_GENT_SEM);

        sem_wait(uprav_sem);
        (*waiting)++; // pocitadlo cekajicich pred zastavkou
        sem_post(uprav_sem);
    }

    //while(*bus_ready == 0)
    //    sem_post(RIDER_SEM);

    sem_wait(uprav_sem);
    (*zastavka)++;
    sem_post(uprav_sem);


    sem_wait(zapis_sem);
    fprintf(f,"%d: RID %d: enter: %d\n",(*OP_COUNTER)++,ID,*zastavka); //print-->prichod na zatavku
    sem_post(zapis_sem);

    //sem_wait(board_sem);
    //sem_wait(RIDER_SEM);
    //if (*bus_ready == 0)
    //     sem_wait(board_sem);
    sem_wait(board_sem);

    sem_wait(uprav_sem);
    (*board)++;
    sem_post(uprav_sem);


    sem_wait(zapis_sem);
    fprintf(f,"%d: RID %d: boarding\n",(*OP_COUNTER)++,ID);
    sem_post(zapis_sem);


    sem_wait(uprav_sem);
    (*zastavka)--;
    sem_post(uprav_sem);

    sem_wait(BUS_SEM);

    sem_wait(zapis_sem);
    fprintf(f,"%d: RID %d: finish\n",(*OP_COUNTER)++,ID);
    sem_post(zapis_sem);

    sem_wait(uprav_sem);
    (*RID_ALL)--;
    sem_post(uprav_sem);

    exit(0);
}
void rider_generator( int pocet, unsigned int delay)
{
    //dokud nejsou vygenerovani vsichni
    for (int i =0;i<pocet;++i)
    {
        //cekej neakou dobu
        delay_time(delay);
        //vygeneruj cestujiciho
        pid_t RID = fork();
        if (RID == 0) {
            RIDER(i+1); // kazdy cestujici si ponese sve ID
        }
        else if (RID < 0)
            fprintf(stderr,"Nepovedlo se vytvorit RID %d\n",i+1);

    }
    exit(0);

}



int main(int argc, char *argv[]) {
    pid_t bus_driver;
    pid_t riders;
    //printf("start testitg\n");
    if (check_parametr(argc,argv) == -1)
    {
        fprintf(stderr,"CHYBA: spathne zadane parametry\n");
        return -1;

    }
    if (inicialization() != 0 )
    {
        clean_all();
        inicialization();
    }
    else inicialization();

    setbuf(f,NULL);

    (*OP_COUNTER) = 1;
    (*RID_ALL) = strtol(argv[1],NULL,10);
    bus_driver = fork();
    if (bus_driver == 0)
    {
        BUS(strtol(argv[2],NULL,10),strtol(argv[4],NULL,10));
    }
    else if (bus_driver == -1){
        fprintf(stderr,"Nepovedl se vytvorit child proces bus\n");
        return 1;
    }
    else if (bus_driver > 0) {
        riders = fork();
        if (riders == 0) {
            rider_generator(strtol(argv[1], NULL, 10), strtol(argv[3], NULL, 10));
        }
        if (riders < 0){
            fprintf(f,"Nepovedl se vytvorit child proces riders\n");
            return 1;
        }

    }
    while(wait(NULL)>0);


    //printf("finish\n");
    fclose(f);
    clean_all();
    return 0;
}