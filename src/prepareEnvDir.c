#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/mount.h>
#include <errno.h>
#include <dirent.h>
#include <sys/stat.h>
#include <sys/types.h>

#include <cuntainer.h>

char * sharedDirsRo = NULL;
char * sharedDirsRw = NULL;
char * envDir = NULL;


char **
splitDirectory(char *dir)
{
    return splitStringBy(dir,'/',1);
}


void
checkDirectory(char * dir)
{
    char ** dirs = splitDirectory(dir);
    int i = 0;
    int ret;
    while(dirs[i])
    {
	//printf("dir: %s\n",dirs[i]);

	DIR* d = opendir(dirs[i]);
	if(d)
	{
	    closedir(d);
	}else
	{
	    //	    printf("directory %s not exists, createing.\n",dirs[i]);
	    ret = mkdir(dirs[i],0777);
	    if(ret < 0)
	    {
		perror("MKdir:");
		exit(1);
	    }
	}

	free(dirs[i]);
	i++;
    }

    free(dirs);
}


void
doMount(char * from,char * to,char *type,int flags,char *params)
{
    int ret;
    ret =  mount(from, to,
		 type, flags,
		 params);
    printf("=====try mount %s to %s ret %d %d\n",from
	   ,to,ret,errno);
    if(ret < 0)
    {
	perror("Error: mount");
	exit(1);
    }

}

void
mountSharedDirs(char * dirsStr,int ro)
{
    int ret;
    int flags;
    char **sharedDirSplit = splitStringBy(dirsStr,';',0);
    int i = 0;

    //printf("dirs: %s\n",dirsStr);
    while(sharedDirSplit[i])
    {
	char dirInEnv[1024];

	snprintf(dirInEnv, 1024, "%s%s",envDir,sharedDirSplit[i]);
	printf("dir: %s dirInEnv: %s\n",sharedDirSplit[i],dirInEnv);
	checkDirectory(dirInEnv);
	//mount directory
	flags = MS_BIND;
	doMount(sharedDirSplit[i], dirInEnv,
		 "none", flags,
		 NULL);

	if(ro)
	{
	    flags = MS_REMOUNT|MS_BIND|MS_RDONLY;
	    doMount(sharedDirSplit[i], dirInEnv,"none",flags,NULL);
	}
	i++;
    }


}

void checkDirectoryOn(char *baseDir,char *dir)
{
    char dirInEnv[1024];

    snprintf(dirInEnv, 1024, "%s/%s",baseDir,dir);
    checkDirectory(dirInEnv);

}

int main()
{
    int ret;
    char **envDirs = NULL;
    sharedDirsRo = getenv(SHARED_DIRS_RO);
    if(!sharedDirsRo)
    {
	fprintf(stderr,"Error: env variable SHARED_DIRS_RO not defined exit...");
	exit(1);
    }

    sharedDirsRw = getenv(SHARED_DIRS_RW);
    if(!sharedDirsRw)
    {
	fprintf(stderr,"Error: env variable SHARED_DIRS_RW not defined exit...");
	exit(1);
    }

    envDir = getenv(ENV_DIR);
    if(!envDir)
    {
	fprintf(stderr,"Error: env variable ENV_DIR not defined exit...");
	exit(1);
    }



    checkDirectory(envDir);
    checkDirectoryOn(envDir,"/tmp");
    checkDirectoryOn(envDir,"/proc");
    checkDirectoryOn(envDir,"/dev");
    mountSharedDirs(sharedDirsRo,1);
    mountSharedDirs(sharedDirsRw,0);
    return 0;
}
