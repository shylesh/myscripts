#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
//#include <attr/xattr.h>
#include <string.h>
#include <sys/time.h>

#define NUM_THREADS 10 
#define DEPTH 1000
#define BREADTH 2000 
#define PATH_MAX 16000

int depth = 1;
pthread_mutex_t depthlock;

void *md(void *thid)
{

    int cur_dir = 0;
    int me = *(int *) thid;
    int ret = 0;
    char dname[10];
    char dirpath[PATH_MAX];


    while (depth <= DEPTH) {
        pthread_mutex_lock (&depthlock);
        cur_dir = depth++;
        sprintf (dname, "%d", cur_dir);
	
	/* stat (".."); getxattr(".."); */
	mkdir (dname, 0777);
        /* setxattr(); stat(); getxattr(); */
			
	chdir (dname);
 		
        getcwd (dirpath, PATH_MAX);
        pthread_mutex_unlock(&depthlock);
        subdir (dirpath);

        printf ("depth is %d from thread %d\n", cur_dir, me);
    }

    return thid;

}

int
subdir (char *dname)
{

   int i;
   char subd[PATH_MAX];
   char file[PATH_MAX];
   int re;
   struct timeval *time_val;

   time_val = (struct timeval *) malloc (sizeof (struct timeval));
   for (i = 1001; i <= BREADTH; i++) {
        sprintf (subd, "%s/%d",dname, i);
        mkdir(subd,0777);
	gettimeofday (time_val, NULL);
	sprintf (file, "%s/%zu", dname, time_val->tv_usec); 
	re = mknod (file, S_IFREG, 0);	
	if (re == -1) {
		printf ("mknod failed for %s", file);
	}
	
	
   }
 return;

}

int main(int argc, char *argv[])
{
    pthread_t thread[NUM_THREADS];
    int rc;
    int t;
    int *status;


    for (t = 0; t < NUM_THREADS; t++) {
        printf ("main thread creating the thread %d \n", t);
        rc = pthread_create (&thread[t],NULL, md, (void *) &t);

        if (rc) {
            printf ("ERROR, ret from pthread_create is %d", rc);
            exit (-1);
        }
    }

    for (t = 0; t < NUM_THREADS; t++) {
        if (rc = pthread_join (thread[t], (void *)&status)) {

            printf ("ERROR , ret frin pthread_join is %d", rc);
            exit (-1);
  }



    }

}

	
