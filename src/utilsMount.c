#include <stdio.h>
#include <stdlib.h>
#include <cuntainer.h>





enum rowPosition
{
    FROM = 0,
    TO,
    TYPE,
    OPTIONS,
    E1,
    E2
};



void setMountEntry(struct mountPoint *mp,int type,char * string)
{
    switch (type)
    {
    case FROM:
	mp->from = string;
	break;
    case TO:
	mp->to = string;
	break;
    case TYPE:
	mp->type = string;
	break;
    case OPTIONS:
	mp->options = string;
    case E1:
	//	mp->e1 = string;
	break;
    case E2:
	break;
    default:
	break;
    }
}


struct list *
getMounts()
{
    struct list * mountList = createList();
    struct list * currentList = mountList;

    int ret;
    char * mounts = NULL;
    size_t mountsSize = 0;
    char *p;
    char * rowStart = mounts;
    int rowPos = FROM;
    char * tupleStart = NULL;
    size_t len = 0;
    char *buf;
    struct mountPoint * mp = malloc(sizeof(struct mountPoint));


    if( !(ret = readFile("/proc/mounts",
			&mounts,
			&mountsSize,
			4096)))
    {
	fprintf(stderr,"Error: can`t read /proc/mounts\n");
	exit(1);
    }

    p = mounts;
    tupleStart = mounts;




    while(*p)
    {
	if(*p == '\n')
	{
	    //	    rowStart = mounts;
	    len = ((p - tupleStart) +1);

	    makeStringFromSting(&buf,tupleStart,len);
	    //printf("++%s|\n",buf);
	    setMountEntry(mp,rowPos,buf);
	    /*
	    printf("mount point: %s %s %s %s\n",mp->from,
		   mp->to,
		   mp->type,
		   mp->options);
	    */
	    rowPos = FROM;
	    if(!currentList->value)
	    {
		currentList->value = (void *)mp;
	    }else
	    {
		currentList->next = createList();
		currentList = currentList->next;
		currentList->value = (void *) mp;
	    }
	    mp = malloc(sizeof(struct mountPoint));
	    p++;
	    tupleStart = p;
	    continue;
	}
	if( *p == ' ')
	{
	    len = ((p - tupleStart) +1);

	    makeStringFromSting(&buf,tupleStart,len);
	    setMountEntry(mp,rowPos,buf);
	    p++;
	    rowPos++;
	    //printf("%s|\n",buf);
	    tupleStart = p;
	    continue;
	}
	p++;
    }

    return mountList;
}
