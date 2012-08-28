#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>


int 
main(int argc, char *argv[])
{
        char    *fname = NULL;
        int     ret;
        
        fname = argv[1];
        

        ret = mknod (fname, S_IFREG, 0);
        if (ret == -1) {
                fprintf (stderr, "mknod failed : %s", strerror (errno));
                exit(1);
        }
}

