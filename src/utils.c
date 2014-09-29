#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <stdint.h>

#include <cuntainer.h>

void makeStringFromSting(char **dst,char *src,size_t len)
{
    char *buf = malloc(len);
    memcpy(buf,src,len - 1);
    buf[len] = 0;
    *dst = buf;

}


char **
splitStringBy(char * dir,char sep,int withLast)
{
    char * p  = dir;
    char *st = dir;
    int arr_len = 0;
    int arr_cur_len = 10;
    int len;
    char ** ptrs = (char **) malloc(sizeof(char *) * arr_cur_len);

    printf("directory for split %s\n",dir);
    while( *p )
    {
	if(*p == sep)
	{
	    len = p - st;
	    //printf("len %d");
	    ptrs[arr_len] = malloc(len + 2);
	    memcpy(ptrs[arr_len],st,len + 1);
	    if(withLast)
	    {
		ptrs[arr_len][len+1] = 0;
	    }
	    else
	    {
		ptrs[arr_len][len] = 0;
		st = p + 1;

	    }
	    arr_len++;
	    if(arr_len == arr_cur_len -1)
	    {
		ptrs = realloc(ptrs,sizeof(char *) * (arr_cur_len * 2));
		arr_cur_len = arr_cur_len * 2;
	    }
	}
	p++;
    }
    len = p - st;
    ptrs[arr_len] = malloc(len + 2);
    memcpy(ptrs[arr_len],st,len+1);
    if(withLast)
    {
	ptrs[arr_len][len+1] = 0;
    }
    else
    {
	ptrs[arr_len][len] = 0;
    }

    //ptrs[arr_len][len+2] = 0;
    arr_len++;

    ptrs[arr_len] = NULL;
    return ptrs;
}


int readFile(const char *path,
	     char **outBuf,size_t *size,
	     size_t forceSize)
{
    int fd;
    size_t needRead = 0;
    struct stat st;
    int n;
    char * intermidiate_;
    //  size_t bytes_;

    fd = open(path,O_RDONLY);
    if(fd < 0){
	//	printf("Can`t open file %s\n",path);
	return ERROR;
    }



    stat(path, &st);

    if(st.st_size)
    {
	*size = st.st_size;
	needRead = st.st_size;
    }else
    {
	*size = forceSize;
	needRead = forceSize;
    }


    intermidiate_ = (char *)malloc(needRead);
    if (!intermidiate_){
	close(fd);
	return ERROR;
    }

    n = read(fd,intermidiate_,needRead);
    if(needRead != n && !forceSize)
    {
	printf("Read error: Read data count not equal request %d %d\n",
	       n,needRead);
	close(fd);
	return ERROR;
    }

    close(fd);
    *outBuf = intermidiate_;
    return SUCCESS;
}

struct list *
createList()
{
    struct list * list = malloc(sizeof(struct list));
    list->next = NULL;
    list->value = NULL;

    return list;
}



void
freeList(struct list *list,void (*deepFree)(void *))
{
    while(list)
    {
	if(deepFree)
	    deepFree(list->value);
	else
	    free(list->value);
	struct list *tmp = list->next;
	free(list);
	list = tmp;
    }
}
