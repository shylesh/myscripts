#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

int
main (int argc, char *argv[])
{
        FILE        *fp1 = NULL;
        FILE        *fp2 = NULL;
        char        c;
        char        *err = NULL;

        fp1 = fopen (argv[1], "r");

        if (!fp1)    {
               err = strerror (errno); 
               printf ("%s", err);
               exit (1);
        }

        fp2 = fopen ("myfile", "a+");
        if (!fp2)    {
               err = strerror (errno); 
               printf ("%s", err);
               exit (1);
        }

        while (fread (&c, 1, 1, fp1))   {
                
                printf ("sleep..\n");
                sleep (1);
                printf ("writing %c\n", c);
                fwrite (&c, 1, 1, fp2);
                fflush (fp2);
        }

        fclose (fp1);
        fclose (fp2);
 }
