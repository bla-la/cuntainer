#include <stdio.h>
#include <sys/types.h>
#include <dirent.h>


void
linkRecursive(struct dirent * dir)
{
}


int main(int argc,char **argv)
{
    char * from = NULL;
    char * to = NULL;
    struct dirent *readdir(DIR *dirp);
    if(argc < 3)
    {
	fprintf(stderr,"linkRecursive <from> <to>\n");
	exit(1);
    }

    from = argv[1];
    to = argv[2];

    DIR *fromDir = opendir(from);
    if(!fromDir)
    {
	perror("Erro: open dir");
	exit(1);
    }

    return 0;
}
