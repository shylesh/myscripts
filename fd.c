#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define BUF_SIZE	(1024 * 1024)

int main(int argc, char *argv[])
{

	int	fd;
	int	ret;
	int	fd1;
	char	buf[BUF_SIZE];


	fd = open (argv[1], O_RDWR | O_APPEND);
	if (fd == -1) {
		perror ("open failed\n");
		exit (1);
	}

	fd1 = open ("/dev/urandom", O_RDONLY);	
	if (fd == -1) {
		perror ("open failed for urandom\n");
		exit (1);
	}

	while (1) {
		/* copy till quota exceeds */
		if ((ret = read (fd1, buf, BUF_SIZE)) != -1) {
			if (write (fd, buf, ret) != ret) {
				perror ("write failed\n");
				exit (1);
			}
			if (fsync (fd) == -1) {
				perror ("fsync failed\n");
				exit (1);
			}
		}
		if (errno)
			perror ("read failed\n");
	}
}
		
		
