#include <stdio.h>
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

        fname = argv[1];
        offset = atoi (argv[2]);
        
        retval = truncate (fname, offset);

        if (retval) {
                fprintf (stderr, "truncate failed : %s\n", strerror(errno));
                exit(1);
        }
}
