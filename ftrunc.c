#include <unistd.h>
#include <sys/types.h>
#include <string.h>
#include <errno.h>

int
main(int argc, char *argv[])
{
        char    *fname = NULL;
        int     retval = -1;
        off_t   offset = 0;
        int     fd;

        fname = argv[1];  
        offset = atoi (argv[2]);

        fd = open (fname, O_RDWR || O_TRUNC);

        if (-1 == fd) {   
                fprintf (stderr, "open failed : %s\n", strerror(errno));
                exit(1);  
        }

        retval = ftruncate (fd, offset);

        if (retval) {
                fprintf (stderr, "truncate failed : %s\n", strerror(errno));
                exit(1);  
        }
}

