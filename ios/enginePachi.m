//
//  enginePachi.c
//
//  Created by Horace Ho on 2013/08/01.
//  Copyright (c) 2013 Horace Ho. All rights reserved.
//

#include <assert.h>
#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#include "board.h"
#include "debug.h"
#include "engine.h"
#include "replay/replay.h"
#include "montecarlo/montecarlo.h"
#include "random/random.h"
#include "patternscan/patternscan.h"
#include "patternplay/patternplay.h"
#include "joseki/joseki.h"
#include "t-unit/test.h"
#include "uct/uct.h"
#include "distributed/distributed.h"
#include "gtp.h"
#include "chat.h"
#include "timeinfo.h"
#include "random.h"
#include "version.h"
#include "network.h"

#include "enginePachi.h"

// gtp.c 
#define NO_REPLY (-2)

int debug_level = 3;
bool debug_boardprint = true;
long verbose_logs = 0;

static struct engine *pachi = NULL;
static struct board *board = NULL;

struct time_info ti[S_MAX];

enum engine_id {
	E_RANDOM,
	E_REPLAY,
	E_PATTERNSCAN,
	E_PATTERNPLAY,
	E_MONTECARLO,
	E_UCT,
	E_DISTRIBUTED,
	E_JOSEKI,
	E_MAX,
};

static struct engine *(*engine_init[E_MAX])(char *arg, struct board *b) = {
	engine_random_init,
	engine_replay_init,
	engine_patternscan_init,
	engine_patternplay_init,
	engine_montecarlo_init,
	engine_uct_init,
	engine_distributed_init,
	engine_joseki_init,
};

static struct engine *init_engine(enum engine_id engine, char *e_arg, struct board *b)
{
	char *arg = e_arg? strdup(e_arg) : e_arg;
	assert(engine < E_MAX);
	struct engine *e = engine_init[engine](arg, b);
	if (arg) free(arg);
	return e;
}

static void done_engine(struct engine *e)
{
	if (e->done) e->done(e);
	if (e->data) free(e->data);
	free(e);
}

void engineInit()
{
    enum engine_id engine = E_UCT;
	char *fbookfile = NULL;

    int seed = time(NULL);
    fast_srandom(seed);
    board = board_init(fbookfile);
    
	char *e_arg = NULL;
	pachi = init_engine(engine, e_arg, board);

    struct time_info ti_default = { .period = TT_NULL };
    
	ti[S_BLACK] = ti_default;
	ti[S_WHITE] = ti_default;
}

int engineCommand(const char *command)
{
    enum parse_code code = gtp_parse(board, pachi, ti, (char *) command);
    printf("%s: %d", command, code);

    return code;
}

void gtp_reply(int id, ...)
{
	va_list params;
	va_start(params, id);
    engineOutput('=', id, params);
	va_end(params);
}
 
void engineOutput(char prefix, int id, va_list params)
{

    NSMutableString *message = [NSMutableString string];

    if (id == NO_REPLY) {
        [message appendString:@"No Reply"];
    } else {
        if (id > 0) {
            [message appendFormat:@"%c%d ", prefix, id];
        } else {
            [message appendFormat:@"%c ", prefix];
        }
        char *s;
        while ((s = va_arg(params, char *))) {
            [message appendFormat:@"%s", s];
        }
    }
    [message appendString:@"\n"];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"Pachi" object:message];
}

void engineDone()
{
	done_engine(pachi);
    pachi = NULL;
}
