#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/mman.h>
#define __USE_GNU
#include <sched.h>
#include <unistd.h>
#include <sys/mount.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <sys/wait.h>
#include <signal.h>
#include <sys/types.h>
#include <dirent.h>

#include <cuntainer.h>


char * envDir = NULL;
const int defaultStackSize = 138240;

struct sysLimits
{
    unsigned long long stackSizeSoft;
    unsigned long long stackSizeHard;
};

struct cloneParams
{
    unsigned long long stackSize;
    int (*childFunc)(void *);
    int flags;
    pid_t childPid;
    void * args;

};

int
getSysLimits(struct sysLimits * limits)
{
    struct rlimit limit = {0};
    int ret = 0;

    ret = getrlimit(RLIMIT_STACK,&limit);
    if(ret < 0)
    {
	fprintf(stderr,"Error: getrlimit RLIMIT_STACK, errno:%d\n",errno);
	return 0;
    }

    limits->stackSizeSoft = limit.rlim_cur;
    limits->stackSizeHard = limit.rlim_max;
    return 1;
}


int
doClone(struct cloneParams * param)
{
    char * childStackPtr;
    childStackPtr = (char *) mmap(NULL,
			 param->stackSize,
			 PROT_READ|PROT_WRITE,
			 MAP_PRIVATE|MAP_GROWSDOWN|MAP_ANONYMOUS,
			 0,
			 0);
    if(childStackPtr < 0)
    {
	fprintf(stderr,"Error: mmap failed\n");
	return 0;
    }
    printf("map child stack at 0x%llx\n",childStackPtr);

    param->childPid = clone(param->childFunc,
			    childStackPtr + param->stackSize,
			    param->flags|SIGCHLD, //Inform parrent
			    param->args);
    return 1;
}
int startChildProc(void *args)
{
    int ret = 0;
    printf("child func\n");
    envDir = getenv(ENV_DIR);
    if(!envDir)
    {
	fprintf(stderr,"Error: env variable ENV_DIR not defined exit...");
	exit(1);
    }

    ret =  setenv(ENV_NAME, envDir,1);


    chroot(envDir);
    //    ret = unshare(CLONE_FS|CLONE_NEWNET);
    //   printf("ret: %d\n",ret);

    if (mount(NULL, "/", NULL, MS_PRIVATE|MS_REC, NULL) < 0) {
	printf("mount /");
    }

    if (mount("proc", "/proc", "proc",MS_REC, NULL) < 0) {
	perror("Mount error:");
        printf("++++++mount /proc %d\n",errno);
	exit(1);
    }

    if (mount("udev", "/dev", "devtmpfs",MS_REC, NULL) < 0) {
	perror("Mount error:");
        printf("++++++mount /dev %d\n",errno);
	exit(1);
    }


    char * params[] = {"bash",NULL};

    execv("/bin/bash",params);


    return 0;
}

int main(int argc,char ** argv)
{
    int status = 0;
    pid_t pid;
    struct sysLimits sysLimits = {0};
    struct cloneParams childParam = {0};

    getSysLimits(&sysLimits);
    printf("stack limit: soft %lld, hard %lld\n",
	   sysLimits.stackSizeSoft,
	   sysLimits.stackSizeHard);

    childParam.stackSize = defaultStackSize;
    childParam.childFunc = startChildProc;
    childParam.args = NULL;
    childParam.flags = CLONE_NEWNS|CLONE_NEWPID;

    doClone(&childParam);

    printf("child PID:%d\n",childParam.childPid);
    pid = waitpid(-1, &status,0);
    printf("Child exit %d\n",pid);
    exit(0);

    return 0;
}
