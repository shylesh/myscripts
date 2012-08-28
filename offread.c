
/*
 * This program reads size number of bytes
 * at specified offset on specified file
 *
 * Author: Shylesh kumar <shylesh.mohan@redhat.com>
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>



int main(int argc, char *argv[])
{
	int opt;
	ssize_t offset;
	ssize_t size;
	int ret;
	int fd;
	char *filename;
	char *pumpstring;
	char sample[] = "This is the string to be pumped";

	if (argc < 3) {
		fprintf (stderr, " Usage: %s filename offset size\n", argv[0]);
		exit (1);
	}

	

 	/* while ((opt = getopt(argc, argv, "fOs")) != -1)  {
		switch (opt) {
		case 'f':
			filename = optarg;
			break;
		case 'O':
			offset = atoi(optarg);
			break;
		case 's':
			size = atoi(optarg);
			break;
		default:
			fprintf (stderr, "Usage : %s [-f] file [-O] offset [-s size]",
				 argv[0]);
			exit (EXIT_FAILURE);
		}
	} */
	
		   	
	fd = open (argv[1], O_RDWR); 
	if (fd == -1 ) {
		printf ( "open failed: %s\n", strerror(errno));
		exit (EXIT_FAILURE);
	}

	/* If the size is specified then we have to pump the data */

	pumpstring = (char *) malloc (sizeof(atoi(argv[3])));	

	offset = atoi(argv[2]);
	size = atoi(argv[3]);
	

	ret = lseek (fd, atoi(argv[2]), SEEK_SET);
	if (ret == -1 ) {
		printf ( "lseek failed:%s\n", strerror(errno));
		exit (EXIT_FAILURE);
	}
	

	ret = read(fd, pumpstring, size);
	if (ret == -1) {
		printf("stderr", "write failed");
		exit (EXIT_FAILURE);
	}

	printf ("%s", pumpstring);

}
		
	
