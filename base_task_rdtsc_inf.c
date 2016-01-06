/* based_task.c -- A basic real-time task skeleton. 
 *
 * This (by itself useless) task demos how to setup a 
 * single-threaded LITMUS^RT real-time task.
 */

/* First, we include standard headers.
 * Generally speaking, a LITMUS^RT real-time task can perform any
 * system call, etc., but no real-time guarantees can be made if a
 * system call blocks. To be on the safe side, only use I/O for debugging
 * purposes and from non-real-time sections.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/* Second, we include the LITMUS^RT user space library header.
 * This header, part of liblitmus, provides the user space API of
 * LITMUS^RT.
 */
#include "litmus.h"

/* Next, we define period and execution cost to be constant. 
 * These are only constants for convenience in this example, they can be
 * determined at run time, e.g., from command line parameters.
 *
 * These are in milliseconds.
 */
#define PERIOD            100
#define RELATIVE_DEADLINE 100
#define EXEC_COST         10

#define NS_PER_MS         1e6
#define NS_PER_US         1e3

#define CPU_FREQ 2e9
#define CYCLES_TO_MS(x)	((x)/(double)(CPU_FREQ)*1000)

#define LOOP_COUNT_1US 480l

#define DEBUG

/* Catch errors.
 */
/*
#define CALL( exp ) do { \
		int ret; \
		ret = exp; \
		if (ret != 0) \
			fprintf(stderr, "%s failed: %m\n", #exp);\
		else \
			fprintf(stderr, "%s ok.\n", #exp); \
	} while (0)
	*/
 #define CALL( exp ) exp

__inline__ unsigned long rdtsc(void) {
  unsigned long lo, hi;
  __asm__ __volatile__ (      // serialize
  "xorl %%eax,%%eax \n        cpuid"    
  ::: "%rax", "%rbx", "%rcx", "%rdx");  
  __asm__ __volatile__ ("rdtsc" : "=a" (lo), "=d" (hi));
  return (unsigned long long)hi << 32 | lo;    
} 

/* Declare the periodically invoked job. 
 * Returns 1 -> task should exit.
 *         0 -> task should continue.
 */
int job(void);


double wcet_f;
double period_f;

long long wcet_us;
long dur;
long count;

/* typically, main() does a couple of things: 
 * 	1) parse command line parameters, etc.
 *	2) Setup work environment.
 *	3) Setup real-time parameters.
 *	4) Transition to real-time mode.
 *	5) Invoke periodic or sporadic jobs.
 *	6) Transition to background mode.
 *	7) Clean up and exit.
 *
 * The following main() function provides the basic skeleton of a single-threaded
 * LITMUS^RT real-time task. In a real program, all the return values should be 
 * checked for errors.
 */
int main(int argc, char** argv)
{
	int do_exit;//, ret;
	struct rt_task param;

    // wcet = atoi(argv[1]);    // in ms
    // period = atoi(argv[2]);  // in ms

    wcet_f = atof(argv[1]);    // in ms
    period_f = atof(argv[2]);  // in ms

    wcet_us = (int)(wcet_f*1000);	// Convert ms to us

    // wcet_frac = modf(wcet_f,&int_temp);
    // wcet_int = (int)(int_temp);

    dur = 1000 * atoi(argv[3]);     // in seconds -> to ms
    count = (dur / period_f) + 1;

// printf("wcet_f: %f\tperiod_f: %f\twcet_us: %ld\tcount: %d\n",
// wcet_f,period_f,wcet_us,count);

	/* Setup task parameters */
	memset(&param, 0, sizeof(param));
	// param.exec_cost = wcet_f * NS_PER_MS;
	// param.period = period_f * NS_PER_MS;
	param.exec_cost = wcet_f * NS_PER_MS;
	param.period = period_f * NS_PER_MS;
// printf("param.exec: %ld\tparam.period: %ld\n",param.exec_cost, param.period);
// return 0;
	param.relative_deadline = period_f * NS_PER_MS;

	/* What to do in the case of budget overruns? */
	param.budget_policy = NO_ENFORCEMENT;

	/* The task class parameter is ignored by most plugins. */
	param.cls = RT_CLASS_SOFT;
	param.cls = RT_CLASS_HARD;

	/* The priority parameter is only used by fixed-priority plugins. */
	param.priority = LITMUS_LOWEST_PRIORITY;

	/* The task is in background mode upon startup. */


	/*****
	 * 1) Command line paramter parsing would be done here.
	 */



	/*****
	 * 2) Work environment (e.g., global data structures, file data, etc.) would
	 *    be setup here.
	 */



	/*****
	 * 3) Setup real-time parameters. 
	 *    In this example, we create a sporadic task that does not specify a 
	 *    target partition (and thus is intended to run under global scheduling). 
	 *    If this were to execute under a partitioned scheduler, it would be assigned
	 *    to the first partition (since partitioning is performed offline).
	 */
	CALL( init_litmus() );

	/* To specify a partition, do
	 *
	 * param.cpu = CPU;
	 * be_migrate_to(CPU);
	 *
	 * where CPU ranges from 0 to "Number of CPUs" - 1 before calling
	 * set_rt_task_param().
	 */
	CALL( set_rt_task_param(gettid(), &param) );


	/*****
	 * 4) Transition to real-time mode.
	 */
	CALL( task_mode(LITMUS_RT_TASK) );

	/* The task is now executing as a real-time task if the call didn't fail. 
	 */

	// ret = wait_for_ts_release();  
	// if (ret != 0)
	// 	printf("ERROR: wait_for_ts_release()");


	/*****
	 * 5) Invoke real-time jobs.
	 */
	do {
		/* Wait until the next job is released. */
		sleep_next_period();
		/* Invoke job. */
		do_exit = job();		
	} while (!do_exit);


	
	/*****
	 * 6) Transition to background mode.
	 */
	CALL( task_mode(BACKGROUND_TASK) );



	/***** 
	 * 7) Clean up, maybe print results and stats, and exit.
	 */
	return 0;
}


int job(void) 
{
    long long i = 0;
    long j = 0;

	#ifdef DEBUG
	// double start, mytime;
	unsigned long startCycles, endCycles;
	#endif

	/* Do real-time calculation. */
	#ifdef DEBUG
	// start = wctime();
	startCycles = rdtsc();
	#endif
	for (i = 0; i < wcet_us; ++i) {
   		for ( j = 0; j < LOOP_COUNT_1US; ++j )
       		sqrt((double)j*(j+1));
	}
	#ifdef DEBUG
	// mytime = wctime()-start;
	endCycles = rdtsc();
	// printf("Duration:\t%f\n",mytime);
	printf("\nCycles: %lu\tDuration (ms):\t%f",endCycles-startCycles,CYCLES_TO_MS(endCycles-startCycles));
	#endif

	// --count;
	
	if (count > 0) return 0;   // don't exit
	else return 1;             // exit

	/* Don't exit. */
	//return 0;
}
