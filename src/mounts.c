#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/mount.h>
#include <errno.h>
#include <dirent.h>
#include <sys/stat.h>
#include <sys/types.h>

#include <cuntainer.h>





enum type
{
    SHOW_MOUNTS,
    MOUNT,
    UMOUNT
};




int main(int argc, char ** argv)
{
    int opt;
    int callType = SHOW_MOUNTS;
    char * umountTarget;
    int ret;

    while ((opt = getopt(argc, argv, "u:")) != -1)
    {
	switch(opt)
	{
	case 'u':
	    callType = UMOUNT;
	    umountTarget = optarg;
	    break;
	default:
	    break;
	}
    }

    struct list * mountList = getMounts();
    struct list * p = mountList;

    switch(callType)
    {
    case SHOW_MOUNTS:
	while(p)
	{
	    struct mountPoint *point = (struct mountPoint *) p->value;
	    printf("%s %s %s\n",point->from,
		   point->to,
		   point->type);
	    p = p->next;
	}
	break;
    case UMOUNT:
	/*TODO
	  check target is mounted.
	 */
	ret = umount2(umountTarget,MNT_DETACH);
	if(ret < 0)
	{
	    perror("Error umount:");
	    exit(1);
	}
    default:
	break;
    }

    freeList(mountList,NULL);
    return 0;
}
