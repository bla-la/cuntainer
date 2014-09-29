#ifndef __CUNTAINER_H__
#define __CUNTAINER_H__

#define SHARED_DIRS_RO  "SHARED_DIRS_RO"
#define SHARED_DIRS_RW  "SHARED_DIRS_RW"
#define ENV_DIR "ENV_DIR"
#define EXEC_IN_ENV "EXEC_IN_ENV"
#define ENV_NAME "ENV_NAME"


#ifndef __ERROR_CODES
#define __ERROR_CODES
enum errorCodes
{
    ERROR = 0,
    SUCCESS
};
#endif

#ifndef MS_PRIVATE
#define MS_PRIVATE  (1<<18) /* 262144 Private*/
#endif
#ifndef MS_REC
#define MS_REC    0x4000  /* 16384: Recursive loopback */
#endif


struct mountPoint
{
    char *from;
    char *to;
    char *type;
    char *options;
};

struct list
{
    struct list * next;
    void *value;
};

struct list * createList();
void freeList(struct list *list,void (*deepFree)(void *));
void makeStringFromSting(char **dst,char *src,size_t len);
char ** splitStringBy(char * dir,char sep,int withLast);
struct list * getMounts();
int readFile(const char *path,char **outBuf,size_t *size,size_t forceSize);


#endif
