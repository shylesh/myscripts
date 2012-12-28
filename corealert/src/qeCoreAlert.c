/* qeCoreAlert.c --> send mail alert to the user
 * upon coredump.
 *
 * Prerequisites: mailx, /proc/sys/kernel/core_pattern settings
 *
 * Required settings will be done by ../qeCoreAlert.sh
 *
 * Author: shylesh kumar <shmohan@redhat.com>
 * Date:Mon 10 Dec 2012 01:15:08 PM IST
 * Script name : qeCoreAlert.c
 * Purpose : Whenever core dump happens this program will be run,
 *    this will collect the core along with the information
 *    like pid, hostname etc and will be mailed to the
 *    below set mail id. core file generated will be saved in /tmp/core.pid
 *    only the backtrace and process and host details will be mailed
 *    to the user.
 */
#include <sys/stat.h>
#include <fcntl.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>


#define BUF_SIZE PATH_MAX


/* gdb --batch --quiet -ex "thread apply all bt full" -ex "quit" ${exe} ${corefile} */
int
main(int argc, char *argv[])
{
	int tot, j = 0;
	int fd;
	ssize_t nread, nwrite;
	char buf[BUF_SIZE];
	FILE *fp;
	int fd2;
	int ret;

	char cmd[1024];
	char gdb_cmd[1024] = "gdb --batch --quiet -ex \"thread apply all bt full\" -ex \"quit\" ";
	char bin[1024];
	char *cmd1;
	char final[1024];

	char core_path[1024];
	char core_info[1024];
	char core_bt[1024];
	char *email = "shmohan@redhat.com";
	char *pid = argv[4];

	sprintf (core_path, "/tmp/core.dump.%s", pid);
	sprintf (core_info, "/tmp/core.info.%s", pid);
	sprintf (core_bt, "/tmp/bt.%s", pid);

	strtok(argv[1], "=");
	cmd1 = strtok (NULL, "=");
	strcpy(bin,cmd1 );
	strcat (bin, " ");

	/* Write output to file "core.info"*/

	fp = fopen(core_info, "w+");

	#ifdef DEBUG
		fprintf (fp, "executable name is %s", bin);
	#endif
	if (fp == NULL)
		exit(EXIT_FAILURE);

	fd = open (core_path, O_CREAT|O_RDWR, S_IRWXU);
	if (fd == -1)
		exit(EXIT_FAILURE);

	/* Display command-line arguments given to core_pattern
	   pipe program */

	for (j = 1; j < argc; j++)
		fprintf(fp, "%s\n", argv[j]);

	/* Count bytes in standard input (the core dump) */

	tot = 0;
	while ((nread = read(STDIN_FILENO, buf, BUF_SIZE)) > 0) {
		tot += nread;
		nwrite = write(fd, buf, nread);
	}
	if (nwrite <= 0)
		fprintf (fp, "error: %s", strerror(errno));
		fprintf(fp, "Total bytes in core dump: %d\n", tot);

	/* Extract bt from the core and write it to CORE_BT file */
	fd2 = open(core_bt, O_CREAT|O_RDWR, S_IRWXU);
	if (fd2 == -1) {
		fprintf (fp, "%s", "openning fp2 failed\n");
		exit(EXIT_FAILURE);
	}
	strcat(gdb_cmd, strcat(bin, core_path));

	#ifdef DEBUG
		fprintf (fp, "final gdb_cmd= %s", gdb_cmd);
	#endif

	sprintf (final, "%s > %s", gdb_cmd, core_bt);
	#ifdef DEBUG
		fprintf (fp, "gdb command  is %s", final);
	#endif

	ret = system(final);
	if (ret)
		fprintf (fp, "system command failed\n");

	fflush(fp);
	fsync(fd2);
	sync();

	sprintf (cmd, "/bin/mailx %s %s %s %s %s %s %s", "-s",
						       "Core-Alert",
						       "-a",
						       core_bt,
						       email,
						       "<",
						       core_info);
	#ifdef DEBUG
		fprintf (fp, "mailx cmd is : %s", cmd);
	#endif

	ret = system(cmd);

	if (ret)
		exit(EXIT_FAILURE);

	fclose(fp);
	close(fd2);
	close(fd);

	exit(EXIT_SUCCESS);

}
