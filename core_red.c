       #include <sys/stat.h>
       #include <fcntl.h>
       #include <limits.h>
       #include <stdio.h>
       #include <stdlib.h>
       #include <unistd.h>
       #include <string.h>
       #include <errno.h>


       #define BUF_SIZE 1024


	/* gdb --batch --quiet -ex "thread apply all bt full" -ex "quit" ${exe} ${corefile} */
       int
       main(int argc, char *argv[])
       {
           int tot, j = 0;
	   int fd;
           ssize_t nread, nwrite;
           char buf[BUF_SIZE];
           FILE *fp;
	   FILE *fp1;
	   int fd2;
           char cwd[PATH_MAX];
	   char *args_to_exec[10];
	   int ret;
	   char cmd[1024];
	   char gdb_cmd[1024] = "gdb --batch --quiet -ex \"thread apply all bt full\" -ex \"quit\" ";
	   char bin[1024]; 
	   char buf1[BUF_SIZE];
	   char *cmd1, *cmd2;
	   int count = 0;
	   char final[1024];
	   char core_path[1024];
	   char core_info[1024];
  	   char core_bt[1024]; 
	   char *email = "shmohan@redhat.com";
	   char *pid = argv[4];

	   sprintf (core_path, "/tmp/core.dump.%s", pid);
	   sprintf (core_info, "/tmp/core.info.%s", pid);
     	   sprintf (core_bt, "/tmp/bt.%s", pid);
	   


	   cmd1 = argv[1];	
       	   while (*(cmd1++) != '=');
	   cmd2 = cmd1;	
	   strcpy(bin,cmd2 );
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
 *                 pipe program */

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
	   	fprintf (fp, "final is %s", final);
	   #endif
	   ret = system(final);
	   if (ret)
		fprintf (fp, "system failed\n");
	  // fp1 = popen (gdb_cmd, "r");
	   //if (fp1 == NULL) 
	    //   exit(EXIT_FAILURE);
		
	   /*while (fgets(buf1, sizeof(buf1), fp1) != NULL) {
		count = write(fd2, buf1, sizeof(buf1));
		if (count == -1) 
			exit(EXIT_FAILURE);
	   } */
			
	
	    
	   
	   fflush(fp);
	   fsync(fd2);
	   sync();
	
	   args_to_exec[0] = "-s";
	   args_to_exec[1] = "Core-Alert";
	   args_to_exec[2] = "-a";
	   args_to_exec[3] = core_bt;
	   args_to_exec[4] = email;	
	   args_to_exec[5] = "<";
	   args_to_exec[6] = core_info;
	   sprintf (cmd, "/bin/mailx %s %s %s %s %s %s %s", args_to_exec[0],
						       args_to_exec[1],
						       args_to_exec[2],
						       args_to_exec[3],
						       args_to_exec[4],
						       args_to_exec[5],
						       args_to_exec[6]);
	  fprintf (fp, "cmd is : %s", cmd);
	  	 
	
          ret = system(cmd);
	  if (ret)
         	exit(EXIT_FAILURE);

	  fclose(fp);
	  //fclose(fp1);
	  close(fd2);
	  close(fd);
	 
          exit(EXIT_SUCCESS);
       }

