#include <stdio.h>
#include <sys/types.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <cuntainer.h>

char * getTargetDir(char *base,char *from,char *to)
{
    char * targetDir = NULL;
    char **baseDirs = NULL;
    char **fromDirs = NULL;
    int baseDirsCount = 0;
    int i = 0;

    printf("base %s from %s\n",base,from);
    if(!strcmp(base,from))
    {
	targetDir = malloc(strlen(to) +1);
	strcpy(targetDir,to);
	return targetDir;
    }

    baseDirs = splitStringBy(base,'/',0);
    while(baseDirs[baseDirsCount])
	baseDirsCount++;
    baseDirsCount -= 2;

    fromDirs = splitStringBy(from,'/',0);
    while(fromDirs[i])
    {
	printf("base %d i %d %s %s\n",baseDirsCount,i,targetDir,fromDirs[i]);
	if(i <= baseDirsCount)
	{
	    i++;
	    continue;
	}
	if(!targetDir)
	{
	    targetDir = malloc(257);
	    strcpy(targetDir,to);
	    printf(" ++++ %s %s\n",targetDir,fromDirs[i]);
	}
	//targetDir = malloc(256);
	if(targetDir[strlen(targetDir) - 1] != '/')
	    strcat(targetDir,"/");
	strcat(targetDir,fromDirs[i]);

	i++;
    }

    return targetDir;
}


void
linkRecursive(char * base,char * from,char *to)
{
    struct dirent * dirEntry = NULL;
    DIR *fromDir = opendir(from);
    char filePath[256];
    char *dirToCheck = NULL;

    dirToCheck = getTargetDir(base,from,to);
    printf("src dir %s target dir %s\n",from,dirToCheck);
    checkDirectory(dirToCheck);



    if(!fromDir)
    {
	perror("Erro: open dir");
	exit(1);
    }

    while ( (dirEntry = readdir(fromDir)))
    {
	int ret;
	struct stat fileStat;
	if(dirEntry->d_name[0] == '.')
	    continue;
	if(from[strlen(from)-1] != '/')
	    snprintf(filePath,256,"%s/%s",from,dirEntry->d_name);
	else
	    snprintf(filePath,256,"%s%s",from,dirEntry->d_name);

	ret = lstat(filePath,&fileStat);
	if(ret < 0)
	{
	    fprintf(stderr,"Error lstat %d\n",errno);
	    exit(1);
	}
	if(S_ISDIR(fileStat.st_mode))
	{
	    linkRecursive(base,filePath,to);
	}
	else
	{
	    char targetFileName[256];
	    snprintf(targetFileName,256,"%s/%s",dirToCheck,dirEntry->d_name);
	    printf("link %s to %s\n",
		   filePath,targetFileName);
	    ret = symlink(filePath,targetFileName);
	    if(ret < 0)
	    {
		fprintf(stderr,"Error: symlink %d\n",errno);
		exit(1);
	    }
	}
    }
    free(dirToCheck);
}


int main(int argc,char **argv)
{
    char * from = NULL;
    char * to = NULL;


    if(argc < 3)
    {
	fprintf(stderr,"linkRecursive <from> <to>\n");
	exit(1);
    }

    from = argv[1];
    to = argv[2];
    linkRecursive(from,from,to);

    return 0;
}
